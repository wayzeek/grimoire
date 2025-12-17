#!/usr/bin/env bash

# Grimoire - CLI for managing Claude Code skills and agents

set -e

# Disable gum choose help text
export GUM_CHOOSE_SHOW_HELP=false

# Check if gum is installed
if ! command -v gum &> /dev/null; then
    echo "Error: 'gum' is required but not installed."
    echo ""
    echo "Install with:"
    echo "  macOS:   brew install gum"
    echo "  Linux:   See https://github.com/charmbracelet/gum#installation"
    echo ""
    exit 1
fi

# Paths
GRIMOIRE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_SKILLS_DIR="$GRIMOIRE_DIR/.claude/skills"
USER_CLAUDE_DIR="$HOME/.claude"
USER_SKILLS_DIR="$USER_CLAUDE_DIR/skills"

# Create user directories if they don't exist
mkdir -p "$USER_SKILLS_DIR"

# Parse YAML frontmatter to extract description
parse_description() {
    local file="$1"
    local in_frontmatter=false
    local description=""

    while IFS= read -r line; do
        if [[ "$line" == "---" ]]; then
            if [ "$in_frontmatter" = true ]; then
                break
            fi
            in_frontmatter=true
            continue
        fi

        if [ "$in_frontmatter" = true ] && [[ "$line" =~ ^description:\ *(.+)$ ]]; then
            description="${BASH_REMATCH[1]}"
            description="${description#\"}"
            description="${description%\"}"
        fi
    done < "$file"

    echo "$description"
}

# Check if skill is installed
is_installed() {
    local name="$1"
    [ -d "$USER_SKILLS_DIR/$name" ]
}

# Check if installed version needs update
needs_update() {
    local name="$1"
    local src="$LOCAL_SKILLS_DIR/$name"
    local dst="$USER_SKILLS_DIR/$name"

    if [ ! -e "$dst" ]; then
        return 0
    fi

    ! diff -rq "$src" "$dst" > /dev/null 2>&1
}

# Get status label
get_status() {
    local name="$1"

    if ! is_installed "$name"; then
        echo "not installed"
    elif needs_update "$name"; then
        echo "update available"
    else
        echo "installed"
    fi
}

# Install a skill
install_skill() {
    local skill_name="$1"

    gum spin --spinner dot --title "Installing $skill_name..." -- \
        cp -r "$LOCAL_SKILLS_DIR/$skill_name" "$USER_SKILLS_DIR/"

    gum style --foreground 212 "Installed: $skill_name"
}



