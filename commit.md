# Commit Workflow

1. Review changes:
   ```bash
   git status
   git diff
   ```
2. Stage intentionally — avoid blind `git add .`
3. Verify nothing in `.gitignore` is staged
4. Commit format:
   ```bash
   git commit -m "feat(theme): add hero animation"
   ```
   Types: `feat`, `fix`, `chore`, `style`, `refactor`, `docs`, `build`

5. ACF fields changed? Confirm JSON exported and staged.
6. Setup/architecture changed? Update `README.md` and include in this commit.

**Never commit:** `wp-config.php`, `node_modules/`, `vendor/`, `wp-content/uploads/`, `.DS_Store`, `*.sql`
