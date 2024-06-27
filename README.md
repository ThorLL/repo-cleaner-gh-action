# Repository Cleaner GitHub Action

The **Repository Cleaner** GitHub Action is designed to delete all branches, tags, releases, and history,
providing a clean slate for your repository.
Use this action with extreme caution, as it will irreversibly erase critical repository data.

## Author
ThorLL [<img src="https://skillicons.dev/icons?i=github" alt="GitHub Icon" style="vertical-align: middle; height: 1em;">](https://github.com/ThorLL)

## Usage
To use the Repository Cleaner action, create a [workflow file](https://docs.github.com/en/actions/using-workflows/about-workflows) in your repository (e.g., `github/workflows/clean.yml`) with the following content:

### Permissions required:
- contents: write
- deployments: write
- actions: write

```yaml
name: Clean Repository

on: workflow_dispatch

permissions:
  contents: write
  deployments: write
  actions: write

jobs:
  clean-repo:
    runs-on: ubuntu-latest
    steps:
      - name: Repository Cleaner
        uses: ThorLL/repo-cleaner-gh-action@v1.0.0
        with:
          gh-token: ${{ secrets.GITHUB_TOKEN }}
          init-message: 'Your custom commit message'
          wipe-deployments: 'true | false | omit'
          wipe-workflow-history: 'true | false | omit'
```

## Inputs

- `gh-token`: (required) GitHub Token to authenticate API requests.
- `init-message`: (optional) The commit message for the new initial commit. Defaults to Init Commit.
- `wipe-deployments`: (optional) Whether to delete all deployments. Defaults to true.
- `wipe-workflow-history`: (optional) Whether to delete all workflow history. Defaults to true.

## ⚠️ WARNING ⚠️
This action will have a destructive impact on your repository:

- All branches except the default branch will be deleted.
- All tags and releases will be deleted.
- The entire commit history will be replaced with a single new initial commit.
- All deployments will be deleted if wipe-deployments is set to true.
- All workflow history will be deleted if wipe-workflow-history is set to true.
  This action is irreversible. Ensure you have proper backups and fully understand the consequences before using this action.