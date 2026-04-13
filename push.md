# Push & Deploy Workflow

1. Final check:
   ```bash
   git log --oneline -5
   ```
2. Push:
   ```bash
   git push origin your-branch-name
   ```
3. After PR merge → go to GitHub Actions tab immediately
4. Confirm build steps passed: npm install → build → composer → deploy
5. Check WPEngine env URL to verify changes are live

**If anything looks wrong:** do NOT push again — check logs first.

GitHub Actions runs automatically on merge. No manual deploys.
After merging to `main`, verify production within 10 minutes.
