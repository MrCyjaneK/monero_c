#!/bin/bash
set -euo pipefail

cd "$(realpath $(dirname $0))"

WORKDIR="$PWD"

MIRROR_URL="https://static.mrcyjanek.net/download_mirror/git/mirror.git"
SUPPORTED_REPOS=("monero" "wownero" "zano")
ROOT_COMMIT=$(git rev-parse HEAD)

# Function to try getting repo from bundle
try_bundle() {
    local repo="$1"
    local target_commit="$2"
    local original_url=$(git config -f .gitmodules submodule.$repo.url)
    
    # Convert URL to bundle name using same logic as mirror.sh
    local bundle_name=$(echo -n -e "$original_url" | sed 's|https://||' | sed 's|\.git$||' | tr '/' '-' | tr '.' '-' | tr '[:upper:]' '[:lower:]')-${target_commit:0:8}.bundle
    
    echo "Attempting to clone from bundle: $bundle_name"
    mkdir -p $WORKDIR/tools/mirror/mirrors/bundles
    if [ -f "$WORKDIR/tools/mirror/mirrors/bundles/$bundle_name" ]; then
        echo "Bundle already exists, using cached version"
        if git clone "$WORKDIR/tools/mirror/mirrors/bundles/$bundle_name" "$repo"; then
            return 0
        fi
    else
        if curl -f -s -o "$WORKDIR/tools/mirror/mirrors/bundles/$bundle_name" "https://static.mrcyjanek.net/download_mirror/git/$bundle_name"; then
            if git clone "$WORKDIR/tools/mirror/mirrors/bundles/$bundle_name" "$repo"; then
                return 0
            fi
        fi
    fi
    return 1
}

# Function to update a single submodule
update_submodule() {
    local path="$1"
    local parent_path="$2"
    local full_path="${parent_path:+$parent_path/}$path"
    
    echo "Updating submodule: $full_path"
    
    # Get original URL from .gitmodules
    original_url=$(git config -f .gitmodules submodule.$path.url)
    
    # Get target commit - first try from the index (after patches), then fallback to config
    target_commit=$(git ls-tree HEAD "$path" | awk '{print $3}' || \
                   git config -f .git/modules/$full_path/config core.commitish 2>/dev/null || \
                   git submodule status "$path" | awk '{print $1}' | sed 's/^[+-]//')
    
    if [[ -z "$original_url" ]]; then
        echo "Warning: No URL found for submodule $path in .gitmodules, skipping"
        return 0
    fi
    
    echo "Original URL: $original_url"
    echo "Target commit: $target_commit"
    
    # Store the original directory
    local original_dir="$PWD"
    
    # Try original URL first
    if ! git submodule update --init --force "$path"; then
        echo "Failed with original URL, trying bundle for $path..."
        rm -rf "$path"
        # Try bundle
        if ! try_bundle "$path" "$target_commit"; then
            echo "Bundle attempt failed for $path"
            # Try original URL one last time
            if ! git clone "$original_url" "$path"; then
                echo "Both bundle and original source failed for $path"
                return 1
            fi
        fi
        
        # Checkout the correct commit
        cd "$path"
        if ! git checkout "$target_commit"; then
            echo "Failed to checkout target commit $target_commit"
            cd "$original_dir"
            return 1
        fi
        
        # Update any nested submodules
        if [[ -f ".gitmodules" ]]; then
            echo "Updating nested submodules in $full_path"
            while IFS= read -r submodule; do
                local subpath
                subpath=$(echo "$submodule" | awk '{print $2}')
                update_submodule "$subpath" "$full_path"
            done < <(git config -f .gitmodules --get-regexp '^submodule\..*\.path$')
        fi
        cd "$original_dir"
    fi
}

# Function to check if repatching is needed
needs_repatching() {
    local repo="$1"
    local current_root_commit="$2"
    
    if [[ ! -f "$repo/.patch-applied" ]]; then
        return 0 # True, needs patching
    fi
    
    # Get stored commit hash from .patch-applied
    local stored_commit
    stored_commit=$(cat "$repo/.patch-applied")
    
    if [[ "$stored_commit" != "$current_root_commit" ]]; then
        echo "Root repository changed ($stored_commit -> $current_root_commit)"
        echo "Removing releases/$repo directory..."
        rm -rf "releases/$repo"
        return 0 # True, needs patching
    fi
    
    return 1 # False, no need to patch
}

