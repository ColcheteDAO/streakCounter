#!/bin/bash

USERNAME=$1
USER_FILE="data/${USERNAME}.json"
STREAK_FILE="streakData/${USERNAME}.json"

# 1. Extract and Format Dates
RAW_CREATED_AT=$(jq -r '.user.createdAt' "$USER_FILE")
# Using maxStreakDate as requested
RAW_MAX_STREAK_DATE=$(jq -r '.maxStreakDate' "$STREAK_FILE")

START_DATE=$(date -d "$RAW_CREATED_AT" +"%b %d, %Y")
# Format maxStreakDate - if it's null, default to today
if [ "$RAW_MAX_STREAK_DATE" != "null" ]; then
    MAX_STREAK_DISPLAY=$(date -d "$RAW_MAX_STREAK_DATE" +"%b %d, %Y")
else
    MAX_STREAK_DISPLAY=$(date +"%b %d, %Y")
fi

# 2. Extract Streak Data
STREAK=$(jq -r '.streakCount' "$STREAK_FILE")
TOTAL_CONTRIB=$(jq -r '.contributionCount' "$STREAK_FILE")
MAX_STREAK=$(jq -r '.maxStreak' "$STREAK_FILE")

# 3. Styling & Layout
WIDTH=850
HEIGHT=250
BG_COLOR="#0d1117"
TEXT_COLOR="#ffffff"
ORANGE="#ff9a00"
SUB_TEXT="#8b949e"
DIVIDER="#30363d"

# Auto-detect a working font
MY_FONT=$(convert -list font | grep -oE "Arial|Liberation-Sans|DejaVu-Sans" | head -n 1)
[ -z "$MY_FONT" ] && MY_FONT="fixed"

OUTPUT="badges/${USERNAME}_badge.png"
mkdir -p badges

# 4. Generate Badge (Strictly NO comments allowed between backslashes)
convert -size ${WIDTH}x${HEIGHT} xc:"$BG_COLOR" \
    -font "$MY_FONT" -fill "$TEXT_COLOR" \
    -gravity NorthWest \
    -pointsize 52 -draw "text 50,60 '$TOTAL_CONTRIB'" \
    -pointsize 18 -draw "text 45,130 'Total Contributions'" \
    -fill "$SUB_TEXT" -pointsize 14 -draw "text 48,170 '$START_DATE - Present'" \
    -fill none -stroke "$DIVIDER" -strokewidth 2 \
    -draw "line 280,40 280,210" \
    -draw "line 570,40 570,210" \
    -stroke none -fill none -stroke "$ORANGE" -strokewidth 5 \
    -draw "arc 370,45 480,155 140,400" \
    -fill "$ORANGE" -stroke none -draw "path 'M 425,35 Q 415,50 425,65 Q 435,50 425,35 Z'" \
    -fill "$ORANGE" -pointsize 18 -draw "gravity North -annotate +0+165 'Current Streak'" \
    -fill "$SUB_TEXT" -pointsize 14 -draw "gravity North -annotate +0+195 '$MAX_STREAK_DISPLAY - Present'" \
    -fill "$TEXT_COLOR" -pointsize 52 -draw "gravity North -annotate +0+75 '$STREAK'" \
    -stroke none -fill "$TEXT_COLOR" -gravity NorthEast \
    -pointsize 52 -draw "text 90,60 '$MAX_STREAK'" \
    -pointsize 18 -draw "text 65,130 'Longest Streak'" \
    -fill "$SUB_TEXT" -pointsize 14 -draw "text 95,170 'All-time High'" \
    "$OUTPUT"

echo "Success: Badge generated for $USERNAME at $OUTPUT"
