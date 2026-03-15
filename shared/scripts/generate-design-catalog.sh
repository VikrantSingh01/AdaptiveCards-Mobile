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
            # Screenshot key uses dir-basename (e.g., teams-official-samples-list)
            # to match design-pass.sh naming that avoids collisions
            local screenshot_key
            screenshot_key=$(echo "$dir/$basename_no_ext" | tr '/' '-')
            echo "${screenshot_key}|${category}|${dir}/$(basename "$f")" >> "$CARD_MAP_FILE"
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
  .controls input[type="text"] { flex: 1; min-width: 200px; }
  .controls input[type="text"]::placeholder { color: #888; }
  .controls select { min-width: 180px; }
  .section-title { font-size: 18px; font-weight: 600; color: #7ec8e3; margin: 24px 0 12px; padding-bottom: 8px; border-bottom: 2px solid #7ec8e3; }
  .grid { display: grid; gap: 16px; }
  .card-row { display: grid; grid-template-columns: 40px 120px 160px 80px 1fr 1fr; gap: 16px; background: #16213e; border-radius: 10px; padding: 16px; box-shadow: 0 1px 3px rgba(0,0,0,0.3); align-items: start; transition: box-shadow 0.2s; border: 1px solid #2a2a4a; }
  .card-row:hover { box-shadow: 0 4px 12px rgba(0,0,0,0.4); border-color: #3a3a5a; }
  .card-row.missing { background: #2a1a1a; border-left: 3px solid #e74c3c; }
  .card-info { display: flex; flex-direction: column; gap: 6px; }
  .card-name { font-weight: 600; font-size: 14px; color: #e0e0e0; word-break: break-word; }
  .card-category { font-size: 12px; color: #aaa; background: #2a2a4a; padding: 2px 8px; border-radius: 10px; display: inline-block; }
  .card-link { display: flex; align-items: center; justify-content: center; }
  .card-link a { color: #7ec8e3; text-decoration: none; font-size: 13px; font-weight: 500; padding: 4px 10px; border: 1px solid #7ec8e3; border-radius: 6px; transition: all 0.2s; }
  .card-link a:hover { background: #7ec8e3; color: #1a1a2e; }
  .screenshot-col { text-align: center; }
  .screenshot-col img { max-width: 100%; width: 390px; border: 1px solid #3a3a5a; border-radius: 6px; cursor: pointer; transition: transform 0.2s; image-rendering: -webkit-optimize-contrast; }
  .screenshot-col img:hover { transform: scale(1.02); border-color: #7ec8e3; }
  .screenshot-col .platform-label { font-size: 11px; color: #888; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 4px; }
  .no-screenshot { color: #e74c3c; font-size: 13px; font-style: italic; padding: 40px 0; }
  /* Review checkbox */
  .review-col { display: flex; align-items: flex-start; justify-content: center; padding-top: 4px; }
  .review-check { width: 22px; height: 22px; cursor: pointer; accent-color: #2ecc71; }
  .review-check:checked + .review-label { color: #2ecc71; }
  .card-row.reviewed { border-left: 3px solid #2ecc71; }
  .review-filter { display: flex; gap: 8px; align-items: center; font-size: 14px; color: #ccc; }
  .review-filter input { accent-color: #2ecc71; }
  .review-counter { background: #2ecc71; color: #1a1a2e; padding: 4px 12px; border-radius: 20px; font-size: 13px; font-weight: 600; }
  /* Review status + notes */
  .status-col { display: flex; flex-direction: column; gap: 6px; min-width: 120px; }
  .status-select { padding: 4px 8px; border: 1px solid #3a3a5a; border-radius: 6px; font-size: 12px; background: #2a2a4a; color: #e0e0e0; cursor: pointer; width: 100%; }
  .status-select.approved { border-color: #2ecc71; color: #2ecc71; }
  .status-select.needs-changes { border-color: #e67e22; color: #e67e22; }
  .note-input { padding: 4px 8px; border: 1px solid #3a3a5a; border-radius: 6px; font-size: 11px; background: #2a2a4a; color: #e0e0e0; resize: vertical; min-height: 28px; width: 100%; font-family: inherit; }
  .note-input::placeholder { color: #666; }
  .note-input:focus { border-color: #7ec8e3; outline: none; }
  .card-row.status-approved { border-left: 3px solid #2ecc71; }
  .card-row.status-needs-changes { border-left: 3px solid #e67e22; }
  /* Reviewer bar */
  .reviewer-bar { display: flex; gap: 12px; align-items: center; margin-bottom: 16px; padding: 12px 16px; background: #16213e; border-radius: 10px; border: 1px solid #2a2a4a; }
  .reviewer-bar label { font-size: 14px; color: #ccc; white-space: nowrap; }
  .reviewer-bar input { padding: 6px 12px; border: 1px solid #3a3a5a; border-radius: 8px; font-size: 14px; background: #2a2a4a; color: #e0e0e0; width: 200px; }
  .reviewer-bar input::placeholder { color: #666; }
  .reviewer-bar .reviewer-name { color: #7ec8e3; font-weight: 600; }
  .reviewer-bar button { padding: 6px 14px; border: 1px solid #3a3a5a; border-radius: 8px; font-size: 13px; background: #2a2a4a; color: #e0e0e0; cursor: pointer; }
  .reviewer-bar button:hover { background: #3a3a5a; }
  .status-filter select { padding: 6px 10px; border: 1px solid #3a3a5a; border-radius: 8px; font-size: 13px; background: #2a2a4a; color: #e0e0e0; }
  /* Setup guide */
  .setup-guide { margin-bottom: 20px; background: #16213e; border: 1px solid #2a2a4a; border-radius: 10px; overflow: hidden; }
  .setup-guide summary { padding: 12px 16px; cursor: pointer; font-size: 14px; color: #7ec8e3; font-weight: 600; user-select: none; }
  .setup-guide summary:hover { background: rgba(126,200,227,0.05); }
  .setup-guide .guide-content { padding: 0 16px 16px; font-size: 13px; line-height: 1.7; color: #ccc; }
  .setup-guide .guide-content ol { padding-left: 20px; }
  .setup-guide .guide-content li { margin-bottom: 8px; }
  .setup-guide .guide-content code { background: #2a2a4a; padding: 2px 6px; border-radius: 4px; font-size: 12px; color: #7ec8e3; }
  .setup-guide .guide-content a { color: #7ec8e3; }
  .setup-guide .guide-content .step-note { color: #888; font-size: 12px; }
  /* Lightbox */
  .lightbox { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.95); z-index: 1000; justify-content: center; align-items: center; cursor: pointer; }
  .lightbox.active { display: flex; }
  .lightbox img { max-width: 95vw; max-height: 95vh; border-radius: 8px; image-rendering: -webkit-optimize-contrast; }
  .lightbox .close-btn { position: absolute; top: 20px; right: 30px; color: white; font-size: 30px; cursor: pointer; }
  .footer { text-align: center; margin-top: 40px; padding: 20px; color: #666; font-size: 13px; }
  .footer a { color: #7ec8e3; }
  @media (max-width: 1200px) {
    .card-row { grid-template-columns: 40px 120px 1fr; }
    .card-link { justify-content: flex-start; }
    .screenshot-col img { width: 100%; max-width: 390px; }
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
  <div class="review-filter">
    <label><input type="checkbox" id="hideReviewed" onchange="filterCards()"> Hide reviewed</label>
    <label><input type="checkbox" id="showOnlyUnreviewed" onchange="filterCards()"> Unreviewed only</label>
    <div class="status-filter">
      <select id="statusFilter" onchange="filterCards()">
        <option value="all">All statuses</option>
        <option value="not-reviewed">Not reviewed</option>
        <option value="approved">Approved</option>
        <option value="needs-changes">Needs changes</option>
      </select>
    </div>
    <span id="reviewCounter" class="review-counter">0 / 0 reviewed</span>
  </div>
</div>

<div class="reviewer-bar" id="reviewerBar">
  <label>👤 Reviewer:</label>
  <span id="reviewerDisplay" style="display:none"><span class="reviewer-name" id="reviewerName"></span></span>
  <input type="text" id="reviewerInput" placeholder="Enter your GitHub username..." onkeydown="if(event.key==='Enter')setReviewer()">
  <button onclick="setReviewer()" id="reviewerSetBtn">Set</button>
  <button onclick="changeReviewer()" id="reviewerChangeBtn" style="display:none">Change</button>
  <span style="color:#555">|</span>
  <span id="tokenStatus" style="font-size:13px"></span>
  <input type="password" id="tokenInput" placeholder="GitHub PAT (repo scope)..." style="width:220px;font-size:12px" onkeydown="if(event.key==='Enter')setToken()">
  <button onclick="setToken()" id="tokenSetBtn" title="Fine-grained PAT with Contents:write on this repo">Save Token</button>
  <button onclick="removeToken()" id="tokenRemoveBtn" style="display:none">Remove Token</button>
  <span style="color:#555">|</span>
  <button onclick="forceSyncNow()" title="Force sync to GitHub now">Sync</button>
  <button onclick="exportReviewData()" title="Export review data as JSON">Export</button>
  <span id="syncStatus" style="font-size:12px;color:#888"></span>
</div>

<details class="setup-guide">
  <summary>Reviewer Setup Guide (one-time)</summary>
  <div class="guide-content">
    <p>Your review status and notes persist across page updates and work on any browser/device once synced.</p>
    <ol>
      <li><strong>Enter your GitHub username</strong> in the Reviewer field above and click <strong>Set</strong>.</li>
      <li>
        <strong>Create a fine-grained GitHub PAT</strong> for syncing reviews to the repo:
        <ol type="a">
          <li>Go to <a href="https://github.com/settings/tokens?type=beta" target="_blank">GitHub Settings &rarr; Fine-grained tokens</a></li>
          <li>Click <strong>Generate new token</strong></li>
          <li>Name: <code>AC Design Review</code>, Expiration: 90 days</li>
          <li>Repository access: <strong>Only select repositories</strong> &rarr; search for <code>AdaptiveCards-Mobile</code> &rarr; select <code>VikrantSingh01/AdaptiveCards-Mobile</code></li>
          <li>Permissions &rarr; Repository permissions &rarr; <strong>Contents: Read and write</strong> (everything else: No access)</li>
          <li>Click <strong>Generate token</strong> and copy it</li>
        </ol>
      </li>
      <li><strong>Paste the token</strong> into the PAT field above and click <strong>Save Token</strong>.
        <span class="step-note">The token is stored in your browser only, never sent to any server other than github.com.</span>
      </li>
    </ol>
    <p><strong>How it works:</strong> Reviews save to your browser instantly. With a token configured, they also auto-sync (after 5s) to <code>reviews/{username}.json</code> on the <code>gh-pages</code> branch via a GitHub Actions workflow. On page load, remote reviews are fetched and merged with local data so your feedback survives catalog updates, browser changes, and device switches.</p>
    <p><strong>Without a token:</strong> Reviews still work but are stored in your browser's localStorage only. Use the <strong>Export</strong> button to save a JSON backup.</p>
  </div>
</details>

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
    echo "  { name: \"$display_name\", screenshot: \"$name\", category: \"Visualizer Screen\", jsonUrl: \"\", isApp: true, ios: $ios_exists, android: $android_exists }," >> "$OUTPUT_HTML"
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
  const hideReviewed = document.getElementById('hideReviewed').checked;
  const showOnlyUnreviewed = document.getElementById('showOnlyUnreviewed').checked;
  const statusFilter = document.getElementById('statusFilter')?.value || 'all';
  const reviewed = getReviewedSet();

  let filtered = CATALOG_DATA;
  if (categoryFilter !== 'all') {
    filtered = filtered.filter(c => c.category === categoryFilter);
  }
  if (search) {
    filtered = filtered.filter(c => c.name.toLowerCase().includes(search));
  }
  if (hideReviewed || showOnlyUnreviewed) {
    filtered = filtered.filter(c => !reviewed.has(c.screenshot));
  }
  if (statusFilter !== 'all') {
    filtered = filtered.filter(c => getCardStatus(c.screenshot) === statusFilter);
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
    'Visualizer Screen',
    'Teams Official',
    'Official Samples',
    'Element Samples',
    'Root',
    'Templates',
    'Host Configs',
    'Versioned v1.5',
    'Versioned v1.6'
  ];

  // Visualizer Screen: custom item order (Gallery, Performance, More, Settings first)
  const appScreenOrder = ['Gallery', 'Performance', 'More', 'Settings'];
  if (groups['Visualizer Screen']) {
    groups['Visualizer Screen'].sort((a, b) => {
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
      const label = cat === 'Visualizer Screen' ? 'Visualizer Screens' : cat + ' (' + groups[cat].length + ')';
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

    const status = getCardStatus(card.screenshot);
    const note = getCardNote(card.screenshot);
    const statusClass = status !== 'not-reviewed' ? ` status-${status}` : '';
    const checkedAttr = status !== 'not-reviewed' ? ' checked' : '';

    html += `<div class="card-row${missing}${statusClass}" data-category="${card.category}" data-screenshot="${card.screenshot}">
      <div class="review-col">
        <input type="checkbox" class="review-check" title="Mark as reviewed" ${checkedAttr} onchange="quickToggleReview('${card.screenshot}', this)">
      </div>
      <div class="status-col">
        <select class="status-select ${status}" onchange="setCardStatus('${card.screenshot}', this.value, this)" title="Review status">
          <option value="not-reviewed"${status==='not-reviewed'?' selected':''}>Not reviewed</option>
          <option value="approved"${status==='approved'?' selected':''}>✓ Approved</option>
          <option value="needs-changes"${status==='needs-changes'?' selected':''}>✗ Needs changes</option>
        </select>
        <textarea class="note-input" placeholder="Add note..." rows="1" onchange="setCardNote('${card.screenshot}', this.value)" onfocus="this.rows=3" onblur="if(!this.value)this.rows=1">${note}</textarea>
      </div>
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

// === Config ===
const REVIEWER_KEY = 'ac-design-reviewer';
const REVIEW_DATA_KEY = 'ac-design-review-data';
const TOKEN_KEY = 'ac-design-github-token';
const REPO = 'VikrantSingh01/AdaptiveCards-Mobile';
let syncTimer = null;
let syncStatus = 'idle'; // idle, syncing, synced, error

// === Reviewer identity ===
function getCurrentReviewer() { return localStorage.getItem(REVIEWER_KEY) || ''; }

function setReviewer() {
  const input = document.getElementById('reviewerInput');
  const name = input.value.trim().replace(/[^a-zA-Z0-9_-]/g, '');
  if (!name) return;
  localStorage.setItem(REVIEWER_KEY, name);
  updateReviewerUI();
  fetchRemoteReviews().then(() => { renderCatalog(); updateReviewCounter(); });
}

function changeReviewer() {
  localStorage.removeItem(REVIEWER_KEY);
  updateReviewerUI();
  renderCatalog();
}

function updateReviewerUI() {
  const reviewer = getCurrentReviewer();
  const display = document.getElementById('reviewerDisplay');
  const input = document.getElementById('reviewerInput');
  const setBtn = document.getElementById('reviewerSetBtn');
  const changeBtn = document.getElementById('reviewerChangeBtn');
  const nameEl = document.getElementById('reviewerName');
  if (reviewer) {
    display.style.display = '';
    nameEl.textContent = '@' + reviewer;
    input.style.display = 'none';
    setBtn.style.display = 'none';
    changeBtn.style.display = '';
  } else {
    display.style.display = 'none';
    input.style.display = '';
    input.value = '';
    setBtn.style.display = '';
    changeBtn.style.display = 'none';
  }
}

// === GitHub token ===
function getToken() { return localStorage.getItem(TOKEN_KEY) || ''; }

function setToken() {
  const input = document.getElementById('tokenInput');
  const val = input.value.trim();
  if (val) localStorage.setItem(TOKEN_KEY, val);
  input.value = '';
  updateTokenUI();
}

function updateTokenUI() {
  const hasToken = !!getToken();
  const indicator = document.getElementById('tokenStatus');
  const input = document.getElementById('tokenInput');
  const setBtn = document.getElementById('tokenSetBtn');
  const removeBtn = document.getElementById('tokenRemoveBtn');
  if (hasToken) {
    indicator.textContent = '🔑 Token set';
    indicator.style.color = '#2ecc71';
    input.style.display = 'none';
    setBtn.style.display = 'none';
    removeBtn.style.display = '';
  } else {
    indicator.textContent = '⚠ No token (reviews saved locally only)';
    indicator.style.color = '#e67e22';
    input.style.display = '';
    setBtn.style.display = '';
    removeBtn.style.display = 'none';
  }
}

function removeToken() {
  localStorage.removeItem(TOKEN_KEY);
  updateTokenUI();
}

// === Local review data (write-through cache) ===
function getAllReviewData() {
  try { return JSON.parse(localStorage.getItem(REVIEW_DATA_KEY) || '{}'); }
  catch { return {}; }
}

function saveAllReviewData(data) {
  localStorage.setItem(REVIEW_DATA_KEY, JSON.stringify(data));
}

function getReviewerData() {
  const reviewer = getCurrentReviewer();
  if (!reviewer) return {};
  return getAllReviewData()[reviewer] || {};
}

function getCardStatus(screenshot) {
  return getReviewerData()[screenshot]?.status || 'not-reviewed';
}

function getCardNote(screenshot) {
  return getReviewerData()[screenshot]?.note || '';
}

function setCardStatus(screenshot, status, selectEl) {
  const reviewer = getCurrentReviewer();
  if (!reviewer) { alert('Please set your GitHub username first.'); if (selectEl) selectEl.value = 'not-reviewed'; return; }
  const allData = getAllReviewData();
  if (!allData[reviewer]) allData[reviewer] = {};
  if (!allData[reviewer][screenshot]) allData[reviewer][screenshot] = {};
  allData[reviewer][screenshot].status = status;
  allData[reviewer][screenshot].updatedAt = new Date().toISOString();
  saveAllReviewData(allData);
  const row = selectEl?.closest('.card-row');
  if (row) {
    row.classList.remove('status-approved', 'status-needs-changes');
    if (status !== 'not-reviewed') row.classList.add('status-' + status);
  }
  if (selectEl) selectEl.className = 'status-select ' + status;
  const checkbox = row?.querySelector('.review-check');
  if (checkbox) checkbox.checked = status !== 'not-reviewed';
  updateReviewCounter();
  scheduleSyncToGitHub();
}

function setCardNote(screenshot, note) {
  const reviewer = getCurrentReviewer();
  if (!reviewer) return;
  const allData = getAllReviewData();
  if (!allData[reviewer]) allData[reviewer] = {};
  if (!allData[reviewer][screenshot]) allData[reviewer][screenshot] = {};
  allData[reviewer][screenshot].note = note;
  allData[reviewer][screenshot].updatedAt = new Date().toISOString();
  saveAllReviewData(allData);
  scheduleSyncToGitHub();
}

function quickToggleReview(screenshot, checkbox) {
  setCardStatus(screenshot, checkbox.checked ? 'approved' : 'not-reviewed', null);
  renderCatalog();
}

function getReviewedSet() {
  const data = getReviewerData();
  return new Set(Object.keys(data).filter(k => data[k].status && data[k].status !== 'not-reviewed'));
}

function isReviewed(name) { return getReviewedSet().has(name); }

function updateReviewCounter() {
  const reviewed = getReviewedSet();
  const total = CATALOG_DATA.length;
  const count = CATALOG_DATA.filter(c => reviewed.has(c.screenshot)).length;
  const el = document.getElementById('reviewCounter');
  if (el) el.textContent = count + ' / ' + total + ' reviewed';
}

// === Remote fetch (read from gh-pages, no auth needed) ===
async function fetchRemoteReviews() {
  try {
    const resp = await fetch('./reviews/_index.json', { cache: 'no-store' });
    if (!resp.ok) return;
    const index = await resp.json();
    const allData = getAllReviewData();
    for (const reviewer of (index.reviewers || [])) {
      try {
        const r = await fetch(`./reviews/${reviewer}.json`, { cache: 'no-store' });
        if (!r.ok) continue;
        const remote = await r.json();
        if (!remote.reviews) continue;
        // Merge: remote wins unless local entry is newer
        const local = allData[reviewer] || {};
        for (const [key, remoteEntry] of Object.entries(remote.reviews)) {
          const localEntry = local[key];
          if (!localEntry || (remoteEntry.updatedAt && (!localEntry.updatedAt || remoteEntry.updatedAt > localEntry.updatedAt))) {
            local[key] = remoteEntry;
          }
        }
        allData[reviewer] = local;
      } catch {}
    }
    saveAllReviewData(allData);
  } catch {}
}

// === Sync to GitHub (write via repository_dispatch) ===
function scheduleSyncToGitHub() {
  if (syncTimer) clearTimeout(syncTimer);
  syncTimer = setTimeout(syncToGitHub, 5000);
  setSyncStatus('pending');
}

async function syncToGitHub() {
  const token = getToken();
  const reviewer = getCurrentReviewer();
  if (!token || !reviewer) return;
  setSyncStatus('syncing');
  try {
    const data = getReviewerData();
    const payload = { reviewer, reviews: data, syncedAt: new Date().toISOString() };
    const resp = await fetch(`https://api.github.com/repos/${REPO}/dispatches`, {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${token}`, 'Accept': 'application/vnd.github+json' },
      body: JSON.stringify({ event_type: 'sync-review', client_payload: { reviewer, review_data: JSON.stringify(payload) } })
    });
    if (resp.status === 204) {
      setSyncStatus('synced');
    } else {
      console.error('Sync failed:', resp.status);
      setSyncStatus('error');
    }
  } catch (e) {
    console.error('Sync error:', e);
    setSyncStatus('error');
  }
}

function setSyncStatus(status) {
  syncStatus = status;
  const el = document.getElementById('syncStatus');
  if (!el) return;
  const labels = { idle: '', pending: '⏳ Saving...', syncing: '🔄 Syncing to GitHub...', synced: '✅ Synced', error: '❌ Sync failed' };
  el.textContent = labels[status] || '';
  if (status === 'synced') setTimeout(() => { if (syncStatus === 'synced') setSyncStatus('idle'); }, 3000);
}

function forceSyncNow() {
  if (syncTimer) clearTimeout(syncTimer);
  syncToGitHub();
}

function exportReviewData() {
  const reviewer = getCurrentReviewer();
  if (!reviewer) { alert('Set your GitHub username first.'); return; }
  const data = getReviewerData();
  const blob = new Blob([JSON.stringify({ reviewer, reviews: data, exportedAt: new Date().toISOString() }, null, 2)], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url; a.download = `review-${reviewer}-${new Date().toISOString().slice(0,10)}.json`;
  a.click();
  URL.revokeObjectURL(url);
}

// === Init ===
init();
updateReviewerUI();
updateTokenUI();
fetchRemoteReviews().then(() => { renderCatalog(); updateReviewCounter(); });
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
