#!/usr/bin/env bash
set -euo pipefail

INPUT="$1"
if [[ ! -f "$INPUT" ]]; then
  exit 1
fi

OUTDIR="$HOME/.config/omarchy/themes/dynamic"
COLORS_CONF="$OUTDIR/colors.conf"
COLORS_CSS="$OUTDIR/colors.css"
FILENAME="$(basename "$INPUT")"

mkdir -p "$OUTDIR"

case "$FILENAME" in
  kitty.conf)
    if [[ ! -f "$COLORS_CSS" ]]; then
      exit 1
    fi
    
    declare -A color_map
    while IFS= read -r line; do
      [[ "$line" =~ ^[[:space:]]*(\/\/|\/\*) ]] && continue
      [[ -z "$line" ]] && continue
      
      if [[ "$line" =~ ^[[:space:]]*([a-zA-Z0-9_-]+)[[:space:]]*=[[:space:]]*([^[:space:]]+) ]]; then
        key="${BASH_REMATCH[1]}"
        value="${BASH_REMATCH[2]}"
        color_map["$key"]="$value"
      elif [[ "$line" =~ @define-color[[:space:]]+([a-zA-Z0-9_-]+)[[:space:]]+([^;]+) ]]; then
        key="${BASH_REMATCH[1]}"
        value="${BASH_REMATCH[2]}"
        color_map["$key"]="$value"
      fi
    done < "$COLORS_CSS"
    
    fallback_colors=()
    for i in {1..5}; do
      if [[ -n "${color_map[color$i]:-}" ]]; then
        fallback_colors+=("${color_map[color$i]}")
      fi
    done
    
    while IFS= read -r line; do
      if [[ -z "$line" ]]; then
        echo ""
        continue
      fi
      
      [[ "$line" =~ ^[[:space:]]*# ]] && continue
      
      if [[ "$line" =~ ^([[:space:]]*[a-zA-Z0-9_]+)[[:space:]]+(.+)$ ]]; then
        key="${BASH_REMATCH[1]}"
        value="${BASH_REMATCH[2]}"
        key_trimmed="${key#"${key%%[![:space:]]*}"}"
        
        if [[ "$value" =~ ^#[0-9A-Fa-f]{6}$ ]] || [[ "$value" =~ ^#[0-9A-Fa-f]{3}$ ]]; then
          if [[ "$key_trimmed" == "foreground" ]] && [[ -n "${color_map[foreground]:-}" ]]; then
            echo "$key ${color_map[foreground]}"
          elif [[ "$key_trimmed" == "background" ]] && [[ -n "${color_map[background]:-}" ]]; then
            echo "$key ${color_map[background]}"
          elif [[ "$key_trimmed" == "selection_foreground" ]] && [[ -n "${color_map[selection_foreground]:-}" ]]; then
            echo "$key ${color_map[selection_foreground]}"
          elif [[ "$key_trimmed" == "selection_background" ]] && [[ -n "${color_map[selection_background]:-}" ]]; then
            echo "$key ${color_map[selection_background]}"
          elif [[ "$key_trimmed" == "cursor" ]] && [[ -n "${color_map[cursor]:-}" ]]; then
            echo "$key ${color_map[cursor]}"
          elif [[ "$key_trimmed" == "cursor_text_color" ]] && [[ -n "${color_map[cursor_text_color]:-}" ]]; then
            echo "$key ${color_map[cursor_text_color]}"
          elif [[ "$key_trimmed" =~ ^color[0-9]+$ ]]; then
            color_num="${key_trimmed#color}"
            if [[ -n "${color_map[$key_trimmed]:-}" ]]; then
              echo "$key ${color_map[$key_trimmed]}"
            elif [[ ${#fallback_colors[@]} -gt 0 ]]; then
              random_color="${fallback_colors[$RANDOM % ${#fallback_colors[@]}]}"
              echo "$key ${random_color}"
            else
              echo "$line"
            fi
          elif [[ "$key_trimmed" =~ border.*color|tab.*background|tab.*foreground ]]; then
            if [[ -n "${color_map[$key_trimmed]:-}" ]]; then
              echo "$key ${color_map[$key_trimmed]}"
            elif [[ ${#fallback_colors[@]} -gt 0 ]]; then
              random_color="${fallback_colors[$RANDOM % ${#fallback_colors[@]}]}"
              echo "$key ${random_color}"
            else
              echo "$line"
            fi
          else
            if [[ ${#fallback_colors[@]} -gt 0 ]]; then
              random_color="${fallback_colors[$RANDOM % ${#fallback_colors[@]}]}"
              echo "$key ${random_color}"
            else
              echo "$line"
            fi
          fi
        else
          echo "$line"
        fi
      else
        echo "$line"
      fi
    done < "$INPUT" > "$OUTDIR/$FILENAME"
    ;;
    
  *.conf)
    if [[ ! -f "$COLORS_CONF" ]]; then
      exit 1
    fi
    
    declare -A color_map
    while IFS= read -r line; do
      [[ "$line" =~ ^[[:space:]]*# ]] && continue
      [[ -z "$line" ]] && continue
      
      if [[ "$line" =~ ^\$([a-zA-Z0-9_.]+)[[:space:]]*=[[:space:]]*(.+)$ ]]; then
        key="${BASH_REMATCH[1]}"
        value="${BASH_REMATCH[2]}"
        color_map["$key"]="$value"
      fi
    done < "$COLORS_CONF"
    
    fallback_colors=()
    for color_key in accent accent_soft accent_strong subtle shadow; do
      if [[ -n "${color_map[$color_key]:-}" ]]; then
        fallback_colors+=("${color_map[$color_key]}")
      fi
    done
    
    if [[ ${#fallback_colors[@]} -eq 0 ]]; then
      for color_key in background foreground; do
        if [[ -n "${color_map[$color_key]:-}" ]]; then
          fallback_colors+=("${color_map[$color_key]}")
        fi
      done
    fi
    
    while IFS= read -r line; do
      if [[ -z "$line" ]]; then
        echo ""
        continue
      fi
      
      if [[ "$line" =~ ^[[:space:]]*# ]]; then
        echo "$line"
        continue
      fi
      
      if [[ "$line" =~ ^([[:space:]]*\$([a-zA-Z0-9_.]+)[[:space:]]*=[[:space:]]*).+$ ]]; then
        prefix="${BASH_REMATCH[1]}"
        varname="${BASH_REMATCH[2]}"
        
        current_value="${line#*=}"
        current_value="${current_value#"${current_value%%[![:space:]]*}"}"
        
        if [[ "$current_value" =~ rgba?\([[:space:]]*0[[:space:]]*,[[:space:]]*0[[:space:]]*,[[:space:]]*0[[:space:]]*,[[:space:]]*0[[:space:]]*\) ]]; then
          echo "$line"
        elif [[ -n "${color_map[$varname]:-}" ]]; then
          echo "${prefix}${color_map[$varname]}"
        else
          if [[ ${#fallback_colors[@]} -gt 0 ]]; then
            random_color="${fallback_colors[$RANDOM % ${#fallback_colors[@]}]}"
            echo "${prefix}${random_color}"
          else
            echo "$line"
          fi
        fi
      else
        echo "$line"
      fi
    done < "$INPUT" > "$OUTDIR/$FILENAME"
    ;;
    
  *.css)
    if [[ ! -f "$COLORS_CSS" ]]; then
      exit 1
    fi
    
    declare -A color_map
    while IFS= read -r line; do
      [[ "$line" =~ ^[[:space:]]*(\/\/|\/\*) ]] && continue
      [[ -z "$line" ]] && continue
      
      if [[ "$line" =~ ^[[:space:]]*([a-zA-Z0-9_-]+)[[:space:]]*=[[:space:]]*([^[:space:]]+) ]]; then
        key="${BASH_REMATCH[1]}"
        value="${BASH_REMATCH[2]}"
        color_map["$key"]="$value"
      elif [[ "$line" =~ @define-color[[:space:]]+([a-zA-Z0-9_-]+)[[:space:]]+([^;]+) ]]; then
        key="${BASH_REMATCH[1]}"
        value="${BASH_REMATCH[2]}"
        color_map["$key"]="$value"
      fi
    done < "$COLORS_CSS"

    fallback_colors=()
    for i in {1..5}; do
      if [[ -n "${color_map[color$i]:-}" ]]; then
        fallback_colors+=("${color_map[color$i]}")
      fi
    done
    
    while IFS= read -r line; do
      if [[ -z "$line" ]]; then
        echo ""
        continue
      fi
      
      if [[ "$line" =~ ^[[:space:]]*(\/\/|\/\*) ]]; then
        echo "$line"
        continue
      fi
      
      if [[ "$line" =~ ^([[:space:]]*@define-color[[:space:]]+)([a-zA-Z0-9_-]+)([[:space:]]+)([^;]+)(;.*)$ ]]; then
        prefix="${BASH_REMATCH[1]}"
        varname="${BASH_REMATCH[2]}"
        spacing="${BASH_REMATCH[3]}"
        old_value="${BASH_REMATCH[4]}"
        suffix="${BASH_REMATCH[5]}"
        
        if [[ -n "${color_map[$varname]:-}" ]]; then
          echo "${prefix}${varname}${spacing}${color_map[$varname]}${suffix}"
        else
          if [[ ${#fallback_colors[@]} -gt 0 ]]; then
            random_color="${fallback_colors[$RANDOM % ${#fallback_colors[@]}]}"
            echo "${prefix}${varname}${spacing}${random_color}${suffix}"
          else
            echo "$line"
          fi
        fi
      else
        echo "$line"
      fi
    done < "$INPUT" > "$OUTDIR/$FILENAME"
    ;;
    
  *)
    exit 1
    ;;
esac
