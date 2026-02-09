#!/bin/bash
# Git History Cleanup Toolkit
# Interactive tool for cleaning Git history and managing repos

set -e  # Exit on error

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'

# Print functions
print_header() {
    echo -e "\n${CYAN}${BOLD}=== $1 ===${NC}\n"
}

print_success() {
    echo -e "${GREEN}[OK] $1${NC}"
}

print_error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

print_info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

print_step() {
    echo -e "${MAGENTA}${BOLD}> $1${NC}"
}

# Banner
show_banner() {
    clear
    echo -e "${CYAN}"
    echo ""
    echo "  Git History Cleanup Toolkit" 
    echo ""
    echo -e "${NC}\n"
}

# Check if in git repo
check_git_repo() {
    if [ ! -d .git ]; then
        print_error "Not in a git repository!"
        echo "Please run this script from the root of your Git repository."
        exit 1
    fi
    print_success "Git repository detected"
}

# Check for unstaged changes
check_working_tree() {
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        print_error "You have unstaged changes!"
        echo ""
        echo "Please commit or stash your changes:"
        echo "  git add ."
        echo "  git commit -m 'Save changes'"
        echo "  OR"
        echo "  git stash"
        exit 1
    fi
    print_success "Working tree is clean"
}

# Get current branch
get_current_branch() {
    git rev-parse --abbrev-ref HEAD
}

# Get remote branches
get_remote_branches() {
    git branch -r | grep -v '\->' | sed 's/origin\///' | sed 's/^[[:space:]]*//'
}

# Select files to remove
select_files_to_remove() {
    print_header "FILE SELECTION"
    
    echo "Choose files/patterns to remove from Git history:"
    echo ""
    echo "1) .DS_Store (macOS system files)"
    echo "2) node_modules/ (Node.js dependencies)"
    echo "3) .env files (Environment variables)"
    echo "4) *.log files (Log files)"
    echo "5) assets/ folder"
    echo "6) Custom file/pattern"
    echo "7) Multiple files (interactive selection)"
    echo ""
    echo -n "Enter your choice (1-7): "
    read -r choice
    
    case $choice in
        1)
            FILES=".DS_Store **/.DS_Store"
            DESCRIPTION=".DS_Store files"
            ;;
        2)
            FILES="node_modules/"
            DESCRIPTION="node_modules directories"
            ;;
        3)
            FILES=".env .env.local .env.*.local"
            DESCRIPTION=".env files"
            ;;
        4)
            FILES="*.log"
            DESCRIPTION="log files"
            ;;
        5)
            FILES="assets/"
            DESCRIPTION="assets folder"
            ;;
        6)
            echo ""
            echo -n "Enter file/pattern to remove: "
            read -r custom_file
            FILES="$custom_file"
            DESCRIPTION="$custom_file"
            ;;
        7)
            echo ""
            echo "Enter files/patterns (one per line, empty line to finish):"
            FILES=""
            DESCRIPTION=""
            while true; do
                read -r line
                if [ -z "$line" ]; then
                    break
                fi
                FILES="$FILES $line"
                if [ -z "$DESCRIPTION" ]; then
                    DESCRIPTION="$line"
                else
                    DESCRIPTION="$DESCRIPTION, $line"
                fi
            done
            ;;
        *)
            print_error "Invalid choice!"
            exit 1
            ;;
    esac
    
    echo ""
    print_info "Selected: $DESCRIPTION"
}

# Select branch
select_branch() {
    print_header "BRANCH SELECTION"
    
    current_branch=$(get_current_branch)
    print_info "Current branch: $current_branch"
    
    echo ""
    echo "Available branches:"
    branches=($(get_remote_branches))
    
    for i in "${!branches[@]}"; do
        echo "$((i+1))) ${branches[$i]}"
    done
    
    echo ""
    echo -n "Select branch to push to (or press Enter for '$current_branch'): "
    read -r branch_choice
    
    if [ -z "$branch_choice" ]; then
        TARGET_BRANCH="$current_branch"
    elif [ "$branch_choice" -ge 1 ] && [ "$branch_choice" -le "${#branches[@]}" ]; then
        TARGET_BRANCH="${branches[$((branch_choice-1))]}"
    else
        print_error "Invalid selection. Using current branch."
        TARGET_BRANCH="$current_branch"
    fi
    
    print_success "Target branch: $TARGET_BRANCH"
}

