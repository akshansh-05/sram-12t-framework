# Git Setup & Commands — Unified 12T SRAM Repository

A complete guide to initialising, using, and sharing this repository.

---

## Initial Setup (First Time Only)

```bash
# 1. Navigate into the project directory
cd sram-12t-framework

# 2. Initialise Git repository
git init

# 3. Set your identity (skip if already configured globally)
git config user.name  "Your Name"
git config user.email "you@example.com"

# 4. Stage all files
git add .

# 5. Create the initial commit
git commit -m "Initial commit: Unified 12T SRAM Design Framework

- Full gap analysis of DSPS-12T, SCM-12T, SR-Latch-12T, SER-12T
- Unified 12T cell HSPICE netlist (P1-P2/N1-N2 latch, P3-P4 DSPS
  write assist, N3-N4 write access, N5-N8 decoupled read path)
- Testbenches: read, write, row/column half-select, Monte Carlo
- Behavioural Verilog array model (128x32, 4 Kib)
- Python analysis scripts: SNM butterfly, MC distribution, benchmark
- Comprehensive documentation: gap analysis, architecture,
  operating modes, circuit analysis, references"
```

---

## Connect to GitHub / GitLab / Bitbucket

```bash
# Create a new (empty) repo on GitHub, then:
git remote add origin https://github.com/YOUR_USERNAME/sram-12t-framework.git

# Push to remote
git push -u origin main

# If your default branch is 'master', rename it first:
git branch -M main
git push -u origin main
```

---

## Daily Workflow

```bash
# Check status
git status

# Stage specific files
git add src/spice/unified_12T_cell.sp
git add docs/cell_architecture.md

# Stage all changes
git add .

# Commit with descriptive message
git commit -m "feat(spice): add DSPS P3/P4 body-effect parameters to netlist"

# Push to remote
git push
```

---

## Branching — Recommended Workflow

```bash
# Create a feature branch for new simulations
git checkout -b feature/finFET-7nm-extension

# ... make changes ...
git add .
git commit -m "feat: add 7nm FinFET technology model integration"

# Merge back to main when ready
git checkout main
git merge feature/finFET-7nm-extension

# Delete the feature branch after merge
git branch -d feature/finFET-7nm-extension
```

### Suggested Branch Names

| Branch | Purpose |
|---|---|
| `main` | Stable, paper-submission state |
| `feature/silicon-tapeout` | Post-layout and tapeout files |
| `feature/finFET` | 7–16 nm FinFET extension |
| `feature/SEU-hardening` | Space/radiation SEU analysis |
| `results/mc-65nm` | Monte Carlo results for 65 nm corner |

---

## Tagging Versions

```bash
# Tag the current state as paper submission version
git tag -a v1.0.0 -m "IEEE TVLSI submission — May 2026"
git push origin v1.0.0

# List all tags
git tag -l

# Checkout a specific tag
git checkout v1.0.0
```

---

## Useful Commands

```bash
# View commit history (pretty format)
git log --oneline --graph --decorate

# View changes in a file
git diff src/spice/unified_12T_cell.sp

# Undo unstaged changes in a file
git checkout -- src/spice/tb_write.sp

# Undo last commit (keep changes staged)
git reset --soft HEAD~1

# Show all remote branches
git branch -r

# Pull latest from remote
git pull origin main

# Stash uncommitted work temporarily
git stash
git stash pop
```

---

## Commit Message Conventions

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(scope): short description

[optional body]
[optional footer]
```

| Type | Use for |
|---|---|
| `feat` | New files, features, testbenches |
| `fix` | Bug fixes in netlists or scripts |
| `docs` | Documentation changes |
| `sim` | New simulation results added |
| `refactor` | Netlist cleanup, parameter changes |
| `chore` | Build scripts, requirements updates |

**Examples:**
```bash
git commit -m "feat(spice): add column half-select testbench"
git commit -m "docs: add circuit analysis derivations for WM"
git commit -m "sim: add 1000-pt MC results at 65nm SF corner"
git commit -m "fix(python): correct SNM normalisation in radar chart"
```

---

## Repository Structure Reminder

```
sram-12t-framework/
├── README.md
├── LICENSE
├── .gitignore
├── requirements.txt
├── GIT_COMMANDS.md          ← You are here
├── docs/                    ← All documentation
├── src/spice/               ← HSPICE netlists and testbenches
├── src/verilog/             ← Behavioural RTL models
├── src/python/              ← Analysis and plotting scripts
├── results/tables/          ← CSV data tables
├── results/figures/         ← Generated plots (gitignored by default)
└── scripts/                 ← Automation shell scripts
```
