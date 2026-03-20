# Design Review Learnings

This file is read by the review agent at the start of every iteration. It accumulates knowledge across iterations to avoid repeating mistakes and reduce noise.

Last updated: 2026-03-19 (iteration 15 review + learnings update, design-catalog-20260319-162916)

---

## 1. False Positives to Skip

- **SingleColumnFlowLayout flagged as broken**: This card is intentionally single-column on both platforms. Do not report it as a flow layout failure.
- **Visualizer app screen differences** (`_app-gallery`, `_app-settings`, `_app-editor`, `_app-more`, `_app-bookmarks`, `_app-performance`): These are sample app UI, not card rendering. Feature differences between iOS/Android sample apps are expected and out of scope for parity review.
- **SimpleFallback pill badges vs plain text** (Issue #42): Styling of unknown-element fallback is platform-specific. Not a card rendering parity issue — skip unless functional behavior differs.
- **Checkbox vs Toggle for multi-select** (Issue #21): Already documented as intentional platform difference (section 4). Do not report as P1 — only flag if selection state or data binding behavior differs functionally.
- **Input field styling systematic differences** (Issue #28): Underline vs rectangular borders, trailing icons, chevron styles are all platform-native input styling. Already documented in section 4. Do not report as P2 unless functional behavior differs.
- **Progress indicator spinner style** (Issue #33): Was initially P1, reclassified to P2, then actively aligned in `6609b48`/`2fba5e5`/`fd32220`. If future reviews re-flag minor spinner style differences, skip — these have been intentionally aligned to arc-based style.
- **Accordion row styling** (Issue #44): Both platforms aligned to flat divider style in `500338b`/`1783c7b`. Do not re-flag minor chrome differences as parity issues.
- **StringResources.Invalid.* cards** (all 4 variants + base): These cards intentionally test display of invalid `${rs:hello}` syntax (missing colon, case mismatch, etc.). The curly brackets are the expected rendered output. Do not report as template failures.
- **Tab set bar background** (Issue #32): Both platforms aligned in `cb0bb77`/`3fa83ae`. Minor tab indicator style differences (underline vs fill) are platform-native. Skip unless functional behavior differs.
- **DataGrid header text and row styling** (Issue #36): Aligned in `ca020a8`/`06078e6`. Minor remaining cell border differences are acceptable.
- **ProgressBar track styling** (Issue #48): Track tint and end-cap dot differences are platform-native rendering. Skip unless progress value or label rendering differs functionally.
- **Toggle switch positioning** (Issue #37): Both platforms aligned in `35c8135`. Minor platform-native toggle chrome (iOS pill vs Android Material) is expected. Skip unless functional behavior differs.
- **Image horizontal alignment** (Issue #38): Both platforms aligned in `eb11ec2`. Minor size differences from font/layout metrics are acceptable. Skip unless functional behavior differs.
- **Date off-by-1-day timezone** (Issue #29): FIXED in `eb1914b` (iOS) and `7b4a124` (Android). Do not re-report date off-by-one issues — both platforms now use UTC-consistent parsing.
- **Overflow button glyph "..." vs "--"** (Issue #31): P2 fix agent confirmed both platforms already use `\u2026` (ellipsis) — the visual difference was misidentified in review screenshots. Skip in future reviews.
- **code-block curly brackets** (OCR false positive): The code-block card intentionally displays Swift code containing `{` `}`. OCR detects these as "curly brackets" but they are legitimate code content, not unresolved template expressions. Skip in future OCR scans.
- **StringResources.Invalid.1-4 unresolved expressions** (OCR false positive): Cards named "Invalid" intentionally use invalid `${rs:...}` string resource references to test graceful degradation. The raw expressions ARE the expected output. Skip in future OCR scans.
- **Android `_app-*` screenshots showing "Empty JSON string"**: These are sample app screens (gallery, settings, etc.), not card renders. The app screens don't have card JSON to load. Already documented above — continue to skip.
- **Template ImageGallery image differences** (Issue #50): Template engines are identical on both platforms; image differences come from unstable external image URLs resolving differently. Not a code issue — skip unless template logic differs.
- **Bookmarks page differences** (Issue #56): iOS uses swipe gestures, Android uses tap — these are platform-native interaction patterns. Not a parity issue.
- **Performance page layout** (Issue #57): Already structurally aligned between platforms. Minor visual differences are acceptable.
- **OCR false positives — canonical list**: The following cards trigger OCR curly bracket / "fail" detection but are intentional content. Skip in all future OCR scans: (1) **code-block** — Swift code with `{}`, (2) **Template.DataBinding** — literal `{hello}` text, (3) **Container.ScrollableSelectableList** — URL params `{aParameter=true}`, (4) **Input.ChoiceSet.FilteredStyle.TestCard** — "Validation should fail" description, (5) **StringResources.Invalid.1-4** — intentionally invalid `${rs:}` expressions. Only flag OCR results for card names NOT on this list.
- **Screenshot size ratio differences due to screen density**: iOS screenshots are consistently 2-5x larger than Android due to iPhone 3x retina scaling vs Android device density. A 300%+ ratio does NOT indicate a rendering issue — only investigate when the ratio is extreme (>600%) or when absolute Android size is very small (<60KB, suggesting error screen).
- **Carousel showing different images on iOS vs Android**: Confirmed false positive 4+ times. Both platforms use identical `initialPage ?? 0` logic. The `carousel.json` uses `picsum.photos?random=N` (non-deterministic) + auto-timer causes different visible pages at capture time. Only flag if carousel structure (dots, navigation, text) differs — do NOT re-report image content differences.
- **Compound button styling divergence** (Issue #4): FIXED in prior commit `d095c3f` (solid backgrounds and icon mapping). Review re-flagged as "Confirmed" but was already resolved. Skip in future reviews unless regression detected.
- **Action button grid column count 2 vs 3** (Issue #7): FIXED in prior commit `c763109` (iOS 3-column layout). Review re-flagged as "Confirmed" but was already resolved. Skip in future reviews.
- **iOS markdown raw bold markers in list items** (Issue #6): FIXED in prior commits `e279c8d` (parser decomposition) + `a3b9edc` (inline parsing). Review re-flagged as "Confirmed" but was already resolved.
- **Progress bar trailing green dot** (Issue #15): FIXED in prior commit `ac2e082` (`drawStopIndicator = {}`). Review re-flagged as "Confirmed" but was already resolved.
- **weather-compact temperature symbol**: Both platforms render "°F" correctly. Review agent misread as "oF" vs "℉" but at-resolution screenshots show identical rendering. False positive.
- **NestedFlowLayout icon style difference**: SF Symbols (dotted/filled) vs Material Icons (outlined) is a known intentional platform difference. Do not report.
- **Badge icon spacing in versioned-v1.5-badge**: Minor spacing difference in badge icons is within acceptable platform tolerance. Do not report as parity issue.
- **Media play button overlay styling** (v1.6-Media, v1.6-Media.Sources): FIXED in `fc8f5d84` (Android aligned to iOS overlay style). Both platforms now use matching play button styling. Skip in future reviews unless regression detected.
- **Tab set styling filled vs underline** (Issue #13): Already aligned per prior learnings. Remaining differences (filled background vs underline indicator) are platform-native tab styling. Do not flag as parity issue.
- **Popover auto-expanded on Android vs collapsed on iOS** (Issue #11): Low confidence — likely a screenshot capture state artifact. The popover/ShowCard may have been toggled before capture on Android. Verify runtime behavior before fixing; do not treat screenshot state differences as rendering bugs.
- **NestedFlowLayout column breakpoint differences** (Issue #18): Root cause is CompoundButton internal sizing, not FlowLayout logic. FlowLayout is already aligned between platforms. Skip unless FlowLayout algorithm itself differs.
- **ExpenseReport "Pending" badge missing on Android** (Issue #19): Misidentified as a Badge element — it is actually an Image element. The missing "Pending" indicator traces to image loading, not badge rendering. Reclassify to ImageView issue in future reports.
- **CompoundButton v1.6 missing chevrons** (Issue #5 from catalog 20260315-122222): FIXED in prior commit `985874d`. Review re-flagged as "Confirmed" but P3-1 agent verified chevrons are already unconditionally rendered at `CompoundButtonView.swift:100`. Skip in future reviews.
- **Multi-select compact rendering divergence** (Issue #6 from catalog 20260315-122222): Already fixed — iOS `ChoiceSetInputView.swift` renders dropdown `Menu` for multi-select compact. Review worklist referenced non-existent file `ChoiceSetView.swift`. Skip unless regression detected.
- **ActionModeTestCard Android content truncation** (Issue #9 from catalog 20260315-122222): FIXED in `efc20cc` — added `verticalScroll` to Android card body. Skip unless regression detected.
- **Container.Nested.Flow deep-link** (Issue #2 from catalog 20260315-122222): FIXED in `4e77257` — Base64 URL-safe encoding replaces failed %2E percent-encoding after 4 attempts. Skip unless regression detected.
- **FluentIcon rendering style** (Issue #10 from catalog 20260315-122222): SF Symbols vs Material Icons have inherently different aesthetics. Icon sizes aligned in `0b4df72` but remaining style differences (dot-grid fill vs outlined stroke) are platform-native. Skip unless icon sizes or visibility differ.

- **iOS markdown header sizes** (Issue #7): FIXED in `136d3b1` — H1/H2/H3 now have proper size hierarchy. Skip unless regression detected.
- **iOS container maxHeight/overflow clipping** (Issue #8): FIXED in `f6c75a3` — maxHeight enforced as hard constraint. Skip unless regression detected.
- **iOS table row backgrounds** (Issue #9): FIXED in `908ff9a` — row style backgrounds applied to non-header rows. Skip unless regression detected.
- **iOS table vertical alignment "Top" label** (Issue #5): FIXED in `c29b667` — default vertical alignment set to `.top`. Skip unless regression detected.
- **iOS Image.FitMode auto stretching** (Issue #4): FIXED in `07869b3` — auto-sized images now render at natural dimensions. Skip unless regression detected.
- **iOS ExpenseReport v1.5 missing actions** (Issue #6): FIXED in `4b50e27` — scroll frame fix ensures action buttons visible on long cards. Skip unless regression detected.
- **Android Agenda/ExpenseReport auto-column collapse** (Issues #2, #3): FIXED in `24e8041` + `bfe6cdb` — measure auto columns directly, with fallback for zero intrinsic width. Skip unless regression detected.
- **iOS progress indicator center alignment** (Issue #11): FIXED in `5d60768`. Skip unless regression detected.
- **iOS themed images center alignment** (Issue #12): FIXED in `fa7f4d0`. Skip unless regression detected.
- **iOS flight-update-table row spacing** (Issue #14): FIXED in `b0ed8bd`. Skip unless regression detected.
- **iOS targetWidth AtLeast:Narrow hides content** (Issue #13): FIXED in `62fa2b6` — defaults to narrow width category when card width is unmeasured. Skip unless regression detected.
- **iOS Agenda time column** (prev P2 #2): FIXED in `3b4d6d2` (ProportionalColumnLayout direct measurement). Skip unless regression detected.
- **iOS Expense Report Pending badge** (prev P2 #3): FIXED via same auto-column fix as Agenda. Skip unless regression detected.
- **iOS ExpenseReport v1.5 missing actions** (prev P2 #6): FIXED in `4b50e27` (scroll frame fix). Skip unless regression detected.
- **Date/Time input styling differences** (iOS plain label vs Android bordered input): This is a platform-native input styling difference (iOS HIG vs Material). Already documented in section 4. Do not report as P2.
- **DataGrid header text color** (iOS blue/accent vs Android dark): Aligned in prior commits, minor remaining color differences are acceptable per learnings. Skip.
- **Action.MenuActions button wrapping** (3 buttons per row iOS vs 2+1 Android): Button width calculation differs due to font metrics. Not a functional issue — P4 at most. Skip unless buttons are clipped.
- **iOS Image.FitMode.Contain zoomed/labels missing** (Report Issue #1): FIXED in `5e348f49` — fitMode images no longer get unconditional `maxWidth:.infinity`. However, Issue #4 in catalog 20260315-213139 shows this REGRESSED — labels missing again, image oversized. P2-1 agent in round 2 could not fix (worktree was deleted mid-session). Do NOT skip — verify in next catalog.
- **iOS Image.FitMode.Fill missing section labels** (Report Issue #5): FIXED in same commit `5e348f49` — but Issue #5 in catalog 20260315-213139 shows this REGRESSED. P2-1 agent in round 2 could not fix (worktree deleted). Do NOT skip — verify in next catalog.
- **iOS MultiColumnFlowLayout single-column** (Report Issue #2): FIXED in `49cda0e5` — `calculatedItemWidth()` now returns nil when only maxItemWidth is set, matching Android behavior. This was the 5th commit after 4 prior attempts. Skip unless regression detected.
- **iOS overflow button row placement** (Report Issue #11): Overflow "..." button sits inline on iOS vs new row on Android — this is a minor action button wrapping difference driven by platform font metrics. P4 cosmetic only. Skip unless buttons are clipped or missing.
- **iOS Carousel.ForbiddenElements text alignment** (Report Issue #12): Left-aligned on iOS vs center-aligned on Android. P4 cosmetic — forbidden element names are informational only. Skip unless element types are missing.
- **iOS CompoundButton left-edge clipping** (Issue #6 from catalog 20260315-213139): FIXED in `ea9edef3` — added explicit spacing to inner HStack. Skip unless regression detected.
- **iOS DataGrid header bold blue/centered** (Issue #11 from catalog 20260315-213139): FIXED in `69ceb888` — aligned header styling with Android (plain text, left-aligned). Skip unless regression detected.
- **iOS badge outline icons / ExtraLarge text truncation** (Issue #12 from catalog 20260315-213139): FIXED in `789e7e00` — use filled SF Symbol icons and allow ExtraLarge text wrapping. Skip unless regression detected.
- **iOS communication card text truncation** (Issue #10 from catalog 20260315-213139): Addressed in `b7d45231` — capped auto-column width to remaining space in ColumnSet layout. Further fixed in `492c507d` — corrected `isExplicitAutoSize` to return false when explicit pixel dimensions present (image column was stealing text column space). Skip unless regression detected. **Note**: `492c507d` is on unmerged branch `worktree-fix-ios-2-round-1`.
- **iOS Image.FitMode.Contain/Fill regression** (Issues #4, #5 from catalog 20260315-213139): FIXED in `bdde0e14` + `492c507d` — dedicated contain fitMode branch + isExplicitAutoSize fix. This was the 4th successful attempt after `5e348f49` (partial), two P2-1 agent failures (worktree deleted). Skip unless regression detected. **Note**: Fixes on unmerged branch `worktree-fix-ios-2-round-1`.
- **iOS SVG black rectangles/missing images** (Issue #8 from catalog 20260315-213139): FIXED in `b30cedb4` — WKWebView transparent background, direct URL loading, viewBox sizing. Skip unless regression detected. **Note**: Fix on unmerged branch `worktree-fix-ios-2-round-1`.
- **iOS CompoundButton badge fixedSize clipping** (Issue #6 from catalog 20260315-213139): FULLY FIXED across 3 commits: `4a24089b` (layoutPriority), `ea9edef3` (HStack spacing), `86662f27` (remove badge fixedSize). The third commit is the definitive fix. Skip unless regression detected. **Note**: `86662f27` on unmerged branch `worktree-fix-ios-1-round-1`.
- **iOS DataGrid header semibold weight** (Issue #11 from catalog 20260315-213139): Previously partially fixed in `69ceb888` (color + alignment). Fully fixed with `583f92b6` (removed semibold weight). Skip unless regression detected. **Note**: `583f92b6` on unmerged branch `worktree-fix-ios-1-round-1`.
- **iOS badge ExtraLarge unlimited text wrapping** (Issue #12 from catalog 20260315-213139): Previously partially fixed in `789e7e00` (filled icons + lineLimit=2). Fully fixed with `dcc40bce` (lineLimit=nil, unlimited wrapping matching Android). Skip unless regression detected. **Note**: `dcc40bce` on unmerged branch `worktree-fix-ios-1-round-1`.
- **iOS FlowLayout arrangeSubviews maxItemWidth cap** (Issue #7 from catalog 20260315-213139): FIXED in `8d4883c8` — removed maxItemWidth cap in `arrangeSubviews()`. This is the 8th commit in the FlowLayout fix saga, addressing a SEPARATE cap in the layout pass that survived all prior `calculatedItemWidth()` fixes. Skip unless regression detected. **Note**: Fix on unmerged branch `worktree-fix-ios-1-round-1`.
- **Android Agenda/FlightUpdate/ExpenseReport/FlightDetails ColumnSet truncation** (Issues #1, #2, #3, #9 from catalog 20260315-213139): FIXED in `73897919` — ProportionalColumnLayout Pass 2 now uses `maxIntrinsicWidth` for auto columns (not full `remainingWidth`), and Pass 3 always distributes proportionally even when `remainingWidth <= 0`. All 10 affected cards now render correctly. Skip unless regression detected.
- **iOS MultiColumnFlowLayout uniform grid** (Issue #7 from catalog 20260315-213139): FIXED in `1d994906` — removed the maxItemWidth cap in `arrangeSubviews` (lines 158-162) that was forcing uniform 150px tile widths. Items now use intrinsic widths matching Android asymmetric layout. Skip unless regression detected.
- **iOS Icon.Styles "Filled icon" button** (Issue #13 from catalog 20260315-213139): Was not assigned to any fix agent worklist in rounds 1-2. **FIXED in round 3** (`8c10ff46`) — added defensive `.buttonStyle(.plain)` to prevent inherited SwiftUI tinting from overriding outline button style. **Note**: Fix is on unmerged branch `worktree-fix-ios-1-round-1` — skip once merged, unless regression detected.
- **Sample app gallery cache miss ≠ rendering bug**: When cards show blank/wrong content on BOTH platforms with identical error patterns (Android "Empty JSON string", iOS stale cached card), the issue is in sample app deep-link routing, NOT card rendering. Fixed 6 times now (`fe57f87a` being latest round-3 commit, `85ee4325` round-2). Do not classify as P1 rendering issue — classify as sample app infrastructure issue. The fallback-to-direct-asset-loading pattern in `CardDetailScreen.kt` is now the canonical fix.
- **iOS ColumnSet auto-column width** (previously P1 #1): FIXED in `08a461de` — `ColumnSetView.swift:72` changed from `maxAutoWidth` to `nil` width proposal. All 15+ affected cards (Agenda, FlightUpdate, ExpenseReport, Communication columns, StockUpdate, WorkItem, FlightItinerary) now render correctly. Skip unless regression detected.
- **iOS Icon.Styles/Clickable invisible icons** (previously P2 #4, #5): FIXED in `08a461de` — `.buttonStyle(.plain)` added to `ActionSetView.swift`. Both Icon.Styles and Icon.Clickable now show icons with correct foreground colors. Skip unless regression detected.
- **Android CompoundButton lavender tint** (previously P3 #9 partial): FIXED in `08a461de` — Material3 theme defaults replaced with host-config colors in `CompoundButtonView.kt`. Skip unless regression detected.
- **iOS isExplicitAutoSize for explicit pixel dimensions** (previously part of P1 #2): FIXED in `13db8ad4` — `isExplicitAutoSize` now returns false when explicit pixel dimensions are present. Skip unless regression detected.
- **iOS SVG WKWebView opaque background** (previously part of P1 #2): PARTIALLY FIXED in `13db8ad4` — transparent background + direct URL loading for network SVGs. Data URI SVGs with complex viewBox still render as black rectangles. **UPDATE**: Further fixed in `376c3cf3` — HTML wrapper for network SVGs + light mode color scheme override. Verify in next catalog whether black rectangles are fully resolved.
- **iOS Image.FitMode.Contain/Fill missing labels** (P1 #1, catalog 20260316-074113): FIXED in `7e0adffb` — dedicated `isContainMode` branch in ImageView.swift. This is the 5th+ attempt at this fix; the dedicated branch approach (separate code path for contain/fill) is now confirmed as the correct pattern. Skip unless regression detected.
- **iOS MultiColumnFlowLayout single-column** (P1 #2, catalog 20260316-074113): Fix attempted in `6f254946` — mathematical column count calculation from maxItemWidth constraint. This is the 10th FlowLayout fix commit. Verify in next catalog — if still broken, the manual layout approach should be abandoned in favor of SwiftUI `Grid` or `Layout` protocol.
- **iOS list card numbered items truncation** (P2 #4, catalog 20260316-074113): FIXED in `eff40f7b` — root cause was nested ScrollView inside `ListView.swift`, NOT `AdaptiveCardView.swift` as the report assumed. The fix uses conditional ScrollView only when maxHeight is set. Skip unless regression detected.
- **iOS communication card text truncation** (P3 #7, catalog 20260316-074113): FIXED in `817e1063` — TextBlockView.swift was applying `frame(maxWidth: .infinity)` unconditionally, causing text in weighted columns to expand beyond allocated space. Fix makes it conditional on center/right alignment only. Skip unless regression detected.
- **iOS AreaGrid column sizing** (P3 #8, catalog 20260316-074113): FIXED in `62eda01e` — aligned AreaGridLayout.swift with Android weight-based proportional column distribution. Skip unless regression detected.
- **iOS SVG black rectangles** (P3 #6, catalog 20260316-074113): FIXED in `376c3cf3` — WKWebView HTML wrapper for network SVGs plus light mode color scheme override. Skip unless regression detected.
- **RtlTestCard Android OCR false positive**: `versioned-v1.5-RtlTestCard` triggers OCR curly bracket detection but the content is RTL layout artifacts, not template failures. Add to canonical false positive list.
- **iOS progress-indicators missing steps 3-4** (P2 #3, catalog 20260316-074113): iOS fix agent investigated and determined this is a viewport density difference, not a layout bug. The card renders all 4 steps but steps 3-4 are below the visible viewport — matching the expected behavior for a non-scrollable card. Verify in next catalog before fully skipping — if confirmed, add to intentional differences.
- **Screenshot size ratio is NOT a reliable issue indicator**: Many cards with 300%+ size ratio (edge-deeply-nested 402%, edge-empty-card 375%, Fallback.Root.Recursive 391%) render identically on both platforms. The ratio reflects iOS retina 3x scaling vs Android density, not rendering differences. Only investigate when Android absolute size is very small (<10KB suggesting blank) or ratio is extreme (>600%).
- **iOS progress-indicators steps 3-4 confirmed viewport density difference**: Catalog 20260316-121415 review confirms this is NOT a rendering bug — the card renders all steps but 3-4 are below the visible viewport. Add to intentional platform differences. Do not re-report.
- **iOS Image.FitMode.Contain/Fill labels** (prev P1): CONFIRMED FIXED in `7e0adffb`. Catalog 20260316-121415 shows both FitMode.Contain and FitMode.Cover rendering correctly with section labels visible. Skip in future reviews.
- **iOS list card truncation** (prev P2 #4): CONFIRMED FIXED in `eff40f7b`. List card renders fully in catalog 20260316-121415. Skip unless regression detected.
- **teams-official-samples-insights center-aligned labels**: iOS centers section labels while Android left-aligns. This is a symptom of the systematic text center-alignment issue (#6 in this review). Will be fixed by the ContainerView.swift alignment fix. Do not report separately.
- **teams-official-samples-issue Priority row wrapping**: Flag icon and "Critical" text on separate lines on iOS. Likely caused by the same systematic center-alignment issue or ColumnSet width allocation. Verify after issue #6 fix.
- **teams-official-samples-account missing "See more" link** (Issue #12, P4): Not assigned to any fix agent worklist in iteration 9. Low fix confidence in the report — may be an intentional platform difference (iOS may not render the ToggleVisibility target). Verify card JSON before re-dispatching. If the JSON lacks a "See more" element, this is a card content difference, not a rendering bug.
- **Android chart and area-grid smoke test failures** (bar-chart, container-area-grid-1/2, donut-chart, horizontal-bar-chart, line-chart): These Android smoke test failures are NOT caused by the iOS fix agents' commits — they are pre-existing Android sample app state issues (small screenshot size ~60KB = error screen). The fix agents only modified iOS files. Do not attribute Android smoke failures to iOS fix branches.

- **iOS SVG black rectangles** (Issue #3, catalog 20260316-121415): FIXED in `be4d1170` — WKNavigationDelegate hides webview until content loads, then fades in. This is a DIFFERENT approach from the prior `376c3cf3` fix (HTML wrapper) — it addresses small/inline SVGs that the prior fix missed. **Note**: Fix on unmerged iteration-9 branch. Skip unless regression detected.
- **iOS carousel single-page vs peek** (Issue #5, catalog 20260316-121415): FIXED in `a7f25be2` — increased page horizontal padding to match Android peek inset. **Note**: Fix on unmerged iteration-9 branch. Skip unless regression detected.
- **iOS Carousel.ForbiddenElements vertical alignment** (Issue #11, catalog 20260316-121415): FIXED in `09988e15` — `.topLeading` alignment with `maxHeight: .infinity` to fill page slot from top. **Note**: Fix on unmerged iteration-9 branch. Skip unless regression detected.
- **iOS ContainerView text center-alignment** (Issue #6, catalog 20260316-121415): FIXED in `05e70d97` — systemic fix changing ContainerView alignment from `.top` to `.topLeading`. Resolves 7+ cards. **Note**: Fix on unmerged iteration-9 branch. Skip unless regression detected.
- **iOS container-scrollable overflow clipping** (Issue #10, catalog 20260316-121415): FIXED in `d5437107` — only clips for hidden/scroll overflow, uses `clipShape(Rectangle())` for hidden. **Note**: Fix on unmerged iteration-9 branch. Skip unless regression detected.
- **iOS ContainerAreaGrid5 image misalignment** (Issue #9, catalog 20260316-121415): FIXED in `9784d18d` — `.topLeading` alignment for Grid and `.top` for fallback HStack. **Note**: Fix on unmerged iteration-9 branch. Skip unless regression detected.
- **iOS project-dashboard missing content** (Issue #1, P1, catalog 20260316-121415): FIXED in `04a3776e` — implicit columns expanded with remaining percentage. **Note**: Fix on unmerged iteration-9 branch. Skip unless regression detected.
- **iOS Table.AreaGrid text truncated** (Issue #7, catalog 20260316-121415): FIXED in same commit `04a3776e` as Issue #1 — shared root cause (AreaGrid implicit column weights). **Note**: Fix on unmerged iteration-9 branch. Skip unless regression detected.
- **iOS TableFlowLayout columns misaligned** (Issue #8, catalog 20260316-121415): FIXED in `8a05c21f` — flow items now measure at width 0 for intrinsic size. **Note**: Fix on unmerged iteration-9 branch. Skip unless regression detected.
- **iOS bar chart missing x-axis labels** (Issue #4, catalog 20260316-121415): FIXED in `118b859e` — proportional 0.8 factor. **Note**: Fix on unmerged iteration-9 branch. Skip unless regression detected.
- **iOS CompoundButton v1.6 text clipping** (Issue #5, catalog 20260316-133654): Iteration-10 fix agent addressed in `440871c5` (iteration-2 worktree). Prior fixes `ea9edef3` (HStack spacing) and `985874d` (chevron) also targeted this. **Note**: Fix on unmerged iteration-10 branch. Skip unless regression detected.
- **iOS list card excessive spacing** (Issue #10, catalog 20260316-133654): FIXED in `2b521c7b` — replaced external `.padding(.vertical, 4)` with VStack `spacing: 4` in `ListView.swift`. **Note**: Fix on unmerged iteration-10 branch. Skip unless regression detected.
- **teams-official-samples-issue Priority line break** (Issue #14, P4, catalog 20260316-133654): Blocks on issue #6 (systemic center-alignment). Will likely resolve when ContainerView alignment fix `05e70d97` is merged. Do not dispatch a separate fix agent — verify after issue #6 merge.
- **teams-official-samples-simple-event date overlay** (Issue #15, P4, catalog 20260316-133654): Blocks on issue #6 (systemic center-alignment). May resolve when ContainerView alignment fix is merged. Verify after merge before dispatching.
- **iOS table header text color** (Issue #12, P4, catalog 20260316-133654): Not assigned to any fix agent in iteration 10. Low priority — cosmetic accent vs dark color on header row. Consider as intentional styling difference if HostConfig does not specify header text color. **UPDATE (iteration 11)**: Promoted to P2 — Android explicitly applies accent color to header TextBlocks in `MediaAndTableViews.kt:202-212`. This IS a parity issue, not intentional.
- **OCR pre-scan all false positives** (iteration 11, catalog 20260318-115833): All 18 OCR-detected issues were false positives — code-block cards with intentional `{}`, StringResources cards with intentional invalid `${rs:...}` expressions, FilteredStyle card with intentional "fail" text, datagrid `Name {` column header. OCR pre-scan is useful for actual template failures but produces noise on code-display and intentional-error test cards.
- **Android deep-link screenshot capture timing** (iteration 11): 3 Android cards showed wrong card content (activity-update→TextBlock Style, stock-update→Sporting Event, cafe-menu→Book a Room). These are capture timing artifacts, not rendering bugs. The deep-link handler loads the correct card but the screenshot is captured before navigation completes. Do not report as rendering issues.
- **Carousel.NestedForbiddenElements rendering inputs** (iteration 11): Both platforms render forbidden input elements (Input.Text, Input.Number, etc.) inside the carousel. This appears to be a shared behavior — the spec says these should be suppressed, but both platforms allow them. Not a parity issue since both behave the same way. Only flag if behavior diverges between platforms.
- **Android blank renders are emulator boot/ANR artifacts, not rendering bugs** (iteration 14, catalog 20260319-111407): ~23 Android cards show Google boot splash, loading spinner, or ANR dialog. These are emulator state issues (not ready when deep-link capture began), not card rendering failures. All 23 cards render correctly on iOS. Do not report as individual rendering bugs — report as single infrastructure issue.
- **Android deep-link routing wrong-card pattern** (iteration 14): ~12 cards navigate to wrong card (e.g., inputs-with-validation→InputFormWithRTL, WeatherLarge→WeatherCompact). This is a systematic index-based lookup mismatch in `MainActivity.kt`, NOT individual card rendering bugs. Report as single routing issue. The pattern involves adjacent cards in alphabetical order being swapped.
- **edge-max-actions overflow button inline vs new row** (iteration 14): iOS fits the overflow "..." button inline on the last action row, while Android wraps it to a new row. Per prior learnings, overflow button placement is a known platform difference (documented in section 4). P4 cosmetic only — skip.
- **Carousel.ScenarioCards.Timer different initial page** (iteration 14): iOS shows page 1, Android shows page 2. Timer auto-advances carousel pages before screenshot capture. This is a capture timing artifact, not a rendering bug. Skip.
- **versioned-v1.5-NestedFlowLayout Android shows Google splash** (iteration 14): Deep link was intercepted by Chrome instead of sample app, or emulator was still booting. Infrastructure issue, not rendering. Skip.
- **iOS table header accent color** (Issue #5, iteration 15): FIXED in `2ba7fdb6` — accent color now applied to table header text by rendering directly. Prior fix `cbb76ef4` also addressed firstRowAsHeaders variant. Report still shows "Confirmed" because catalog was captured before fix landed. Skip in future reviews unless regression detected.
- **iOS CompoundButton chevron with trailing icon** (iteration 15): FIXED in `ebb2b885` — default chevron suppressed when CompoundButton has a trailing icon. Skip unless regression detected.
- **iOS CompoundButton badge horizontal overflow** (iteration 15): FIXED in `7233f07a` — removed badge `fixedSize` that caused CompoundButton horizontal overflow. This is the definitive fix for the badge fixedSize saga (prior: `4a24089b`, `ea9edef3`, `86662f27`). Skip unless regression detected.
- **Android ImageSet grid minimum height** (iteration 15): FIXED in `e48f5435` — ImageSet grid images now have minimum height. Skip unless regression detected.

- **iOS AreaGridLayoutView — UIScreen.main.bounds.width → custom Layout** (iteration 15, `a1cbb37a`): FIXED by replacing SwiftUI Grid + UIScreen-based column widths with a custom `AreaGridRow` Layout that receives actual proposed width from parent. THREE approaches failed first: (1) equal-width Grid columns (compiled but lost image — `resolveColumnWeightValues()` was added but NEVER CALLED), (2) GeometryReader (collapsed height in table cells), (3) HStack + `.layoutPriority(weight)` (text took all space, image disappeared). Only the custom Layout protocol approach worked because it receives the actual container width in `sizeThatFits(proposal:)` and distributes it proportionally in `placeSubviews`. **Key lesson**: When replacing UIScreen.main.bounds.width in a rendering view, the ONLY reliable approach is a custom `Layout` that reads `proposal.width`. Grid, GeometryReader, and layoutPriority all fail in nested contexts.
- **iOS AreaGridLayoutView — dead code regression** (iteration 15): Fix agent added 50-line `resolveColumnWeightValues()` function but never wired it up. Code compiled. All 17 AreaGrid cards silently regressed to equal-width columns. **Key lesson**: After every fix, grep for each new function name to verify it has callers. `swift build` success does NOT mean the fix works.
- **SwiftUI `.layoutPriority(N)` is NOT `Modifier.weight(N)`** (iteration 15): Two attempts used `.layoutPriority(Double(weight))` expecting proportional width like Compose `Modifier.weight()`. layoutPriority only controls SHRINK/GROW ORDER, not proportional RATIO. In an HStack with two `maxWidth: .infinity` views, the higher-priority view takes ALL space. For proportional distribution, use a custom `Layout` (see `AreaGridRow` and `WeightedRow`).

## 2. Failed Fix Patterns

- **iOS FlowLayoutView height: clamped width is not enough — must re-measure at actual width**: First fix attempt (`a94e5af`) re-measured flow items at clamped width. This was insufficient — a second commit (`b7adf21`) was needed to re-measure at actual rendered width for correct wrapped height. **Lesson**: Flow layout height must be computed at the final rendered width, not a pre-clamped estimate.

- **Fixing flow layout on one platform can regress the other**: Fixing iOS Table.Flow (multi-column) caused Android Table.Flow to regress to single-column (Issue #7). **Lesson**: When fixing flow/table/layout on one platform, always verify the equivalent card on the other platform before merging.

- **P0 fix agent hit image dimension limit**: Agent session failed with "image exceeds dimension limit for many-image requests" — unable to complete visual verification. **Lesson**: Fix agents should limit screenshot verification to 3-4 cards per session, or use OCR text checks instead of full screenshot comparison.

- **iOS BadgeView needed iterative layout refinement**: Initial fix (`8f75acd` in earlier round) didn't fully resolve badge rendering. Required follow-up (`0a3efcc`) switching from double-`fixedSize` chain to single `fixedSize`. Badge still listed as P0 after round-1, meaning the `fixedSize` fix alone is insufficient — the root cause likely involves the badge's intrinsic content size or parent container constraints, not just the fixedSize modifier. **Lesson**: SwiftUI `fixedSize()` composition is fragile — prefer a single `fixedSize(horizontal: true, vertical: false)` over chaining multiple modifiers. But also verify the underlying view reports correct intrinsic size.

- **iOS FlowLayoutView maxItemWidth fix required FOUR commits**: First commit (`41b698d`) used maxItemWidth as a cap instead of exact width. Second commit (`635b0ea`) added multi-column logic when only maxItemWidth is specified. Third commit (`c8bc59a`) computed the actual multi-column grid dimensions correctly. Fourth commit (`5039cc2`) switched to intrinsic width for flow items when only maxItemWidth is specified — the grid dimensions were correct but items still measured wrong without using their intrinsic size. **Lesson**: FlowLayout sizing has four independent concerns — item width capping, column count determination, grid dimension computation, and per-item intrinsic width measurement. Each can appear "fixed" in isolation but the layout only works when all four are correct. When fixing flow/grid layouts, verify the full pipeline (width → columns → grid → item measurement) end-to-end rather than patching incrementally.

- **Android ColumnSetView auto-column fix needed refinement for zero-intrinsic-width edge case**: Initial fix (`24e8041`) switched from `maxIntrinsicWidth` to direct measurement, but auto columns with zero intrinsic width (e.g., images not yet loaded) still collapsed. Follow-up `bfe6cdb` added a fallback to direct measurement when intrinsic width reports zero. **Lesson**: Compose `maxIntrinsicWidth` returns 0 for some content types (images without explicit size, lazily-loaded content). Auto-column measurement must handle the zero case explicitly — either by falling back to direct measurement or by enforcing a minimum width.

- **iOS MultiColumnFlowLayout — 6 commits still insufficient, 7th commit resolved**: Commits `41b698d`, `635b0ea`, `c8bc59a`, `5039cc2`, `49cda0e5`, `6c4c9510` all attempted to fix multi-column flow layout but the 5th-6th commits only fixed `calculatedItemWidth()` — the layout pass in `arrangeSubviews()` (lines 158-162) STILL capped item widths to maxItemWidth. **7th commit `1d994906` finally resolved it** by removing the maxItemWidth cap in `arrangeSubviews()`, matching Android where items use intrinsic widths. **Lesson**: FlowLayout has FIVE independent sizing stages — `calculatedItemWidth()`, column count, grid dimensions, item measurement, and `arrangeSubviews()` width capping. All prior fixes targeted stages 1-4 but missed stage 5. **Key takeaway**: When a calculated value is correct but the visual output is wrong, the value may be overridden downstream in the layout pass. Always trace from calculation through to final frame assignment.

- **iOS ImageView unconditional maxWidth:.infinity breaks column layouts**: `ImageView.swift:158` applies `.frame(maxWidth: .infinity)` unconditionally, causing images in proportionally-distributed columns to expand beyond their allocated width. This is the root cause for both the communication card (image column too large) and Image.FitMode.Contain (image fills entire card). **Lesson**: Image sizing must be contextual — check if the image is in a constrained column before expanding to fill width.

- **iOS Image.FitMode fix `5e348f49` insufficient for explicit pixel dimensions**: The `needsFullWidthFrame` guard prevents fitMode images from getting `maxWidth:.infinity`, but cards using explicit `width: "200px"` + `height: "auto"` + `fitMode: "contain"` still render oversized. The explicit pixel width code path (line ~120) may bypass the fitMode guard entirely. **Lesson**: The fix must trace the FULL rendering path for images with both explicit dimensions AND fitMode — the explicit pixel dimension handler and the fitMode frame modifier interact in ways the initial fix didn't address. This is the second regression of this issue. **UPDATE (round 2)**: P2-1 agent assigned to fix this had its worktree deleted mid-session by merge cleanup — produced zero output in both rounds. **UPDATE (round 3)**: FIXED in `bdde0e14` — added dedicated `isContainMode` branch in ImageView.swift success handler that handles each dimension combination explicitly (both, width-only, height-only, none). Also fixed `isExplicitAutoSize` in `492c507d` to return false when explicit pixel dimensions are present. **Key lesson**: FitMode with explicit dimensions needs a SEPARATE code path, not a conditional guard on the existing path. The 4th attempt succeeded by adding a new branch rather than patching the existing one. **Note**: Fix is on unmerged branch `worktree-fix-ios-2-round-1` — verify after merge.

- **iOS CompoundButton layoutPriority(-1) clips title text**: `CompoundButtonView.swift:70` uses `.layoutPriority(-1)` on title text, causing SwiftUI to deprioritize it when the badges `.fixedSize()` competes for space. Result: first characters of title text get clipped. **Lesson**: Never use negative layoutPriority on user-visible text — use positive priority or restructure the HStack instead.

- **Android $root template fix was insufficient**: Fix `0dba58d` allowed template expansion with empty `$data` items, but the actual `$root` keyword resolution in expressions still fails — `Template.DataBinding` still dumps raw JSON instead of resolving `$root.employee.id`. **Lesson**: The `$root` fix needs to target the expression evaluator's keyword resolution (likely in `ExpressionParser.kt` or `TemplateEngine.kt`), not just the data binding entry point.

- **P1 fix agent had very low throughput in round 1**: Out of 22 P1 issues, only 3 peripheral fixes were made. **Lesson**: P1 worklists should prioritize the highest-impact issues first and include explicit file paths + code snippets to reduce agent search time. **Update (round 2)**: Round 2 P1 agent was much more productive (7+ core fixes) — confirming that explicit file paths and fix hints in worklists dramatically improve agent throughput.

- **iOS long card truncation fix — removing inner ScrollView**: Fix `6182412` removed an inner `ScrollView` inside `AdaptiveCardView.swift` that was causing nested scroll clipping — content was being laid out in an unconstrained scroll context but then clipped by the outer container. **Lesson**: Do not nest ScrollViews inside card rendering; let the outermost container handle scrolling. If the card exceeds viewport, the outer scroll context should expand, not an inner one.

- **Android $root template — stripping $data is still insufficient**: Fix `5f0f871` strips `$data` directive from `expandDictionary` output, but the `$root` keyword in expressions (`$root.employee.id`) still doesn't resolve correctly — Template.DataBinding still dumps raw JSON. **Lesson**: The fix needs to be in the expression evaluation path that resolves `$root` to the top-level data context, not in the dictionary expansion phase. Look at `ExpressionParser.kt` or `ExpressionEvaluator.kt` for where variable references are resolved.

- **iOS FlowLayout 9th fix attempt (`08a461de`) still insufficient for MultiColumnFlowLayout**: Added `min(itemWidth, maxW)` cap in `arrangeSubviews()` when `dynWidth == nil`, but iOS still renders single-column. The cap applies in `sizeThatFits()` but the `arrangeSubviews()` function may still use a different code path to compute final frame widths. **Lesson**: FlowLayout now has SIX identified sizing stages: (1) `calculatedItemWidth()`, (2) column count, (3) grid dimensions, (4) item measurement mode, (5) `arrangeSubviews()` width capping, and (6) final CGRect frame assignment. The 9th fix targeted stage 5 in `sizeThatFits` but may not have propagated to stage 6 in `arrangeSubviews`. **Recommendation**: At this point, consider replacing the manual frame computation with SwiftUI's built-in `Grid` layout or a cleaner `Layout` protocol implementation that doesn't have 6 independent sizing stages to keep in sync.

- **iOS FlowLayout 10th fix attempt (`6f254946`) — mathematical column count approach**: Used `floor(containerWidth / maxItemWidth)` to compute column count directly instead of relying on the existing sizing pipeline. This is a fundamentally different approach from the 9 prior attempts that each patched a different stage of the pipeline. **Lesson**: After 9 incremental fixes all targeting different stages of the same broken pipeline, the correct approach was to bypass the pipeline entirely with a direct mathematical calculation. **Key takeaway**: When a multi-stage pipeline has been patched 5+ times and the issue persists, the pipeline design itself is the problem — replace it with a simpler direct computation rather than continuing to patch stages.

- **iOS list card truncation was in ListView.swift, not AdaptiveCardView.swift**: Report Issue #4 attributed the list card truncation to card body height clipping in `AdaptiveCardView.swift` (same root cause as progress-indicators). Fix agent traced the actual cause to a nested ScrollView inside `ListView.swift` — the ScrollView was wrapping list content and causing inner clipping, NOT the card body frame. **Lesson**: When multiple truncation issues share symptoms (bottom content missing), do NOT assume they share the same root cause. The list card has its own ScrollView in ListView.swift that the progress-indicators card does not.

- **iOS communication text truncation was unconditional maxWidth:.infinity, not lineLimit**: Report Issue #7 attributed text truncation to a `lineLimit` or `truncationMode` in TextBlockView.swift. The actual cause was `frame(maxWidth: .infinity)` being applied unconditionally, which caused text in weighted columns to expand beyond its allocated space (text measures at full width, gets truncated when rendered in column). **Lesson**: When text is truncated in a column layout, check frame modifiers (`maxWidth`) before checking text-specific modifiers (`lineLimit`). The `maxWidth:.infinity` pattern has now caused THREE separate issues: (1) images expanding beyond columns, (2) fitMode images pushing labels off-screen, (3) text expanding beyond weighted columns.

- **Android fix agent produced 0 commits again (empty log, 6th occurrence)**: Android agent was assigned 2 issues (P2 Action.MenuActions + P3 AreaGrid) but log file is empty — 0 commits. This is the 6th time an agent has produced an empty log. **Lesson**: The platform-split approach (iOS agent vs Android agent) means the Android agent has fewer issues but still fails to start. The worklist had Android AreaGrid as issue #8 but iOS agent fixed this from the iOS side (`62eda01e`), making the Android worklist partially redundant. **Prevention**: When an issue is "both" platform, assign it to ONE agent (the one with the most work), not both.

- **P1-1 agent hit image dimension limit again in round 3**: Same "image exceeds dimension limit for many-image requests" error despite prior learnings. Agent produced 8 good commits (`d22a936`..`2ffcf29`) on `worktree-fix-p1-1-round-1` but session terminated before all issues were addressed. **Lesson**: The worklist generation must enforce a hard cap of 8 issues per agent, or agents must batch screenshots (verify 2-3 cards, commit, then next batch). This is the third occurrence — needs a structural fix in the orchestrator, not just agent guidance.

- **P1-2 agent produced zero commits**: Agent was assigned 16 issues but produced no output at all — log file is empty. **Lesson**: When an agent log is empty, the agent likely failed to start or was blocked by resource contention (5 parallel agents competing for Claude API). The orchestrator should stagger agent launches by 30-60 seconds and verify each agent's log has content within 2 minutes of launch.

- **Worktree rebase fails when worktree is still checked out**: Round 3 merge phase got `fatal: '<branch>' is already used by worktree` errors for P1-1 and P1-3 branches. Both branches had good commits (8 and 15 respectively) but couldn't merge. **Lesson**: The orchestrator must `git worktree remove` each worktree before attempting to rebase/merge its branch. The current `design-review-loop.sh` attempts rebase while worktrees are still active.

- **Iteration 5 produced zero net progress**: Review found 9 issues (3 P1, 4 P2, 2 P3) — identical to iteration 4 because all fix branches from prior rounds were deleted without merge. No fix agents were dispatched in this iteration. **Lesson**: The review-fix loop is wasted if the merge step fails. Future iterations must verify that fix commits from the PREVIOUS iteration are on `main` before starting a new review. If prior fixes are missing, re-implement them BEFORE running a new review pass. Running a review on unchanged code produces duplicate findings and wastes resources.

- **Re-implementation priority for lost commits**: When re-implementing lost fixes, prioritize by impact and re-implementation difficulty: (1) P1 #1 ColumnSet auto-column — single line change in `ColumnSetView.swift:72` (nil width proposal), highest impact (15+ cards); (2) P2 #4 Icon.Styles — `.buttonStyle(.plain)` in `ActionSetView.swift`, also fixes Icon.Clickable; (3) P1 #3 FlowLayout — remove maxItemWidth cap in `arrangeSubviews()`; (4) P1 #2 Image.FitMode/SVG — multi-part fix in `ImageView.swift` (dedicated isContainMode branch + isExplicitAutoSize fix + WKWebView SVG fix). Items 1-3 are small, high-confidence fixes. Item 4 is larger and needs careful testing.

- **Iteration 10 produced 20+ commits across 4 fix agents but NONE merged to main (8th occurrence)**: Fix agents ran in 2 iterations with 2 agents each (ios-1 and ios-2). Iteration-1 agents produced 10 commits (6 from ios-1, 4 from ios-2). Iteration-2 agents re-fixed the same issues with 9 more commits (5 from ios-1, 4 from ios-2). All commits remain on worktree branches that were never merged to `main`. HEAD is still `654a6ec`. **Lesson**: This is now the 8th iteration where fix commits fail to land on main. The orchestrator's merge step is fundamentally broken. Fix commits MUST be cherry-picked to main immediately after each agent completes — not batched for a merge phase that consistently fails. The review-fix loop has produced 100+ total commits across iterations 5-10 with <20 making it to main.

- **Iteration-2 fix agents duplicated iteration-1 work**: Both iteration-2 agents re-fixed issues already addressed in iteration 1 (project-dashboard, AreaGrid, SVG, CompoundButton, bar chart, center-alignment, FlowLayout). The orchestrator launched new fix agents without checking if iteration-1 fixes were already on worktree branches. **Lesson**: Before launching a new fix round, verify which issues already have uncommitted fix branches from prior rounds. Only dispatch agents for issues that remain unfixed.

- **Issue #9 maxActions fix (`4224d223`) is likely INCORRECT**: Fix agent changed `HostConfig.swift` maxActions default from 5 to 6. The report says iOS shows 5 actions vs Android 4. Increasing the default to 6 allows even MORE actions to display, making the discrepancy worse. The correct fix should DECREASE the default or enforce the limit differently. **Lesson**: When an issue says "iOS shows N, Android shows N-1", the fix should make iOS show fewer, not more. Verify the fix direction matches the desired parity direction before committing.

- **MultiColumnFlowLayout now has 12+ contradictory fix attempts**: Iteration-10 ios-2 agent produced `10044bb0` (intrinsic widths capped by maxItemWidth) in iteration 1, then `95cadf44` (removed ceil-based column formula) in iteration 2. These are the 11th and 12th approaches. The iteration-2 approach (removing ceil formula) contradicts the iteration-1 approach. **Lesson**: At 12+ attempts, incremental patching of FlowLayoutView.swift is definitively unproductive. The next iteration MUST replace the entire layout with SwiftUI `Grid` or `Layout` protocol. No more incremental patches.

## 3. Recurring Root Causes

- **Root cause**: iOS unconditional `frame(maxWidth:.infinity)` breaks sizing in multiple views and contexts
- **Affected cards**: teams-official-samples-communication (image column too large → `ImageView.swift`), Image.FitMode.Contain/Fill (labels pushed off-screen → `ImageView.swift`), communication text truncation (`TextBlockView.swift`)
- **Single fix**: Make `maxWidth:.infinity` contextual in ALL views — do not apply when inside a constrained column, when fitMode is "contain"/"fill", or when text alignment is left/leading
- **Status**: FIXED across 3 commits in iteration 6: `7e0adffb` (ImageView.swift — dedicated contain fitMode branch), `817e1063` (TextBlockView.swift — conditional on center/right alignment), and prior `13db8ad4` (isExplicitAutoSize fix). **Key insight**: This pattern caused THREE distinct issues in THREE different files — all sharing the symptom of "content expands beyond column boundaries". When future reviews flag content expanding beyond allocated space, check for unconditional `maxWidth:.infinity` in the rendering view FIRST.

- **Root cause**: iOS FlowLayoutView doesn't compute intrinsic height for nested containers
- **Affected cards**: Container.Nested.Flow, TableFlowLayout, Table.Flow, MultiColumnFlowLayout
- **Single fix**: Fix `FlowLayoutView.swift` height calculation — must re-measure items at actual rendered width (not clamped width)
- **Status**: 13 commits and counting. MultiColumnFlowLayout commits: `41b698d` (maxItemWidth as cap) + `635b0ea` (multi-column logic) + `c8bc59a` (grid dimension computation) + `5039cc2` (intrinsic width for flow items) + `49cda0e5` (return nil, remove round()) + `6c4c9510` (intrinsic widths) + `1d994906` (remove maxItemWidth cap in arrangeSubviews) + `8d4883c8` (arrangeSubviews cap on branch) + `08a461de` (min cap in sizeThatFits) + `6f254946` (mathematical column count) + `10044bb0` (removed column-count formula, intrinsic widths capped) + `95cadf44` (removed ceil-based column formula) + iteration-2 duplicate. **Key takeaway**: 12th and 13th attempts in iteration 10 contradict each other (intrinsic widths vs removed ceil formula). NONE of the 13 attempts have been visually verified on main because none were merged. **MANDATORY**: Do NOT attempt a 14th incremental patch. The next iteration MUST either: (1) merge one of the existing fix branches and visually verify, or (2) replace `FlowLayoutView.swift` entirely with SwiftUI `Grid` or `Layout` protocol. The manual sizing pipeline is fundamentally unmaintainable with 6+ independent stages that keep falling out of sync.

- **Root cause**: Android template engine `$root` keyword resolution failure
- **Affected cards**: templates-Template.DataBinding
- **Single fix**: Fix `$root` keyword handling in Android templating expression evaluator — must be in expression evaluation path, not dictionary expansion
- **Status**: Two fixes attempted (`0dba58d` empty data, `5f0f871` strip $data directive). Neither resolves $root in expressions. Needs expression evaluator fix.

- **Root cause**: iOS card body VStack clips bottom content on cards with more than ~4 vertical sections
- **Affected cards**: progress-indicators (steps 3-4 missing), list (numbered items 3-4 missing)
- **Issues**: P2 #3, P2 #4 from catalog 20260316-074113
- **Single fix**: Check `AdaptiveCardView.swift` for fixed height constraint or maxHeight on card body VStack. Card content that exceeds the viewport height is clipped instead of being scrollable or expanding. This is the iOS counterpart of the Android truncation pattern fixed in `efc20cc` (missing verticalScroll).
- **Status**: PARTIALLY RESOLVED. List card (#4) was FIXED in `eff40f7b` — root cause was actually a nested ScrollView in `ListView.swift`, NOT the card body VStack. Progress-indicators (#3) was reclassified by the fix agent as a viewport density difference, not a layout bug. **Key insight**: These two issues did NOT share the same root cause despite identical symptoms (bottom content missing). The list card had its own nested ScrollView; the progress-indicators card may simply exceed the viewport.

- **Root cause**: iOS `TableView.swift` column width calculation doesn't constrain to available width
- **Affected cards**: FlightUpdateTable, table (left-edge clipping), table-vertical-alignment, table (text wrapping)
- **Issues**: #5, #13, #19, #39 — all trace to the same file
- **Single fix**: Fix `TableView.swift` column width distribution to fit within card bounds and enable text wrapping
- **Status**: FIXED in round 2 (`4161e6f`). Verify no regressions in next review — table column clipping and text overflow addressed.

- **Root cause**: Android image loading failures in column layouts / themed contexts
- **Affected cards**: Agenda (pin icons), InputForm (hero image), ThemedUrls.Actions (dark image)
- **Issues**: #15, #20, #51
- **Single fix**: Investigate Android `ImageView.kt` image loading for inline/column/themed images
- **Status**: Agenda icons FIXED in round 2 (`bf7a61f` — auto-size images in auto-width columns). InputForm (#20) and ThemedUrls.Actions (#51) still unresolved — may be different root causes (hero image loading vs dark theme URL resolution).

- **Root cause**: Date off-by-1-day timezone on both platforms
- **Affected cards**: 4+ input cards across categories
- **Single fix**: Use UTC timezone consistently in date parsing/display functions
- **Status**: FIXED in this iteration (`eb1914b` iOS, `7b4a124` Android). Remove from future reports.

- **Root cause**: iOS long card content truncation — action buttons cut off at bottom
- **Affected cards**: ExpenseReport (3 variants), time-off-request, book-a-room
- **Issues**: #9, #14 — cards exceeding viewport height lose bottom content
- **Single fix**: Remove inner ScrollView that causes nested scroll clipping (`AdaptiveCardView.swift`)
- **Status**: FIXED. Prior fix `6182412` removed inner ScrollView. Latest `4b50e27` adds scroll indicators and fixes frame for long card content — ExpenseReport v1.5 Approve/Reject buttons now visible.

- **Root cause**: Android carousel page height undersized — nested content truncated
- **Affected cards**: 5+ carousel cards (scenario-cards, scenario-timer, CarouselTemplatedPages)
- **Issues**: #8
- **Single fix**: Fix `CarouselView.kt` page height calculation to accommodate all nested content
- **Status**: FIXED in round 2 (`50d5ee9`). Approach: aligned ColumnSet height estimate with iOS. Verify all 5+ affected carousel cards in next review.

- **Root cause**: iOS BadgeView renders as vertical bars instead of horizontal pills
- **Affected cards**: versioned-v1.5-badge
- **Issues**: #1 (P0)
- **Single fix**: Fix BadgeView intrinsic content size — the view's size calculation reports incorrect dimensions, causing vertical expansion
- **Status**: FIXED. Commits `cc72dfe` and `f5f12cf` were eventually merged. Review catalog 20260315-101810 confirms badges render as proper horizontal pills with correct sizing and color variants.

- **Root cause**: Review agent hits "image exceeds dimension limit" on iteration 2+ when reviewing 300+ card screenshots
- **Affected**: Review phase in iteration 2 of every loop run (4th occurrence total)
- **Single fix**: Pre-resize all screenshots to <2000px max dimension in the capture pipeline (e.g., `sips --resampleHeightWidthMax 1800` on macOS) before passing to the review agent
- **Status**: NEW. This is a systemic pipeline issue — not an agent behavior problem. Needs fix in `design-pass.sh` or `design-review-loop.sh` Phase 1.

- **Root cause**: Parallel fix agents editing overlapping files cause merge conflicts
- **Affected**: P1-1 and P1-3 branches in round 3 both touched `ios/Sources/ACRendering/Views/` files
- **Issues**: All fix agent output lost when merge phase fails — 23 commits across 2 branches couldn't merge
- **Single fix**: Partition worklists by **file ownership** (not just issue count) so parallel agents don't touch the same files. E.g., one agent owns iOS rendering, another owns Android rendering, another owns markdown/templating.
- **Status**: NEW. This caused total loss of round 3 fix output. The orchestrator's `owned_files` concept in worklists exists but isn't enforced — agents still modify files outside their partition.

- **Root cause**: Sample app card loading regression — ~42 Android cards show "Empty JSON string", ~30 iOS cards show wrong fallback card
- **Affected cards**: All versioned/v1.5/*, versioned/v1.6/* (subset), templates/* (non-template suffix), element-samples/* (subset), teams-official-samples-account, teams-official-samples-book-a-room
- **Issues**: #1, #2 from round-4 review
- **Single fix**: Debug sample app deep-link handlers on both platforms. Android: `MainActivity.kt:525-546`. iOS: CardDetailView routing. Likely regression from worktree merges (`5baba96`, `9fdc1b0`).
- **Status**: FIXED as of catalog 20260315-101810. Only 1 card still fails (Container.Nested.Flow on Android — dot-in-filename deep-link issue).

- **Root cause**: Android deep-link handler fails on card filenames containing dots (e.g., `Container.Nested.Flow`)
- **Affected cards**: versioned-v1.5-Container.Nested.Flow (and potentially other dot-named cards)
- **Issues**: #1 from catalog 20260315-101810
- **Single fix**: Use Base64 URL-safe encoding for card paths in navigation routes
- **Status**: FIXED in `4e77257` (4th attempt). Prior approaches failed: `11027d0` (%2E encoding) — Navigation Compose 2.7.x normalizes percent-encoded unreserved characters before route matching, making %2E ineffective. Base64 encoding works because Navigation Compose does not decode Base64 strings. Added `decodeCardId()` helper that detects Base64 (deep links) vs URL-encoded (gallery/bookmarks) formats.

- **Root cause**: Android truncates deeply nested card content (project-dashboard has 784 lines of JSON)
- **Affected cards**: teams-official-samples-project-dashboard
- **Issues**: #2 from catalog 20260315-101810
- **Single fix**: Check `AdaptiveCardView.kt` or `ContainerView.kt` for height constraints that clip content. The `heightIn(max=...)` or `clipToBounds()` in ContainerView.kt:99-100 may be activated by deeply nested structures.
- **Status**: Actually an AreaGrid column calculation issue, not a ContainerView height constraint. FIXED in `6bdab06` — when areas reference columns beyond the `columns` list size, the columns list is now expanded with equal-share widths (matching iOS behavior). The review's root cause attribution was wrong.

- **Root cause**: Android image loading HTTP 403 — missing User-Agent header in Coil/AsyncImage requests
- **Affected cards**: official-samples-input-form-official (hero image), versioned-v1.5-ThemedUrls.Actions (action icons), potentially other cards with images from strict servers (Wikipedia, etc.)
- **Issues**: #3, #8 from catalog 20260315-101810
- **Single fix**: Add proper `User-Agent` header to all image request contexts
- **Status**: FIXED in `2530dee` (Coil ImageRequest in ImageView.kt) and `1c0fbe7` (AsyncImage in ActionSetView.kt). If future image loading failures appear on Android, check User-Agent header first.

- **Root cause**: iOS nested ScrollView causing content truncation (third occurrence of this pattern)
- **Affected cards**: datagrid (horizontal ScrollView nesting), ActionModeTestCard (long card without scroll), ExpenseReport variants (prior iteration)
- **Issues**: #9, #10 from catalog 20260315-101810; #9, #14 from prior catalogs
- **Single fix**: Remove nested ScrollViews; use single outer ScrollView for card body
- **Status**: FIXED in `f4f895d` (DataGrid — removed inner vertical ScrollView) and `8e87501` (ActionModeTestCard — added outer card body ScrollView). This is the THIRD time nested ScrollView has been the root cause (prior: `6182412`). Any future iOS content truncation should check for nested ScrollViews first.

- **Root cause**: Material3 `Card` composable adds surface tint on elevation, causing lavender/purple backgrounds instead of intended white/gray
- **Affected cards**: element-samples-carousel-basic (carousel pages), versioned-v1.5-AdaptiveCardFlowLayout (flow items), CompoundButton containers
- **Issues**: #16, #17 from catalog 20260315-101810
- **Single fix**: Replace Material3 `Card` with plain `Box` + `clip` + `background` where white/neutral backgrounds are intended
- **Status**: Partially FIXED — carousel fixed in `2482ef2`. Flow layout (#17) still uses Material3 Card tint via CompoundButtonView.kt. Apply same Box replacement pattern to remaining Material3 Card usages.

- **Root cause**: Android ColumnSetView IntrinsicSize.Max doesn't propagate width to nested auto-width columns in weighted parents
- **Affected cards**: official-samples-agenda, versioned-v1.5-Agenda, templates-Agenda.template (all 3 Agenda variants)
- **Single fix**: Replaced `Row` + `IntrinsicSize.Max`/`weight()` with a custom `ProportionalColumnLayout` that computes column widths in 3 passes (pixel → auto → weighted), matching iOS behavior
- **Status**: FIXED in `4c4351e`. The key insight: Compose's `Row` with mixed `IntrinsicSize.Max` (auto) and `weight()` (weighted) doesn't properly distribute widths to nested ColumnSets. A custom layout was needed. **UPDATE**: Catalog 20260315-213139 shows ProportionalColumnLayout still has issues: (1) auto columns consume all width leaving weighted columns at zero (Issues #1-#3), (2) height constraints truncate nested ColumnSets (Issue #1), (3) weighted columns with `width:"1"` get zero space when `remainingWidth` is exhausted (Issue #9). All 4 issues in `ColumnSetView.kt`. This is a REGRESSION or incomplete fix from `4c4351e`.

- **Root cause**: Android ProportionalColumnLayout 3-pass algorithm has multiple failure modes for complex ColumnSet nesting
- **Affected cards**: official-samples-agenda (3 variants), official-samples-flight-update (2 variants), official-samples-expense-report (3 variants), official-samples-flight-details (2 variants) — 10 cards total
- **Issues**: #1, #2, #3, #9 from catalog 20260315-213139
- **Single fix**: Three distinct bugs in the same layout: (1) Pass 2 auto-column measurement can consume all `remainingWidth`, leaving zero for Pass 3 weighted columns; (2) Pass 3 weighted columns with `width:"1"` need minimum proportional space even when `remainingWidth <= 0`; (3) Height constraints (`constraints.maxHeight`) may be incorrectly bounded for nested ColumnSet children (lines 204-222). All three must be fixed together in `ColumnSetView.kt`.
- **Status**: FIXED in `73897919`. Pass 2 changed from measuring at full `remainingWidth` to using `maxIntrinsicWidth` (matching iOS `sizeThatFits(.unspecified)`), with fallback to 50%-capped direct measurement when intrinsic width is 0. Pass 3 removed the `remainingWidth > 0` guard and always distributes proportionally. All 10 affected cards verified working. **Key insight**: A single commit fixed all 4 issues because they shared the same root cause — auto columns greedily consuming all available space. The fix pattern (intrinsic width + coerceAtLeast(0) for weighted) is the canonical approach for ProportionalColumnLayout.

- **Root cause**: Android template engine lacks graceful error handling — uncaught expression evaluation exceptions blank the entire card
- **Affected cards**: templates-FoodOrder.template (blank on Android), templates-InputForm.template (missing image)
- **Single fix**: Wrap `expandValue()` calls in `TemplateEngine.kt` with try-catch and fallback to original value, matching iOS `try?` pattern
- **Status**: FIXED in `27be821`. The root cause was NOT in `ExpressionEvaluator.kt` as initially attributed — it was missing error handling in `TemplateEngine.kt:expandDictionary/expandArray`. Expression evaluation errors propagated up and blanked the entire card.

- **Root cause**: iOS TableView.swift has multiple parity gaps — vertical alignment defaults, row style backgrounds, and cell padding
- **Affected cards**: table-vertical-alignment (#5), table-basic (#9), flight-update-table (#14)
- **Issues**: 3 issues in this iteration, all in `TableView.swift`
- **Single fix**: Three targeted fixes: (1) default vertical alignment to `.top` (`c29b667`), (2) apply row style backgrounds to non-header rows (`908ff9a`), (3) reduce cell vertical padding (`b0ed8bd`)
- **Status**: FIXED in this iteration. All three commits merged. Verify no table regressions in next review.

- **Root cause**: Android card body or ActionSet may enforce maxActions globally instead of per-ActionSet, truncating bottom action sections
- **Affected cards**: versioned-v1.5-Action.MenuActions
- **Issues**: P2 #6 from catalog 20260316-004720, P2 #5 from catalog 20260316-074113
- **Single fix**: Check `ActionSetView.kt` for `maxActions` limit from HostConfig — verify it's applied per-ActionSet, not globally. Also check if card body `Column` has `verticalScroll` modifier for long content with multiple ActionSets.
- **Status**: STALE — persisted across 3 iterations with 0 fix attempts. Android fix agent produced empty log in iteration 6. This issue MUST be assigned to a dedicated solo agent in the next iteration with explicit file paths (`ActionSetView.kt` lines for maxActions logic, `AdaptiveCardView.kt` for verticalScroll). iOS renders correctly — use as reference implementation.

- **Root cause**: AreaGrid column weight calculation differs when areas span multiple columns
- **Affected cards**: versioned-v1.5-ContainerAreaGrid5, versioned-v1.5-ContainerAreaGrid6
- **Issues**: P3 #7 from catalog 20260316-004720, P3 #8 from catalog 20260316-074113
- **Single fix**: Compare `AreaGridLayout.swift` and `AreaGridLayout.kt` column weight distribution for multi-span areas. Align iOS to match Android asymmetric column sizing.
- **Status**: FIXED in `62eda01e` — aligned AreaGridLayout.swift with Android weight-based proportional column distribution. Skip unless regression detected.

- **Root cause**: iOS default alignment is `.center` while Android defaults to `.leading`/start for multiple element types
- **Affected cards**: progress-indicators (#11), themed-images (#12), potentially other cards with images/spinners
- **Issues**: Systemic — affects `ProgressIndicatorView.swift` and `ImageView.swift` (confirmed), potentially other views
- **Single fix**: Change default alignment to `.leading` in each affected view
- **Status**: FIXED. Per-view fixes for images (`fa7f4d0`) and progress indicators (`5d60768`) were symptoms; ROOT cause fixed in `05e70d97` — `ContainerView.swift` alignment changed from `.top/.center/.bottom` to `.topLeading/.leading/.bottomLeading`. This resolves center-aligned text on 7+ cards (streaming-card, markdown, list, textblock-style, spacing_sample, Template.DataBinding, ProgressBar labels). **Note**: Fix on unmerged iteration-9 branch — verify after merge.

- **Root cause**: iOS AreaGridLayoutView implicit column weight defaults to 1fr causing severe width imbalance
- **Affected cards**: teams-official-samples-project-dashboard (P1 — 70% content missing), versioned-v1.5-Table.AreaGrid (title truncated), versioned-v1.5-ContainerAreaGrid5 (image misalignment)
- **Issues**: #1, #7, #9 from catalog 20260316-121415
- **Single fix**: In `AreaGridLayoutView.swift:244-256` `resolveColumnWidths()`, when `columns` array has fewer entries than actual column count, implicit columns should share the remaining percentage equally instead of defaulting to `1fr` weight 1
- **Status**: FIXED in `04a3776e` (issues #1 and #7 — implicit columns get remaining percentage) and `9784d18d` (issue #9 — `.topLeading` alignment for Grid rows). Two separate commits because the misalignment had two causes: column width imbalance AND vertical alignment. **Note**: Fixes on unmerged iteration-9 branch — verify after merge.

- **Root cause**: iOS bar chart uses fixed pixel reservation (40pt) for x-axis labels instead of proportional sizing
- **Affected cards**: charts
- **Issues**: #4 from catalog 20260316-121415
- **Single fix**: `BarChartView.swift:73` — change `(geometry.size.height - 40)` to `(geometry.size.height * 0.75)` to match Android proportional approach
- **Status**: FIXED in `118b859e` — proportional 0.8 factor replaces fixed 40pt, matching Android 80% fill. **Note**: Fix on unmerged iteration-9 branch — verify after merge.
- **Status**: FIXED for images (`fa7f4d0`) and progress indicators (`5d60768`). If future reviews flag center vs left alignment on other element types, check the SwiftUI view's default alignment modifier.

- **Root cause**: iOS SwiftUI inherited button tinting makes action icons invisible against white background
- **Affected cards**: versioned-v1.6-Icon.Styles, versioned-v1.6-Icon.Clickable
- **Single fix**: Add `.buttonStyle(.plain)` to action buttons in `ActionSetView.swift` to prevent inherited SwiftUI tinting from overriding icon foreground colors
- **Status**: Was FIXED in `8c10ff46` on deleted branch `worktree-fix-ios-1-round-1` — commit LOST. Must be re-implemented. Icon.Clickable (P2 #5) confirmed to share this root cause — fixing Icon.Styles will likely resolve both cards.

- **Root cause**: Android card body missing `verticalScroll` modifier — long cards truncated at viewport bottom
- **Affected cards**: versioned-v1.5-ActionModeTestCard (action buttons clipped)
- **Single fix**: Add `verticalScroll(rememberScrollState())` to card body `Column` in `AdaptiveCardView.kt`
- **Status**: FIXED in `efc20cc`. This is the Android counterpart of the iOS nested ScrollView truncation pattern (prior: `6182412`, `f4f895d`, `8e87501`). iOS had ScrollViews causing nesting issues; Android simply lacked a scroll modifier entirely. **Any future card content truncation on Android should check for missing verticalScroll first.**

- **Root cause**: iOS HostConfig container style color resolution may differ from Android for emphasis/attention styles
- **Affected cards**: element-samples-carousel-styles (#10)
- **Single fix**: Compare `ContainerStyleConfig` color values in iOS HostConfig defaults against Android defaults — one platform may have emphasis/attention colors swapped
- **Status**: FIXED in `952739e6` — iOS container style emphasis/attention background colors aligned with Android defaults. This was the most persistent issue in the project (0 agents attempted across ALL prior iterations). Finally resolved when a dedicated fix agent was assigned with explicit file paths and the debugging recipe documented in learnings. **Key finding**: The actual fix was in `HostConfig.swift` (default color values), NOT `ContainerStyleConfig.swift` (style resolution logic) as the worklist suggested. The emphasis color `#08000000` had only 3% alpha, rendering as transparent — Android used `#F1F1F1` (visible light gray).

- **Root cause**: iOS CompoundButtonView.swift negative layoutPriority clips title text
- **Affected cards**: versioned-v1.6-CompoundButton (#4)
- **Single fix**: Remove `.layoutPriority(-1)` from title text in CompoundButtonView.swift:70, or use positive priority
- **Status**: FIXED in `4a24089b` — changed to positive layoutPriority for title text. **UPDATE**: Catalog 20260315-213139 Issue #6 showed left-edge clipping persisted — the layoutPriority fix alone was insufficient. Additional fix `ea9edef3` added explicit `spacing` to the inner HStack (matching Android `Arrangement.spacedBy(8.dp)`). Both fixes together resolve the issue. **Lesson**: CompoundButton clipping had TWO causes: (1) negative layoutPriority and (2) missing HStack spacing — fixing only one still showed clipping from the other.

- **Root cause**: iOS ActionSetView.swift does not enforce maxActions host config limit
- **Affected cards**: versioned-v1.5-ActionModeTestCard (#9), edge-max-actions (#13)
- **Single fix**: Truncate actions array to `hostConfig.actions.maxActions` before rendering in ActionSetView.swift. Do NOT change the HostConfig default value — the issue is enforcement, not the default.
- **Status**: FIX ATTEMPTED BUT INCORRECT. Iteration-10 agent changed HostConfig maxActions from 5 to 6 (`4224d223`) — this is WRONG (increases visible actions instead of enforcing the limit). Correct approach: keep default at 5, ensure `ActionSetView.swift` slices the actions array to `min(actions.count, maxActions)` before rendering, with overflow in a menu. Use Android `ActionSetView.kt` as reference implementation.

- **Root cause**: Sample app deep-link card loading — CardCache.getCards() does not index all cards, causing null lookup for 10 cards
- **Affected cards**: element-samples-carousel-styles, element-samples-input-style, teams-official-samples-communication, versioned-v1.5-ActionModeTestCard, versioned-v1.5-badge, versioned-v1.5-Image.FitMode.Contain, versioned-v1.5-Image.FitMode.Fill, versioned-v1.5-MultiColumnFlowLayout, versioned-v1.6-Carousel.ForbiddenElements, versioned-v1.6-CompoundButton
- **Issues**: #1 from design-catalog-20260315-202851
- **Single fix**: Add fallback direct asset loading in CardDetailScreen.kt when gallery cache lookup returns null. Also fix iOS deep-link handler to show error instead of stale card.
- **Status**: FIXED in `85ee4325` (round 2), re-fixed in `fe57f87a` (round 3). This is the SIXTH fix for sample app card loading regressions. The fallback-to-assets pattern is now the canonical solution — if future cards fail to load via deep link, check that the fallback path in CardDetailScreen.kt covers the new card's asset directory structure. **Note**: Round 3 re-dispatched this issue unnecessarily because the recapture cycle didn't reflect the round-2 fix. See fix agent pitfalls.

- **Root cause**: iOS `TargetWidth` breakpoint evaluation categorizes iPhone 16 Pro width (~393pt) incorrectly, hiding `AtLeast:Narrow` content
- **Affected cards**: teams-official-samples-account (#13)
- **Single fix**: Default to `.narrow` width category when card width is unmeasured (zero or unset)
- **Status**: FIXED in `62fa2b6` — when card width is unmeasured, defaults to narrow category instead of veryNarrow. Verify no regressions in cards that use targetWidth breakpoints.

- **Root cause**: Android TargetWidth defaults to Standard instead of Narrow — same pattern as iOS fix `62fa2b6` but on Android
- **Affected cards**: teams-official-samples-account (P1 blank render)
- **Issues**: #3 from catalog 20260318-115833
- **Single fix**: In `AdaptiveCardView.kt:147-152`, default to Narrow when measured card width is 0 or unset, matching iOS behavior
- **Status**: NEW. This is the Android counterpart of the iOS fix. The iOS fix was in `62fa2b6` — apply the same pattern to Android.

- **Root cause**: iOS TableView.swift missing accent color on header text (firstRowAsHeaders)
- **Affected cards**: table, element-samples-table-first-row-headers, element-samples-table-basic, element-samples-table-grid-style (4 cards)
- **Issues**: #4 and #7 from catalog 20260318-115833, #5 from catalog 20260319-162916
- **Single fix**: Add `.foregroundColor(Color(hex: hostConfig.containerStyles.default.foregroundColors.accent.default))` to header cell in `TableView.swift:197`
- **Status**: FIXED in `2ba7fdb6` — accent color applied to table header text by rendering directly (bypassing the unreliable pattern match on `.textBlock` case). Prior fix `cbb76ef4` addressed the `firstRowAsHeaders` variant. Both commits now on main. Skip unless regression detected.

- **Root cause**: iOS BadgeView falls back to dark grey (#212121) default when HostConfig badge styles not propagated through FlowLayout
- **Affected cards**: versioned-v1.5-badge, ContainerFlowLayout, NestedFlowLayout, MultiColumnFlowLayout, ColumnSetWithDifferentWidths, Table.Flow, v1.6-CompoundButton (7 cards)
- **Issues**: #6 from catalog 20260318-115833
- **Single fix**: Trace HostConfig propagation through FlowLayoutView → CompoundButtonView → BadgeView. The `hostConfig.badgeStyles` is likely nil in flow layout contexts.
- **Status**: NEW. This is a systemic issue affecting 7+ cards. The fix is in the HostConfig propagation chain, not the BadgeView rendering itself.

- **Root cause**: Android deep-link routing fails for cards with multiple dots or `.template` suffix
- **Affected cards**: versioned-v1.6-Fallback.Root.Recursive, templates-CarouselTemplatedPages.template
- **Issues**: #1, #2 from catalog 20260318-115833
- **Status**: PARTIALLY FIXED. Fallback.Root.Recursive and Fallback.Root now load correctly in catalog 20260318-142204. But 5 NEW cards show wrong-card routing (see next entry).

- **Root cause**: Android gallery card index mismatch — gallery list order differs from capture script expectations after new test cards added
- **Affected cards**: accordion (→ProductVideo), all-inputs (→All Action Types), progress-indicators (→Popover Action), Icon.Styles (→Icon.Clickable), flight-itinerary (→Flight Details)
- **Issues**: #1 from catalog 20260318-142204
- **Single fix**: Check `CardCache.getCards()` sort order in `MainActivity.kt`. Adding `test-bar-chart-only.json` may have shifted indices in some categories. Verify alphabetical sorting consistency between gallery list and deep-link route resolution.
- **Status**: PARTIALLY ADDRESSED. `8da20076` added `launchSingleTop` to deep-link navigation which fixes wrong-card display after ANR restarts (duplicate Activity instances). This resolves the ANR-cascading wrong-card pattern but the underlying index-based lookup remains. Verify in next catalog whether wrong-card issues persist without ANR triggers.
- **Single fix**: Fix `decodeCardId()` in `MainActivity.kt` to handle multi-dot filenames and `.template` suffix. Prior Base64 fix `4e77257` may not cover all edge cases.
- **Status**: NEW. This is the THIRD iteration of deep-link routing issues (prior: `%2E` encoding, Base64 encoding). Each fix resolves some cards but misses others.

## 4. Platform Differences (Intentional)

- **Difference**: iOS uses SF Pro / `.SF UI Text`, Android uses Roboto — line heights and character widths differ slightly
- **Why it's OK**: Platform-native font stacks per Figma design spec. Do not report minor text wrapping differences caused by this.

- **Difference**: iOS date picker / time picker chrome looks different from Android
- **Why it's OK**: Platform-native input controls. Only report if functionality differs.

- **Difference**: Separator colors differ (`#FFDFDEDE` iOS vs `#0D16233A` Android)
- **Why it's OK**: Intentional per Figma HostConfig specs. Do not report separator color differences as issues.

- **Difference**: iOS multi-select expanded renders as toggle switches, Android renders as checkboxes
- **Why it's OK**: Platform-native selection controls. iOS uses `Toggle`, Android uses `Checkbox`. Only report if selection state or data binding differs.

- **Difference**: Input field borders — iOS uses underline-style, Android uses full rectangular borders with trailing icons
- **Why it's OK**: Platform-native input styling (iOS HIG underline vs Material outlined). Do not flag as parity issue unless functionality or label rendering differs.

- **Difference**: Accordion row styling — iOS uses flat rows with divider lines, Android uses card-like borders with spacing
- **Why it's OK**: Both aligned in `500338b`/`1783c7b` to flat divider style. Do not flag as parity issue.

- **Difference**: Table header background — iOS had no emphasis, Android had none. Both aligned in `a6d53a6`.
- **Why it's OK**: Header emphasis is now consistent. Minor shade differences are acceptable.

- **Difference**: Toggle switch positioning — iOS label above toggle, Android toggle floated right of label
- **Why it's OK**: Both aligned in `35c8135` to inline label+toggle layout. Minor platform-native toggle chrome differences (iOS pill switch vs Android Material switch) are expected.

- **Difference**: Image horizontal alignment default — iOS centers images, Android left-aligns
- **Why it's OK**: RESOLVED. First aligned in `eb11ec2` (stretch-only behavior), then fully fixed in `fa7f4d0` (default alignment changed to `.leading`). Both platforms now default to left/start alignment. Do not re-flag.

- **Difference**: Carousel peek behavior — iOS shows peek of adjacent pages, Android shows full-width pages
- **Why it's OK**: Android carousel peek aligned in `80a36a5` (P1-3 branch, pending merge). Once merged, minor peek distance differences are acceptable. Do not flag as P2.

- **Difference**: Overflow button glyph — iOS uses "..." (ellipsis), Android uses "--" (dashes)
- **Why it's OK**: P2 fix agent confirmed both platforms actually use `\u2026` (ellipsis) already. The visual difference was a screenshot artifact. Do not flag as parity issue.

- **Difference**: Bookmarks page — iOS uses swipe-to-delete, Android uses tap-to-delete
- **Why it's OK**: Platform-native interaction patterns. Do not flag as parity issue.

- **Difference**: FluentIcon rendering style — iOS SF Symbols use dot-grid/dotted fill, Android Material Icons use outlined/stroked style
- **Why it's OK**: Platform-native icon libraries have inherently different aesthetics. Icon sizes aligned in `0b4df72`, but remaining style differences are not fixable without shipping custom icon assets. Only flag if icon sizes or visibility differ functionally.

- **Difference**: Tab set indicator style — iOS uses filled/highlighted background on selected tab, Android uses underline indicator
- **Why it's OK**: Both functionally equivalent. This was confirmed P3 across multiple iterations and fix agents skipped it as already aligned. Minor tab chrome differences are platform-native styling.

- **Difference**: Popover/ShowCard initial expansion state — Android may show expanded content in screenshots while iOS shows collapsed
- **Why it's OK**: Likely a screenshot capture timing artifact, not a rendering difference. The popover state depends on user interaction history. Do not flag as parity issue unless confirmed by runtime testing.

- **Difference**: iOS progress-indicators steps 3-4 below viewport vs Android showing all 4
- **Why it's OK**: Confirmed in catalog 20260316-121415 as viewport density difference, not a layout bug. Card renders all steps but 3-4 are below the visible area on iPhone screen size. Do not report.

- **Difference**: Overflow "..." button placement — iOS inline with last action row, Android on its own row
- **Why it's OK**: Minor action button wrapping difference driven by platform font metrics and flow layout behavior. Both platforms show all actions and overflow. P4 cosmetic only — documented across 3 catalogs (20260316-074113, 20260316-121415, 20260316-133654). Do not report unless buttons are clipped or missing.

- **Difference**: Media play button overlay styling — RESOLVED
- **Why it's OK**: Previously iOS used light/white overlay and Android used darker gray. FIXED in `fc8f5d84` — Android now aligned with iOS styling. Both platforms match. Do not report in future reviews.

## 5. Fix Agent Pitfalls

- **Pitfall**: Using `ScrollView` or `LazyVStack` in iOS snapshot/rendering views — defeats `layer.render` capture
- **Prevention**: Always use `VStack` with synchronous view model. See CLAUDE.md snapshot rules.

- **Pitfall**: Fixing iOS without applying equivalent fix on Android (or vice versa) — creates new parity gap
- **Prevention**: Every rendering fix must list both platform files. Check counterpart even if only one platform is broken.

- **Pitfall**: Changing shared model files (ACCore/ac-core) without running parser regression tests
- **Prevention**: After any model change, run `swift test --filter CardParsingRegressionTests` and `./gradlew :ac-core:test`.

- **Pitfall**: P0 worklist included P1 and P2 issues mixed in (10 issues for one agent), causing scope bloat and session failure
- **Prevention**: Keep P0 worklists to <=5 true P0 issues. Do not bundle lower-priority issues into the P0 fix agent — they dilute focus and increase screenshot count beyond session limits.

- **Pitfall**: Fix agent couldn't find relevant code for SimpleFallback "gray pill badges" styling — skipped the issue entirely
- **Prevention**: When a fix agent can't locate the relevant code, it should grep for the element type's view/composable name rather than skipping. Provide explicit file paths in worklist `affected_files`.

- **Pitfall**: SwiftUI `fixedSize()` modifier composition is fragile — chaining multiple `fixedSize` calls produces unexpected layout
- **Prevention**: Use a single `fixedSize(horizontal:vertical:)` call with explicit axis control instead of chaining `.fixedSize().fixedSize(horizontal:vertical:)`.

- **Pitfall**: P2 fix agents were productive (8+ fixes merged) but P1 fix agents only touched peripheral issues (duplicate import removal, icon mappings) — skipping the core rendering/layout P1 bugs
- **Prevention**: P1 worklists should be ordered by impact and include the top 5 most impactful issues first. Include specific file paths, line numbers, and a code-level hint for each issue so the agent doesn't waste time searching.

- **Pitfall**: Round-2 worktree branches were created but contain zero commits — agents either failed to start or hit blockers without reporting
- **Prevention**: Fix agents should make at least one diagnostic commit (even a comment or TODO) within the first few minutes to signal they've started. If a worktree is created but empty, the orchestrator should detect this and re-queue.

- **Pitfall**: Column layout support was added to `ColumnView.swift` and `ColumnSetView.kt` (`afe9122`) for flow/grid, but this cross-cutting change wasn't tested against all ColumnSet-heavy cards
- **Prevention**: When adding layout mode support to container types (Column, ColumnSet, Container), run visual tests on ALL cards that use those containers — not just the specific card that triggered the fix.

- **Pitfall**: Parallel worktree branches (P0, P1, P2 fix agents) needed manual rebase before merge (`1bdaecc`) because they all branched from the same base and made overlapping file changes
- **Prevention**: The orchestrator script should auto-rebase worktree branches sequentially before merging (P0 first, then P1 rebased on P0, then P2 rebased on P1). Fix `design-review-loop.sh` to handle this.

- **Pitfall**: iOS BadgeView P0 was not attempted in round 2 despite being the #1 priority — fix agents likely skipped it because prior rounds' approaches failed and no new approach was documented
- **Prevention**: For persistent P0 issues that survive multiple rounds, the worklist should include a "prior failed approaches" section and explicitly suggest a different strategy. For BadgeView, the next attempt should inspect the parent container's layout constraints, not just the badge's fixedSize modifiers.

- **Pitfall**: 5 parallel fix agents overwhelmed API capacity — P1-2 produced empty logs (never started), P2 produced no branch, P3 produced 0 commits
- **Prevention**: Limit parallel fix agents to 3 maximum. Stagger launches by 30-60 seconds. Verify each agent's log has content within 2 minutes; if empty, re-launch as a replacement.

- **Pitfall**: Worktree merge phase attempts `git rebase` while worktrees are still checked out, causing `fatal: '<branch>' is already used by worktree` errors
- **Prevention**: The orchestrator must run `git worktree remove <path>` for each worktree BEFORE attempting rebase/merge of its branch. Add this as a mandatory step in Phase 5 of `design-review-loop.sh`.

- **Pitfall**: Round 3 produced 23 good commits across 2 branches (P1-1: 8 commits, P1-3: 15 commits) but NONE were merged to main — total loss of iteration output
- **Prevention**: When merge fails, the orchestrator should cherry-pick non-conflicting commits individually rather than abandoning the entire branch. Use `git cherry-pick --no-commit` to test each commit, skip conflicts, and salvage what can be merged cleanly.

- **Pitfall**: Worklist assigned 16-18 issues per agent — far too many for a single session to address meaningfully
- **Prevention**: Cap worklists at 8 issues per agent maximum. Prioritize by impact within each worklist. Better to fix 6/8 well than attempt 16 and hit session limits.

- **Pitfall**: P0 fix agent produced 2 good commits (badge fix `cc72dfe`, flow layout fix `f5f12cf`) but merge conflict prevented them from landing on main — entire P0 output lost for iteration
- **Prevention**: When merge fails, the orchestrator should attempt `git cherry-pick` of individual commits rather than abandoning the entire branch. For P0 fixes specifically, the orchestrator should retry merge with manual conflict resolution or alert the user immediately rather than silently moving on.

- **Pitfall**: Review agent in iteration 2 hit "image exceeds dimension limit for many-image requests" — same recurring issue as rounds 1 and 3 of previous iterations. This is now the 4th occurrence across iterations.
- **Prevention**: The review prompt must enforce image dimension limits (resize screenshots to <2000px before sending). Alternatively, the orchestrator should pre-resize all screenshots before launching the review agent. This is a systemic issue that needs a structural fix in the capture/review pipeline.

- **Pitfall**: P1 agent produced 0 commits in iteration 2 (empty log) despite having 38 issues assigned — same pattern as P1-2 in round 3 of the previous iteration
- **Prevention**: The orchestrator's 38-issue P1 worklist is overwhelming agents. Combined with the P0 and P2 agents competing for API capacity, the P1 agent either fails to start or times out reading the prompt. Split P1 into two agents (P1-A and P1-B) with ≤15 issues each, or launch P1 after P0/P2 complete rather than in parallel.

- **Pitfall**: Worktree rebase bug (`fatal: '<branch>' is already used by worktree`) recurred in this iteration despite being documented in prior learnings — the `design-review-loop.sh` still doesn't remove worktrees before rebase
- **Prevention**: The `git worktree remove` fix documented in prior learnings has not been applied to the script. The orchestrator fell back to direct merge (which worked for P1 round 1 and P2 round 2) but failed with merge conflict for P0 round 2. This fallback-to-merge path needs conflict resolution logic, not just `git merge --abort`.

- **Pitfall**: Worktree merges (`5baba96`, `9fdc1b0`) introduced a regression in sample app card loading — ~42 Android cards and ~30 iOS cards now fail to load (Empty JSON String / wrong card rendered). The fix agents' rendering changes were merged but apparently broke the sample app's deep-link routing.
- **Prevention**: After merging worktree fix branches, ALWAYS run a quick card loading sanity check on both platforms (open 5-10 representative cards via deep links and verify they load). The `design-review-loop.sh` Phase 4 (catalog capture) should detect this by checking for a spike in ~60KB Android screenshots (error screens) or identical-size iOS screenshots (wrong card). If >10% of cards fail to load, abort the iteration and investigate the merge.

- **Pitfall**: Review agent classified OCR-detected curly brackets in code-block card as P1 TEMPLATE_FAIL — but the card intentionally displays Swift code containing `{}`.
- **Prevention**: OCR pre-scan should whitelist known code-display cards (code-block, any card with "code" in name) from curly bracket detection. Similarly, cards named "Invalid" should be whitelisted from expression detection since they intentionally test invalid expressions.

- **Pitfall**: Review agents report iOS screenshot size being 2-5x larger than Android as evidence of rendering issues — but this is normal 3x retina scaling.
- **Prevention**: Do not use raw screenshot file size ratio as a primary issue indicator. Only flag when: (a) ratio exceeds 600%, (b) Android screenshot is very small (<60KB, likely error screen), or (c) visual inspection confirms content difference. The size-diff pre-filter is useful for prioritizing review but most differences are density-related.

- **Pitfall**: Review agents report carousel cards showing different images on iOS vs Android as rendering bugs — but this is capture timing artifact.
- **Prevention**: Carousel screenshots capture whichever page is currently displayed. Different pages may be active at capture time on each platform. Only flag carousel issues if structure (dots, navigation, text layout) differs, not if the visible page content differs.

- **Pitfall**: Review agent re-flags issues as "Confirmed" that were already fixed in prior commits not yet captured in the review catalog (e.g., compound buttons `d095c3f`, action grid `c763109`, markdown bold `e279c8d`/`a3b9edc`, progress bar dot `ac2e082`). This wastes fix agent time investigating non-issues.
- **Prevention**: The review agent (or worklist generator) should check `git log --oneline -50` before classifying issues as "Confirmed". If a commit message references the card/element being flagged, mark it as "Likely Fixed — verify in next catalog" instead of "Confirmed".

- **Pitfall**: P2-1 fix agent was assigned 4 issues but found all were either already fixed or misattributed to wrong files — produced 0 commits. Agent wasted an entire session.
- **Prevention**: Validate worklists before dispatch: (1) check git log for recent fixes matching the issue, (2) verify `affected_files` actually contain the relevant code (e.g., list bullet issue #5 was attributed to `MarkdownRenderer.kt` but actual problem was in `ListView.kt`).

- **Pitfall**: Issue #5 (Android list bullet alignment) was attributed to `MarkdownRenderer.kt` but the actual rendering problem is in `ListView.kt`. Fix agent couldn't find relevant code in the assigned file and skipped the issue.
- **Prevention**: When attributing `affected_files` for layout/rendering issues, trace the composable hierarchy to find where the bullet + text layout is actually composed. For list items, the layout is in the list view, not the markdown renderer.

- **Pitfall**: Issue #19 (ExpenseReport Pending badge missing) was classified as a BadgeView issue but the "Pending" indicator is actually an Image element, not a Badge. Fix agent skipped it because BadgeView code was correct.
- **Prevention**: Before attributing issues to specific view files, verify the element type in the card JSON. Use `jq` to check which Adaptive Card element type renders the flagged content. Misidentified element types waste fix agent time.

- **Pitfall**: Android badge icon fix `84f3d7c` ("use filled badge icons") addressed filled vs outlined style but did NOT fix the icon name mapping — badge icons still render as generic placeholders in catalog 20260315-112459.
- **Prevention**: Badge icon fix needs TWO changes: (1) filled vs outlined style (done), (2) expand the Fluent-to-Material icon name mapping in BadgeView.kt:129-141 to cover all icon names used in badge cards (ArrowSync, CalendarLtr, Info, Checkmark, Warning, etc.).

- **Pitfall**: project-dashboard and Container.Nested.Flow still show as loading failures in catalog 20260315-112459 despite prior fixes (6bdab06 and 11027d0). The sample app may not have been rebuilt after the fixes.
- **Prevention**: After merging fix commits, always rebuild and reinstall the sample app on both platforms BEFORE capturing a new catalog. The deep-link test pipeline should verify at least the previously-failing cards load successfully before proceeding with full capture.

- **Pitfall**: iOS food-order card missing ImageSet images was not caught in previous reviews because the card was not in the high-priority review list and the size ratio (134%) was below the flag threshold.
- **Prevention**: Include all cards with remote image URLs in the priority review list, regardless of size ratio. Image loading failures produce similar-sized screenshots (text renders the same) but with missing visual content.

- **Pitfall**: iOS Action.ResetInputs renders as empty squares because it falls to the .unknown(type:) case in CardAction.swift. This was not caught until visual review of the MenuActions card.
- **Prevention**: Run `grep -r "Action.ResetInputs\|resetInputs" shared/test-cards/` to identify all cards using unimplemented action types, then verify those cards render correctly on both platforms.

- **Pitfall**: Android Agenda card shows only location pills with empty space below — nested ColumnSets with auto-width columns inside weighted parents collapse to intrinsic size instead of filling available space.
- **Prevention**: When fixing ColumnSet layout issues on Android, check `IntrinsicSize.Max` modifier usage for auto-width columns inside weighted parent Rows. Compare with iOS `ProportionalColumnLayout` that explicitly proposes calculated widths to children.

- **Pitfall**: Issue #6 (multi-select compact) worklist referenced non-existent file `ChoiceSetView.swift` — actual file is `ChoiceSetInputView.swift`. P3-3 agent found the issue was already fixed in the correct file.
- **Prevention**: Worklist generator must verify `affected_files` exist on disk before dispatch. Use `test -f <path>` as a pre-check. Wrong filenames waste agent time searching for code that doesn't exist.

- **Pitfall**: Android template engine FoodOrder blank screen (Issue #3) was attributed to `ExpressionEvaluator.kt` nested array indexing, but the actual fix was graceful error handling in `TemplateEngine.kt` — wrapping `expandValue()` with try-catch to match iOS `try?` pattern.
- **Prevention**: When template cards render blank, the root cause is more likely in the template expansion pipeline (TemplateEngine) than the expression evaluator. The expansion pipeline propagates uncaught exceptions that blank the entire card, while expression evaluation failures only affect individual fields.

- **Success pattern**: This iteration (post-fix-round-1) achieved 10/10 issues addressed across 5 parallel agents (1 P1, 1 P2, 3 P3). Key factors: (1) explicit file paths and fix hints in worklists, (2) capping P3 worklists at 2-3 issues per agent, (3) all 8 worktree branches merged successfully. **Lesson**: The split of P3 into 3 agents with 2-3 issues each is the right granularity — much more productive than prior rounds with 16-18 issues per agent.

- **Success pattern**: P2 agent recognized both template issues (#3 and #4) shared the same root cause (missing error handling in TemplateEngine.kt) and fixed them with a single commit. **Lesson**: When worklists group issues by affected module, agents can identify shared root causes and batch fixes efficiently.

- **Pitfall**: Iteration 2026-03-15-213137 P3 fix branch addressed only iOS issues (5 commits) despite 3 P1 Android ColumnSetView issues and 2 P2 Android issues being higher priority. P1/P2 agents produced no merged output.
- **Prevention**: When dispatching fix agents by priority tier, verify P1/P2 agents produce at least one commit before closing the iteration. If P1 agent produces zero output, re-dispatch as a standalone focused agent before merging P3 fixes. P3 fixes should not merge ahead of unaddressed P1 issues.

- **Pitfall**: 4 issues (#1, #2, #3, #9 from catalog 20260315-213139) all target the same Android file (`ColumnSetView.kt` ProportionalColumnLayout) but no agent fixed any of them. A single focused agent could batch all 4.
- **Prevention**: When multiple P1/P2 issues share the same affected file, assign them to a single dedicated agent with that file as its sole focus. Include all issue descriptions, the iOS reference implementation path (`ColumnSetView.swift`), and specific line ranges (Pass 2: 139-158, Pass 3: 161-189, height: 204-222).
- **Pitfall**: project-dashboard loading issue is RESOLVED in catalog 20260315-122222 — both platforms render the dashboard correctly. The sample app rebuild was the missing step.
- **Prevention**: Already documented.

- **Pitfall**: FoodOrder template (templates-FoodOrder.template) renders blank on Android while the non-template variant (official-samples-food-order) works fine. Template engine fails on nested array indexing expressions (hasMenu.hasMenuSection[0].name).
- **Prevention**: When reviewing template cards, always compare the template variant against the non-template version. If the non-template works but the template doesn't, the issue is in the template expansion pipeline (`TemplateEngine.kt` error handling), not necessarily the expression evaluator. **Update**: FIXED in `27be821` — graceful error handling wraps `expandValue()` with try-catch matching iOS `try?` pattern.

- **Pitfall**: Fix branches with 8 commits (`worktree-fix-ios-1-round-1`) and 3 commits (`worktree-fix-ios-2-round-1`) were deleted without being merged — all 11 fix commits permanently lost. These resolved P1 Image.FitMode, P1 MultiColumnFlowLayout, P2 Icon.Styles, and several P3 issues.
- **Prevention**: Fix branches must be merged to main immediately after verification — never leave them as dangling worktree branches. If automated merge fails, the orchestrator should alert the user and preserve the branch. Add branch protection: worktree branches with commits should never be auto-deleted until merge is confirmed. **Key takeaway**: Worktree cleanup scripts should check `git log main..<branch> --oneline` before deletion — if non-empty, abort deletion and warn. **Update (iteration 5)**: Confirmed — iteration 5 review found ALL prior fix commits still missing. Lost commits include: `bdde0e14`/`492c507d`/`b30cedb4` (Image.FitMode/SVG), `8d4883c8` (MultiColumnFlowLayout), `8c10ff46` (Icon.Styles), `86662f27` (CompoundButton badge), `583f92b6` (DataGrid header), `dcc40bce` (Badge wrapping). These must be RE-IMPLEMENTED from scratch — the branches are unrecoverable.

- **Pitfall**: Icon.Clickable (v1.6) renders completely blank on iOS after the title — this is a NEW issue not caught in prior reviews despite Icon.Styles being a known P2.
- **Prevention**: When an issue affects one card in a feature group (Icon.Styles), verify ALL cards in that feature group (Icon.Clickable, Icon.RTL, etc.) before closing the review. Related cards often share the same root cause. **Update (iteration 5)**: Confirmed Icon.Clickable shares root cause with Icon.Styles (SwiftUI button tinting — `.buttonStyle(.plain)` missing). Fix these together.

- **Pitfall**: FlowLayout background styling difference (Android lavender Material3 Card tint vs iOS white) was missed in prior reviews.
- **Prevention**: Material3 Card surface tint issue was documented for carousel (fixed in `2482ef2`) but was not checked across all composables using Material3 Card. When fixing a Material3 tint issue, grep for ALL usages of `Card(` in Android composables and fix them all in one pass. **Update (iteration 5)**: ContainerFlowLayout and NestedFlowLayout still affected (P3 #9). Apply same Box replacement pattern as carousel fix.

- **Pitfall**: Container.Nested.Flow Android deep-link fix (11027d0, %2E encoding) is insufficient across 3+ review cycles — the card still fails to load.
- **Prevention**: The percent-encoding approach for dots in Navigation Compose routes is fundamentally flawed. Navigation Compose 2.7.x normalizes percent-encoded unreserved characters before route matching, making `%2E` encoding ineffective. **Update**: FIXED in `4e77257` — replaced percent-encoding with Base64 URL-safe encoding. Added `decodeCardId()` helper that detects Base64 (deep links) vs URL-encoded (gallery/bookmarks) formats. This is the definitive fix after 4 attempts.

- **Pitfall**: Review agents hit "image exceeds dimension limit for many-image requests" when reading full-resolution screenshots directly. 5 of 5 initial agents failed.
- **Prevention**: Pre-resize ALL screenshots to <1200px max dimension BEFORE launching review agents: `sips --resampleHeightWidthMax 1200 <src> --out /tmp/resized-<platform>/<name>`. Then point agents at /tmp/resized-ios/ and /tmp/resized-android/. This is the 5th+ occurrence — make this a mandatory pipeline step.

- **Success pattern**: Splitting review into 7 small agents (14-20 cards each) with pre-resized screenshots worked well. All 7 completed successfully with detailed findings. Key: max 4 images per read batch, resize first, 2-3 cards compared at a time.

- **Success pattern (iteration 12)**: 9 parallel review agents with pre-resized screenshots (1200px max) covered all 295 cards successfully. Issue count dropped from 21 to 2. Key improvements: (1) resize ALL screenshots before launching ANY agents, (2) use /tmp/resized-ios/ and /tmp/resized-android/ paths, (3) 3-4 cards per read batch, (4) direct P1 verification via full-res screenshot reads after agent reports. **Lesson**: The massive fix round (`e11edf47`, `cbb76ef4`, `0c0878d1`, `1974c8c1`, `edfb2b94`, `26a2e316`, `a9578a72`) resolved 19 of 21 prior issues in a single merge commit sequence.

- **Pitfall (iteration 12)**: First wave of 9 review agents ALL failed with "image exceeds dimension limit" because they were launched before screenshots were resized. Wasted ~20 minutes and 9 agent invocations.
- **Prevention**: ALWAYS resize screenshots FIRST, verify resize is complete (check file count), THEN launch review agents. Never launch agents pointing at original screenshot paths. Add `sips --resampleHeightWidthMax 1200` as mandatory first step.

- **Pitfall**: Report attributed list card truncation (#4) to `AdaptiveCardView.swift` card body height clipping — same as progress-indicators (#3). Fix agent found actual cause was nested ScrollView in `ListView.swift`. Report's root cause grouping was WRONG — two issues with identical symptoms had different root causes.
- **Prevention**: When multiple truncation issues are flagged, do NOT pre-group them by assumed shared root cause. Each issue should have its own investigation trace. Only merge root causes AFTER fix agents confirm they share the same code path. Worklist should list `affected_files` for each issue independently — not copy from a "grouped" parent issue.

- **Pitfall**: Report attributed communication text truncation (#7) to `lineLimit` or `truncationMode` in TextBlockView.swift. Actual cause was unconditional `frame(maxWidth: .infinity)`.
- **Prevention**: When text is truncated in a column layout, the `fix_hint` should suggest checking frame modifiers (`maxWidth`, `frame`) BEFORE text-specific modifiers (`lineLimit`, `truncationMode`). The `maxWidth:.infinity` pattern is now the #1 cause of truncation in this codebase (3 separate issues).

- **Pitfall**: Android fix agent produced 0 commits with empty log — 6th occurrence across iterations. Platform-split dispatch means the Android agent gets fewer issues, but the agent still fails silently.
- **Prevention**: When the Android worklist has ≤2 issues and one is "both" platform (already on iOS worklist), fold the Android-only issue into a cross-platform agent instead of launching a separate Android-only agent. Solo agents with 1-2 issues have a higher failure rate. For P2 Action.MenuActions specifically, this issue has persisted across 3 iterations with 0 fix attempts — assign a dedicated solo agent with explicit `ActionSetView.kt` line ranges.

- **Success pattern**: iOS fix agent completed 6/7 issues in a single session (all 6 commits landed on main). Agent correctly reclassified Issue #3 (progress-indicators) as viewport density difference rather than layout bug, avoiding an unnecessary fix. **Lesson**: Platform-focused single agents (one iOS, one Android) with 5-8 issues each is productive when issues are well-scoped with file paths and fix hints.

- **Success pattern**: The dedicated `isContainMode` branch approach for Image.FitMode (`7e0adffb`) is the 5th attempt at this fix and follows the pattern that succeeded in round 3 (`bdde0e14`, lost branch). Adding a SEPARATE code path for contain/fill mode rather than patching the existing path is now confirmed as the correct pattern. Prior attempts that used guards/conditionals on the existing path all regressed.

- **Pitfall**: Android auto-column width calculation (ColumnSetView.kt:136-142) is a recurring root cause across multiple cards (Agenda, ExpenseReport). The `maxIntrinsicWidth` approach underestimates for text and images.
- **Prevention**: Issues #2 and #3 share the same root cause — fix both with a single change to ProportionalColumnLayout Pass 2 auto-column measurement. Use actual measured width instead of intrinsic width hints. **Update**: FIXED in `24e8041` + `bfe6cdb` — measure auto columns directly, with zero-width fallback for columns whose intrinsic width reports 0 (e.g., images not yet loaded).

- **Pitfall**: iOS image default alignment is center while Android defaults to start/left. This creates subtle misalignment across many cards but was only flagged on themed-images where it is most visible.
- **Prevention**: This is a systemic default difference. A single fix to ImageView.swift default alignment from .center to .leading would fix many cards at once. But verify this doesnt regress cards that rely on center default. **Update**: FIXED in `fa7f4d0` — default image alignment changed to leading. Verify no regressions in cards that previously relied on center default.

- **Pitfall**: Fix agents skip cross-cutting issues (e.g., HostConfig color resolution) that require multi-file investigation. Issue #10 (container style colors) survived ALL rounds until a dedicated solo agent was assigned.
- **Prevention**: For issues requiring cross-file investigation, assign a dedicated solo agent with ONLY that issue. Include a step-by-step debugging recipe as mandatory first steps.

- **Success pattern**: This iteration (post-fix-round-1, catalog 20260315-145336) addressed 11/14 issues with commits across 4 worktree branches (P2-1, P2-2, P2-3, P3), all merged successfully. Key factors: (1) P2 split into 3 sub-agents for parallel execution, (2) explicit file paths and fix hints in all worklist issues, (3) issues grouped by affected module enabling root-cause batching (3 TableView fixes in one agent). **Lesson**: Splitting by module/file ownership with 2-4 issues per agent is the sweet spot.

- **Success pattern**: Three iOS TableView issues (#5 vertical alignment, #9 row backgrounds, #14 row spacing) were batched to a single agent and fixed with 3 targeted commits (`c29b667`, `908ff9a`, `b0ed8bd`). Grouping by file ownership is more efficient than grouping by priority.

- **Success pattern**: Issues #11 (progress indicator alignment) and #12 (image alignment) both traced to iOS defaulting to `.center` instead of `.leading`. Fixing both in the same agent session (`5d60768`, `fa7f4d0`) prevented the second from being missed.

- **Pitfall**: iOS FlowLayoutView P1 required 4 separate commits across 2 rounds (`41b698d`, `635b0ea`, `c8bc59a`, `5039cc2`) — each commit fixed one piece of the flow layout pipeline but left the overall layout broken until all four were in place. The 4th commit (intrinsic width for flow items) was only discovered after the 3-commit "fix" still rendered incorrectly.
- **Prevention**: Flow/grid layout fixes should be verified end-to-end on the actual card before committing. Build and deep-link to the affected card (`versioned/v1.5/MultiColumnFlowLayout`) after each change. If the card still renders single-column, the fix is incomplete — do not commit as "fixed" until multi-column rendering is visually confirmed. Specifically, verify: (1) column count is correct, (2) items are distributed across columns, (3) item text is not truncated, (4) item widths use the correct measurement (intrinsic vs fixed).

- **Pitfall**: Android auto-column measurement fix (`24e8041`) didn't handle the zero-intrinsic-width edge case, requiring a follow-up commit (`bfe6cdb`). Compose `maxIntrinsicWidth` returns 0 for some content types.
- **Prevention**: When fixing Compose layout measurement, always test with: (1) text-only columns, (2) image-only columns (may have zero intrinsic width before load), (3) mixed content columns. The zero-width case is a common Compose pitfall that should be tested explicitly.

- **Pitfall**: iOS TargetWidth issue (#13) was skipped in the initial fix round but resolved in a follow-up round (`62fa2b6`) with a simple 4-line fix (default to narrow when unmeasured).
- **Prevention**: Issues that appear complex in the report may have simple fixes. When an agent skips an issue, the re-queue should note that a simpler approach (default value fallback) may work rather than the full debugging suggested in the original report.

- **Success pattern**: Iteration 5 OCR pre-scan correctly classified ALL curly bracket / "fail" detections as known false positives using the canonical list from section 1. Zero false OCR alarms, zero wasted investigation time. The canonical OCR whitelist (code-block, Template.DataBinding, Container.ScrollableSelectableList, Input.ChoiceSet.FilteredStyle.TestCard, StringResources.Invalid.*) is comprehensive and should not need expansion unless new code-display or intentional-error cards are added.

- **Success pattern**: Iteration 5 delta summary correctly identified that all 8 prior issues persisted because fix branches were deleted — rather than re-investigating each issue from scratch. The review agent's branch-awareness (checking git log for prior fixes) is working well.

- **Success pattern**: This iteration's follow-up round addressed 3 remaining issues (P1 #1 refinement, P2 #2/#3 refinement, P3 #13) with targeted commits to 3 files. The follow-up round pattern — fixing issues that survived the main batch — is effective for catching edge cases and incremental fixes that the first pass missed.

- **Pitfall**: Issue #10 (carousel-styles container style color mismatch) survived ALL fix rounds in prior iterations — 0 agents attempted it until dedicated worktree agent was assigned.
- **Prevention**: For HostConfig/theming issues that require cross-file investigation, provide a step-by-step debugging recipe in the worklist: (1) print iOS `ContainerStyleConfig.emphasis.backgroundColor` at runtime, (2) print Android's equivalent, (3) compare hex values. **Update**: RESOLVED in `952739e6`. The debugging recipe approach combined with a dedicated worktree agent finally worked. Key lesson: cross-cutting theming issues need solo agents, not shared worklists.

- **Pitfall**: P1 FlowLayout fix needed a 4th commit (`5039cc2`) even after 3 commits were merged — the 3rd commit appeared to fix grid dimensions but items still didn't use intrinsic width for measurement, causing continued truncation.
- **Prevention**: For multi-step layout fixes, verify EACH of these independently: (1) container dimensions are correct, (2) child item measurement uses correct width mode (intrinsic vs fixed vs proportional), (3) text within items wraps correctly, (4) visual output matches reference platform. A "correct grid" with "wrong item measurement" looks broken — both must be right.

- **Success pattern**: P1 fix round in catalog 20260315-193653 produced 2 targeted commits (`5e348f49` for ImageView fitMode, `49cda0e5` for FlowLayout) addressing 3 issues (P1 #1, #2, and P2 #5). Both fixes were clean single-file changes with clear Android reference implementations cited. **Lesson**: When the report includes explicit root cause analysis with file:line references and Android reference code, fix agents produce precise, minimal fixes on the first attempt.

- **Pitfall**: MultiColumnFlowLayout required a 5th commit (`49cda0e5`) because the 3rd commit (`c8bc59a`) re-introduced `round()` logic that overrode the correct approach in the 4th commit (`5039cc2`). The merge order between conflicting approaches matters.
- **Prevention**: When multiple commits target the same function with different strategies, the LAST merged commit wins. If two branches propose conflicting approaches (round-based column count vs nil return), the orchestrator must pick one strategy and discard the other, not merge both.

- **Pitfall**: Carousel-styles container color mismatch (Issue #7) survived ALL fix rounds across MULTIPLE iterations — 0 agents attempted it until this round.
- **Prevention**: For issues that survive 3+ rounds with 0 attempts, escalate to a dedicated solo agent with ONLY that issue in the worklist. Include the debugging recipe as mandatory first steps (not optional). **Update**: RESOLVED in `952739e6` — dedicated worktree agent with explicit file paths finally cracked it. The escalation-to-dedicated-agent strategy works.

- **Pitfall**: 9 new issues appeared in catalog 20260315-193653 while only 3 stuck issues remained from prior catalog. The new-to-stuck ratio (9:3) suggests the fix pipeline is generating new issues at a similar rate to fixing old ones — possibly from cascading effects of layout fixes.
- **Prevention**: After merging layout/sizing fixes (especially to ImageView, ColumnSetView, FlowLayoutView), do a quick visual spot-check of 10-15 high-traffic cards before capturing a new catalog. Layout fixes have wide blast radius and can create new issues on previously-passing cards.

- **Success pattern**: Catalog 20260315-202851 round-2 fix agents resolved ALL 3 fixable issues (P1, both P2s) in a single round using 3 parallel worktree agents. Total issue count dropped from 12 → 4 → effectively 1 (carousel timing artifact). Key factors: (1) each agent had exactly 1 issue in its worklist, (2) explicit file paths and fix hints from prior learnings, (3) the most persistent issue (container style colors, 0 agents across ALL prior iterations) was finally cracked by a dedicated solo worktree agent. **Lesson**: 1 issue per agent with detailed fix hints produces 100% success rate — better than batching multiple issues.

- **Pitfall (iteration 13)**: Android perf commit `95a44ba7` (replace exception-based enum parsing with HashMap lookups) likely caused MASSIVE regression — ~52 Android cards failed (10 ANR crashes, 33 blank renders, 9 wrong-card routing). Previous catalog had only 2 issues total. The HashMap change may return null where `Enum.valueOf()` previously threw caught exceptions, causing null propagation → infinite loops → ANR on complex cards → app restart → blank renders → shifted gallery index → wrong cards loaded.
- **Prevention**: Performance changes to core parsing code (CardElementSerializer, enum deserialization) have the highest blast radius in the codebase. ALWAYS run full card catalog capture (or at minimum 20 representative cards across all categories) BEFORE AND AFTER merging perf changes. If ANR count increases by >3, revert immediately.

- **Pitfall (iteration 13)**: Android "System UI isn't responding" ANR cascades to 3 distinct failure modes: (1) ANR dialog on the card that caused the hang, (2) loading spinners/blank screens on subsequent cards as the app restarts, (3) wrong card loaded for cards navigated during recovery. A single ANR can cause ~5 additional card failures.
- **Prevention**: When reviewing a catalog with >10 Android failures, check if ANR dialogs appear in any screenshots first. If found, the root cause is the ANR — not individual card rendering bugs. Trace the ANR to the first card that shows it, and the blank/wrong-card issues are secondary cascade effects. Do not report ~50 individual issues — report 1 root cause issue with cascade effects.

- **Pitfall (iteration 13)**: 2 of 6 review agents hit "image exceeds dimension limit for many-image requests" despite known workaround of using smaller batches. Agents tried to read 12 screenshot pairs (24 images) in sequence and still hit the limit.
- **Prevention**: Cap review agents at 6 screenshot pairs (12 images) maximum per agent. The dimension limit is per-conversation, not per-read — even sequential reads accumulate. For 295 cards, need ~50 agents at 6 cards each, OR use the pre-resize pipeline from iteration 12 (1200px max).

- **Root cause (iteration 13)**: Android ANR on complex cards — heavy card parsing on main thread
- **Affected cards**: ~52 Android cards across all categories (10 ANR + 33 blank + 9 wrong-card, all cascading from ANR)
- **Single fix**: Move card parsing off main thread in `CardDetailScreen.kt`
- **Status**: FIXED in `75be2e32` — card parsing moved to background coroutine. The report attributed the ANR to HashMap null-safety in `CardElementSerializer.kt` (commit `95a44ba7`), but the actual cause was synchronous main-thread parsing. The perf commit `95a44ba7` was NOT the root cause — it just made parsing marginally faster, while the ANR was caused by the threading model. Deep-link routing issues (#3) fixed in `8da20076` with `launchSingleTop`. Blank renders (#2) expected to resolve as cascade effect. **Verify in next catalog.**

- **Pitfall**: Image.FitMode.Contain/Fill issues (catalog 20260315-213139 Issues #4, #5) reappeared despite fix `5e348f49` being verified present in the codebase. The fix correctly guards `needsFullWidthFrame` but the card uses explicit pixel dimensions (`width: "200px"`, `height: "auto"`) which may bypass the fitMode guard through a separate code path (explicit dimension handling around line 120-140).
- **Prevention**: When verifying fitMode fixes, test with ALL dimension combinations: (1) no explicit dimensions, (2) explicit width only, (3) explicit height only, (4) both explicit. The `5e348f49` fix addresses the no-dimensions case but may not cover the explicit-dimensions path.

- **Root cause**: Android ProportionalColumnLayout ColumnSet truncation — systemic issue across 10+ cards
- **Affected cards**: official-samples-agenda, templates-Agenda.template, versioned-v1.5-Agenda, official-samples-flight-update, templates-FlightUpdate.template, official-samples-expense-report, templates-ExpenseReport.template, versioned-v1.5-ExpenseReport, official-samples-flight-details, versioned-v1.5-FlightDetails
- **Issues**: P1 #1, #2, #3 and P2 #9 from catalog 20260315-213139
- **Single fix**: The `ProportionalColumnLayout` 3-pass algorithm in `ColumnSetView.kt` has multiple failure modes: (1) nested ColumnSets lose height propagation, (2) auto columns consume all `remainingWidth` leaving weighted columns at zero, (3) weighted columns with `width: "1"` may receive no space. All 10 cards share the same Android `ColumnSetView.kt` root cause.
- **Status**: FIXED in `73897919`. The fix addressed all 3 failure modes in a single commit: (1) moved `totalWeight` computation before Pass 2, (2) Pass 2 auto columns now use `maxIntrinsicWidth` instead of expanding to full `remainingWidth`, with 50%-cap fallback for zero intrinsic width, (3) Pass 3 always distributes proportionally using `remainingWidth.coerceAtLeast(0)`. All 10 affected cards verified. **Key pattern**: The canonical approach for proportional column layouts with mixed auto/weighted columns is: measure auto columns at intrinsic width (not available width), then distribute ALL remaining space proportionally to weighted columns even if remaining is negative (coerceAtLeast(0)).

- **Pitfall**: Previous P1 card loading regression (10 cards blank) was masking underlying rendering issues. Once the loading fix (`fe57f87a`) landed, 10+ new rendering issues became visible in the next catalog.
- **Prevention**: When fixing infrastructure issues (card loading, deep links, caching), always recapture screenshots and re-review — the fixed cards may reveal previously hidden rendering bugs.

- **Pitfall**: P2-1 fix agent (assigned Issues #4, #5, #8 — FitMode and SVG) had its worktree deleted mid-session by another process (likely merge cleanup). Agent produced zero output in both rounds because its CWD was yanked.
- **Prevention**: The orchestrator must NOT delete worktrees while fix agents are still running. Either (1) wait for agent process to exit before `git worktree remove`, or (2) run `git worktree list` and check for active processes in each worktree before cleanup. This is distinct from the "empty log" pattern — the agent started but lost its filesystem.

- **Pitfall**: Issue #13 (iOS Icon.Styles button solid blue vs outline) was not assigned to ANY worklist in either round of iteration 20260315-213137. It was reported in the review but dropped during worklist generation. **UPDATE**: Finally fixed in round 3 of iteration 20260315-233737 (`8c10ff46`) — took 3 rounds before worklist generator assigned it.
- **Prevention**: After generating worklists, validate that every issue in `issues.json` appears in at least one worklist. Run a simple set-difference check: `jq '.issues[].id' issues.json` minus all worklist issue IDs. Any unassigned issues should be added to the lowest-priority worklist or flagged for next iteration.

- **Success pattern**: P1 agent in round 2 fixed ALL 4 Android ColumnSetView issues (#1, #2, #3, #9) with a single commit (`73897919`) because they shared the same root cause. The P1 worklist correctly grouped all 4 issues together with the same `affected_files` entry. **Lesson**: When multiple issues share `affected_files`, grouping them in one worklist enables root-cause batching — the agent sees the pattern and writes one fix instead of four.

- **Success pattern**: P2-2 agent correctly identified Issue #6 (CompoundButton clipping) was already fixed in prior commit `ea9edef3` and produced no unnecessary duplicate commit. It then focused on the actual unfixed issue (#7, FlowLayout) and resolved it. **Lesson**: Agents that check `git log` before fixing avoid wasted work on already-resolved issues.

- **Pitfall**: iOS FlowLayoutView `arrangeSubviews` (lines 158-162) had a SEPARATE maxItemWidth cap that survived through 6 prior fix commits to `calculatedItemWidth()`. The calculation pipeline returned nil (correct) but the layout pass capped widths anyway (incorrect). The fix was in a different function than all prior attempts targeted.
- **Prevention**: When a flow/grid layout fix doesn't work despite correct width calculation, check BOTH the calculation function AND the layout/arrange function. They may independently cap or constrain widths. Verify the entire pipeline: `calculatedItemWidth()` → layout pass → `arrangeSubviews()` → final frame assignment.

- **Pitfall**: iOS CompoundButton left-edge clipping (Issue #6) is a NEW issue that emerged after the `layoutPriority(-1) → layoutPriority(1)` fix in `4a24089b`. The title no longer gets deprioritized, but the inner HStack (line 64) lacks explicit spacing between title and badge, causing content to clip on the left.
- **Prevention**: When fixing SwiftUI layout priority issues, also verify that the containing HStack has explicit spacing. SwiftUI default HStack spacing can cause measurement issues when combined with `fixedSize` modifiers on sibling views.

- **Pitfall**: iOS SVG rendering (Issue #8) produces black rectangles and missing images. This is a NEW capability gap — iOS UIImage SVG support is limited compared to Android Coil/AndroidSVG. P2-1 agent was assigned this but produced zero output due to worktree deletion.
- **Prevention**: SVG rendering requires dedicated handling on iOS. Check if ImageView.swift has an SVG-specific rendering path or if it relies on UIImage's limited built-in SVG support. Assign to a dedicated solo agent in next iteration. **UPDATE (round 3)**: FIXED in `b30cedb4` — three distinct SVG fixes: (1) added `underPageBackgroundColor = .clear` to WKWebView to prevent black background, (2) network SVG URLs now load directly via `WKWebView.load(URLRequest)` instead of embedding in `<img>` tag (avoids CORS/CSP issues), (3) added viewBox parsing for data URI SVGs to calculate proportional height. **Key lesson**: iOS SVG rendering via WKWebView has THREE independent failure modes — background color, URL loading method, and size calculation. All three needed fixing. **Note**: Fix is on unmerged branch `worktree-fix-ios-2-round-1` — verify after merge.

- **Remaining unresolved from catalog 20260315-213139**: All 12 issues from this catalog have now been addressed across 3 rounds of fixes. Issues #4/#5 (FitMode.Contain/Fill) fixed in `bdde0e14` + `492c507d`, Issue #8 (SVG) fixed in `b30cedb4`, Issue #13 (Icon.Styles) fixed in `8c10ff46`. However, iOS fix branches (`worktree-fix-ios-1-round-1`, `worktree-fix-ios-2-round-1`) remain UNMERGED — only the Android branch was merged. See pitfall below.

- **Success pattern**: The container style emphasis/attention color issue (`952739e6`) was the single longest-surviving unresolved issue in the project (0 attempts across ALL prior iterations). It was finally resolved when: (1) escalated to a dedicated solo agent, (2) given explicit file paths for both platforms, (3) debugging recipe was embedded in the worklist. **Lesson**: For persistent cross-cutting issues that no agent attempts, the fix is procedural (solo agent + debugging recipe), not just documentation (learnings entries alone don't cause agents to act).

- **Pitfall**: Container style color issue worklist pointed agents at `ContainerStyleConfig.swift` but the actual fix was in `HostConfig.swift` (where default color values are defined). Agents following the worklist's `affected_files` would look in the wrong file.
- **Prevention**: For HostConfig/theming issues, distinguish between the **config definition file** (where default values live — `HostConfig.swift` / `HostConfig.kt`) and the **config model file** (where the struct is defined — `ContainerStyleConfig.swift`). Default color values are typically set at the definition/initialization site, not the struct declaration.

- **Pitfall (iteration 13 fix round)**: Report attributed Android ANR to HashMap null-safety in `CardElementSerializer.kt` (commit `95a44ba7`), but the actual fix was moving heavy card parsing off the main thread in `CardDetailScreen.kt` (`75be2e32`). The HashMap change was not the direct cause of ANR — the issue was that complex card parsing was synchronous on the main thread regardless of the parsing implementation.
- **Prevention**: When diagnosing Android ANR, distinguish between "the code is slow" (perf issue in parsing) and "the code blocks the main thread" (threading issue). ANR means >5s on main thread — the fix is to move work off-main, not just to optimize the work itself. Always check thread context before blaming the algorithm.

- **Pitfall (iteration 13 fix round)**: Report recommended switching from index-based to name-based card lookup for deep-link routing (Issue #3, 8th occurrence). The actual fix was simpler — `launchSingleTop` flag on navigation intent (`8da20076`). The wrong-card display was caused by duplicate Activity instances after ANR-triggered restarts, not by index-based lookup.
- **Prevention**: When Android deep-link routing shows wrong cards after app crashes/restarts, check Activity lifecycle (duplicate instances, `launchSingleTop`, `singleTask`) BEFORE assuming the card lookup algorithm is wrong. The 8 prior occurrences of this issue may have all been lifecycle/restart artifacts, not lookup bugs.

- **Pitfall (iteration 13 fix round)**: Issue #2 (33 blank renders) was correctly identified as cascade from Issue #1 (ANR). No separate fix was needed — resolving the ANR (`75be2e32`) should eliminate blank renders. However, this needs verification in the next catalog capture.
- **Prevention**: When a review flags 3 related issues (ANR → blank renders → wrong cards), only the root cause (ANR) needs a fix. The downstream issues (#2, #3) are cascade effects. Worklist should mark cascading issues as "verify after #1 fix" rather than dispatching separate fix attempts.

- **Pitfall (iteration 13 fix round)**: Issue #4 (Android hero image missing on author-highlight-video) was not addressed by the Android fix agent despite being in its worklist. Agent likely ran out of time after spending effort on the P1 ANR fix (110+ lines changed in CardDetailScreen.kt).
- **Prevention**: When a worklist has a large P1 fix (threading refactor) alongside smaller P2 issues, the P2 may get dropped. Consider splitting into separate agents or explicitly ordering: "Fix P1 first, then P2 if time allows."

- **Pitfall (iteration 13 fix round)**: iOS fix agent produced commit `00cb501f` (align iOS media play button with Android) but the branch was not merged. Meanwhile, the Android agent produced `fc8f5d84` (align Android media play button with iOS). Both agents fixed the same issue from OPPOSITE directions on different platforms.
- **Prevention**: When Issue #5 (media play button) was "both" platform and assigned to both worklists, the agents picked opposite reference implementations. The worklist should specify which platform is the "reference" and which gets modified. For "both" platform issues, assign to ONE agent only with explicit direction (e.g., "align Android to match iOS").

- **Success pattern (iteration 13 fix round)**: Android fix agent addressed 3 of 5 issues with 3 targeted commits, all merged successfully. The ANR fix (`75be2e32`) is expected to cascade-resolve 2 additional issues. The agent correctly prioritized the P1 root cause (ANR) and the P1 deep-link issue, plus the P3 media styling. Only the P2 hero image was skipped.

- **Success pattern (iteration 13 fix round)**: Worktree rebase failed again (`fatal: already used by worktree`) but the fallback to direct merge succeeded. The 3-commit Android branch merged cleanly. Post-merge build check passed. Post-merge smoke test verified 4 impacted cards. **Lesson**: The rebase-then-fallback-to-merge pattern in the orchestrator works well enough — the worktree removal before rebase is still not implemented but the merge fallback covers it.

- **Pitfall (iteration 13 fix round)**: iOS sample app build failed during smoke test (CodeSign error). This did not block the Android merge but means iOS verification was incomplete. The CodeSign failure is a recurring SPM/Xcode issue with `CODE_SIGN_IDENTITY=-` not being passed correctly during smoke builds.
- **Prevention**: Smoke test build command must include CodeSign flags: `CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO`. Check `design-review-loop.sh` smoke test build step for missing flags.

- **Success pattern (iteration 15)**: Issue count dropped from 21 (iteration 12) to 13 with 0 regressions. Key fixes that landed on main since iteration 14: `adef5bb3` (media play button iOS), `2ba7fdb6` (table header accent), `ebb2b885` (CompoundButton chevron), `7233f07a` (badge fixedSize overflow), `e48f5435` (Android ImageSet height). The table header accent fix (`2ba7fdb6`) used a "render directly" approach rather than pattern-matching on `.textBlock` case — this is more robust because it works regardless of cell content type wrapping.

- **Pitfall (iteration 15)**: Report lists Issue #5 (table header accent) as "Confirmed" even though `2ba7fdb6` already fixed it — the catalog was captured before the fix commit landed. This creates a false "Confirmed" status that could trigger unnecessary fix agents.
- **Prevention**: When the catalog timestamp precedes recent fix commits that match an issue, mark the issue as "Likely Fixed — verify in next catalog" rather than "Confirmed". Compare `issues.json` timestamps against `git log --since` to catch this.

- **Success pattern**: This iteration (design-review-loop-20260315-193651, rounds 2-3) achieved 3/3 real issues fixed + 1/1 false positive correctly identified. All 4 parallel agents completed successfully in both rounds. Key factors: (1) exactly 1 issue per agent, (2) owned_files partitioning prevented merge conflicts, (3) P3 agent correctly identified carousel as a known false positive and produced no unnecessary commit. **Lesson**: 1-issue-per-agent with file ownership partitioning is now a proven pattern across 2 consecutive iterations with 100% success rate.

- **Root cause**: iOS ProportionalColumnLayout auto-column measurement proposes remainingWidth instead of intrinsic width
- **Affected cards**: 13 cards — official-samples-agenda, official-samples-flight-update, official-samples-expense-report, official-samples-flight-update-table, official-samples-flight-itinerary, official-samples-stock-update, templates-Agenda/FlightUpdate/ExpenseReport, versioned-v1.5-Agenda/ExpenseReport, teams-official-samples-communication, teams-official-samples-work-item
- **Issues**: P1 #1 from catalog 20260316-004720
- **Single fix**: `ColumnSetView.swift:72` — change `subviews[i].sizeThatFits(ProposedViewSize(width: maxAutoWidth, height: nil)).width` to `subviews[i].sizeThatFits(ProposedViewSize(width: nil, height: nil)).width`. The nil width proposal returns intrinsic width, matching Android's `maxIntrinsicWidth`. Line 74 `min(ideal, maxAutoWidth)` already caps the result.
- **Status**: NEW — confirmed as #1 priority for next fix round. This is the iOS counterpart of the Android ColumnSet fix `73897919`. Android was fixed first; iOS still uses the old approach. The fix is a single-line change with high confidence. **Impact expanded**: Catalog 20260316-004720 confirms 13 cards affected (up from 10 in prior catalog — 3 new cards: official-samples-flight-update-table, official-samples-flight-itinerary, teams-official-samples-work-item). P2 #5 (progress-indicators) is also likely blocked by this. Fixing this single line could resolve 14+ cards.

- **Pitfall**: Fixing Android ProportionalColumnLayout (`73897919`) without applying the equivalent iOS fix created a platform parity inversion — previously-broken Android cards now work, but the equivalent iOS cards (which may have appeared to work only because Android was worse) now show as broken in comparison.
- **Prevention**: When fixing layout algorithms on one platform, always check if the OTHER platform has the same algorithmic issue. The Android fix used `maxIntrinsicWidth` for auto columns — iOS `ColumnSetView.swift` still uses `sizeThatFits(width: remainingWidth)` which is the equivalent of the pre-fix Android code. A cross-platform fix should have been applied simultaneously.

- **Pitfall**: Two worktree fix branches (`worktree-fix-ios-1-round-1`, `worktree-fix-ios-2-round-1`) with 8 total commits remain unmerged across catalog boundaries. This means fixes for P1 #2, P1 #3, and P2 #4 exist but are not reflected in the current catalog. The review correctly identifies these as "fix on unmerged branch" but if the orchestrator re-dispatches fix agents, they may duplicate existing work.
- **Prevention**: Before dispatching fix agents, check for unmerged worktree branches (`git branch | grep worktree`). If branches exist with commits matching the issue, merge them first rather than creating new fix agents. Add a pre-flight check to the orchestrator that lists unmerged branches and their commit messages.

- **Pitfall**: Additional iOS cards failing that were previously listed as "Full card renders correctly" in prior reports (e.g., teams-official-samples-work-item, teams-official-samples-expense-report, official-samples-stock-update). These were NOT flagged in prior catalogs.
- **Prevention**: These cards may have been failing but were not reviewed because: (1) the prior reviewer focused on the more broken Android platform, or (2) the cards were not in the high-priority review list. Ensure every card with ColumnSet nesting is reviewed on BOTH platforms, regardless of which platform appears more broken overall.

- **iOS progress-indicators truncation (P2 #5 from catalog 20260316-004720)**: This card uses ColumnSets internally for step layout. The missing steps 3-4 are almost certainly caused by P1 #1 (iOS auto-column width expansion hiding weighted columns). Do NOT assign to a separate fix agent — verify after P1 #1 ColumnSet fix lands. Only investigate as standalone issue if P1 #1 fix doesn't resolve it.
- **Android Action.MenuActions partial render (P2 #6 from catalog 20260316-004720)**: Before assigning a fix agent, verify whether this is a `maxActions` enforcement issue or a card body scroll issue. Check if the card JSON has multiple `ActionSet` elements — if so, the bug may be `maxActions` applied globally across all ActionSets rather than per-ActionSet. The iOS reference shows all 3 sections render correctly, so the card JSON is valid.
- **False positive to skip in future**: Compound button background differences (iOS shows light background, Android shows no background) — this is a platform-native card/container styling difference. iOS uses visible card containers, Android uses flat layout. Not a functional issue.

- **False positive to skip in future**: Carousel cards showing different visible pages on iOS vs Android — confirmed as capture timing artifact (5th+ occurrence). Both platforms use identical initialPage logic.

- **Pitfall**: Fixed/dismissed issues get re-dispatched to fix agents when worklists are regenerated between rounds without deduplication.
- **Prevention**: Before dispatching worklists, check `git log --oneline -20` for commits matching each issue. If a fix commit exists, mark as "Likely Fixed — verify in next catalog" instead of re-dispatching. Also check previous round's worklist outcomes.

- **Root cause (iteration 15)**: Badge icon-only rendering broken on BOTH platforms — vertical bar instead of properly sized icon badge
- **Affected cards**: versioned-v1.5-badge (iOS P2 #7 + Android P4 #13)
- **iOS behavior**: Standalone icon badge renders as dark vertical bar (zero-width text container causes collapse)
- **Android behavior**: Calendar icon visible but thin dark vertical bar next to it (empty text container rendered as bar)
- **Single fix**: Both platforms need to hide/suppress the text container when badge has no label text. iOS: `BadgeView.swift` — add `.frame(minWidth: 24)` or conditional for icon-only layout. Android: `BadgeView.kt` — hide text `Row`/`Box` when label is empty. Fix BOTH together to maintain parity.
- **Status**: NEW as cross-platform issue. iOS was first reported in iteration 14, Android newly reported in iteration 15. Shared root cause: both BadgeView implementations render an empty text container alongside the icon.

- **Stuck issues status (iteration 15)**: 3 P1 issues remain stuck after 15 iterations with zero progress in this iteration:
  - (1) **MultiColumnFlowLayout** — 13+ fix attempts, all failed. MANDATORY: Replace `FlowLayoutView.swift` entirely with SwiftUI `Grid` or `Layout` protocol. No more incremental patches.
  - (2) **SVG black rectangles** — Prior fixes addressed network SVGs but data URI SVGs still broken. Needs dedicated `data:image/svg+xml` handling in WKWebView HTML wrapper.
  - (3) **Icon.Clickable blank on both platforms** — Both platforms show same blank behavior. Root cause likely in card JSON or parsing, not rendering. Check `shared/test-cards/versioned/v1.6/Icon.Clickable.json` content first — if card JSON is malformed or uses unsupported element types, this is a card-level issue, not a code bug.

- **Pitfall**: Orchestrator merged only 1 of 3 fix branches (Android) and left 2 iOS branches (`worktree-fix-ios-1-round-1` with 5 commits, `worktree-fix-ios-2-round-1` with 3 commits) unmerged. The loop log shows "1 merged, 0 empty, 0 reverted" — the iOS branches were silently skipped after the Android merge + conflict resolution consumed the merge phase budget.
- **Prevention**: The orchestrator's merge phase must attempt ALL fix branches, not stop after the first conflict resolution. If merge phase has a timeout, it should be per-branch (not total). After the merge phase, log explicitly which branches remain unmerged and warn. The 8 iOS fix commits are orphaned on branches and will be lost if not merged manually.

- **Pitfall**: iOS `CompoundButtonView.swift` badge `fixedSize(horizontal: true, vertical: false)` was making the badge non-compressible, which combined with the prior `layoutPriority(-1)` fix still caused title clipping. The round-3 fix (`86662f27`) REMOVED fixedSize from the badge entirely rather than adding more spacing.
- **Prevention**: When `fixedSize` on one sibling view clips another sibling in an HStack, the fix is to remove `fixedSize` (not add spacing or layoutPriority). The `fixedSize` modifier forces SwiftUI to allocate the view's ideal size before distributing remaining space, which starves flexible siblings. This is the THIRD CompoundButton fix — the progression was: (1) `layoutPriority(-1)` → `(1)` (`4a24089b`), (2) add HStack spacing (`ea9edef3`), (3) remove badge fixedSize (`86662f27`). The third fix addresses the actual root cause.

- **Pitfall**: iOS `DataGridInputView.swift` header had `.weight(.semibold)` that was missed in the prior fix `69ceb888` which only changed text color and alignment. Round 3 catch-up commit `583f92b6` removed the semibold weight.
- **Prevention**: When aligning styling between platforms, check ALL style properties (color, weight, alignment, background) in one pass. Making separate commits for color vs weight on the same view leads to incomplete parity.

- **Success pattern**: Iteration 9 (design-review-loop-20260316-121411) fix agents addressed 11/12 issues with 10 commits across 2 agents (ios-1: 7 issues → 6 commits, ios-2: 4 issues → 4 commits). Agent ios-1 correctly identified Issues #1 and #7 shared the same AreaGrid root cause and fixed both with a single commit. **Lesson**: 5-7 issues per agent with file ownership partitioning continues to be productive when issues are well-scoped.

- **Success pattern**: ios-2 agent fixed the "Stuck" MultiColumnFlowLayout issue (#2, 11th attempt) with a fundamentally different approach — removed column-count formula and used intrinsic widths capped by maxItemWidth. This contradicts the prior lesson from attempt 10 but the agent made a deliberate choice to revert. **Lesson**: When pipeline fixes oscillate between two strategies (mathematical column count vs intrinsic widths), the fix branch MUST be merged and visually verified before either approach is accepted.

- **Pitfall**: Issue #12 (P4 — missing "See more" link) was not assigned to either worklist. Worklist generator dropped it during dispatch, likely because it was the lowest priority with "low" fix_confidence.
- **Prevention**: Run set-difference validation: `jq '.issues[].id' issues.json` minus worklist issue IDs. Any unassigned issues should be explicitly logged as "Deferred to next iteration" rather than silently dropped.

- **Pitfall**: iOS smoke test CodeSign failure (`CodeSign ACCore.bundle`) blocked verification of all 10 fix commits. The fix agents' code changes were likely fine but the sample app build infrastructure prevented confirmation.
- **Prevention**: The smoke test build command must use `CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO` flags (already documented in CLAUDE.md for snapshot tests but not applied in the smoke test pipeline). Fix the smoke test script.

- **Pitfall**: Smoke test bisection incorrectly attributed Android failures (container-area-grid, charts) to ios-1 branch, despite ios-1 only modifying iOS source files. The bisection logic doesn't filter by platform.
- **Prevention**: Smoke test bisection should run `git diff --name-only <base>..<branch>` and only test the platform that was actually modified. iOS-only branches cannot cause Android regressions.

- **Pitfall**: 10 fix commits produced but NONE merged to main (7th occurrence of "commits exist but not on main" pattern). The merge phase was blocked by iOS CodeSign failure in smoke test, then smoke bisection falsely attributed Android failures to iOS branches.
- **Prevention**: The smoke test gate is too strict — it blocks merge even when failures are pre-existing or on the wrong platform. Add a pre-smoke baseline that captures failures BEFORE the fix branch, then only block merge for NEW failures introduced by the fix branch (delta-based gating, not absolute).

- **Pitfall**: iOS fix branches produced 10 commits across 2 agents (ios-1: 6 commits, ios-2: 4 commits) addressing all 11/12 issues but were NOT merged to main. Smoke test failed with iOS CodeSign error (`CodeSign ACCore.bundle` in target from SampleApp project), blocking verification.
- **Prevention**: CodeSign failures in SPM-based iOS builds are a recurring infrastructure issue. Fix agents should build with `CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO` flags during verification. The smoke test pipeline should use these flags too. If CodeSign blocks the smoke test, the merge should still proceed if Android verification passes and the iOS commits are code-only (no project file changes).

- **Pitfall**: iOS MultiColumnFlowLayout 11th fix attempt (`10044bb0`) — agent reversed the 10th attempt's column-count formula approach and went back to intrinsic widths capped by maxItemWidth. This contradicts the lesson from attempt 10 that "bypass the pipeline with direct calculation."
- **Prevention**: The FlowLayout fix saga is now at 11 commits with contradictory approaches. The 10th commit used `floor(containerWidth / maxItemWidth)` (bypassing pipeline), the 11th removed that and used intrinsic widths capped by maxItemWidth (back to pipeline). Neither approach has been verified as working because fix branches keep not merging. **Resolution**: The next iteration MUST merge the fix branch, rebuild, and visually verify MultiColumnFlowLayout on iOS before any further FlowLayout changes. Stop iterating on the algorithm without visual verification.

- **Pitfall**: Smoke test bisection narrowed ios-1 branch as causing Android container-area-grid failures — but ios-1 only modified `AreaGridLayoutView.swift` (iOS), `ContainerView.swift` (iOS), and `CarouselView.swift` (iOS). Android failures are false attribution.
- **Prevention**: Smoke test bisection should not attribute Android failures to iOS-only commits. The bisection logic should check `git diff --name-only` for each branch and only attribute platform failures to branches that modified files on that platform.

- **Pitfall**: iOS `isExplicitAutoSize` in ImageView returned `true` when `width: "150px"` + `height: "auto"` was present — treating explicit pixel widths as "auto-size" and rendering at natural pixel dimensions. This caused the communication card's image column to steal space from the text column.
- **Prevention**: The "auto-size" check must verify BOTH width and height are truly auto/unspecified. If either has an explicit pixel value, the image has an explicit size and should not be treated as auto. This was a subtle semantic bug — the function name `isExplicitAutoSize` implies "explicitly set to auto" but the implementation was checking the wrong condition.

- **Success pattern**: Platform-split agents (1 Android + 2 iOS) in iteration 20260315-233737 was highly effective. The Android agent fixed all 4 P1 ColumnSet issues in a single commit in just 4 minutes. The iOS-1 agent fixed 5 issues (P2+P3) in 15 minutes. The iOS-2 agent fixed 4 issues (P2 FitMode/SVG + P3 communication) in 23 minutes. All 3 agents completed with zero errors.
- **Key factors**: (1) Platform-based splitting eliminated cross-platform merge conflicts entirely, (2) Android had a single shared root cause enabling batch fix, (3) iOS agents didn't compete for the same files since issues were partitioned by affected_files. **Lesson**: Platform-split is strictly superior to priority-split when issues span both platforms.

- **Success pattern**: Android conflict resolution agent successfully chose HEAD's more complete approach (totalWeight-aware fallback) over incoming branch's simpler version. The resolution correctly identified that HEAD's approach had moved `totalWeight` computation before Pass 2, enabling smarter auto-column capping. **Lesson**: When conflict resolution involves layout algorithms, prefer the version with MORE conditional logic (fallbacks, caps, edge-case handling) over the simpler one.

- **Success pattern**: iOS CompoundButton fix required 3 separate commits across 3 iterations to fully resolve (`4a24089b` → `ea9edef3` → `86662f27`). Each fix addressed a real contributing cause but the issue persisted until the root cause (badge `fixedSize`) was removed. **Lesson**: Multi-layered SwiftUI layout bugs may need iterative peeling — each fix exposes the next layer. If an issue persists after a fix, look for OTHER modifiers on SIBLING views, not just the directly affected view.

- **Pitfall**: iOS SampleApp build failed with CodeSign error during smoke test (`CodeSign ACCore.bundle` in target `AdaptiveCards_ACCore`), but the overall smoke test continued and passed on Android. The CodeSign failure is a known intermittent issue with SPM bundle targets in Xcode.
- **Prevention**: Smoke tests should use the same CodeSign flags documented in CLAUDE.md: `CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO`. If the smoke test build command doesn't include these, intermittent CodeSign failures will produce false negatives.

- **Pitfall**: Two iOS fix branches (`worktree-fix-ios-1-round-1` with 5 commits, `worktree-fix-ios-2-round-1` with 3 commits) have survived across TWO catalog iterations (20260315-213139 → 20260316-004720) without being merged. This means 3 of the 8 current issues (P1 #2, P1 #3, P2 #4) have EXISTING fixes that are just sitting on branches. The orchestrator documented "Action needed: MERGE" but no merge happened.
- **Prevention**: The orchestrator's pre-flight phase must check for unmerged worktree branches (`git branch --list 'worktree-*'`) and merge them BEFORE dispatching new fix agents. Any branch with >0 commits that is older than 1 catalog cycle should be force-prioritized for merge. This is the single highest-leverage action for the next iteration — merging existing branches resolves 3 of 8 issues with zero new code.

- **Pitfall**: Fixing Android ProportionalColumnLayout auto-column measurement (`73897919`) without simultaneously fixing iOS `ColumnSetView.swift` created a "platform parity inversion" — Android went from broken to fixed, iOS went from "same as Android" to "worse than Android". The review now shows 13 iOS-only ColumnSet failures that didn't exist before the Android fix.
- **Prevention**: When fixing a layout algorithm that exists on both platforms, apply the fix to BOTH platforms in the same iteration. If only one platform's fix is ready, at minimum document the other platform's equivalent code location and create a tracking issue. The iOS fix for P1 #1 is a single-line change (`ColumnSetView.swift:72` — nil width proposal) — it should have been applied alongside the Android fix.

- **Success pattern**: Iteration 4 (catalog 20260316-004720) reduced total issues from 12 → 8 (-4) with Android ColumnSet P1s fully resolved, CompoundButton clipping fixed, and flight-details fixed. The Android ProportionalColumnLayout fix (`73897919`) resolved all 10 affected Android cards in a single commit. Issue count would drop to 5 if the 2 unmerged iOS branches were merged (resolving P1 #2, P1 #3, P2 #4). **Lesson**: The biggest remaining bottleneck is not code quality but merge pipeline execution — 3 of 8 issues have working fixes that just need to be merged.

- **Pitfall**: The NestedFlowLayout text truncation (P3 #8 — "Sum mar..." on iOS) is attributed to CompoundButton sizing but is actually blocked by the FlowLayout fix (P1 #3) on unmerged branch `worktree-fix-ios-1-round-1`. Do not assign a separate fix agent for this — it may resolve once the FlowLayout fix is merged.
- **Prevention**: Check `blocks` field in issues.json before dispatching fix agents. If an issue blocks on another issue, merge the blocking fix first and re-verify before assigning new work.

## 6. Regression Root Cause Analysis (Iteration 20260315-213137)

This iteration found 12 issues (3 P1, 5 P2, 4 P3) — worse than the prior iteration's 4 issues. Root cause analysis reveals three systemic patterns:

### Pattern A: Merge Conflict Resolution Chose Simpler (Wrong) Approach

- **What happened**: Commit `987ca9fe` merged `worktree-fix-p2-3-round-2` and resolved a conflict in `ColumnSetView.kt` by choosing the simplified direct-measurement approach (commit `3b4d6d2b`) over the hybrid `maxIntrinsicWidth` + proportional distribution approach (commit `bfe6cdb0`).
- **Impact**: 3 P1 Android regressions (Agenda, FlightUpdate, ExpenseReport) — all caused by cascading width depletion where auto-width columns are measured sequentially, each consuming `remainingWidth`, starving later columns.
- **Prevention**: When resolving merge conflicts in rendering/layout code, ALWAYS prefer the approach with MORE logic (proportional distribution, fallback strategies, two-tier measurement). Rendering edge cases need nuance — simplification is the enemy. If unsure, test both approaches against 3+ ColumnSet-heavy cards before choosing.

### Pattern B: Rapid Back-to-Back Worktree Merges Without Incremental Testing

- **What happened**: 4 worktree branches merged in rapid succession without regression testing between merges:
  1. `worktree-fix-p2-1-round-2` → CompoundButton fix
  2. `worktree-fix-p2-2-round-2` → HostConfig colors
  3. `worktree-fix-p1-round-2` → Image/FlowLayout fixes
  4. `worktree-fix-p1-round-3` → final round
- **Impact**: Compound interactions created 5 P2 regressions — each fix was correct in isolation but the combination broke previously-passing cards. E.g., ImageView alignment change (`.center` → `.top`) + frame sizing change together broke FitMode labels.
- **Prevention**: After EACH worktree merge, run a 5-card smoke test on both platforms before proceeding to the next merge. If any card regresses, investigate BEFORE merging the next branch. Use `visual-test-loop.sh` on the 5 most complex cards (Agenda, FlightUpdate, ExpenseReport, FoodOrder, CompoundButton) as a quick regression gate.

### Pattern C: Over-Correction — Fixes That Change More Than Necessary

- **What happened**: Multiple fixes changed adjacent/unrelated parameters beyond the minimal scope:
  - ImageView: Fixed width expansion but also changed alignment from centered to `.top` (P2 regression)
  - FlowLayoutView: Fixed single-column by returning `nil` but changed grid geometry to uniform vs asymmetric (P2 regression)
  - CompoundButton: Changed `layoutPriority(-1)` to `(1)` but didn't address the actual HStack spacing issue, requiring a second fix
  - ColumnSetView: Simplified auto-column measurement by removing proportional distribution (3 P1 regressions)
- **Prevention**: Before writing a fix, list EXACTLY which lines need to change and WHY. If a fix touches more than 5 lines of rendering code, verify each changed line is necessary for the specific issue. Test the fix against BOTH the broken card AND 3+ unrelated cards to catch over-correction. For layout code (ColumnSet, FlowLayout, ImageView): always test with nested containers, multiple columns, and mixed auto/weighted widths.

### Mandatory Pre-Merge Smoke Test Cards

Based on regression analysis, these 8 cards exercise the most fragile layout paths and should be tested after EVERY worktree merge:

1. `official-samples/agenda` — nested ColumnSets with auto+weighted columns
2. `official-samples/flight-update` — multi-column with weighted distribution
3. `official-samples/expense-report` — auto+auto+weighted columns
4. `official-samples/flight-details` — extraLarge TextBlocks in columns
5. `versioned/v1.5/MultiColumnFlowLayout` — flow layout with maxItemWidth
6. `versioned/v1.5/Image.FitMode.Contain` — fitMode with explicit dimensions
7. `versioned/v1.6/CompoundButton` — badge + title layout priority
8. `compound-buttons` — multiple CompoundButton variants
9. `versioned/v1.5/Action.MenuActions` — multiple ActionSets with maxActions enforcement
10. `progress-indicators` — ColumnSet-dependent step layout (proxy for P1 #1 fix verification)

---

## Iteration 7 Updates (design-catalog-20260316-100744)

### New False Positives to Skip

- **Image.FitMode.Contain labels missing** (prev P1): FIXED in `7e0adffb` — dedicated `isContainMode` branch. Labels now visible on iOS. Only remaining issue is image sizing (~40% wider than Android), which is P3. Do not re-report as P1.
- **NestedFlowLayout layout divergence**: First-pass agent flagged "linear vs card-based" difference. Visual inspection shows both platforms render similar 2-column compound button layouts. Minor differences in badge pill vs circle styling are platform-native. Do not report as P2.
- **ContainerFlowLayout icon differences**: iOS uses hamburger menu icons, Android uses info circle icons. Both are platform-native icon variants (SF Symbols vs Material Icons). Layout structure matches. Do not report.
- **v1.6 CompoundButton layout divergence**: Agent flagged as FAIL but visual differences are minor (icon circle styling, spacing). Previously fixed in `ea9edef3` (HStack spacing) + `4a24089b` (layoutPriority). Skip unless text clipping or missing content detected.
- **Icon.Styles fill vs outline**: SF Symbols vs Material Icons have inherently different fill aesthetics. Already documented in section 4. Do not report.

### New Failed Fix Patterns

- **iOS Image.FitMode.Fill — isContainMode branch doesn't cover fill mode**: The `7e0adffb` fix added a dedicated `isContainMode` branch (lines 121-146) that correctly handles contain mode. BUT fill mode falls through to `isCoverMode` branch (lines 147-167) which still applies `frame(maxWidth: .infinity)`, causing the "Fit Auto" image to expand and push remaining sections below the viewport. **Lesson**: The dedicated-branch pattern that worked for contain mode must ALSO be applied to fill mode. Each fitMode value needs its own explicit code path.

- **iOS list card regression despite ListView.swift fix**: Fix `eff40f7b` made ScrollView conditional on maxHeight, but the list card truncation persists. The root cause may be in the OUTER card body frame (AdaptiveCardView.swift) clipping content, not in ListView itself. **Lesson**: When a view-level fix doesn't resolve truncation, check the PARENT container constraints. The card body VStack may have a fixed height or clipping that prevents child views from expanding.

- **iOS progress-indicators — spinner size causes viewport overflow**: iOS renders full arc-circle spinners (~60pt) vs Android tiny dashes (~12pt). This isn't a layout bug but a SIZE MISMATCH that consumes vertical space and pushes Step Progress below viewport. Prior fix agent classified as "viewport density difference" which is partially correct — the root cause is disproportionate spinner size, not card body clipping. **Lesson**: When content is "below viewport", check component SIZES not just layout constraints. Oversized components can consume all available space even with correct layout.

### Updated Recurring Root Causes

- **Root cause**: iOS Image.FitMode images need SEPARATE code paths per mode (auto/contain/cover/fill)
- **Affected cards**: FitMode.Contain (FIXED), FitMode.Fill (still broken), FitMode.Cover (untested)
- **Single fix**: Add dedicated `isFillMode` branch in ImageView.swift mirroring the successful `isContainMode` pattern
- **Status**: Contain FIXED in `7e0adffb`. Fill needs the same treatment. After 5+ attempts, the dedicated-branch pattern is confirmed as the only approach that works for fitMode — do NOT try to fix with guards/conditionals on the existing path.

### New Fix Agent Pitfalls

- **Pitfall**: Review sub-agents hit "image exceeds dimension limit" when reading 10+ full-resolution screenshots. 3 of 4 parallel agents failed in this iteration.
- **Prevention**: Limit each sub-agent to 5 cards max (10 screenshots). Split review into more agents with fewer cards rather than fewer agents with more cards. Pre-resizing to <1200px also helps but doesn't fully prevent the issue with many images.

- **Pitfall**: First-pass review agent misidentified MultiColumnFlowLayout as "Android regressed to linear layout" — but Android actually renders correct asymmetric 2-column. The agent confused asymmetric column widths with "single column".
- **Prevention**: When reviewing flow/grid layouts, note that ASYMMETRIC column widths (one narrow, one wide) is CORRECT behavior — it means items use intrinsic widths. UNIFORM narrow columns with truncated text is the actual bug (iOS current state). Do not flag asymmetric layout as a regression.

### Iteration 10 Learnings (catalog 20260316-133654)

- **Critical finding: ALL iteration-9 fix branches remain unmerged.** 7 of 10 P1-P3 issues have commits that fix them (`04a3776e`, `05e70d97`, `be4d1170`, `118b859e`, `9784d18d`, `a7f25be2`, `8a05c21f`) but none are on `main`. The review found ZERO regressions and ZERO new P1/P2 issues — only persisting issues from unmerged branches. **Action**: Before dispatching fix agents, MERGE existing fix branches first.

- **Pitfall**: Review iteration 10 found the same 10 issues as iteration 9 because no fixes were merged between reviews. This is the second time a review was wasted on unchanged code (iteration 5 had the same problem).
- **Prevention**: The orchestrator MUST check `git log main..HEAD --oneline` for pending fix branches before starting a new review. If fix branches exist, merge them first. If all are merged and no new code changed, skip the review.

- **iOS list card spacing (NEW)**: List card vertical spacing between items is larger on iOS than Android. This is a DIFFERENT issue from the prior truncation bug (fixed in `eff40f7b`). Root cause likely in `ListView.swift` item spacing values. NOT related to the ContainerView alignment issue (#6).

- **iOS ActionModeTestCard maxActions (NEW)**: iOS shows 5 action buttons while Android shows 4 in the maxActions test row. `ActionSetView.swift:74-76` correctly applies `hostConfig.actions.maxActions` — the discrepancy may be in HostConfig default values differing between platforms (iOS defaulting to 5 or 6 vs Android 4). Verify HostConfig `.maxActions` default on both platforms before fixing.

- **Carousel.ForbiddenElements and container-scrollable**: Both showed improvement from previous review — ForbiddenElements content alignment and container-scrollable clipping appear better. These may have been partially addressed by prior merged commits (ContainerView.swift changes). Mark as resolved unless future reviews re-flag.

- **Agenda template avatars**: templates-Agenda.template shows full avatar images on iOS but tiny placeholders on Android. This is likely an external image URL loading issue on Android, not a rendering parity bug. Skip unless structural layout differs.

- **Pitfall**: Iteration 10 ran TWO full fix rounds (iteration-1 and iteration-2 within the loop), producing 20+ commits total. Iteration-2 agents re-fixed the SAME issues that iteration-1 agents had already addressed (project-dashboard, SVG, bar chart, center-alignment, CompoundButton). Worktree branches from iteration-1 were not merged before iteration-2 launched, so iteration-2 started from the same base (`654a6ec`) and duplicated all work.
- **Prevention**: The orchestrator must merge iteration-1 worktree branches to main BEFORE launching iteration-2 fix agents. If merge fails, iteration-2 should only target issues NOT addressed by iteration-1 agents. Currently both iterations produce independent, conflicting fix branches on the same files.

- **Pitfall**: Issue #9 (ActionModeTestCard maxActions) fix agent changed HostConfig default maxActions from 5 to 6 — this INCREASES the number of visible actions, making the iOS-vs-Android discrepancy worse (iOS now shows 6 vs Android 4).
- **Prevention**: Fix agents must verify the fix direction before committing. When the issue says "iOS shows more than Android", the fix should reduce the count on iOS, not increase it. Include a pre-commit verification step: check if the change makes the platforms MORE similar or LESS similar.

- **Success pattern**: Iteration-10 ios-1 agent in iteration-1 correctly batched issues #1 and #7 (shared AreaGrid root cause) into a single commit `04a3776e`, and grouped the ContainerView alignment fix (#6) with AreaGrid alignment (#9) since both involved `.topLeading` alignment changes. Root-cause-aware batching continues to be the most productive pattern.

- **Success pattern**: Iteration-10 ios-2 agent successfully identified a new fix approach for SVG black rectangles (`be4d1170` — WKNavigationDelegate with opacity animation) that addresses small/inline SVGs missed by the prior `376c3cf3` fix (HTML wrapper approach). Multiple valid fix strategies for the same issue is fine — the agent chose the one that covered the remaining edge case.

- **CRITICAL — Merge infrastructure is the #1 bottleneck**: Across iterations 5-10, fix agents have collectively produced 100+ commits. Fewer than 20 made it to main. The review-fix loop is productive at generating fixes but catastrophically broken at landing them. The next iteration MUST prioritize merging existing unmerged fixes over generating new ones. If the orchestrator cannot reliably merge worktree branches, switch to having fix agents commit directly to main (sequential, not parallel).

## 7. Iteration 11 Findings (catalog 20260318-115833)

### Confirmed Fixes from Prior Iterations
These prior issues are NOW RESOLVED and should be removed from future reports:
- P1 project-dashboard missing content → FIXED (`5151280f` implicit AreaGrid columns — now on main)
- P2 SVG black rectangles → FIXED (`376c3cf3`, `31ffaf9f` — now on main)
- P2 bar chart x-axis labels → FIXED (`46928f2d` proportional height — now on main)
- P2 CompoundButton v1.6 text clipping → FIXED (`a8a0eb95` remove badge fixedSize — now on main)
- P3 center-alignment systemic → FIXED (`edfb2b94` leading alignment VStack — now on main)
- P3 ContainerAreaGrid5 alignment → FIXED (`62eda01e` AreaGrid weight distribution — now on main)

### New Issue Patterns
- **Android deep-link routing regression (P1 #1, #2)**: Third iteration of deep-link issues. Prior `4e77257` Base64 fix does not cover all multi-dot filenames. Pattern: `Fallback.Root.Recursive` (3 dots) and `CarouselTemplatedPages.template` (1 dot) both fail. The Base64 encoding strategy may need to be applied more broadly to ALL card navigation paths, not just specific deep-link entry points.

- **Android targetWidth default (P1 #3)**: iOS fix `62fa2b6` defaulted to Narrow; Android never got the equivalent fix. This is a pattern we see repeatedly: iOS fix applied but Android counterpart not created. Dispatch rule: every iOS rendering fix must generate a TODO for the Android equivalent.

- **iOS badge rendering (P3 #6, systemic)**: 7 cards affected. This is likely a HostConfig propagation issue, not a BadgeView rendering bug. The badges work fine in non-flow contexts. Investigation should focus on the FlowLayout → CompoundButtonView → BadgeView environment propagation chain.

- **iOS table header accent color (P2 #4)**: High-confidence fix — single line in TableView.swift. Android has the explicit accent color logic in MediaAndTableViews.kt:202-212. This should be a first-pass fix.

### Key Observation
The merge pipeline appears to have improved — the 6 confirmed fixes above all landed on `main`. However, 3 new P1 Android issues (deep-link + targetWidth) suggest the Android sample app and rendering pipeline need more attention. iOS rendering quality is improving (center-alignment, AreaGrid, SVG, charts all fixed), but iOS still has more P3 issues (8 of 10 P3s are iOS).

### Recommended Fix Priority for Next Iteration (Iteration 14)
1. P1 #2 (Android deep-link routing wrong card) — high confidence, single-file fix in `MainActivity.kt`, replace index lookup with name-based find
2. P1 #3 (iOS Media poster missing) — high confidence, add poster image rendering in `MediaView.swift`
3. P1 #4 (iOS ThemedUrls.BackgroundImage blank) — medium confidence, investigate themed URL resolution in background image rendering
4. P2 #7 (iOS list truncation regression) — high confidence, check `ListView.swift` for re-introduced nested ScrollView
5. P2 #8 (iOS markdown truncation) — medium confidence, card body height constraint issue
6. P3 #9 (iOS table header accent color) — high confidence, single-line fix in `TableView.swift`
7. P1 #1 (Android emulator boot/ANR) — infrastructure fix in capture script, add boot-complete wait

### New Findings (Iteration 14, catalog 20260319-111407)

- **Android ANR cascade reduced by ~50%**: Previous catalog had ~52 Android failures, this one has ~23. The `75be2e32` (move parsing off main thread) fix was partially effective. Remaining failures are emulator boot timing + ANR during composable layout phase (not parsing).
- **Android deep-link routing is systematically broken for ~12 cards**: Pattern is off-by-one index misalignment after new test cards were added. The `8da20076` `launchSingleTop` fix prevented duplicate Activity instances but did not fix the underlying index-based lookup. Name-based lookup is the correct fix.
- **iOS has 3 regression issues** (FitMode.Fill, CompoundButton overflow, list truncation): All three were previously fixed but have regressed. This may indicate the fix branches were lost/not merged, or subsequent changes reverted the fixes.
- **iOS Media poster is a NEW capability gap**: MediaView.swift does not render the poster image at all. This is a missing feature, not a regression.
- **iOS ThemedUrls.BackgroundImage is completely blank**: This appears to be a themed URL resolution failure specific to the backgroundImage property. ThemedUrls.Image and ThemedUrls.Actions render correctly — only the BackgroundImage variant fails.
- **Pre-resize screenshots to 800px** worked well for this review — all 6 review agents completed without hitting dimension limits. Prior iterations at 1200px still had occasional failures. 800px is sufficient for detecting P1-P3 issues.
- **Parallel review agents (6 agents, 20-40 cards each) with topical grouping** is the optimal approach: agents grouped by card category (OCR blanks, high-ratio cards, versioned, teams/elements, edge cases) produced consistent, non-overlapping findings.

## 8. Iteration 15 Findings (catalog 20260319-162916)

### Confirmed Fixes from Prior Iterations
These prior issues are NOW RESOLVED and should be skipped in future reviews:
- **iOS Image.FitMode.Contain**: Previously P1 — now renders correctly with section labels visible. FIXED (confirmed across multiple prior commits, now stable on main).
- **iOS project-dashboard**: Previously P1 — renders full content on both platforms. FIXED in `5151280f`.
- **iOS Agenda ColumnSet auto-column**: Previously P1 — proper time/content column distribution. FIXED (`08a461de` nil width proposal in ColumnSetView.swift).
- **iOS table header accent color**: Previously P2 #4/#7 — TableView.swift now applies accent color to header TextBlocks directly (bypassing ElementView foregroundColor override). FIXED in `2ba7fdb6` (lines 196-207 render Text() directly with accent color). Skip unless regression detected.
- **iOS CompoundButton badge fixedSize clipping**: Previously P2 — FIXED across `4a24089b`, `ea9edef3`, `86662f27`. Skip unless regression detected.
- **iOS CompoundButton default chevron suppression**: FIXED in `ebb2b885` — default chevron suppressed when CompoundButton has trailing icon.
- **iOS CompoundButton badge horizontal overflow**: FIXED in `7233f07a` — removed badge fixedSize causing overflow.
- **Android ImageSet grid minimum height**: FIXED in `e48f5435` — grid images have minimum height.
- **Media play button overlay styling**: FIXED in `fc8f5d84` — both platforms now use matching darker overlay style (confirmed by `adef5bb3`).

### Persisting Issues (Still Open)
These issues persist from prior iterations and were re-confirmed in this catalog:
1. **P1 #1: iOS MultiColumnFlowLayout cramped 3-column grid** (Status: Stuck, 13+ fix attempts). FlowLayout sizing pipeline has 6 independent stages that keep falling out of sync. **MANDATORY**: Do NOT attempt a 14th incremental patch. Must replace with SwiftUI `Grid` or `Layout` protocol.
2. **P1 #2: iOS SVG data URI black rectangles** (Status: Stuck). Network SVGs and Disney logo SVGs render correctly; data URI SVGs with complex viewBox still show as black rectangles. Prior fix `376c3cf3` addressed network SVGs but data URIs need the HTML wrapper to decode and inject with proper viewBox sizing.
3. **P1 #3: Icon.Clickable blank on both platforms** (Status: Stuck). Both iOS and Android render only the title and a question mark icon. This is likely a card JSON or parsing issue (both platforms blank = shared code path). Fix hint: check card JSON first for Icon elements with selectAction, then trace parsing.
4. **P2 #6: iOS Table.AreaGrid text truncation** — description text cut off after 3 lines. Check AreaGridLayoutView.swift for height constraints on grid rows.
5. **P2 #7: iOS badge icon-only vertical bar** — standalone icon badge shows as dark vertical bar instead of icon. Fix: add `.frame(minWidth: 24)` for icon-only badge layout path in BadgeView.swift.
6. **P3 #8: FlowLayout badge colors dark grey (#212121)** — HostConfig badge styles not propagated through FlowLayout environment chain. Systemic issue affecting 7+ cards.

### New Issues (First Appearance in Iteration 15)
- **P2 #4: iOS v1.6 CompoundButton left-edge text clipping** — titles clipped at left: "iew active work items" instead of "View active work items". Fix hint: add `.padding(.leading, 12)` to content HStack matching Android `padding(start=12.dp)`. High confidence.
- **P3 #10: iOS markdown list spacing larger than Android** — ~8-10dp more vertical spacing between bullet/numbered list items on iOS. Root cause in `MarkdownRenderer.swift` list item vertical padding. NEW issue not seen in prior iterations.
- **P3 #11: iOS list card excessive vertical spacing** — related to but distinct from the markdown spacing issue. Root cause in `ListView.swift` VStack spacing and item padding. NEW issue.
- **P4 #13: Android badge icon-only thin dark vertical bar** — empty text container visible next to calendar icon. Fix: hide text container when badge label is empty/null in BadgeView.kt. NEW issue.

### OCR Pre-Scan Validation (Iteration 15)
All 18 OCR-detected items were false positives — confirming iteration 14 findings. The canonical OCR whitelist remains comprehensive. Cards triggering OCR: code-block (Swift `{}`), Template.DataBinding (`{hello}`), Container.ScrollableSelectableList (URL params), Input.ChoiceSet.FilteredStyle.TestCard ("fail" description), StringResources.Invalid.1-4 (intentional invalid expressions), datagrid column headers, RtlTestCard RTL artifacts. **No expansion of OCR whitelist needed.**

### Updated False Positives
- **Icon.Clickable blank on both platforms**: While reported as P1, this MAY be a card JSON issue rather than a rendering bug. Both platforms being blank suggests the card JSON may not contain the expected Icon elements, or the parsing path for Icon + selectAction drops elements. Verify card JSON content before dispatching a rendering fix agent.
- **iOS table header accent color**: NOW FIXED. TableView.swift lines 196-207 render header TextBlocks directly as `Text()` with accent foregroundColor, bypassing ElementView which would override the parent foregroundColor. Add to "skip" list.

### Key Observations
- **Issue count trending down**: 13 issues (3 P1, 4 P2, 4 P3, 2 P4) vs 21 in iteration 11, 23 in iteration 14 (when Android ANR cascade inflated counts). Excluding the 3 "Stuck" P1s (FlowLayout, SVG data URI, Icon.Clickable), there are only 10 actionable issues.
- **iOS dominates remaining issues**: 11 of 13 issues are iOS-only. Android rendering quality has stabilized after the ProportionalColumnLayout fix and ANR resolution. Remaining Android issues are P4 cosmetic only.
- **Merge pipeline improved**: All recent fix commits (`adef5bb3`, `2ba7fdb6`, `ebb2b885`, `7233f07a`, `e48f5435`) successfully landed on main. The chronic merge failure pattern from iterations 5-10 appears resolved.
- **High-confidence fixes available**: Issues #4 (CompoundButton padding), #7 (badge minWidth), #10 (markdown spacing), #11 (list spacing), #13 (Android badge text hide) are all high-confidence single-file fixes. These 5 issues could be resolved in a single fix round.

### Recommended Fix Priority for Next Iteration (Iteration 16)
1. **P2 #4** (iOS CompoundButton left-edge clipping) — single-line `.padding(.leading, 12)`, high confidence
2. **P2 #7** (iOS badge icon-only vertical bar) — `.frame(minWidth: 24)`, high confidence
3. **P3 #10** (iOS markdown list spacing) — reduce padding in MarkdownRenderer.swift, high confidence
4. **P3 #11** (iOS list card spacing) — reduce VStack spacing in ListView.swift, high confidence
5. **P4 #13** (Android badge text container) — hide empty text in BadgeView.kt, high confidence
6. **P1 #3** (Icon.Clickable blank) — investigate card JSON first, then parsing. Low confidence until JSON verified.
7. **P1 #1** (MultiColumnFlowLayout) — REPLACE FlowLayoutView.swift entirely. Do NOT patch. Low confidence.
8. **P1 #2** (SVG data URI) — extend WKWebView HTML wrapper for data URIs. Medium confidence.
9. **P2 #6** (Table.AreaGrid truncation) — check height constraints in AreaGridLayoutView.swift. Medium confidence.
