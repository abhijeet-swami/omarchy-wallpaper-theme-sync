#!/usr/bin/env bash
set -euo pipefail

OUTDIR="$HOME/.config/omarchy/themes/dynamic"
COLORS_CONF="$OUTDIR/colors.conf"
COLORS_CSS="$OUTDIR/colors.css"

mkdir -p "$OUTDIR"

declare -gA conf_colors=()
declare -gA css_colors=()
declare -ga conf_fallbacks=()
declare -ga css_fallbacks=()

init_color_maps() {
    if [[ -f "$COLORS_CONF" ]]; then
        while IFS= read -r line; do
            [[ "$line" =~ ^[[:space:]]*# ]] && continue
            [[ -z "$line" ]] && continue
            
            if [[ "$line" =~ ^\$([a-zA-Z0-9_.]+)[[:space:]]*=[[:space:]]*(.+)$ ]]; then
                conf_colors["${BASH_REMATCH[1]}"]="${BASH_REMATCH[2]}"
            fi
        done < "$COLORS_CONF"
        
        for key in accent accent_soft accent_strong subtle shadow background foreground; do
            [[ -n "${conf_colors[$key]:-}" ]] && conf_fallbacks+=("${conf_colors[$key]}")
        done
    fi
    
    if [[ -f "$COLORS_CSS" ]]; then
        while IFS= read -r line; do
            [[ "$line" =~ ^[[:space:]]*(#|\/\/|\/\*) ]] && continue
            [[ -z "$line" ]] && continue
            
            if [[ "$line" =~ @define-color[[:space:]]+([a-zA-Z0-9_-]+)[[:space:]]+([^;]+) ]]; then
                css_colors["${BASH_REMATCH[1]}"]="${BASH_REMATCH[2]}"
            elif [[ "$line" =~ ^[[:space:]]*([a-zA-Z0-9_-]+)[[:space:]]*=[[:space:]]*([^[:space:]]+) ]]; then
                css_colors["${BASH_REMATCH[1]}"]="${BASH_REMATCH[2]}"
            fi
        done < "$COLORS_CSS"
        
        for i in {1..5}; do
            [[ -n "${css_colors[color$i]:-}" ]] && css_fallbacks+=("${css_colors[color$i]}")
        done
    fi
}

find_color() {
    local key="$1"
    local -n map_ref="$2"
    
    [[ -n "${map_ref[$key]:-}" ]] && { echo "${map_ref[$key]}"; return 0; }
    
    local alt="${key//_/-}"
    [[ "$alt" != "$key" && -n "${map_ref[$alt]:-}" ]] && { echo "${map_ref[$alt]}"; return 0; }
    
    alt="${key//-/_}"
    [[ "$alt" != "$key" && -n "${map_ref[$alt]:-}" ]] && { echo "${map_ref[$alt]}"; return 0; }
    
    [[ "$key" =~ ^(.+)-color$ ]] && [[ -n "${map_ref[${BASH_REMATCH[1]}]:-}" ]] && {
        echo "${map_ref[${BASH_REMATCH[1]}]}"; return 0;
    }
    
    [[ "$key" =~ ^(.+)_color$ ]] && [[ -n "${map_ref[${BASH_REMATCH[1]}]:-}" ]] && {
        echo "${map_ref[${BASH_REMATCH[1]}]}"; return 0;
    }
    
    return 1
}

get_fallback() {
    local -n arr_ref="$1"
    [[ ${#arr_ref[@]} -gt 0 ]] && echo "${arr_ref[$RANDOM % ${#arr_ref[@]}]}"
}

process_kitty() {
    local input="$1"
    local output="$OUTDIR/$(basename "$input")"
    
    while IFS= read -r line; do
        [[ -z "$line" ]] && { echo ""; continue; }
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        
        if [[ "$line" =~ ^([[:space:]]*[a-zA-Z0-9_]+)[[:space:]]+(.+)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            local key_trimmed="${key#"${key%%[![:space:]]*}"}"
            
            if [[ "$value" =~ ^#[0-9A-Fa-f]{6}$ ]] || [[ "$value" =~ ^#[0-9A-Fa-f]{3}$ ]]; then
                local new_color
                if new_color=$(find_color "$key_trimmed" css_colors); then
                    echo "$key $new_color"
                elif new_color=$(get_fallback css_fallbacks); then
                    echo "$key $new_color"
                else
                    echo "$line"
                fi
            else
                echo "$line"
            fi
        else
            echo "$line"
        fi
    done < "$input" > "$output"
}

process_conf() {
    local input="$1"
    local output="$OUTDIR/$(basename "$input")"

    while IFS= read -r line; do
        [[ -z "$line" ]] && { echo ""; continue; }
        [[ "$line" =~ ^[[:space:]]*# ]] && { echo "$line"; continue; }
        
        if [[ "$line" =~ ^([[:space:]]*\$([a-zA-Z0-9_.]+)[[:space:]]*=[[:space:]]*).+$ ]]; then
            local prefix="${BASH_REMATCH[1]}"
            local varname="${BASH_REMATCH[2]}"
            local current_value="${line#*=}"
            current_value="${current_value#"${current_value%%[![:space:]]*}"}"
            
            if [[ "$current_value" =~ rgba?\([[:space:]]*0[[:space:]]*,[[:space:]]*0[[:space:]]*,[[:space:]]*0[[:space:]]*,[[:space:]]*0[[:space:]]*\) ]]; then
                echo "$line"
            elif new_color=$(find_color "$varname" conf_colors); then
                echo "${prefix}${new_color}"
            elif new_color=$(get_fallback conf_fallbacks); then
                echo "${prefix}${new_color}"
            else
                echo "$line"
            fi
        else
            echo "$line"
        fi
    done < "$input" > "$output"
}

process_css() {
    local input="$1"
    local output="$OUTDIR/$(basename "$input")"
    
    while IFS= read -r line; do
        [[ -z "$line" ]] && { echo ""; continue; }
        [[ "$line" =~ ^[[:space:]]*(\/\/|\/\*) ]] && { echo "$line"; continue; }
        
        if [[ "$line" =~ ^([[:space:]]*@define-color[[:space:]]+)([a-zA-Z0-9_-]+)([[:space:]]+)([^;]+)(;.*)$ ]]; then
            local prefix="${BASH_REMATCH[1]}"
            local varname="${BASH_REMATCH[2]}"
            local spacing="${BASH_REMATCH[3]}"
            local suffix="${BASH_REMATCH[5]}"
            
            if new_color=$(find_color "$varname" css_colors); then
                echo "${prefix}${varname}${spacing}${new_color}${suffix}"
            elif new_color=$(get_fallback css_fallbacks); then
                echo "${prefix}${varname}${spacing}${new_color}${suffix}"
            else
                echo "$line"
            fi
        else
            echo "$line"
        fi
    done < "$input" > "$output"
}

process_file() {
    local input="$1"
    [[ ! -f "$input" ]] && return 1
    
    local filename="$(basename "$input")"
    
    case "$filename" in
        kitty.conf)
            [[ ! -f "$COLORS_CSS" ]] && return 1
            process_kitty "$input"
            ;;
        *.conf)
            [[ ! -f "$COLORS_CONF" ]] && return 1
            process_conf "$input"
            ;;
        *.css)
            [[ ! -f "$COLORS_CSS" ]] && return 1
            process_css "$input"
            ;;
        *)
            return 1
            ;;
    esac
}

init_color_maps

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <file1> [file2] [file3] ..."
    exit 1
fi

for file in "$@"; do
    process_file "$file" || echo "Warning: Failed to process $file" >&2
done
