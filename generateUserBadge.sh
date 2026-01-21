#!/bin/bash

# 1. Safety & Settings
set -e
export LC_NUMERIC="C"

USERNAME=$1
USER_FILE="data/${USERNAME}.json"
STREAK_FILE="streakData/${USERNAME}.json"

echo "Generating badge with fixed spacing for: $USERNAME"

# 2. Check Data
if [ ! -f "$USER_FILE" ] || [ ! -f "$STREAK_FILE" ]; then
    echo "Error: Files not found."
    exit 1
fi

# 3. Extract Data
RAW_CREATED_AT=$(jq -r '.user.createdAt' "$USER_FILE")
RAW_CURRENT_STREAK_DATE=$(jq -r '.currentStreakDate' "$STREAK_FILE")

[[ "$RAW_CREATED_AT" != "null" ]] && START_DATE=$(date -d "$RAW_CREATED_AT" +"%b %d, %Y") || START_DATE="N/A"
[[ "$RAW_CURRENT_STREAK_DATE" != "null" ]] && CURRENT_STREAK_DISPLAY=$(date -d "$RAW_CURRENT_STREAK_DATE" +"%b %d, %Y") || CURRENT_STREAK_DISPLAY="N/A"

STREAK=$(jq -r '.streakCount' "$STREAK_FILE")
TOTAL_CONTRIB=$(jq -r '.contributionCount' "$STREAK_FILE")
MAX_STREAK=$(jq -r '.maxStreak' "$STREAK_FILE")

# 4. Styling & Coordinates
WIDTH=850
HEIGHT=250
BG_COLOR="#0d1117"
TEXT_COLOR="#ffffff"
ORANGE="#ff9a00"
SUB_TEXT="#8b949e"
DIVIDER="#30363d"

# --- Spacing Fixes ---
# VAL_Y (Number): Moved UP to 80 (was 100) to clear space for the text below.
# LBL_Y (Label): Kept at 145. Gap between Number (ends ~132) and Label is now ~13px.
# SUB_Y (Date): Kept at 175.
VAL_Y=80
LBL_Y=145
SUB_Y=175

MY_FONT=$(convert -list font | grep -oE "Arial|Liberation-Sans|DejaVu-Sans" | head -n 1)
[ -z "$MY_FONT" ] && MY_FONT="fixed"

OUTPUT="badges/${USERNAME}_badge.png"
mkdir -p badges

# 5. Build Command
CMD=(
    convert 
    -size "${WIDTH}x${HEIGHT}" 
    xc:"$BG_COLOR"
    -font "$MY_FONT"
    -fill "$TEXT_COLOR"
    
    # --- Vertical Dividers ---
    # Dividers at 283 and 566 (Leaving space for the 220px circle in the middle)
    -fill none -stroke "$DIVIDER" -strokewidth 2
    -draw "line 283,50 283,200"
    -draw "line 566,50 566,200"

    # --- Text Settings ---
    -stroke none -fill "$TEXT_COLOR" -gravity North

    # --- Column 1: Total Contributions ---
    -pointsize 52 -annotate -284+$VAL_Y "$TOTAL_CONTRIB"
    -pointsize 18 -annotate -284+$LBL_Y "Total Contributions"
    -fill "$SUB_TEXT" -pointsize 14 -annotate -284+$SUB_Y "$START_DATE - Present"

    # --- Column 2: Large Circle & Flame ---
    # Circle Box: 315,15 to 535,235 (220px Diameter)
    # This extra width prevents the date text from hitting the sides.
    -fill none -stroke "$ORANGE" -strokewidth 5
    -draw "arc 315,15 535,235 135,405"
    
    # Flame Path: Adjusted to sit exactly on top of the new circle (Y=15)
    -fill "$ORANGE" -stroke none
    -draw "path 'M 425,15 Q 415,30 425,45 Q 435,30 425,15 Z'"
    
    # --- Column 2: Center Text ---
    # Now aligned to VAL_Y=80, ensuring no overlap with the label at 145.
    -fill "$TEXT_COLOR" -pointsize 52 -annotate +0+$VAL_Y "$STREAK"
    -fill "$ORANGE" -pointsize 18 -annotate +0+$LBL_Y "Current Streak"
    -fill "$SUB_TEXT" -pointsize 14 -annotate +0+$SUB_Y "$CURRENT_STREAK_DISPLAY - Present"

    # --- Column 3: Longest Streak ---
    -fill "$TEXT_COLOR" -pointsize 52 -annotate +284+$VAL_Y "$MAX_STREAK"
    -pointsize 18 -annotate +284+$LBL_Y "Longest Streak"
    -fill "$SUB_TEXT" -pointsize 14 -annotate +284+$SUB_Y "All-time High"

    "$OUTPUT"
)

# 6. Execute
"${CMD[@]}"

echo "Success: Badge generated. Text collision resolved."
