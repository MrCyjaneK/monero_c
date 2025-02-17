#!/bin/bash

# Create directories
mkdir -p mirrors/bundles mirrors/temp

# Function to convert URL to bundle name
url_to_bundle_name() {
    local url="$1"
    local hash="$2"
    # Remove https:// and .git, replace / and . with -
    # Append first 8 chars of hash before .bundle
    echo -n -e "$url" | sed 's|https://||' | sed 's|\.git$||' | tr '/' '-' | tr '.' '-' | tr '[:upper:]' '[:lower:]'
    echo -n -e "-${hash:0:8}.bundle"
}

> mirrors/gitbundlemap.txt

while read -r line; do
    url=$(echo "$line" | cut -d' ' -f1)
    commit=$(echo "$line" | cut -d' ' -f2)
    if [ "$commit" == "b7a695cf4b41645a5f5c5a5c1f0d565b283a3585" ]; then
        echo "Skipping $url ($commit)"
        continue
    fi
    bundle_name="$(url_to_bundle_name "$url" "$commit")"
    
    if [ ! -f "mirrors/bundles/$bundle_name" ]; then

        echo "Processing $url ($commit) -> $bundle_name"
        
        if curl -f -s -o "mirrors/bundles/$bundle_name" "https://static.mrcyjanek.net/download_mirror/git/$bundle_name"; then
            echo "Downloaded existing bundle for $url ($commit)"
        else
            echo "No existing bundle found, cloning repository..."
            rm -rf mirrors/temp/repo || true
            # Clone repository
            git clone --mirror "$url" "mirrors/temp/repo" || {
                echo "Failed to clone $url"
                exit 1
            }
            
            # Create bundle for specific commit
            cd mirrors/temp/repo
            git bundle create "../../bundles/$bundle_name" --all "$commit" || {
                echo "Failed to create bundle for $url ($commit)"
                cd ../../..
                exit 1
            }
            cd ../../..
            
            rm -rf mirrors/temp/repo
        fi
    fi
    
    echo "$commit $bundle_name" >> mirrors/gitbundlemap.txt
    
done < submodule-list.txt

sort -u mirrors/gitbundlemap.txt -o mirrors/gitbundlemap.txt
echo rsync -raz --progress $PWD/mirrors/bundles/'*' mrcyjanek@static.mrcyjanek.net:/home/mrcyjanek/web/static.mrcyjanek.net/public_html/download_mirror/git/
echo "Done! Bundles are in mirrors/bundles/"
echo "Commit mappings are in mirrors/gitbundlemap.txt"