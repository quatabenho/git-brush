#!/bin/bash
#
# git brush - A tool to create artistic commit patterns on GitHub
# Made with ❤️ by David Sarrat González
# Visit https://www.github.com/davidsarratgonzalez/git-brush for more information
#

# Default multiplier if not provided
MULTIPLIER=${2:-200}
JSON_FILE=$1

# If no JSON file specified, look for a single JSON file in directory
if [ -z "$JSON_FILE" ]; then
    # Count JSON files
    json_count=$(ls -1 *.json 2>/dev/null | wc -l)
    
    if [ "$json_count" -eq 1 ]; then
        JSON_FILE=$(ls *.json)
    else
        echo "Error: Please specify a JSON file, or ensure only one JSON file exists in directory"
        exit 1
    fi
fi

# Check if git repo is initialized
if [ ! -d .git ]; then
    echo "Error: Not a git repository. Please run 'git init' first."
    exit 1
fi

# Check if JSON file exists
if [ ! -f "$JSON_FILE" ]; then
    echo "Error: JSON file not found"
    exit 1
fi

# Hide cursor and save screen state
tput civis 2>/dev/null || true
tput smcup 2>/dev/null || true

# Handle window resize by redrawing the dashboard
trap 'draw_dashboard' WINCH
trap 'cleanup_and_exit' EXIT INT TERM

cleanup_and_exit() {
    tput rmcup 2>/dev/null || true
    tput cnorm 2>/dev/null || true
    exit 0
}

# Function to draw the dashboard
draw_dashboard() {
    # Get current terminal size
    local term_height
    local term_width
    term_height=$(tput lines 2>/dev/null || echo 24)
    term_width=$(tput cols 2>/dev/null || echo 80)
    
    # Only clear and redraw if we have minimum required space
    if [ "$term_height" -ge 10 ] && [ "$term_width" -ge 50 ]; then
        clear
        echo -e "Thank you for using git brush! 🎨"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "⏳ Progress: [                    ] 0%"
        echo "📅 Current date:"
        echo "📅 Day progress:"
        echo "📅 Year progress:"
        echo "📈 Total progress:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo -e "Made with ❤️  by David Sarrat González"
    fi
}

# Create initial README.md with git brush link
echo "nguyen" > README.md
git add README.md 2>/dev/null
GIT_AUTHOR_DATE="$(date -u +"%Y-%m-%d %H:%M:%S")" \
GIT_COMMITTER_DATE="$(date -u +"%Y-%m-%d %H:%M:%S")" \
git commit -m "Painted my GitHub contribution graph! 🎨

Co-authored-by: David Sarrat González <113605621+davidsarratgonzalez@users.noreply.github.com>" >/dev/null 2>&1

# Clear screen and show initial dashboard
clear
draw_dashboard

# Count total commits needed
total_commits=0
while IFS= read -r line; do
    intensity=$(echo "$line" | grep -o '": [0-9]' | tr -d '": ')
    if [ ! -z "$intensity" ]; then
        total_commits=$((total_commits + intensity * MULTIPLIER))
    fi
done < "$JSON_FILE"

commits_done=0
start_time=$(date +%s)
last_commit_date=""
current_year=""
# Use regular array instead of associative array for compatibility
declare year_commits
declare year_commits_idx

# Disable git auto gc messages
git config gc.auto 0

