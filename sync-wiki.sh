#!/bin/bash
# Script untuk sync wiki dari .github/wiki/ ke GitHub Wiki

WIKI_DIR="$HOME/github/NTT_Playground.wiki"
SOURCE_DIR="$HOME/github/NTT_Playground/.github/wiki"

echo "🔄 Syncing Wiki content..."

# Clone wiki repo if not exists
if [ ! -d "$WIKI_DIR" ]; then
    echo "📦 Cloning wiki repository..."
    git clone https://github.com/termaulmaul/NTT_Playground.wiki.git "$WIKI_DIR"
fi

# Copy all wiki files
echo "📋 Copying wiki files..."
cp -r "$SOURCE_DIR/"* "$WIKI_DIR/"

# Commit and push
cd "$WIKI_DIR"
git add .
git commit -m "docs: sync wiki from .github/wiki/ - $(date '+%Y-%m-%d %H:%M:%S')"
git push origin master

echo "✅ Wiki synced successfully!"
echo "🌐 Visit: https://github.com/termaulmaul/NTT_Playground/wiki"