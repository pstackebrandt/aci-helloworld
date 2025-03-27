#!/bin/bash
# =============================================================================
# Common Bash Utilities Module
# =============================================================================
# Purpose:
#   Provides common utility functions for bash scripts
# =============================================================================

# Function to update .gitignore
# Usage: update_gitignore "pattern"
update_gitignore() {
    local pattern="$1"
    local gitignore_path=".gitignore"
    
    if [ -z "$pattern" ]; then
        echo "Error: Pattern is required" >&2
        return 1
    }
    
    if [ ! -f "$gitignore_path" ]; then
        echo "$pattern" > "$gitignore_path"
        echo "Created .gitignore with $pattern" >&2
        return 0
    }
    
    if ! grep -q "^${pattern}$" "$gitignore_path" 2>/dev/null; then
        echo "$pattern" >> "$gitignore_path"
        echo "Added $pattern to .gitignore" >&2
    fi
}

# Function to check if a pattern exists in .gitignore
# Usage: gitignore_has_pattern "pattern"
gitignore_has_pattern() {
    local pattern="$1"
    local gitignore_path=".gitignore"
    
    if [ -f "$gitignore_path" ] && grep -q "^${pattern}$" "$gitignore_path" 2>/dev/null; then
        return 0
    fi
    return 1
}

# Function to remove a pattern from .gitignore
# Usage: gitignore_remove_pattern "pattern"
gitignore_remove_pattern() {
    local pattern="$1"
    local gitignore_path=".gitignore"
    
    if [ -f "$gitignore_path" ]; then
        sed -i "/^${pattern}$/d" "$gitignore_path"
        echo "Removed $pattern from .gitignore" >&2
    fi
}

# Function to list all patterns in .gitignore
# Usage: gitignore_list_patterns
gitignore_list_patterns() {
    local gitignore_path=".gitignore"
    
    if [ -f "$gitignore_path" ]; then
        cat "$gitignore_path"
    else
        echo "No .gitignore file found" >&2
    fi
} 