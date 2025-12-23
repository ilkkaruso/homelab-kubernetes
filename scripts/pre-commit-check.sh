

#!/bin/bash
echo "🔍 Running pre-commit safety checks..."
echo ""

FOUND_ISSUES=0

# Check for Secret resources (exclude this script)
echo "Checking for Secret resources..."
SECRETS=$(git ls-files | grep -v "pre-commit-check.sh" | xargs grep -l "kind: Secret" 2>/dev/null)
if [ -n "$SECRETS" ]; then
  echo "⚠️  WARNING: Found Secret resources in tracked files!"
  echo "   These files contain Secret definitions:"
  echo "$SECRETS"
  echo ""
  FOUND_ISSUES=1
else
  echo "✅ No Secret resources found"
fi

# Check for base64 tokens (exclude this script)
echo ""
echo "Checking for tokens..."
TOKENS=$(git ls-files | grep -v "pre-commit-check.sh" | xargs grep -E "token:\s*[A-Za-z0-9+/=]{40,}" 2>/dev/null)
if [ -n "$TOKENS" ]; then
  echo "⚠️  WARNING: Found potential tokens!"
  echo "$TOKENS"
  echo ""
  FOUND_ISSUES=1
else
  echo "✅ No tokens found"
fi

# Check for Cloudflare tokens (exclude this script)
echo ""
echo "Checking for Cloudflare tokens..."
CLOUDFLARE=$(git ls-files | grep -v "pre-commit-check.sh" | xargs grep "eyJ" 2>/dev/null)
if [ -n "$CLOUDFLARE" ]; then
  echo "⚠️  WARNING: Found potential Cloudflare token!"
  echo "$CLOUDFLARE"
  echo ""
  FOUND_ISSUES=1
else
  echo "✅ No Cloudflare tokens found"
fi

# Check for API keys (exclude this script)
echo ""
echo "Checking for API keys..."
APIKEYS=$(git ls-files | grep -v "pre-commit-check.sh" | xargs grep -iE "api.?key.*['\"]?[a-z0-9]{20,}|sk-ant-" 2>/dev/null)
if [ -n "$APIKEYS" ]; then
  echo "⚠️  WARNING: Found potential API keys!"
  echo "$APIKEYS"
  echo ""
  FOUND_ISSUES=1
else
  echo "✅ No API keys found"
fi

# Check for passwords (exclude this script)
echo ""
echo "Checking for passwords..."
PASSWORDS=$(git ls-files | grep -v "pre-commit-check.sh" | xargs grep -E "password:\s*['\"]?[a-zA-Z0-9]+" 2>/dev/null | grep -v "secretKeyRef" | grep -v "admin-password" | grep -v "#")
if [ -n "$PASSWORDS" ]; then
  echo "⚠️  WARNING: Found potential passwords!"
  echo "$PASSWORDS"
  echo ""
  FOUND_ISSUES=1
else
  echo "✅ No hardcoded passwords found"
fi

# Check for private keys (exclude this script)
echo ""
echo "Checking for private keys..."
PRIVKEYS=$(git ls-files | grep -v "pre-commit-check.sh" | xargs grep "BEGIN.*PRIVATE KEY" 2>/dev/null)
if [ -n "$PRIVKEYS" ]; then
  echo "⚠️  WARNING: Found private keys!"
  echo "$PRIVKEYS"
  echo ""
  FOUND_ISSUES=1
else
  echo "✅ No private keys found"
fi

echo ""
echo "=========================================="
if [ $FOUND_ISSUES -eq 0 ]; then
  echo "✅ All checks passed! Safe to commit."
  exit 0
else
  echo "❌ STOP! Review the warnings above before committing."
  echo "   If these are false positives, you can proceed."
  echo "   If these are real secrets, remove them first!"
  exit 1
fi
