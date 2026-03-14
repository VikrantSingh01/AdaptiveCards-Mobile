#!/bin/bash

# Copyright (c) Microsoft Corporation. All rights reserved.
# Author: Vikrant Singh (github.com/VikrantSingh01)
# Licensed under the MIT License.

# =============================================================================
# Generate Design Review Catalog
# =============================================================================
#
# Generates a self-contained index.html from a self-heal-dual screenshot
# directory. The HTML page shows side-by-side iOS/Android screenshots with
# links to source card JSON files for lead designer review.
#
# Usage:
#   bash shared/scripts/generate-design-catalog.sh                    # auto-detect latest
#   bash shared/scripts/generate-design-catalog.sh <output-dir>       # specific directory
#
# Output: index.html placed in the screenshot directory
# =============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TEST_CARDS_DIR="$REPO_ROOT/shared/test-cards"
GITHUB_BASE="https://github.com/VikrantSingh01/AdaptiveCards-Mobile/blob/main/shared/test-cards"

# Resolve input directory
if [ -n "${1:-}" ]; then
    SCREENSHOT_DIR="$1"
else
    # Auto-detect latest self-heal-dual output
    LATEST=$(ls -dt "$REPO_ROOT"/shared/test-output/self-heal-dual-* 2>/dev/null | head -1)
    if [ -z "$LATEST" ]; then
        echo "ERROR: No self-heal-dual output found. Run self-heal-dual.sh first."
        exit 1
    fi
    SCREENSHOT_DIR="$LATEST"
fi

if [ ! -d "$SCREENSHOT_DIR/screenshots" ]; then
    echo "ERROR: No screenshots/ directory found in $SCREENSHOT_DIR"
    exit 1
fi

OUTPUT_HTML="$SCREENSHOT_DIR/index.html"
TIMESTAMP=$(basename "$SCREENSHOT_DIR" | sed 's/self-heal-dual-//')

echo "=== Generating Design Review Catalog ==="
echo "  Source: $SCREENSHOT_DIR"
echo "  Output: $OUTPUT_HTML"

# =============================================================================
# Build card name → category + JSON path mapping (Bash 3.2 compatible)
# =============================================================================
# Uses a temp file as a lookup table: "name|category|json_path" per line
CARD_MAP_FILE=$(mktemp /tmp/card-map.XXXXXX)
trap "rm -f '$CARD_MAP_FILE'" EXIT

