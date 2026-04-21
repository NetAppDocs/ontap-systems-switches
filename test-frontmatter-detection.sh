#!/bin/bash
# Test script extracted from frontmatter-checker.md workflow
# Run this to test the detection logic locally

set -e

echo "Frontmatter Quality Test"
echo "========================"
echo ""

# Character validation rules
DISALLOWED='!@#$%&*()+=[]{}|\\:;,<>?/'

# Find all .adoc files (excluding includes and redirects)
echo "Scanning .adoc files for frontmatter issues..."
ADOC_FILES=$(find . -type f -name "*.adoc" \
  ! -path "./_include/*" \
  ! -path "./redirect/*" \
  ! -name "_*" 2>/dev/null)

if [ -z "$ADOC_FILES" ]; then
  echo "No .adoc files found"
  exit 0
fi

# Initialize results
ISSUE_COUNT=0
TOTAL_COUNT=0

# Process each file
for file in $ADOC_FILES; do
  TOTAL_COUNT=$((TOTAL_COUNT + 1))
  
  # Extract frontmatter (between first two ---)
  FM=$(awk '/^---$/{i++; next} i==1' "$file" 2>/dev/null)
  
  if [ -z "$FM" ]; then
    continue
  fi
  
  # Extract fields
  TITLE=$(echo "$FM" | grep "^title:" | sed 's/^title: *//' | tr -d '"')
  KEYWORDS=$(echo "$FM" | grep "^keywords:" | sed 's/^keywords: *//')
  SUMMARY=$(echo "$FM" | grep "^summary:" | sed 's/^summary: *//' | tr -d '"')
  
  FILE_ISSUES=""
  
  # Check title for disallowed characters
  if [ -n "$TITLE" ]; then
    for ((i=0; i<${#DISALLOWED}; i++)); do
      char="${DISALLOWED:$i:1}"
      if [[ "$TITLE" == *"$char"* ]]; then
        FILE_ISSUES="$FILE_ISSUES\n  - title: disallowed char '$char'"
      fi
    done
  fi
  
  # Check keywords for disallowed characters (except comma)
  if [ -n "$KEYWORDS" ]; then
    for ((i=0; i<${#DISALLOWED}; i++)); do
      char="${DISALLOWED:$i:1}"
      [[ "$char" == "," ]] && continue  # Commas allowed in keywords
      if [[ "$KEYWORDS" == *"$char"* ]]; then
        FILE_ISSUES="$FILE_ISSUES\n  - keywords: disallowed char '$char'"
      fi
    done
  fi
  
  # Check summary for disallowed characters and AsciiDoc markup
  if [ -n "$SUMMARY" ]; then
    # Check for ampersand specifically
    if [[ "$SUMMARY" == *"&"* ]]; then
      FILE_ISSUES="$FILE_ISSUES\n  - summary: contains '&' (replace with 'and')"
    fi
    
    # Check for other disallowed (except quotes, commas, forward slash)
    for ((i=0; i<${#DISALLOWED}; i++)); do
      char="${DISALLOWED:$i:1}"
      [[ "$char" =~ [,/\'\"] ]] && continue  # These allowed in summary
      [[ "$char" == "&" ]] && continue  # Already checked
      if [[ "$SUMMARY" == *"$char"* ]]; then
        FILE_ISSUES="$FILE_ISSUES\n  - summary: disallowed char '$char'"
      fi
    done
    
    # Check for AsciiDoc markup
    if [[ "$SUMMARY" =~ \*\*[^*]+\*\* ]]; then
      FILE_ISSUES="$FILE_ISSUES\n  - summary: contains bold markup (**text**)"
    fi
    if [[ "$SUMMARY" =~ \`[^\`]+\` ]]; then
      FILE_ISSUES="$FILE_ISSUES\n  - summary: contains monospace markup (\`text\`)"
    fi
    if [[ "$SUMMARY" =~ _[^_]+_ ]]; then
      FILE_ISSUES="$FILE_ISSUES\n  - summary: contains italic markup (_text_)"
    fi
  fi
  
  # Record issues if found
  if [ -n "$FILE_ISSUES" ]; then
    ISSUE_COUNT=$((ISSUE_COUNT + 1))
    echo "Issues in $file:"
    echo -e "$FILE_ISSUES"
    echo ""
  fi
done

# Summary
echo "================================"
echo "Scanned: $TOTAL_COUNT files"
echo "Issues found: $ISSUE_COUNT files"

if [ $ISSUE_COUNT -gt 0 ]; then
  echo ""
  echo "✗ Found frontmatter issues"
  exit 1
else
  echo ""
  echo "✓ All frontmatter is clean"
  exit 0
fi
