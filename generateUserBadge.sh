#!/bin/bash

USERNAME=$1
USER_FILE="data/${USERNAME}.json"
STREAK_FILE="streakData/${USERNAME}.json"

# 1. Data Extraction & Date Formatting
RAW_CREATED_AT=$(jq -r '.user.createdAt' "$USER_FILE")
RAW_STREAK_START=$(jq -r '.currentStreakStart' "$STREAK_FILE") # Make sure this key exists in your json
STREAK_START=$(date -d "$RAW_STREAK_START" +"%b %d, %Y")
START_DATE=$(date -d "$RAW_CREATED_AT" +"%b %d, %Y")

STREAK=$(jq -r '.streakCount' "$STREAK_FILE")
TOTAL_CONTRIB=$(jq -r '.contributionCount' "$STREAK_FILE")
MAX_STREAK=$(jq -r '.maxStreak' "$STREAK_FILE")

# 2. Styling & Layout Constants
WIDTH=850
HEIGHT=250
BG_COLOR="#0d1117"
TEXT_COLOR="#ffffff"
ORANGE="#ff9a00"
SUB_TEXT="#8b949e"
DIVIDER="#30363d"

# Auto-detect font
MY_FONT=$(convert -list font | grep -oE "Arial|Liberation-Sans|DejaVu-Sans" | head -n 1)
[ -z "$MY_FONT" ] && MY_FONT="fixed"

OUTPUT="badges/${USERNAME}_badge.png"
mkdir -p badges

# 3. Generate Badge with Manual Positioning
# Column 1 Center: 140 | Divider 1: 280 | Column 2 Center: 425 | Divider 2: 570 | Column 3 Center: 710
convert -size ${WIDTH}x${HEIGHT} xc:"$BG_COLOR" \
    -font "$MY_FONT" -fill "$TEXT_COLOR" \
    \
    # --- Column 1: Total ---
    -gravity NorthWest \
    -pointsize 52 -draw "text 50,60 '$TOTAL_CONTRIB'" \
    -pointsize 18 -draw "text 45,130 'Total Contributions'" \
    -fill "$SUB_TEXT" -pointsize 14 -draw "text 48,170 '$START_DATE - Present'" \
    \
    # --- The Vertical Bars (Dividers) ---
    -fill none -stroke "$DIVIDER" -strokewidth 2 \
    -draw "line 280,40 280,210" \
    -draw "line 570,40 570,210" \
    \
    # --- Column 2: Current Streak ---
    -stroke none -fill none -stroke "$ORANGE" -strokewidth 5 \
    -draw "arc 370,45 480,155 140,400" \
    -fill "$ORANGE" -stroke none -draw "path 'M 425,35 Q 415,50 425,65 Q 435,50 425,35 Z'" \
    -fill "$ORANGE" -pointsize 18 -draw "gravity North -annotate +0+165 'Current Streak'" \
    -fill "$SUB_TEXT" -pointsize 14 -draw "gravity North -annotate +0+195 '$STREAK_START - Present'" \
    -fill "$TEXT_COLOR" -pointsize 52 -draw "gravity North -annotate +0+75 '$STREAK'" \
    \
    # --- Column