# Function to process a single repository
process_repo() {
    local repo="$1"
    echo "Processing $repo..."
    
    # Get target commit before attempting any clones
    local target_commit
    target_commit=$(git config -f .git/modules/$repo/config core.commitish || git submodule status "$repo" | awk '{print $1}' | sed 's/^[+-]//')
    
    # Check if repatching is needed
    if ! needs_repatching "$repo" "$ROOT_COMMIT"; then
        echo "No repatching needed for $repo (already at current root commit)"
        return 0
    fi
    BASE_PATH="$PWD"
    # If directory doesn't exist or needs update, try cloning
    if [[ ! -d "$repo" ]]; then
        echo "Fetching $repo..."
        # Try original URL first
        if ! git submodule update --init --recursive --force "$repo"; then
            echo "Failed with original URL, trying bundle..."
            rm -rf "$repo"
            # Try bundle
            if ! try_bundle "$repo" "$target_commit"; then
                echo "Bundle attempt failed for $repo"
                # Try original URL one last time with direct clone
                original_url=$(git config -f .gitmodules submodule.$repo.url)
                if ! git clone --recursive "$original_url" "$repo"; then
                    echo "Both bundle and original source failed for $repo"
                    return 1
                fi
            fi
            
            # Checkout the correct commit
            cd "$repo"
            if ! git checkout "$target_commit"; then
                echo "Failed to checkout target commit $target_commit"
                cd - >/dev/null
                return 1
            fi
            
            # Update any nested submodules
            if [[ -f ".gitmodules" ]]; then
                echo "Updating nested submodules in $repo"
                while IFS= read -r submodule; do
                    local subpath
                    subpath=$(echo "$submodule" | awk '{print $2}')
                    update_submodule "$subpath" ""  # Pass empty string as initial parent path
                done < <(git config -f .gitmodules --get-regexp '^submodule\..*\.path$')
            fi
            cd - >/dev/null
        fi
    fi
    cd "$BASE_PATH"
    if [[ ! -d "$repo" ]]; then
        echo "Failed to fetch $repo"
        return 1
    fi

    # Verify repository is properly initialized
    pushd "$repo"
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: $repo is not a valid git repository"
        popd
        return 1
    fi

    # Verify we have a clean working directory
    if ! git diff --quiet HEAD; then
        echo "Error: $repo has uncommitted changes"
        popd
        return 1
    fi

    # Apply patches
    echo "Applying patches..."
    if ! git am -3 --whitespace=fix --reject ../patches/$repo/*.patch; then
        echo "Error: Failed to apply patches to $repo"
        git am --abort
        popd
        return 1
    fi

    # Create .patch-applied marker with root commit hash
    echo "$ROOT_COMMIT" > .patch-applied
    git add .patch-applied
    git commit -m "add .patch-applied with root commit: ${ROOT_COMMIT}"

    # Check if submodules changed after patching
    if [[ -f ".gitmodules" ]]; then
        echo "Checking for submodule changes after patching..."
        while IFS= read -r submodule; do
            local subpath
            subpath=$(echo "$submodule" | awk '{print $2}')
            update_submodule "$subpath" ""
        done < <(git config -f .gitmodules --get-regexp '^submodule\..*\.path$')
    fi

    popd
    echo "Finished processing $repo"
}

# Function to fetch wownero-seed submodule
fetch_wownero_seed() {
    local repo="wownero_libwallet2_api_c/wownero-seed"
    echo "Fetching $repo..."
    
    # Create directory structure
    mkdir -p "$(dirname "$repo")"
    
    # Skip if already exists
    if [[ -d "$repo" ]]; then
        echo "$repo already exists, skipping"
        return 0
    fi
    
    # Get target commit
    local target_commit
    target_commit=$(git config -f .git/modules/$repo/config core.commitish || git submodule status "$repo" | awk '{print $1}' | sed 's/^[+-]//')
    
    # Try original URL first
    if ! git submodule update --init --force "$repo"; then
        echo "Failed with original URL, trying bundle..."
        rm -rf "$repo"
        # Try bundle
        if ! try_bundle "$repo" "$target_commit"; then
            echo "Bundle attempt failed for $repo"
            # Try original URL one last time with direct clone
            original_url=$(git config -f .gitmodules submodule.$repo.url)
            if ! git clone --recursive "$original_url" "$repo"; then
                echo "Both bundle and original source failed for $repo"
                return 1
            fi
        fi
        
        # Checkout the correct commit
        cd "$repo"
        git checkout "$target_commit"
        cd - >/dev/null
    fi
}

# Main script
fetch_wownero_seed  # Add this line before the main repository processing

if [[ $# -eq 0 ]]; then
    # No arguments, process all repositories
    echo "No repository specified, processing all repositories..."
    for repo in "${SUPPORTED_REPOS[@]}"; do
        echo "=== Processing $repo ==="
        if ! process_repo "$repo"; then
            echo "Warning: Failed to process $repo"
        fi
        echo "=== Finished $repo ==="
        echo
    done
else
    # Process specific repository
    repo="$1"
    if [[ ! " ${SUPPORTED_REPOS[@]} " =~ " ${repo} " ]]; then
        echo "Usage: $0 [monero/wownero/zano]"
        echo "Invalid target given, only monero, wownero and zano are supported targets"
        exit 1
    fi
    process_repo "$repo"
fi

echo "All done!"
