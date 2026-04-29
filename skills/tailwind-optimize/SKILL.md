---
name: tailwind-optimize
description: "Scan CSS files and replace custom CSS with equivalent Tailwind utility classes. Use when user says /tailwind-optimize, 'optimize CSS with tailwind', 'convert CSS to tailwind', or 'replace custom CSS with tailwind classes'."
argument-hint: "[<file|glob|dir>]"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

# Tailwind Optimize Skill

Convert custom CSS to Tailwind utility classes. Target: CSS files, `<style>` blocks in HTML/PHP/Vue/JSX, inline `style=` attributes.

## Input Handling

Based on `$ARGUMENTS`:

| Input | Action |
|-------|--------|
| *(empty)* | Scan current directory — find all `.css`, `.scss`, `.html`, `.php`, `.vue`, `.tsx`, `.jsx` files |
| `<file path>` | Optimize that specific file |
| `<glob>` | Optimize all matching files |
| `<directory>` | Recurse into directory |

## Workflow

### 1. Discovery
- If no argument: `Glob("**/*.css")` + `Glob("**/*.scss")` in cwd
- Also search for `<style>` blocks: `Grep("</style>", ...)` in template files
- Skip: `node_modules/`, `vendor/`, `dist/`, `build/`, minified files (`*.min.css`)

### 2. Audit Each File
Read file. Identify:
- Custom properties that map 1:1 to Tailwind utilities
- Repeated patterns (margin, padding, flex, grid, colors, typography, borders, shadows)
- Classes that can be composed from multiple Tailwind utilities
- Properties already covered by global styles (body/html defaults, `@layer base`) — omit, don't duplicate
- Anything that has NO Tailwind equivalent (keep as-is, flag it)

### 3. Tailwind Mapping Reference

**Spacing** — `margin: 0 auto` → `mx-auto`, `padding: 1rem` → `p-4`, `margin-top: 1.5rem` → `mt-6`

**Flex/Grid**
- `display: flex` → `flex`
- `flex-direction: column` → `flex-col`
- `align-items: center` → `items-center`
- `justify-content: space-between` → `justify-between`
- `gap: 1rem` → `gap-4`
- `display: grid; grid-template-columns: repeat(3, 1fr)` → `grid grid-cols-3`

**Sizing**
- `width: 100%` → `w-full`
- `height: 100vh` → `h-screen`
- `max-width: 1280px` → `max-w-7xl`
- `min-height: 100%` → `min-h-full`

**Typography**
- `font-size: 1rem` → `text-base`, `font-size: 1.5rem` → `text-2xl`
- `font-weight: 700` → `font-bold`
- `line-height: 1.5` → `leading-normal`
- `text-align: center` → `text-center`
- `color: #111827` → `text-gray-900` (nearest Tailwind color)
- `text-transform: uppercase` → `uppercase`
- Fluid font-size → `text-[clamp(min,preferred,max)]` (see Clamp section)

**Backgrounds & Borders**
- `background-color: #fff` → `bg-white`
- `border-radius: 0.5rem` → `rounded-lg`
- `border: 1px solid #e5e7eb` → `border border-gray-200`
- `box-shadow: 0 1px 3px ...` → `shadow-sm` / `shadow` / `shadow-md`

**Position & Display**
- `position: relative` → `relative`
- `position: absolute` → `absolute`
- `display: none` → `hidden`
- `display: block` → `block`
- `overflow: hidden` → `overflow-hidden`

**Interactivity**
- `cursor: pointer` → `cursor-pointer`
- `opacity: 0` → `opacity-0`
- `transition: all 0.2s` → `transition`
- `pointer-events: none` → `pointer-events-none`

### 4. Output Strategy

**For CSS files:**
- If entire ruleset maps to Tailwind → remove the CSS block, note the class name to add in HTML
- If partial → keep non-mappable properties, add comment `/* kept: no Tailwind equivalent */`
- If CSS is applied via class selector → report which HTML elements need `class=""` updated

