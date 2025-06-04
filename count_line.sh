#!/bin/bash

# GitHub Repository Code Line Counter
# Usage: ./git_count_line.sh YOUR_USERNAME

USERNAME=${1:-"YOUR_USERNAME_HERE"}
if [ "$USERNAME" = "YOUR_USERNAME_HERE" ]; then
    echo "Usage: $0 <github_username>"
    echo "Example: $0 octocat"
    exit 1
fi

declare -a file_types=(py sh ps1 java c cpp h hpp dll js ts rb go rs php cs swift kt dart pl r sql asm clj ex sqlite db) 
echo "Working on file type: ${file_types[@]}"
echo -e "If you're using a file type that's not listed,\nplease add it to the file_types array at the top of the script before proceeding.\n"
# Files to exclude from line counting
declare -a exclude_files=(doctest.h TestRunner.cpp)
echo "Exclude those files: ${exclude_files[@]}"
echo -e "Please edit it to your own needed \n\n"
echo -e "Start with 5 seconds... if you want to update the file_types or the exclude_files lists - Do it now :) \n\n"
sleep 5

# Create a directory for cloned repos
CLONE_DIR="github_repos_$USERNAME"
if [[ -d $CLONE_DIR ]]; then
	rm -rf $CLONE_DIR
fi
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

# Clone and analyze each repository
for url in "${repos[@]}"; do
    repo_name=$(basename "$url" .git)
    echo "Processing: $repo_name"
    echo "------------------------"
    
    # Clone repository quietly
    if git clone "$url" &>/dev/null; then
        echo "Cloned successfully"
        
        # Find and count files by extension
        for ext in "${file_types[@]}"; do
            files=$(find "$repo_name" -name "*.${ext}" -type f 2>/dev/null)
            if [ -n "$files" ]; then
                while IFS= read -r file; do
                    filename=$(basename "$file")
					if [[ ! " ${exclude_files[@]} " =~ " ${filename} " ]]; then
						if [ -f "$file" ]; then
							lines=$(python ../count_lines.py $file $ext)
							file_counts["$ext"]=$((${file_counts["$ext"]:-0} + 1))
							line_counts["$ext"]=$((${line_counts["$ext"]:-0} + lines))
							total_files=$((total_files + 1))
							total_lines=$((total_lines + lines))
							echo "  $ext: $(basename "$file") - $lines lines"
						fi
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
echo ""
echo "Note: Line counts exclude empty lines and basic comments"
rm -rf ../$CLONE_DIR
echo ""
echo "Delete the repositories file... BYE BYE"