# Show repo stats
show_repo_stats() {
    print_header "REPOSITORY STATISTICS"
    
    total_commits=$(git rev-list --all --count)
    repo_size=$(du -sh .git 2>/dev/null | cut -f1)
    total_files=$(git ls-files | wc -l)
    
    echo "Current Stats:"
    echo "  Total commits: $total_commits"
    echo "  Repository size: $repo_size"
    echo "  Tracked files: $total_files"
    echo ""
}

# Analyze what will be removed
analyze_removal() {
    print_header "ANALYSIS"
    
    print_step "Searching for files matching pattern..."
    
    # Count files in current working tree
    file_count=0
    for pattern in $FILES; do
        count=$(find . -name "$pattern" 2>/dev/null | wc -l)
        file_count=$((file_count + count))
    done
    
    # Count files in Git history
    git_count=0
    for pattern in $FILES; do
        count=$(git log --all --pretty=format: --name-only --diff-filter=A | grep "$pattern" 2>/dev/null | sort -u | wc -l)
        git_count=$((git_count + count))
    done
    
    echo ""
    print_info "Files in working directory: $file_count"
    print_info "Files in Git history: $git_count"
    
    if [ "$git_count" -eq 0 ]; then
        print_warning "No files found in Git history. Nothing to clean!"
        echo ""
        echo -n "Continue anyway? (y/N): "
        read -r continue_choice
        if [[ ! "$continue_choice" =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi
}

# Perform cleanup
perform_cleanup() {
    print_header "CLEANUP PROCESS"
    
    print_step "Rewriting Git history..."
    print_warning "This will rewrite all commits and remove files from entire history!"
    echo ""
    echo -n "Continue? (y/N): "
    read -r confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_error "Cleanup cancelled by user"
        exit 0
    fi
    
    echo ""
    print_info "Starting history rewrite (this may take a while)..."
    
    # Build filter-branch command
    filter_cmd="git rm -rf --cached --ignore-unmatch"
    for pattern in $FILES; do
        filter_cmd="$filter_cmd $pattern"
    done
    
    # Set environment variable to suppress filter-branch warning
    export FILTER_BRANCH_SQUELCH_WARNING=1
    
    git filter-branch --force --index-filter \
        "$filter_cmd" \
        --prune-empty --tag-name-filter cat -- --all
    
    print_success "Git history rewritten"
    
    # Remove from working directory
    print_step "Removing files from working directory..."
    for pattern in $FILES; do
        find . -name "$pattern" -type f -delete 2>/dev/null || true
        find . -name "$pattern" -type d -exec rm -rf {} + 2>/dev/null || true
    done
    print_success "Removed from working directory"
    
    # Clean up references
    print_step "Cleaning up references..."
    rm -rf .git/refs/original/
    git reflog expire --expire=now --all
    git gc --prune=now --aggressive
    print_success "References cleaned"
    
    # Verify cleanup
    print_step "Verifying cleanup..."
    remaining=0
    for pattern in $FILES; do
        count=$(git ls-files | grep "$pattern" | wc -l)
        remaining=$((remaining + count))
    done
    
    if [ "$remaining" -eq 0 ]; then
        print_success "Verification passed! All files removed."
    else
        print_warning "Found $remaining files still in Git"
    fi
}

show_post_cleanup_stats() {
    print_header "POST-CLEANUP STATISTICS"
    
    new_size=$(du -sh .git 2>/dev/null | cut -f1)
    total_files=$(git ls-files | wc -l)
    
    echo "New Stats:"
    echo "  Repository size: $new_size"
    echo "  Tracked files: $total_files"
    echo ""
}

show_push_instructions() {
    print_header "NEXT STEPS"
    
    print_warning "Your local repository has been cleaned!"
    print_warning "You MUST force push to update the remote repository."
    
    echo ""
    echo "Commands to execute:"
    echo ""
    echo "# 1. Review the changes"
    echo "   git log --oneline -10"
    echo ""
    echo "# 2. Verify files are removed"
    echo "   git ls-files | grep <pattern>"
    echo ""
    echo "# 3. Force push to remote"
    echo "   git push origin $TARGET_BRANCH --force"
    echo ""
    echo "   OR (safer for collaborators):"
    echo "   git push origin $TARGET_BRANCH --force-with-lease"
    echo ""
    
    print_warning "WARNING: Force push will rewrite remote history!"
    print_info "Collaborators will need to re-clone the repository"
    
    echo ""
    echo -n "Do you want to force push now? (y/N): "
    read -r push_now
    
    if [[ "$push_now" =~ ^[Yy]$ ]]; then
        print_step "Force pushing to origin/$TARGET_BRANCH..."
        if git push origin "$TARGET_BRANCH" --force; then
            print_success "Successfully pushed to remote!"
        else
            print_error "Push failed! Please push manually."
        fi
    else
        print_info "Remember to push manually when ready!"
    fi
}

create_backup() {
    print_header "BACKUP CREATION"
    
    echo -n "Create a backup before cleanup? (Y/n): "
    read -r backup_choice
    
    if [[ ! "$backup_choice" =~ ^[Nn]$ ]]; then
        backup_name="git-backup-$(date +%Y%m%d-%H%M%S).bundle"
        print_step "Creating backup bundle..."
        git bundle create "../$backup_name" --all
        print_success "Backup created: ../$backup_name"
        print_info "Restore with: git clone $backup_name restored-repo"
        echo ""
    fi
}

show_main_menu() {
    print_header "MAIN MENU"
    
    echo "What would you like to do?"
    echo ""
    echo "1) Clean Git history (remove files)"
    echo "2) Show repository statistics"
    echo "3) Create backup bundle"
    echo "4) List large files in history"
    echo "5) Search for files in history"
    echo "6) Exit"
    echo ""
    echo -n "Enter your choice (1-6): "
    read -r menu_choice
    
    case $menu_choice in
        1)
            run_full_cleanup
            ;;
        2)
            show_repo_stats
            echo ""
            echo -n "Press Enter to continue..."
            read -r
            show_main_menu
            ;;
        3)
            create_backup
            echo ""
            echo -n "Press Enter to continue..."
            read -r
            show_main_menu
            ;;
        4)
            list_large_files
            echo ""
            echo -n "Press Enter to continue..."
            read -r
            show_main_menu
            ;;
        5)
            search_in_history
            echo ""
            echo -n "Press Enter to continue..."
            read -r
            show_main_menu
            ;;
        6)
            print_success "Goodbye!"
            exit 0
            ;;
        *)
            print_error "Invalid choice!"
            sleep 1
            show_main_menu
            ;;
    esac
}

list_large_files() {
    print_header "LARGE FILES IN HISTORY"
    
    print_step "Analyzing repository (this may take a moment)..."
    
    git rev-list --objects --all |
    git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' |
    sed -n 's/^blob //p' |
    sort --numeric-sort --key=2 --reverse |
    head -n 20 |
    while read -r obj size path; do
        size_mb=$(echo "scale=2; $size / 1024 / 1024" | bc)
        printf "  %.2f MB\t%s\n" "$size_mb" "$path"
    done
}

search_in_history() {
    print_header "SEARCH IN HISTORY"
    
    echo -n "Enter filename or pattern to search: "
    read -r search_pattern
    
    print_step "Searching Git history..."
    echo ""
    
    git log --all --pretty=format: --name-only --diff-filter=A |
    grep -i "$search_pattern" |
    sort -u |
    while read -r file; do
        echo "  $file"
    done
}

run_full_cleanup() {
    check_git_repo
    check_working_tree
    show_repo_stats
    select_files_to_remove
    select_branch
    analyze_removal
    create_backup
    perform_cleanup
    show_post_cleanup_stats
    show_push_instructions
}

main() {
    show_banner
    show_main_menu
}

main