**For template files (HTML/PHP/Vue/JSX) with inline styles or `<style>` blocks:**
- Replace inline `style="..."` with equivalent Tailwind classes in `class="..."`
- Replace `<style>` block rules with Tailwind classes on the elements
- Remove emptied `<style>` blocks

### 5. Report

After processing, output:

```
## Tailwind Optimization Report

### Converted
- `src/css/card.css` — `.card` ruleset → `flex flex-col rounded-lg shadow-md p-6 bg-white`
- `templates/hero.php` — inline style → `text-4xl font-bold text-center mt-12`

### Kept (no Tailwind equivalent)
- `src/css/animations.css` — `@keyframes slideIn` (custom animation)
- `src/css/vendor.css` — third-party, skipped

### Action Required
These CSS classes were removed. Add Tailwind classes to corresponding HTML:
- `.card` → add `flex flex-col rounded-lg shadow-md p-6 bg-white` to `.card` elements
- `.hero-title` → add `text-4xl font-bold text-center mt-12` to `<h1 class="hero-title">`

### Not Converted
- Complex animations or `@keyframes` — keep in CSS
- CSS custom properties (`--var`) used in JS — keep in CSS
- Pseudo-selectors with complex logic — keep in CSS
```

## Clamp — Fluid Values

Use `clamp()` via Tailwind arbitrary values wherever a property varies across breakpoints or a fluid value is more expressive than a fixed one. Prefer `clamp()` over stacked responsive variants (`text-sm md:text-base lg:text-xl`) when a smooth fluid scale is appropriate.

### When to use clamp

| Property | Before | After |
|----------|--------|-------|
| Font size (responsive variants) | `text-sm md:text-lg lg:text-2xl` | `text-[clamp(0.875rem,2.5vw,1.5rem)]` |
| Font size (existing CSS clamp) | `font-size: clamp(1.5rem, 4vw, 3rem)` | `text-[clamp(1.5rem,4vw,3rem)]` |
| Line-height (responsive) | `leading-tight md:leading-normal lg:leading-relaxed` | `leading-[clamp(1.25,1vw+1.1,1.75)]` |
| Padding / margin | `p-4 md:p-6 lg:p-10` | `p-[clamp(1rem,3vw,2.5rem)]` |
| Gap | `gap-4 md:gap-8` | `gap-[clamp(1rem,3vw,2rem)]` |
| Width / max-width | breakpoint overrides | `w-[clamp(300px,80vw,1200px)]` |
| Height / min-height | `h-32 md:h-48 lg:h-64` | `h-[clamp(8rem,20vw,16rem)]` |
| Border-radius (component scales) | `rounded md:rounded-lg lg:rounded-2xl` | `rounded-[clamp(0.25rem,1vw,1rem)]` |

### Clamp formula

```
clamp(MIN, PREFERRED, MAX)
  MIN       = smallest value (mobile floor)
  PREFERRED = fluid middle, typically Xvw or calc(Xvw + Yrem)
  MAX       = largest value (desktop cap)
```

Common preferred expressions:
- `2.5vw` — simple viewport-relative
- `calc(1rem + 1.5vw)` — base + fluid addition (most precise)
- `4vi` — inline-size relative (use when writing-mode matters)

### Clamp generation rules

1. **Font sizes** — any `font-size` with responsive variants → `text-[clamp(...)]`
2. **Line-height** — responsive `leading-*` variants → `leading-[clamp(...)]`; unitless preferred: `clamp(1.2,1vw+1,1.75)`
3. **Spacing (padding/margin/gap)** — 3+ responsive breakpoints on same property → `clamp()`; 2 breakpoints only if jump ≥ 2 Tailwind steps
4. **Dimensions (width/height/min/max)** — breakpoint overrides on same dimension → `clamp()`; use `px` for hard pixel bounds, `rem` for type-relative, `vw`/`vh` for viewport-relative
5. **Border-radius** — component-level radius that changes across breakpoints → `rounded-[clamp(...)]`; global/design-system radius values → keep as Tailwind semantic class (`rounded-lg`)
6. **Existing CSS `clamp()` values** → preserve verbatim, wrap in Tailwind arbitrary
7. **Never clamp:** colors, font-weight, border-width, z-index, opacity, grid column counts — discrete values don't benefit

