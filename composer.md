# Composer Package Skill

Safe install, update, and remove workflow. Always pin exact versions. Never use unversioned or wildcard constraints.

---

## Installing a Package

### 1. Research the package

Check on [packagist.org](https://packagist.org):
- Downloads trending up or down? Prefer packages with high adoption.
- Last release date — prefer versions ≥7 days old (supply chain risk on same-day releases).
- Abandoned flag? Packagist marks unmaintained packages — avoid unless no alternative.
- Maintainer count — single-maintainer packages are higher risk.

```bash
composer show <vendor/package>               # Info on an installed package
```

For uninstalled packages, check packagist.org directly for version history and publish dates.

### 2. Check compatibility before installing

```bash
composer require <vendor/package>:<version> --dry-run
```

- Resolves the full dependency graph without making changes.
- If conflicts appear, stop — do not force-install. Investigate before proceeding.
- Check that the package supports your PHP version and framework version.

### 3. Install pinned

```bash
composer require <vendor/package>:<X.Y.Z> --update-with-dependencies
```

Never: `composer require <vendor/package>` or with `^X.Y` or `~X.Y` constraints.

After install, verify `composer.json` shows an exact version (no `^` or `~`):

```bash
grep <package> composer.json
```

### 4. Security audit

```bash
composer audit
```

- **High/critical advisories** → do NOT proceed. Investigate and resolve before continuing.
- **Moderate/low** → flag to user, document, get explicit OK to continue.
- Clean audit → proceed.

### 5. Verify project integrity

```bash
composer validate
composer install --dry-run    # Confirm lock file is consistent
```

---

## Updating Packages

### 1. Check what's outdated

```bash
composer outdated
```

Output shows: currently installed version vs latest available.

### 2. Assess each update

For each package to update:
- Check packagist.org for publish date of target version — skip same-day releases.
- Major version bump → review changelog and migration guide for breaking changes.
- Minor/patch ≥7 days old → generally safe, but still dry-run first.

### 3. Dry-run first

```bash
composer update <vendor/package> --dry-run
```

Confirm no unexpected transitive dependency changes before applying.

### 4. Update selectively

```bash
composer update <vendor/package> --with-dependencies
```

Avoid `composer update` with no arguments — it updates everything at once and makes auditing harder. Update one package or small logical groups at a time.

After updating, verify `composer.json` and `composer.lock` reflect the expected pinned version:

```bash
grep <package> composer.json composer.lock
```

### 5. Audit after update

```bash
composer audit
```

Same rules as install: high/critical = stop.

### 6. Verify project still works

```bash
composer validate
php artisan test          # Laravel
./vendor/bin/phpunit      # PHPUnit directly
./vendor/bin/pest         # Pest
```

Run the project's test suite. Confirm no regressions before committing `composer.json` / `composer.lock`.

---

## Removing a Package

### 1. Check for dependents first

```bash
composer depends <vendor/package>
```

If other packages depend on it, removing may break the project. Resolve those first.

### 2. Remove

```bash
composer remove <vendor/package>
```

### 3. Audit and verify

```bash
composer audit
composer validate
```

Confirm no new vulnerabilities introduced by the changed dependency graph.

---

## Flags Reference

| Flag | Purpose |
|------|---------|
| `--dry-run` | Preview changes without applying |
| `--update-with-dependencies` | Also update transitive deps of the target package |
| `--with-dependencies` | Same, for `update` command |
| `--no-dev` | Exclude dev dependencies (production installs) |
| `--prefer-stable` | Prefer stable releases over dev/RC versions |
| `--no-scripts` | Skip post-install/update scripts (use carefully) |

---

## Red Flags — Stop and Flag to User

- Package published < 24 hours ago
- Package marked **Abandoned** on Packagist
- Maintainer changed in last 30 days
- `composer audit` shows high or critical advisory
- Package name is a typosquat of a popular package (e.g. `laravell/framework`)
- Dry-run shows unexpected major version bumps in transitive dependencies
- Package requires loosening PHP version or framework version constraints
