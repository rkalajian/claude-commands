# npm Package Skill

Safe install and update workflow. Never use `@latest` or unversioned installs. Always pin exact versions.

---

## Installing a Package

### 1. Research the package

```bash
npm view <package> versions --json   # See all published versions
npm view <package> dist-tags         # See tagged releases (latest, beta, etc.)
npm view <package> time --json       # See publish dates per version
```

Check:
- Downloads trending up or down? Prefer >10k weekly downloads.
- Last publish date — prefer versions ≥1 week old (supply chain risk on same-day releases)
- Is `latest` tag ≥1 week old? If not, pin to the previous stable version.

### 2. Choose a version

```bash
npm view <package> version           # What `latest` tag currently resolves to
```

- Pick the `latest`-tagged version **if** it was published ≥7 days ago
- Otherwise pin to the most recent version that is ≥7 days old:
  ```bash
  npm view <package> time --json | grep -E '"[0-9]+\.[0-9]+\.[0-9]+"' | tail -20
  ```

### 3. Install pinned

```bash
npm install <package>@X.Y.Z --save-exact
```

Never: `npm install <package>` or `npm install <package>@latest`

### 4. Audit

```bash
npm audit
```

- **High/critical vulns** → do NOT proceed. Investigate before continuing.
- **Moderate/low** → flag to user, document, get explicit OK to continue.
- Clean audit → proceed.

### 5. Verify

```bash
cat package.json | grep <package>    # Confirm exact version, no ^ or ~
```

---

## Updating Packages

### 1. Check what's outdated

```bash
npm outdated
```

Output columns: `Current` / `Wanted` (range max) / `Latest` (latest tag)

### 2. Assess each update

For each package to update:

```bash
npm view <package> time --json | grep "\"X.Y.Z\""   # Check publish date of target version
```

- Major version bump → check changelog for breaking changes before updating
- Minor/patch on a dep ≥1 week old → generally safe
- Same-day publish → skip, come back in a week

### 3. Update selectively (not all at once)

```bash
npm install <package>@X.Y.Z --save-exact
```

Avoid `npm update` (applies ranges, not exact pins). Update one package at a time or small logical groups.

### 4. Audit after each update

```bash
npm audit
```

Same rules as install: high/critical = stop.

### 5. Build + test

```bash
npm run build
```

Confirm build passes before committing the package.json / package-lock.json changes.

---

## Resolving Wildcard (`*`) Versions in package.json

When `package.json` contains `*` for a dependency version, replace it with a pinned version before any install or commit.

### 1. Find all wildcards

```bash
grep -E '"[^"]+": "\*"' package.json
```

### 2. Resolve each wildcard to a pinned version

For each package with `*`:

```bash
npm view <package> dist-tags         # See latest tag
npm view <package> time --json       # Check publish date of latest
```

Apply same rules as installing: pick `latest` if ≥7 days old, else pick most recent version ≥7 days old.

### 3. Replace in package.json

Replace `"*"` with exact version string (no `^` or `~`):

```json
"<package>": "X.Y.Z"
```

### 4. Install and audit

```bash
npm install
npm audit
```

Confirm no wildcards remain:

```bash
grep '"*"' package.json   # Should return nothing
```

---

## Removing a Package

```bash
npm uninstall <package>
npm audit     # Confirm no new vulns introduced by dependency graph change
```

---

## Flags Reference

| Flag | Purpose |
|------|---------|
| `--save-exact` | Pins to exact version (no `^` or `~`) |
| `--save-dev` | Dev dependency |
| `--save-prod` | (default) Production dependency |
| `--dry-run` | Preview what would change |

---

## Red Flags — Stop and Flag to User

- Package published < 24 hours ago
- Maintainer changed in last 30 days (check npmjs.com)
- `npm audit` shows high or critical
- Package name is a typosquat of a popular package (e.g. `expres` vs `express`)
- Package has <100 weekly downloads and isn't an internal/niche tool
