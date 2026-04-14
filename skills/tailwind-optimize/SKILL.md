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

## Rules

- Never delete CSS that has no Tailwind equivalent — keep it, flag it
- Never guess at color values — use nearest Tailwind color or flag it
- Custom `--css-variables` used across many places → keep as-is, note it
- Tailwind v3 class names by default; if project has `tailwind.config.js`, read it first for custom theme values
- Check `tailwind.config.js` for custom spacing/colors before using default mappings
- If file uses `@apply` already → respect existing Tailwind usage, extend it
- Responsive/hover/focus variants: `hover:bg-blue-600`, `md:flex-row` — apply when original CSS had media queries or `:hover`
- Never add `!important` via `!` prefix unless original CSS had `!important`

## Config Check

Before optimizing, check for:
```bash
ls tailwind.config.js tailwind.config.ts 2>/dev/null
```
If found → read it. Custom theme values take precedence over defaults.

## Output Style

Match active caveman mode. Default: terse, technical. Show diffs as before/after pairs for significant changes.
