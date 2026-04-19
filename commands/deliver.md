# Deliver Workflow

Runs `/commit` → `/push` in sequence. Stop and report if any step fails.

---

## Step 1 — Commit

1. Review changes:
   ```bash
   git status
   git diff
   ```
2. Stage intentionally — avoid blind `git add .`
3. Verify nothing in `.gitignore` is staged
4. Commit (Conventional Commits format):
   ```bash
   git commit -m "feat(scope): description"
   ```
   Types: `feat`, `fix`, `chore`, `style`, `refactor`, `docs`, `build`

5. ACF fields changed? Confirm JSON exported and staged.
6. Setup/architecture changed? Update `README.md` and include in this commit.

**Never commit:** `wp-config.php`, `node_modules/`, `vendor/`, `wp-content/uploads/`, `.DS_Store`, `*.sql`

---

## Step 2 — Push

1. Final check:
   ```bash
   git log --oneline -5
   ```
2. Push:
   ```bash
   git push origin your-branch-name
   ```

**If anything looks wrong:** do NOT continue — check logs first.