# Read JSON file and process commits
while IFS= read -r line; do
    # Parse date and intensity from each JSON line
    date=$(echo "$line" | grep -o '"[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}"' | tr -d '"')
    intensity=$(echo "$line" | grep -o '": [0-9]' | tr -d '": ')
    
    if [ ! -z "$date" ] && [ ! -z "$intensity" ]; then
        year=$(echo "$date" | cut -d'-' -f1)
        
        # If year changes, initialize year commits
        if [ "$year" != "$current_year" ]; then
            current_year=$year
            # Find or create index for this year
            year_found=0
            for ((i=0; i<${#year_commits_idx[@]}; i++)); do
                if [ "${year_commits_idx[$i]}" = "$year" ]; then
                    year_found=1
                    break
                fi
            done
            if [ $year_found -eq 0 ]; then
                year_commits_idx[${#year_commits_idx[@]}]=$year
                year_commits[${#year_commits[@]}]=0
            fi
        fi
        
        # Make the actual commits
        commit_count=$((intensity * MULTIPLIER))
        for ((i=1; i<=commit_count; i++)); do
            # Set commit time to 10:00 UTC (safer global time)
            hour=10  # This ensures the commit appears on the intended day for most timezones
            minute=0
            second=0
            commit_time=$(printf "%02d:%02d:%02d" $hour $minute $second)
            
            # Set both author and committer dates with UTC timezone
            commit_date="$date $commit_time +0000"
            export GIT_AUTHOR_DATE="$commit_date"
            export GIT_COMMITTER_DATE="$commit_date"
            
            git commit --allow-empty -m "$date: $i 🎨" >/dev/null 2>&1
            commits_done=$((commits_done + 1))
            
            # Update year commits count
            for ((j=0; j<${#year_commits_idx[@]}; j++)); do
                if [ "${year_commits_idx[$j]}" = "$year" ]; then
                    year_commits[$j]=$((year_commits[$j] + 1))
                    break
                fi
            done
            last_commit_date=$date
            
            # Update progress display every 5 commits
            if [ $((commits_done % 5)) -eq 0 ]; then
                # Calculate progress percentage and ETA
                progress=$((commits_done * 100 / total_commits))
                current_time=$(date +%s)
                elapsed=$((current_time - start_time))
                if [ $commits_done -gt 0 ]; then
                    rate=$(bc <<< "scale=2; $elapsed / $commits_done")
                    remaining_commits=$((total_commits - commits_done))
                    eta_seconds=$(bc <<< "$rate * $remaining_commits" | cut -d. -f1)
                    eta_min=$((eta_seconds / 60))
                    eta_sec=$((eta_seconds % 60))
                    
                    # Calculate progress bar width (20 chars)
                    progress_width=$((progress * 20 / 100))
                    
                    # Update progress display
                    draw_dashboard
                    
                    # Only update display if terminal is large enough
                    if [ "$(tput lines 2>/dev/null || echo 24)" -ge 10 ] && [ "$(tput cols 2>/dev/null || echo 80)" -ge 50 ]; then
                        tput cup 2 11 2>/dev/null || true
                        printf "[%-20s] %3d%% (ETA: %02d:%02d)" "$(printf "%${progress_width}s" | tr ' ' '#')" $progress $eta_min $eta_sec
                        tput cup 3 35 2>/dev/null || true
                        echo -n "$date"
                        tput cup 4 35 2>/dev/null || true
                        echo -n "$i/$commit_count"
                        tput cup 5 35 2>/dev/null || true
                        # Find current year's commits
                        for ((j=0; j<${#year_commits_idx[@]}; j++)); do
                            if [ "${year_commits_idx[$j]}" = "$year" ]; then
                                echo -n "${year_commits[$j]}/$total_commits"
                                break
                            fi
                        done
                        tput cup 6 35 2>/dev/null || true
                        echo -n "$commits_done/$total_commits"
                    fi
                fi
            fi
        done
    fi
done < "$JSON_FILE"

# Function to draw final message
draw_final_message() {
    clear
    echo "Thank you for using git brush! 🎨"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "We have painted your contribution graph! 🎉"
    echo "⚠️  Don't forget to push your changes to GitHub!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Made with ❤️  by David Sarrat González"
    echo
    echo "Press any key to exit..."
}

# Update trap to use final message function
trap 'draw_final_message' WINCH

# Draw initial final message
draw_final_message

# Wait for user input before cleanup
read -n 1 -s

# Cleanup and exit handled by trap
trap - WINCH EXIT INT TERM
tput rmcup 2>/dev/null || true
tput cnorm 2>/dev/null || true
exit 0
