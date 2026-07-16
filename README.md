# nix

This repository now includes starter GitHub Actions workflows so you can test and deploy from GitHub without local setup.

## What is included

- `/home/runner/work/nix/nix/.github/workflows/ci.yml`
  Runs basic checks on every push and pull request.
- `/home/runner/work/nix/nix/.github/workflows/deploy.yml`
  Supports manual deploys from the GitHub Actions UI and tag/release deploy triggers.

## Step-by-step (layman friendly)

1. Push your code to GitHub.
2. Open your repository in GitHub.
3. Click the **Actions** tab.
4. Click **Repository CI** and run it (or push a commit to trigger it).
5. Wait for green checks. If it fails, click into the failed job and read the error log.
6. In GitHub, open **Settings → Environments** and create an environment named `production`.
7. In **Settings → Secrets and variables → Actions**, add any deployment secrets your real deployment needs.
8. Go back to **Actions** and open **Repository Deploy**.
9. Click **Run workflow**, choose `confirm = yes`, and run it.
10. Verify your deployed system is healthy, then repeat this cycle for each change.

## Important note

These workflows are safe starter templates. Update the CI "Test" step and deploy steps with your real project commands when your codebase is added.