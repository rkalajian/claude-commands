# Workflow Reference

This folder contains concise Git and npm workflow guidance for the repository.

## Contents

### Atomic
- `commit.md` — commit workflow and formatting rules
- `ghbranch.md` — branch creation and naming conventions
- `checkout.md` — checkout branch and pull latest
- `push.md` — push branch; post-merge deploy verification
- `pr.md` — pull request workflow and checklist
- `npm.md` — safe npm package install/update/remove workflow
- `composer.md` — safe Composer package install/update/remove workflow

### Combo
- `deliver.md` — commit → push
- `ship.md` — commit → push → PR

## Usage

Refer to these files any time you:

- create or switch branches
- stage and commit changes
- open a pull request
- push code to the remote
- verify a deploy after merge
- install or update npm or Composer packages

## Notes

- `staging` is the default PR target for features and fixes
- `main` is reserved for hotfix or production-ready merges
- Always pin npm installs with `--save-exact`
- Do not commit sensitive or generated files like `wp-config.php`, `node_modules/`, or `vendor/`

## Recommended workflow

1. Start from `staging`
2. Create a branch with a clear prefix (`feat/`, `fix/`, `chore/`, `hotfix/`)
3. Make changes and stage intentionally
4. Commit with a structured message
5. Push, open a PR, and assign a reviewer
6. Confirm CI/build success after merge