### Clamp in global style map

When building the global style map, note any existing `clamp()` values in `tailwind.config.js` `fontSize` or `spacing` entries — use those keys directly instead of re-writing the clamp inline.

## Rules

- **Global styles first** — build the global style map before touching any file; use it for every conversion decision
- **Prefer semantic over arbitrary** — `font-sans` beats `font-['Inter']`, `leading-relaxed` beats `leading-[1.6]`
- **Skip inherited globals** — if body/html already sets `font-family` or `line-height` globally, don't repeat on child elements
- **Flag global conflicts** — per-element overrides that contradict globals get a comment: `/* overrides global */`
- Never delete CSS that has no Tailwind equivalent — keep it, flag it
- Never guess at color values — use nearest Tailwind color or flag it
- Custom `--css-variables` used across many places → keep as-is, note it
- Tailwind v3 class names by default; if project has `tailwind.config.js`, read it first for custom theme values
- If file uses `@apply` already → respect existing Tailwind usage, extend it
- Responsive/hover/focus variants: `hover:bg-blue-600`, `md:flex-row` — apply when original CSS had media queries or `:hover`
- Never add `!important` via `!` prefix unless original CSS had `!important`

## Global Style Extraction (Run First)

Before converting any file, extract global style definitions from the project:

### 1. Tailwind Config Theme
```bash
ls tailwind.config.js tailwind.config.ts 2>/dev/null
```
If found → read it. Extract `theme.extend` values for:
- `fontFamily`, `fontSize`, `fontWeight`, `lineHeight`, `letterSpacing`
- `colors`, `spacing`, `borderRadius`, `boxShadow`

Custom theme values **always** take precedence over default mappings.

### 2. CSS Custom Properties
Search for `:root` blocks in CSS/SCSS files:
```bash
grep -r ":root" --include="*.css" --include="*.scss" -l
```
Extract variables like `--font-sans`, `--leading-normal`, `--color-primary`, `--spacing-*`. Map them to Tailwind equivalents where possible.

### 3. Base / Global Stylesheets
Find and read global stylesheets (e.g. `global.css`, `base.css`, `app.css`, `main.css`, `index.css`):
- Extract `@layer base` rules — these define element-level defaults (body font, heading sizes, etc.)
- Extract `@apply` usage — shows which Tailwind classes are already canonical
- Note any `html`/`body` typography rules (font-family, font-size, line-height) — these cascade globally

### 4. Build a Global Style Map
Construct a local mapping before touching any file:

```
Global style map (example):
  --font-sans         → font-sans (or custom: font-['Inter'])
  --color-primary     → text-[var(--color-primary)] or nearest: text-blue-600
  body font-family    → font-sans (applied globally, skip per-element)
  body line-height    → leading-relaxed (applied globally, skip per-element)
  h1 font-size        → text-4xl (applied globally via @layer base)
```

### 5. Apply Global Map During Conversion
- If a CSS property matches a **globally-defined** value → use the semantic Tailwind class, not a hardcoded arbitrary value
- If the property is **already set globally** on that element type → omit the class entirely (it inherits)
- Prefer `font-sans` over `font-['Arial']` when the global font maps to Tailwind's `fontFamily.sans`
- Prefer `leading-normal` over `leading-[1.5]` when `1.5` matches the global `lineHeight.normal`
- Flag any per-element overrides that fight the global defaults — these may be intentional or cruft

## Output Style

Match active caveman mode. Default: terse, technical. Show diffs as before/after pairs for significant changes.
