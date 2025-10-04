# git-brush

A simple command-line tool to clean up your git repository by removing merged branches.

## Features

- Remove local branches that have been merged into the current branch
- Automatically protects important branches (main, master, develop)
- Dry-run mode to preview changes before applying
- Force delete option for unmerged branches

## Installation

Clone the repository and install using pip:

```bash
git clone https://github.com/quatabenho/git-brush.git
cd git-brush
pip install .
```

Or install directly from the repository:

```bash
pip install git+https://github.com/quatabenho/git-brush.git
```

## Usage

Navigate to any git repository and run:

```bash
git-brush
```

### Options

- `--dry-run`: Preview which branches would be deleted without actually deleting them
- `--force`: Force delete branches even if they haven't been merged (use with caution)

### Examples

Preview merged branches that would be deleted:
```bash
git-brush --dry-run
```

Delete all merged branches:
```bash
git-brush
```

Force delete branches:
```bash
git-brush --force
```

## How it works

git-brush identifies local branches that have been merged into your current branch and safely removes them. It automatically skips important branches like `main`, `master`, and `develop` to prevent accidental deletion.

## Requirements

- Python 3.6 or higher
- Git installed and accessible from the command line

## License

This project is open source and available under the MIT License.

