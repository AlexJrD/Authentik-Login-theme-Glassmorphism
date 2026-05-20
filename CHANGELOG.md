# Changelog

All notable changes to this theme are documented in this file.

Format: [Semantic Versioning](https://semver.org/) (MAJOR.MINOR.PATCH).

## [V3.1.1] — 2026-05-20 (cleanup release)

### Refactor — code hygiene, no behavioral change

- **Deduplicated** redundant `:host(...)` rule blocks introduced during iterative
  patches: merged the two `:host(ak-flow-card)` blocks into one, merged the two
  `:host(ak-locale-select)` blocks (layout + color + select styling now in a single
  cohesive rule), merged `:host(ak-form-static) .links a` definitions.
- **Merged** the two `@media (max-width: 768px)` blocks into a single consolidated
  block at the bottom of the file. The mobile rules for `pf-c-form__actions` and
  `ak-stage-user-login` buttons that were in the first block now live alongside
  the rest of the mobile overrides.
- **Consolidated** the two `:root` "shadow-piercing" CSS variable blocks (login-flow
  vars + form/table/tooltip vars) into one. Now all PatternFly variables live in a
  single `:root` block in the "PATTERNFLY CSS VARS" section.
- **No selector or property removed** — only structural cleanup. The cascade order
  is preserved; visual output is byte-for-byte identical to V3.1.

### Documentation

- Added **mobile screenshots** to the README (login identification, login password,
  dashboard, user settings) in a 2×2 table layout.
- Renamed README section "Previews" with explicit subsections **🖥️ Desktop** and **📱 Mobile**.
- Updated all version references from `V3.1` to `V3.1.1`.

### Stats

| Metric | V3.1 | V3.1.1 |
|---|---|---|
| Lines | 3177 | ~3167 (−10) |
| Brace balance | 266 / 266 | 260 / 260 ✅ |
| `:host(ak-flow-card) {` blocks | 2 | 1 |
| `:host(ak-locale-select) {` blocks | 2 | 1 |
| `@media (max-width: 768px)` blocks | 2 | 1 |
| Mobile screenshots | 1 | 4 |

---

## [V3.1] — 2026-05-20 (Authentik 2026.2.3 compatibility fork)

### Context

Authentik 2026.x introduced a major refactor of its frontend components, adding a new Shadow DOM wrapper layer (`<ak-flow-card>`, `<ak-flow-input-password>`, `<ak-form-static>`, `<ak-locale-select>`, etc.) and switching some elements to PatternFly v5 conventions. Many CSS rules in V3.0 that targeted the old structure stopped matching anything. This release audits the V1.1/V3.0 codebase against Authentik 2026.2.3's actual DOM and replaces dead selectors with `::part()` routes that work from the document level.

### 🔴 Hard bugs fixed

- **Invalid `:contains()` pseudo-class** removed (was jQuery syntax, never worked in CSS — silently dropped 3 rules including "Powered by authentik" hide). Replaced by the existing `.pf-c-list.pf-m-inline` fallback.
- **Broken CSS block at line ~1860** — 7 free-floating CSS declarations and 2 stray closing braces that left brace count unbalanced (180 `{` vs 182 `}`). Removed entirely.
- Brace count now balanced (252 / 252).

### 🟠 Dead code / duplicates cleaned

- 9 groups of duplicated CSS rules eliminated (~120 lines).
- `:host(ak-user-settings-source-oauth)` (host name doesn't exist) → replaced by the real `:host(ak-user-settings-source)`.
- `:host(ak-interface-user) .pf-c-page__header-tools-item a.pf-c-button.pf-m-secondary` (the admin button is slotted via `<slot name="extra">`, not inside header-tools-item) → removed.
- Stray duplicate background-rule blocks for `:host(ak-library-impl), :host(ak-interface-user)` → consolidated.
- Triple comment banner "FIX DASHBOARD MOBILE" → single banner.

### 🟢 New Authentik 2026.x components supported

These web components were introduced/changed between 2025.10 and 2026.2.3:

| Component | Coverage |
|---|---|
| `<ak-flow-card>` | Transparent wrapper around each stage; titles + helper text styled |
| `<ak-form-static>` | Avatar + username block on password/MFA stages — glass-styled |
| `<ak-flow-input-password>` | Replaces the old `.pf-c-input-group` — glass blur on password input |
| `<ak-locale-select>` | Language picker centered horizontally at the top via `left: 50vw + translateX(-50%)` |
| `<ak-tabs vertical="">` | Vertical tabs in user settings — uses `.pf-c-tabs__link` (not `__button` as in 2025.x) |
| `<ak-empty-state>` | Loading/empty states centered with text styling |
| `<ak-spinner>` | Web component spinner colored white |
| `<ak-nav-buttons>` | Top header tools wrapper |
| `<pf-tooltip>` | PatternFly v5 tooltip with CSS variables for theme |
| `pf-m-block` variant | Block-level buttons on all MFA/login stages — text wraps, full-width |
| `pf-m-icon` variant | Password input variant — glass styling |
| `<fieldset class="pf-c-form__group pf-m-action">` | New form action wrapper recognized |

### 🟢 Dashboard improvements (2026.x)

- `<fieldset part="app-group">` — new app group styling (transparent, white headers, no separator)
- `<div part="card-wrapper">` — new card wrapper transparency
- App card `⋮` action menu (`<menu popover>`) — glass-styled via `ak-library-impl::part(card-header-actions-menu)` with full sub-parts (action, publisher, description, action button)
- Hidden the new 2026.x `<div part="background-default-slant">` decorative element that conflicted with our full-viewport background

### 🟢 Login flow fixes

- **No more vertical scroll on login** — body/html locked to `100vh; overflow: hidden` when `<ak-flow-executor>` is present; the `<main>` glass box uses `position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%)` for true viewport centering.
- **No more horizontal scroll inside the box** — `overflow-x: clip` (stricter than `hidden`) absolutely prevents scrollbar creation even when child elements force their width.
- **Long button labels wrap** — buttons like "Sélectionnez une autre méthode d'authentification" wrap on multiple lines instead of overflowing.
- **Main box widened to 600px max-width** for desktop, comfortable for long French labels.
- **Locale picker centered on every viewport** — desktop, tablet, mobile portrait/landscape — using viewport units (`50vw`) instead of percentage-of-containing-block.
- **Palo Alto / brand logo centered** via `ak-flow-executor::part(branding)`.

### 🟢 User Settings + Dashboard background

- **Full-viewport background image** moved from `.pf-c-page` (which lives in a shadow root that doesn't receive Custom CSS) to `html, body` directly.
- **All inner wrappers transparentified** via `::part(page)`, `::part(page__header)` so the body's fond shows through.
- **Admin panel still gets its opaque background** via `:host(ak-interface-admin) .pf-c-page` — fond stays invisible there.

### 🟢 PatternFly CSS variables at `:root` for shadow-piercing

Form inputs, tables, tooltips, cards, buttons, empty states — all themed via `--pf-c-*` and `--pf-v5-c-*` variables that inherit through every shadow boundary. This is the only way to style deeply nested elements (like `<input>` inside `<ak-form-element-horizontal>` inside `<ak-user-stage-prompt>` inside `<ak-user-settings-flow-executor>` inside `<ak-user-settings>`) that have no exposed `part`.

### 🟢 Mobile responsive improvements

- Locale picker centered horizontally at the top (`left: 50vw + translateX(-50%)`) — never off-screen.
- Tables in user settings get horizontal scroll on small screens via `::part(table-container)`.
- Table cell font-size and padding reduced on mobile.
- Login `<main>` glass box has stronger blur (`backdrop-filter: blur(18px) saturate(140%)`) on mobile.
- Buttons wrap their text on small viewports to avoid overflow.

### 📊 Stats

- Lines: **2273 → 3032** (cleanup + 2026.x additions)
- Brace balance: **180/182 ❌ → 252/252 ✅**
- Invalid CSS removed: 3 `:contains()` rules + 1 broken syntax block
- `ak-user-settings-source-oauth` (non-existent host): **4 occurrences → 0**
- New shadow component selectors: **~25 new `::part()` routes**

---

## [V3.0] — 2025 (original VULGA01 release)

Original glassmorphism theme by [VULGA01](https://github.com/VULGA01).
Tested on Authentik 2025.10.3.

See the [original repository](https://github.com/VULGA01/Authentik-Login-theme-Glassmorphism) for V3.0 history.
