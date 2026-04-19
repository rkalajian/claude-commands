# Push & Deploy Workflow

## Push

1. Final check:
   ```bash
   git log --oneline -5
   ```
2. Push:
   ```bash
   git push origin your-branch-name
   ```

**If anything looks wrong:** do NOT push again — check logs first.

## Post-Merge Deploy Verification

Applies after PR is merged to `main`.

1. Go to GitHub Actions tab immediately
2. Confirm build steps passed: npm install → build → composer → deploy
3. Check WPEngine env URL to verify changes are live

GitHub Actions runs automatically on merge. No manual deploys.
Verify production within 10 minutes of merge.
