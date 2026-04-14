# PR Workflow

1. Push branch to origin
2. Open PR against `staging` (not `main`) unless hotfix
3. Fill PR template:
   - [ ] What changed
   - [ ] Staging tested?
   - [ ] DB or ACF changes? (describe or note none)
   - [ ] Plugin changes? (describe or note none)
   - [ ] README.md updated if needed?
4. Assign reviewer before marking ready
5. Do not self-merge without at least one approval

**Labels:** `needs-review` → `needs-qa` → `ready-to-merge`

**PRs to `staging`** = ready for QA
**PRs to `main`** = QA approved, ready for production
