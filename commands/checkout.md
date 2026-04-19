# Checkout Workflow

Checks out a branch and pulls latest. Usage: `/checkout <branch-name>`

1. Checkout branch:
   ```bash
   git checkout $ARGUMENTS
   ```
2. Pull latest:
   ```bash
   git pull origin $ARGUMENTS
   ```

**If branch doesn't exist locally:** ask user if they want to track remote branch:
```bash
git checkout -b $ARGUMENTS origin/$ARGUMENTS
```
