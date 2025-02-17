#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

OUTPUT_DIR="$PWD"
OUTPUT_FILE="${OUTPUT_DIR}/submodule-list.txt"
TEMP_FILE="${OUTPUT_DIR}/temp-list.txt"

mkdir -p "${OUTPUT_DIR}"

> "${TEMP_FILE}"

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "${TEMP_DIR}"' EXIT

process_current_submodules() {
    local repo_path="$1"
    local is_main_repo="$2"
    local parent_path="${3:-}"
    local original_dir="$PWD"
    cd "${repo_path}"
    
    echo "DEBUG: Processing submodules in: $(pwd)"
    
    if [[ -f ".gitmodules" ]]; then
        echo "DEBUG: Found .gitmodules file"
        git config --file .gitmodules --get-regexp '^submodule\.[^\.]+\.url' | while read -r key url; do
            name=${key#submodule.}
            name=${name%.url}
            
            path=$(git config --file "${PWD}/.gitmodules" --get "submodule.${name}.path")
            
            if [[ -z "$path" ]]; then
                echo "Warning: Empty path for submodule ${name}, skipping..."
                continue
            fi
            
            full_path="${parent_path:+$parent_path/}${path}"
            
            url=$(echo "$url" | tr -d '"' | tr -d "'")
            
            echo "DEBUG: Found submodule: name=${name}, path=${full_path}, url=${url}"
            
            if [[ -d "${path}" ]]; then
                hash=$(git submodule status "${path}" 2>/dev/null | awk '{print $1}' | tr -d '+' | tr -d '-' || echo "")
                if [[ "${hash}" == "b7a695cf4b41645a5f5c5a5c1f0d565b283a3585" ]]; then
                    echo "Skipping known problematic commit: ${commit}"
                    return 0
                fi
                if [[ -n "${hash}" ]]; then
                    echo "${url} ${hash}" >> "${TEMP_FILE}"
                    
                    echo "DEBUG: Initializing submodule: ${path}"
                    if git submodule update --force --init "${path}" 2>/dev/null; then
                        if [[ -f "${path}/.gitmodules" ]]; then
                            echo "DEBUG: Processing nested submodules in ${full_path}"
                            process_current_submodules "${PWD}/${path}" "false" "${full_path}"
                        fi
                    else
                        echo "Warning: Could not update submodule ${full_path} at commit ${hash}, skipping..."
                        continue
                    fi
                else
                    echo "Warning: Could not get hash for submodule ${full_path}, skipping..."
                    exit 1
                fi
            fi
        done
    fi
    cd "${original_dir}"
}

process_main_repo() {
    local repo_path="$1"
    cd "${repo_path}"

    echo "Getting commit history for main repository..."
    local COMMITS=$(git log --format="%H" --reverse)

    for commit in $COMMITS; do
        echo "Processing commit: ${commit}"
        
        git checkout --force "${commit}"
        git reset --hard
        
        process_current_submodules "${repo_path}" "true"
    done
}

echo "Cloning repository to temporary directory..."
git clone --no-checkout https://github.com/MrCyjaneK/monero_c --branch develop "${TEMP_DIR}/main"

process_main_repo "${TEMP_DIR}/main"

cat "${OUTPUT_FILE}" >> "${TEMP_FILE}"
sort -u "${TEMP_FILE}" > "${OUTPUT_FILE}"

rm "${TEMP_FILE}"

echo "Submodule information has been written to ${OUTPUT_FILE}"
