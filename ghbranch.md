# Branch Workflow

1. Confirm current branch — must be `staging` for features/fixes
2. Pull latest:
   ```bash
   git pull origin staging
   ```
3. Create and checkout:
   ```bash
   git checkout -b feat/your-feature-name
   ```
   Prefixes: `feat/`, `fix/`, `chore/`, `hotfix/`

4. Push and set upstream:
   ```bash
   git push -u origin feat/your-feature-name
   ```

**Hotfix to prod:** branch off `main` → PR to `main` → back-merge to `staging` immediately.
