#!/bin/bash

# GitHub Repository Code Line Counter
# Usage: ./git_count_line.sh YOUR_USERNAME

declare -a file_types=(py sh java c cpp js ts rb go rs php cs swift kt m scala dart lua pl r jl hs vb sql asm clj ex fs sqlite db ps1    dll mak cmake) 
echo "Working on file type: ${file_types[@]}"
echo -e "If you're using a file type that's not listed,\nplease add it to the file_types array at the top of the script before proceeding.\n"

USERNAME=${1:-"YOUR_USERNAME_HERE"}
if [ "$USERNAME" = "YOUR_USERNAME_HERE" ]; then
    echo "Usage: $0 <github_username>"
    echo "Example: $0 octocat"
    exit 1
fi

# Create a directory for cloned repos
CLONE_DIR="github_repos_$USERNAME"
mkdir -p "$CLONE_DIR"
cd "$CLONE_DIR"

echo "Fetching repository list for: $USERNAME"
echo "========================================"

# Get URLs and store in array (excluding archived repositories)
readarray -t repos < <(curl -s "https://api.github.com/users/$USERNAME/repos?type=public&per_page=100" | \
    grep -B15 '"archived": false' | \
	grep '"clone_url":' | \
    sed 's/.*"clone_url": "\([^"]*\)".*/\1/')
	
if [ ${#repos[@]} -eq 0 ]; then
    echo "No active repositories found!"
    exit 1
fi
echo -e "Found ${#repos[@]} repositories to analyze\n"

declare -A file_counts
declare -A line_counts
total_files=0
total_lines=0

# Function to count lines in a file (excluding empty lines and comments)
count_code_lines() {
    local file="$1"
    local ext="$2"
    
    case "$ext" in
        "sh"|"py"|"rb"|"php")
            # Count non-empty lines that don't start with # (after trimming whitespace)
            grep -v '^\s*#' "$file" | grep -v '^\s*$' | wc -l
            ;;
        "c"|"cpp"|"cc"|"cxx"|"java"|"js"|"ts"|"go"|"rs")
            # Count non-empty lines that don't start with // or /* (basic comment removal)
            grep -v '^\s*//' "$file" | grep -v '^\s*/\*' | grep -v '^\s*\*' | grep -v '^\s*$' | wc -l
            ;;
        *)
            # Default: just count non-empty lines
            grep -v '^\s*$' "$file" | wc -l
            ;;
    esac
}

# Clone and analyze each repository
for url in "${repos[@]}"; do
    repo_name=$(basename "$url" .git)
    echo "Processing: $repo_name"
    echo "------------------------"
    
    # Clone repository quietly
    if git clone "$url" "$repo_name" &>/dev/null; then
        echo "Cloned successfully"
        
        # Find and count files by extension
        for ext in "${file_types[@]}"; do
            # Find files with this extension
            files=$(find "$repo_name" -name "*.${ext}" -type f 2>/dev/null)
            
            if [ -n "$files" ]; then
                while IFS= read -r file; do
                    if [ -f "$file" ]; then
                        lines=$(count_code_lines "$file" "$ext")
                        
                        # Update counters
                        file_counts["$ext"]=$((${file_counts["$ext"]:-0} + 1))
                        line_counts["$ext"]=$((${line_counts["$ext"]:-0} + lines))
                        total_files=$((total_files + 1))
                        total_lines=$((total_lines + lines))
                        
                        echo "  $ext: $(basename "$file") - $lines lines"
                    fi
                done <<< "$files"
            fi
        done
        
        echo ""
    else
        echo "Failed to clone"
        echo ""
    fi
done

# Display final statistics
echo ""
echo "================================================================="
echo "                    CODE STATISTICS SUMMARY"
echo "================================================================="
echo ""

printf "%-12s %-8s %-10s\n" "LANGUAGE" "FILES" "LINES"
echo "---------------------------------"

for ext in "${file_types[@]}"; do
    if [ "${file_counts[$ext]:-0}" -gt 0 ]; then
        printf "%-12s %-8d %-10d\n" "$ext" "${file_counts[$ext]}" "${line_counts[$ext]}"
    fi
done

echo "---------------------------------"
printf "%-12s %-8d %-10d\n" "TOTAL" "$total_files" "$total_lines"

echo ""
echo "Analysis completed!"
echo "Repositories cloned in: $(pwd)"
echo ""
echo "Note: Line counts exclude empty lines and basic comments"
rm -rf ../$CLONE_DIR
echo "Delete the repository... BYE BYE"