map_cards_from_dir() {
    local dir="$1"
    local category="$2"
    if [ -d "$TEST_CARDS_DIR/$dir" ]; then
        for f in "$TEST_CARDS_DIR/$dir"/*.json; do
            [ -f "$f" ] || continue
            local basename_no_ext
            basename_no_ext=$(basename "$f" .json)
            echo "${basename_no_ext}|${category}|${dir}/$(basename "$f")" >> "$CARD_MAP_FILE"
        done
    fi
}

map_cards_from_dir "teams-official-samples" "Teams Official"
map_cards_from_dir "element-samples" "Element Samples"
map_cards_from_dir "official-samples" "Official Samples"
map_cards_from_dir "versioned/v1.5" "Versioned v1.5"
map_cards_from_dir "versioned/v1.6" "Versioned v1.6"
map_cards_from_dir "templates" "Templates"
map_cards_from_dir "host-configs" "Host Configs"

# Root-level cards
for f in "$TEST_CARDS_DIR"/*.json; do
    [ -f "$f" ] || continue
    local_name=$(basename "$f" .json)
    echo "${local_name}|Root|$(basename "$f")" >> "$CARD_MAP_FILE"
done

# Lookup helpers
lookup_category() {
    local result
    result=$(awk -F'|' -v name="$1" '$1 == name { print $2; exit }' "$CARD_MAP_FILE")
    echo "${result:-Unknown}"
}

lookup_json_path() {
    local result
    result=$(awk -F'|' -v name="$1" '$1 == name { print $3; exit }' "$CARD_MAP_FILE")
    echo "$result"
}

# =============================================================================
# Collect screenshots
# =============================================================================
IOS_DIR="$SCREENSHOT_DIR/screenshots/ios"
ANDROID_DIR="$SCREENSHOT_DIR/screenshots/android"

# Get unique card names from both platforms (exclude retries and gallery baselines)
ALL_SCREENSHOTS=()
for dir in "$IOS_DIR" "$ANDROID_DIR"; do
    [ -d "$dir" ] || continue
    for f in "$dir"/*.png; do
        [ -f "$f" ] || continue
        name=$(basename "$f" .png)
        # Skip retries and gallery baselines
        [[ "$name" == *-retry* ]] && continue
        [[ "$name" == _gallery_baseline* ]] && continue
        ALL_SCREENSHOTS+=("$name")
    done
done

# Deduplicate and sort
UNIQUE_CARDS=($(printf '%s\n' "${ALL_SCREENSHOTS[@]}" | sort -u))

# Separate app screens from card screenshots
APP_SCREENS=()
CARD_SCREENSHOTS=()
for name in "${UNIQUE_CARDS[@]}"; do
    if [[ "$name" == _app-* ]]; then
        APP_SCREENS+=("$name")
    else
        CARD_SCREENSHOTS+=("$name")
    fi
done

echo "  App screens: ${#APP_SCREENS[@]}"
echo "  Card screenshots: ${#CARD_SCREENSHOTS[@]}"


# =============================================================================
# Generate HTML
# =============================================================================
cat > "$OUTPUT_HTML" << 'HTML_HEADER'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Adaptive Cards Mobile — Design Review Catalog</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #1a1a2e; color: #e0e0e0; padding: 20px; }
  .header { text-align: center; padding: 30px 20px; background: #16213e; color: white; border-radius: 12px; margin-bottom: 24px; border: 1px solid #2a2a4a; }
  .header h1 { font-size: 24px; font-weight: 600; margin-bottom: 8px; }
  .header p { font-size: 14px; opacity: 0.7; }
  .stats { display: flex; gap: 12px; justify-content: center; flex-wrap: wrap; margin-top: 16px; }
  .stat { background: rgba(255,255,255,0.1); padding: 6px 14px; border-radius: 20px; font-size: 13px; }
  .controls { display: flex; gap: 12px; margin-bottom: 20px; flex-wrap: wrap; align-items: center; }
  .controls select, .controls input { padding: 8px 12px; border: 1px solid #3a3a5a; border-radius: 8px; font-size: 14px; background: #2a2a4a; color: #e0e0e0; }
  .controls input { flex: 1; min-width: 200px; }
  .controls input::placeholder { color: #888; }
  .controls select { min-width: 180px; }
  .section-title { font-size: 18px; font-weight: 600; color: #7ec8e3; margin: 24px 0 12px; padding-bottom: 8px; border-bottom: 2px solid #7ec8e3; }
  .grid { display: grid; gap: 16px; }
  .card-row { display: grid; grid-template-columns: 180px 80px 1fr 1fr; gap: 16px; background: #16213e; border-radius: 10px; padding: 16px; box-shadow: 0 1px 3px rgba(0,0,0,0.3); align-items: start; transition: box-shadow 0.2s; border: 1px solid #2a2a4a; }
  .card-row:hover { box-shadow: 0 4px 12px rgba(0,0,0,0.4); border-color: #3a3a5a; }
  .card-row.missing { background: #2a1a1a; border-left: 3px solid #e74c3c; }
  .card-info { display: flex; flex-direction: column; gap: 6px; }
  .card-name { font-weight: 600; font-size: 14px; color: #e0e0e0; word-break: break-word; }
  .card-category { font-size: 12px; color: #aaa; background: #2a2a4a; padding: 2px 8px; border-radius: 10px; display: inline-block; }
  .card-link { display: flex; align-items: center; justify-content: center; }
  .card-link a { color: #7ec8e3; text-decoration: none; font-size: 13px; font-weight: 500; padding: 4px 10px; border: 1px solid #7ec8e3; border-radius: 6px; transition: all 0.2s; }
  .card-link a:hover { background: #7ec8e3; color: #1a1a2e; }
  .screenshot-col { text-align: center; }
  .screenshot-col img { max-width: 100%; width: 270px; border: 1px solid #3a3a5a; border-radius: 6px; cursor: pointer; transition: transform 0.2s; }
  .screenshot-col img:hover { transform: scale(1.02); border-color: #7ec8e3; }
  .screenshot-col .platform-label { font-size: 11px; color: #888; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 4px; }
  .no-screenshot { color: #e74c3c; font-size: 13px; font-style: italic; padding: 40px 0; }
  /* Lightbox */
  .lightbox { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.95); z-index: 1000; justify-content: center; align-items: center; cursor: pointer; }
  .lightbox.active { display: flex; }
  .lightbox img { max-width: 90vw; max-height: 90vh; border-radius: 8px; }
  .lightbox .close-btn { position: absolute; top: 20px; right: 30px; color: white; font-size: 30px; cursor: pointer; }
  .footer { text-align: center; margin-top: 40px; padding: 20px; color: #666; font-size: 13px; }
  .footer a { color: #7ec8e3; }
  @media (max-width: 900px) {
    .card-row { grid-template-columns: 1fr; }
    .card-link { justify-content: flex-start; }
    .screenshot-col img { width: 100%; max-width: 300px; }
  }
</style>
</head>
<body>

<div class="header">
  <h1>Adaptive Cards Mobile — Design Review Catalog</h1>
  <p>Side-by-side iOS & Android rendering for design review | <a href="https://vikrantsingh01.github.io/AdaptiveCards-Mobile/" style="color:#7ec8e3">Live Catalog</a></p>
  <div class="stats" id="stats"></div>
</div>

<div class="controls">
  <select id="categoryFilter" onchange="filterCards()">
    <option value="all">All Categories</option>
  </select>
  <input type="text" id="searchBox" placeholder="Search card names..." oninput="filterCards()">
</div>

<div id="lightbox" class="lightbox" onclick="closeLightbox()">
  <span class="close-btn">&times;</span>
  <img id="lightbox-img" src="" alt="Full size screenshot">
</div>

<div id="catalog"></div>

<div class="footer">
  <p>Generated from <a href="https://github.com/VikrantSingh01/AdaptiveCards-Mobile">AdaptiveCards-Mobile</a></p>
  <p id="timestamp"></p>
</div>

<script>
HTML_HEADER

# Write the card data as a JavaScript array
echo "const CATALOG_DATA = [" >> "$OUTPUT_HTML"

# App screens first
for name in "${APP_SCREENS[@]}"; do
    display_name="${name#_app-}"
    display_name="$(echo "$display_name" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')"
    ios_exists="false"
    android_exists="false"
    [ -f "$IOS_DIR/${name}.png" ] && ios_exists="true"
    [ -f "$ANDROID_DIR/${name}.png" ] && android_exists="true"
    echo "  { name: \"$display_name\", screenshot: \"$name\", category: \"App Screen\", jsonUrl: \"\", isApp: true, ios: $ios_exists, android: $android_exists }," >> "$OUTPUT_HTML"
done

# Card screenshots
for name in "${CARD_SCREENSHOTS[@]}"; do
    category=$(lookup_category "$name")
    json_path=$(lookup_json_path "$name")
    json_url=""
    if [ -n "$json_path" ]; then
        json_url="$GITHUB_BASE/$json_path"
    fi
    ios_exists="false"
    android_exists="false"
    [ -f "$IOS_DIR/${name}.png" ] && ios_exists="true"
    [ -f "$ANDROID_DIR/${name}.png" ] && android_exists="true"
    # Escape any special chars in name
    safe_name=$(echo "$name" | sed 's/"/\\"/g')
    safe_category=$(echo "$category" | sed 's/"/\\"/g')
    echo "  { name: \"$safe_name\", screenshot: \"$safe_name\", category: \"$safe_category\", jsonUrl: \"$json_url\", isApp: false, ios: $ios_exists, android: $android_exists }," >> "$OUTPUT_HTML"
done

cat >> "$OUTPUT_HTML" << 'HTML_SCRIPT'
];

const TIMESTAMP = "REPLACE_TIMESTAMP";

function init() {
  // Build category list
  const categories = [...new Set(CATALOG_DATA.map(c => c.category))];
  const select = document.getElementById('categoryFilter');
  categories.forEach(cat => {
    const opt = document.createElement('option');
    opt.value = cat;
    opt.textContent = cat;
    select.appendChild(opt);
  });

  // Stats
  const totalCards = CATALOG_DATA.filter(c => !c.isApp).length;
  const totalApp = CATALOG_DATA.filter(c => c.isApp).length;
  const iosCount = CATALOG_DATA.filter(c => c.ios).length;
  const androidCount = CATALOG_DATA.filter(c => c.android).length;
  const statsEl = document.getElementById('stats');
  statsEl.innerHTML = `
    <span class="stat">📊 ${totalCards} cards</span>
    <span class="stat">📱 ${totalApp} app screens</span>
    <span class="stat">🍎 ${iosCount} iOS</span>
    <span class="stat">🤖 ${androidCount} Android</span>
    <span class="stat">📅 ${TIMESTAMP}</span>
  `;
  document.getElementById('timestamp').textContent = `Captured: ${TIMESTAMP}`;

  renderCatalog();
}

function filterCards() {
  renderCatalog();
}

function renderCatalog() {
  const categoryFilter = document.getElementById('categoryFilter').value;
  const search = document.getElementById('searchBox').value.toLowerCase();

  let filtered = CATALOG_DATA;
  if (categoryFilter !== 'all') {
    filtered = filtered.filter(c => c.category === categoryFilter);
  }
  if (search) {
    filtered = filtered.filter(c => c.name.toLowerCase().includes(search));
  }

  // Group by category
  const groups = {};
  filtered.forEach(c => {
    if (!groups[c.category]) groups[c.category] = [];
    groups[c.category].push(c);
  });

  let html = '';

  // Defined category order
  const categoryOrder = [
    'App Screen',
    'Teams Official',
    'Official Samples',
    'Element Samples',
    'Root',
    'Templates',
    'Host Configs',
    'Versioned v1.5',
    'Versioned v1.6'
  ];

  // App Screen: custom item order (Gallery, Performance, More, Settings first)
  const appScreenOrder = ['Gallery', 'Performance', 'More', 'Settings'];
  if (groups['App Screen']) {
    groups['App Screen'].sort((a, b) => {
      const ai = appScreenOrder.indexOf(a.name);
      const bi = appScreenOrder.indexOf(b.name);
      if (ai !== -1 && bi !== -1) return ai - bi;
      if (ai !== -1) return -1;
      if (bi !== -1) return 1;
      return a.name.localeCompare(b.name);
    });
  }

  // Render in defined order
  categoryOrder.forEach(cat => {
    if (groups[cat]) {
      const label = cat === 'App Screen' ? 'App Screens' : cat + ' (' + groups[cat].length + ')';
      html += renderSection(label, groups[cat]);
      delete groups[cat];
    }
  });

  // Any remaining categories not in the defined order
  Object.keys(groups).sort().forEach(cat => {
    html += renderSection(cat + ' (' + groups[cat].length + ')', groups[cat]);
  });

  document.getElementById('catalog').innerHTML = html;
}

function renderSection(title, cards) {
  let html = `<h2 class="section-title">${title}</h2><div class="grid">`;
  cards.forEach(card => {
    const missing = (!card.ios || !card.android) ? ' missing' : '';
    const linkHtml = card.jsonUrl
      ? `<a href="${card.jsonUrl}" target="_blank">JSON</a>`
      : '';

    html += `<div class="card-row${missing}" data-category="${card.category}">
      <div class="card-info">
        <div class="card-name">${card.name}</div>
        <span class="card-category">${card.category}</span>
      </div>
      <div class="card-link">${linkHtml}</div>
      <div class="screenshot-col">
        <div class="platform-label">iOS</div>
        ${card.ios
          ? `<img src="screenshots/ios/${card.screenshot}.png" alt="${card.name} iOS" onclick="openLightbox(this.src)" loading="lazy">`
          : `<div class="no-screenshot">No screenshot</div>`}
      </div>
      <div class="screenshot-col">
        <div class="platform-label">Android</div>
        ${card.android
          ? `<img src="screenshots/android/${card.screenshot}.png" alt="${card.name} Android" onclick="openLightbox(this.src)" loading="lazy">`
          : `<div class="no-screenshot">No screenshot</div>`}
      </div>
    </div>`;
  });
  html += '</div>';
  return html;
}

function openLightbox(src) {
  document.getElementById('lightbox-img').src = src;
  document.getElementById('lightbox').classList.add('active');
}

function closeLightbox() {
  document.getElementById('lightbox').classList.remove('active');
}

document.addEventListener('keydown', e => { if (e.key === 'Escape') closeLightbox(); });

init();
</script>
</body>
</html>
HTML_SCRIPT

# Replace timestamp placeholder
sed -i '' "s/REPLACE_TIMESTAMP/$TIMESTAMP/g" "$OUTPUT_HTML"

echo ""
echo "✅ Design catalog generated: $OUTPUT_HTML"
echo "   Open in browser: open \"$OUTPUT_HTML\""
echo "   Cards: ${#CARD_SCREENSHOTS[@]}  |  App screens: ${#APP_SCREENS[@]}"
