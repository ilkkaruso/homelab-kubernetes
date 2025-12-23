#!/bin/bash
echo "Running pre-commit safety checks..."

FOUND_ISSUES=0

# Check for common secret patterns
if git ls-files | xargs grep -l "kind: Secret" 2>/dev/null; then
  echo "⚠️  WARNING: Found Secret resources in tracked files!"
  FOUND_ISSUES=1
fi

# Check for base64 tokens (common in k8s secrets)
if git ls-files | xargs grep -E "token: [A-Za-z0-9+/=]{20,}" 2>/dev/null; then
  echo "⚠️  WARNING: Found potential tokens!"
  FOUND_ISSUES=1
fi

# Check for API keys
if git ls-files | xargs grep -i "api.key.*sk-\|apikey.*sk-" 2>/dev/null; then
  echo "⚠️  WARNING: Found potential API keys!"
  FOUND_ISSUES=1
fi

# Check for passwords
if git ls-files | xargs grep "password:.*[^{]" 2>/dev/null | grep -v "secretKeyRef"; then
  echo "⚠️  WARNING: Found potential passwords!"
  FOUND_ISSUES=1
fi

if [ $FOUND_ISSUES -eq 0 ]; then
  echo "✅ No sensitive data detected!"
else
  echo "❌ STOP! Review the warnings above before committing."
  exit 1
fi







