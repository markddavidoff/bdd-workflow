#!/usr/bin/env bash
# validate-personas.sh — Validates all .persona files in a directory
# Usage: ./validate-personas.sh [personas_dir]

set -euo pipefail

PERSONAS_DIR="${1:-personas}"
ERRORS=0
COUNT=0

# Check if directory exists
if [ ! -d "$PERSONAS_DIR" ]; then
  echo "ERROR: Directory '$PERSONAS_DIR' not found"
  exit 1
fi

# Check if python3 and pyyaml are available
if ! python3 -c "import yaml" 2>/dev/null; then
  echo "WARNING: python3 with PyYAML not available. Performing basic checks only."
  BASIC_ONLY=true
else
  BASIC_ONLY=false
fi

echo "Validating personas in: $PERSONAS_DIR"
echo "---"

for file in "$PERSONAS_DIR"/*.persona; do
  [ -f "$file" ] || continue
  COUNT=$((COUNT + 1))
  filename=$(basename "$file")
  
  if [ "$BASIC_ONLY" = true ]; then
    # Basic checks without YAML parsing
    for field in "id:" "name:" "role:" "goal:" "backstory:"; do
      if ! grep -q "^$field" "$file"; then
        echo "FAIL: $filename — missing required field '$field'"
        ERRORS=$((ERRORS + 1))
      fi
    done
  else
    # Full validation with Python
    python3 -c "
import yaml, sys, re

with open('$file', 'r') as f:
    try:
        data = yaml.safe_load(f)
    except yaml.YAMLError as e:
        print(f'FAIL: $filename — invalid YAML: {e}')
        sys.exit(1)

if not isinstance(data, dict):
    print(f'FAIL: $filename — root must be a YAML mapping')
    sys.exit(1)

errors = []

# Required fields
for field in ['id', 'name', 'role', 'goal', 'backstory']:
    if field not in data or not data[field]:
        errors.append(f'missing or empty required field: {field}')

# ID format
if 'id' in data and data['id']:
    if not re.match(r'^[a-z][a-z0-9-]*$', str(data['id'])):
        errors.append(f'id must be lowercase letters, numbers, hyphens (got: {data[\"id\"]})')

# Style enum validation
if 'style' in data and isinstance(data['style'], dict):
    valid_tones = ['direct', 'diplomatic', 'analytical', 'passionate']
    valid_details = ['brief', 'moderate', 'thorough']
    valid_stances = ['supportive', 'neutral', 'skeptical', 'adversarial']
    
    if 'tone' in data['style'] and data['style']['tone'] not in valid_tones:
        errors.append(f'style.tone must be one of {valid_tones}')
    if 'detail' in data['style'] and data['style']['detail'] not in valid_details:
        errors.append(f'style.detail must be one of {valid_details}')
    if 'stance' in data['style'] and data['style']['stance'] not in valid_stances:
        errors.append(f'style.stance must be one of {valid_stances}')

# Weight range
if 'weight' in data:
    try:
        w = float(data['weight'])
        if w < 0.0 or w > 1.0:
            errors.append(f'weight must be 0.0-1.0 (got: {w})')
    except (ValueError, TypeError):
        errors.append(f'weight must be a number')

# ID matches filename
expected_id = '$filename'.replace('.persona', '')
if 'id' in data and str(data['id']) != expected_id:
    errors.append(f'id \"{data[\"id\"]}\" does not match filename \"{expected_id}\"')

if errors:
    for e in errors:
        print(f'FAIL: $filename — {e}')
    sys.exit(1)
else:
    print(f'PASS: $filename')
" 2>&1
    result=$?
    if [ $result -ne 0 ]; then
      ERRORS=$((ERRORS + 1))
    fi
  fi
done

echo "---"
echo "Validated $COUNT persona(s). Errors: $ERRORS"

if [ $ERRORS -gt 0 ]; then
  exit 1
else
  echo "All personas valid."
  exit 0
fi