# Show header
show_header() {
    clear
    echo ""

    # Book art in a box
    local book_box=$(gum style \
        --border rounded \
        --border-foreground 212 \
        --padding "0 1" \
        --margin "0 2" \
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣀⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠘⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠈⠑⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣶⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⣿⠛⠁⠀⠀⠀⠀⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠙⢻⡇⠀⠀⠀⠀⠀⠀⠀⠐⠻⠏⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⣀⡀⢠⣴⣶⣿⣿⣿⣿⣿⡆⢰⣶⠶⠶⠶⠶⠦⣤⡄⢀⣀⠀⠀⠀⠀
⠀⠀⠀⠀⣿⠁⣼⣿⣿⣿⣿⣿⣿⣿⡇⢸⣿⣶⣶⣶⣶⣶⣿⣧⠈⣿⠀⠀⠀⠀
⠀⠀⠀⢠⡍⢀⣿⣿⣿⣿⣿⣿⣿⣿⡇⢸⣿⠛⠛⠛⠛⠛⠻⣿⡀⢻⡇⠀⠀⠀
⠀⠀⠀⠛⠃⣸⣿⣿⣿⣿⣿⣿⣿⣿⡇⢸⣿⠛⠛⠛⣿⡟⠛⢻⣇⠘⣷⠀⠀⠀
⠀⠀⢰⡟⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⢸⣿⠛⠛⠛⠛⠛⠛⠛⣿⡀⢻⡄⠀⠀
⠀⠀⣾⡇⠘⠟⠛⠛⠉⣉⣉⣉⡉⠛⠃⠘⠛⠛⠛⠛⠛⠛⠛⠲⠿⠃⢸⣧⠀⠀
⠀⢀⣉⣁⣀⣀⣉⣉⣉⣉⣉⣉⣉⣉⣁⣈⣉⣉⣉⣉⣉⣉⣁⣀⣀⣀⣈⣉⡀⠀
⠀⠘⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠃⠀")

    # Title section on the right
    local title_section=$(gum style \
        --margin "2 0" \
        --padding "2 4" \
"$(gum style --bold --foreground 212 'GRIMOIRE')

$(gum style --faint 'Claude Code Skills')

$(gum style --faint 'Full-stack & blockchain development')
$(gum style --faint 'for Solidity, Solana, and modern web apps')")

    # Join horizontally
    gum join --horizontal "$book_box" "$title_section"

    echo ""
}

# Browse and install skills
browse_skills() {
    while true; do
        show_header

        gum style --bold --foreground 212 "Skills"
        echo ""

        # Build choices array
        local choices=()

        for skill_dir in "$LOCAL_SKILLS_DIR"/*; do
            if [ -d "$skill_dir" ]; then
                local name=$(basename "$skill_dir")
                local status=$(get_status "$name")
                choices+=("$name [$status]")
            fi
        done

        # Add "Install All" at the beginning
        if [ ${#choices[@]} -gt 0 ]; then
            choices=("Install All Skills" "${choices[@]}")
        fi

        if [ ${#choices[@]} -eq 1 ]; then
            gum style --foreground 196 "No skills found"
            sleep 2
            return
        fi

        # Let user select
        local selection=$(gum choose \
            --header "↑/↓: Navigate • Enter: Select • ESC: Back" \
            --height 15 \
            "${choices[@]}")

        local exit_code=$?

        # Check exit code (ESC pressed) or empty selection - exit program
        if [ $exit_code -ne 0 ] || [ -z "$selection" ]; then
            clear
            echo ""

            # Farewell messages array
            local farewells=(
                "May your spells compile without error"
                "The grimoire closes... until next time"
                "Your magic awaits in ~/.claude"
                "Happy coding, wizard!"
                "The arcane knowledge has been transferred"
                "May your deployments be ever successful"
                "Closing the book of blockchain wisdom"
                "Your skills are ready. Go forth and build!"
            )

            # Pick a random farewell
            local random_index=$((RANDOM % ${#farewells[@]}))
            gum style --foreground 212 "${farewells[$random_index]}"
            echo ""
            exit 0
        fi

        # Handle "Install All Skills"
        if [[ "$selection" == "Install All Skills"* ]]; then
            gum confirm "Install all skills?" && {
                for skill_dir in "$LOCAL_SKILLS_DIR"/*; do
                    if [ -d "$skill_dir" ]; then
                        local name=$(basename "$skill_dir")
                        install_skill "$name"
                    fi
                done
                gum style --foreground 212 "All skills installed"
                sleep 1
            }
            continue
        fi

        # Extract skill name from selection
        local skill_name=$(echo "$selection" | sed 's/ \[.*\]//')

        # Show details
        show_header
        gum style --bold --foreground 212 "Skill: $skill_name"
        echo ""

        local file="$LOCAL_SKILLS_DIR/$skill_name/SKILL.md"
        local description=$(parse_description "$file")
        local status=$(get_status "$skill_name")

        gum style --italic "$description"
        echo ""
        gum style "Status: $status"
        echo ""

        # Confirm installation
        if [ "$status" = "installed" ]; then
            local choice=$(gum choose \
                --header "What would you like to do?" \
                "Update" \
                "Delete" \
                "Cancel")

            case "$choice" in
                "Update")
                    install_skill "$skill_name"
                    sleep 1
                    ;;
                "Delete")
                    rm -rf "$USER_SKILLS_DIR/$skill_name"
                    gum style --foreground 212 "Deleted: $skill_name"
                    sleep 1
                    ;;
            esac
        else
            local action="Install"
            [ "$status" = "update available" ] && action="Update"

            gum confirm "$action $skill_name?" && {
                install_skill "$skill_name"
                sleep 1
            }
        fi
    done
}



# Main menu - directly browse skills
main_menu() {
    browse_skills
}

# Main execution
if [ ! -d "$LOCAL_SKILLS_DIR" ]; then
    gum style --foreground 196 "Error: No .claude/skills directory found in grimoire"
    exit 1
fi

# Start main menu
main_menu
