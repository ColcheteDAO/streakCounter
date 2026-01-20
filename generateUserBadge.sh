#!/bin/bash

USERNAME=$1
USER_FILE="data/${USERNAME}.json"
STREAK_FILE="streakData/${USERNAME}.json"

# 1. Extract and Format Dates
RAW_CREATED_AT=$(jq -r '.user.createdAt' "$USER_FILE")
RAW_MAX_STREAK_DATE=$(jq -r '.maxStreakDate' "$STREAK_FILE")
START_DATE=$(date -d "$RAW_CREATED_AT" +"%b %d, %Y")
[ "$RAW_MAX_STREAK_DATE" != "null" ] && MAX_STREAK_DATE=$(date -d "$RAW_MAX_STREAK_DATE" +"%b %d, %Y") || MAX_STREAK_DATE="N/A"

# 2. Extract Data
STREAK=$(jq -r '.streakCount' "$STREAK_FILE")
TOTAL_CONTRIB=$(jq -r '.contributionCount' "$STREAK_FILE")
MAX_STREAK=$(jq -r '.maxStreak' "$STREAK_FILE")
TODAY=$(date +"%b %d")

# 3. Dynamic Font Selection (Fixes the DejaVu-Sans error)
# Try to find a common font, fallback to 'fixed' if none found
MY_FONT=$(convert -list font | grep -oE "Arial|Liberation-Sans|DejaVu-Sans|Ubuntu" | head -n 1)
[ -z "$MY_FONT" ] && MY_FONT="fixed"

# 4. Styling
WIDTH=850
HEIGHT=250
BG_COLOR="#0d1117"
TEXT_COLOR="#ffffff"
ORANGE="#ff9a00"
SUB_TEXT="#8b949e"
DIVIDER="#30363d"
OUTPUT="badges/${USERNAME}_badge.png"

mkdir -p badges

# 5. Generate Badge (NO COMMENTS ALLOWED BETWEEN THE \ LINES)
convert -size ${WIDTH}x${HEIGHT} xc:"$BG_COLOR" \
    -fill "$TEXT_COLOR" -font "$MY_FONT" \
    -gravity West -pointsize 45 -draw "text 80,-20 '$TOTAL_CONTRIB'" \
    -fill "$TEXT_COLOR" -pointsize 18 -draw "text 75,25 'Total Contributions'" \
    -fill "$SUB_TEXT" -pointsize 14 -draw "text 80,60 '$START_DATE - Present'" \
    -fill none -stroke "$DIVIDER" -strokewidth 2 -draw "line 280,50 280,200" -draw "line 570,50 570,200" \
    -stroke none -gravity Center \
    -fill none -stroke "$ORANGE" -strokewidth 5 -draw "arc 385,40 465,160 140,400" \
    -fill "$ORANGE" -stroke none -draw "path 'M 425,30 Q 415,50 425,65 Q 435,50 425,30 Z'" \
    -fill "$TEXT_COLOR" -pointsize 45 -draw "text 0,-15 '$STREAK'" \
    -fill "$ORANGE" -pointsize 18 -draw "text 0,55 'Current Streak'" \
    -fill "$SUB_TEXT" -pointsize 14 -draw "text 0,85 '$TODAY - Present'" \
    -gravity East -fill "$TEXT_COLOR" -pointsize 45 -draw "text 100,-20 '$MAX_STREAK'" \
    -pointsize 18 -draw "text 85,25 'Longest Streak'" \
    -fill "$SUB_TEXT" -pointsize 14 -draw "text 70,60 'All-time High ($MAX_STREAK_DATE)'" \
    "$OUTPUT"

echo "Success: Wide Badge generated for $USERNAME using font $MY_FONT"
