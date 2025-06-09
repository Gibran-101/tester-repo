#!/bin/bash

# Helper function to check if a variable is empty
checker(){
    if [ -z "$1" ]; then
        echo "$2"
        return 1
    fi
}

# Validates and sets remote URL if it doesn't already exist
url_validator(){
    if git remote get-url origin >/dev/null 2>&1; then
        echo " Remote 'origin' already exists. Skipping add."
    else
        git remote add origin "$1"
    fi
}

# Setup for a new repository
new_repo() {
    echo " Initializing new repo..."
    git init

    # Ask user which files to add
    read -p " Enter the files to add (space-separated): " add_response

    checker "$add_response" " Please add files first" 

    # Check if provided files actually exist
    for file in $add_response; do
        if [ ! -e "$file" ]; then
            echo " File '$file' does not exist."
            return 1
        fi
    done

    git add $add_response

    # Ask for commit message
    read -p " Enter the first commit message: " commit_msg
    checker "$commit_msg" " Empty commit message not allowed." 

    git commit -m "$commit_msg"

    # Set main as the default branch
    git branch -M main

    # Ask user for preferred URL format
    read -p " Choose URL format (https/ssh): " url_choice

    if [[ "$url_choice" == "https" || "$url_choice" == "ssh" ]]; then
        read -p " Enter the repo URL: " url
        url_validator "$url"
    else
        echo " Invalid URL format. Choose 'https' or 'ssh'."
        return 1
    fi

    # SSH Fix: Use SSH Agent if needed
    if [[ "$url_choice" == "ssh" ]]; then
        eval "$(ssh-agent -s)" >/dev/null
        ssh-add ~/.ssh/id_rsa 2>/dev/null || echo "⚠️ Could not add SSH key. Make sure it exists."
    fi

    # Attempt to push
    if ! git push -u origin main; then
        echo " Push failed. Check your URL or authentication."
        return 1
    fi

    echo " Repo pushed successfully!"
}

# Workflow for an existing repo
existing_repo() {
    echo "Choose how to add files:"
    echo "1. Add all (git add .)"
    echo "2. Add updated/tracked only (git add -u)"
    echo "3. Add specific files"
    read -p " Enter your choice (1/2/3): " add_choice

    case "$add_choice" in
        1) git add . ;;
        2) git add -u ;;
        3)
            read -p " Enter file names separated by space: " file_list
            git add $file_list
            ;;
        *) echo " Invalid choice. No files added."; return 1 ;;
    esac

    read -p " Enter commit message: " commit_msg
    checker "$commit_msg" " Empty commit message not allowed" 

    git commit -m "$commit_msg"

    current_branch=$(git branch --show-current)
    echo " Pushing to origin/$current_branch..."
    git push origin "$current_branch"
}

# Entrypoint prompt
read -p " Enter '1' to create a new repo, '0' to use an existing one: " choice

if [ "$choice" = "1" ]; then
    new_repo
elif [ "$choice" = "0" ]; then
    existing_repo
else
    echo " Invalid entry. Use 1 or 0."
fi

if [ $? -eq 0 ]; then
    echo " Push successful."
else
    echo " Push failed. Fix your conflicts or remote issues."
fi

