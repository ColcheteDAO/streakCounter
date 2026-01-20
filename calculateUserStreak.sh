USERNAME=$1
STREAK_COUNT=0
cat "contributions/${USERNAME}.json" | jq '.[].contributionCount' | while read -r count; 
do 
  if [[ $count -gt 0 ]]; then
    STREAK_COUNT=$(( STREAK_COUNT + 1 ))
  else
    STREAK_COUNT=0
  fi
done

echo $USERNAME streak is $STREAK_COUNT
