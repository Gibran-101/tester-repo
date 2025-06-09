#!/bin/bash

# ============================
# Git Pull Utility Script
# Author: Gibran
# ============================

# Ensure we're in a Git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo " Not a Git repository. Initialize or cd into a repo first."
    exit 1
fi

# Remote and branch input
read -p " Enter remote name (default: origin): " remote
remote=${remote:-origin}

read -p " Enter branch name (default: current branch): " branch
branch=${branch:-$(git branch --show-current)}

# Strategy prompt
echo ""
echo " Pull Strategy Options:"
echo "1. Merge (default)"
echo "2. Rebase"
echo "3. Fast-forward only"
echo "4. Allow unrelated histories"
read -p " Choose your strategy (1/2/3/4): " strategy

# Base command
pull_command="git pull $remote $branch"

# Strategy handling
case $strategy in
    1|"")
        echo " Using merge strategy (default)"
        ;;
    2)
        echo " Using rebase strategy"
        pull_command="git pull --rebase $remote $branch"
        ;;
    3)
        echo " Using fast-forward only strategy"
        pull_command="git pull --ff-only $remote $branch"
        ;;
    4)
        echo "⚠️ Allowing unrelated histories (USE WITH CAUTION)"
        pull_command="git pull $remote $branch --allow-unrelated-histories"
        ;;
    *)
        echo " Invalid strategy. Using default merge strategy."
        ;;
esac

# Execute the pull
echo ""
echo " Running: $pull_command"
eval $pull_command

# Check result
if [ $? -eq 0 ]; then
    echo " Pull successful."
else
    echo " Pull failed. Fix your conflicts or remote issues."
fi

