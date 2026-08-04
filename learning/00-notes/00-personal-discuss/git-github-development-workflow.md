# Git & GitHub Development Workflow

**Date:** 04 August 2026
**Topic:** Personal discussion — the right flow for developing a repo when both local and GitHub only have a `main` branch.

---

## Context

- Repo has only a `main` branch on both local and GitHub.
- Scenario: I need to develop something (e.g. the CTE query fix).
- Question: edit + commit on `main` directly, or create a branch before changing anything?

---

## Recommended Workflow (Branch → PR → Merge)

**Create the branch first, before changing anything.**

```
1. Create & switch to a feature branch (local)
   git checkout -b fix/cte-placement

2. Make edits, verify, test

3. Stage & commit
   git add learning/03-dq-learning/datasets/dq_dataset.sql ...
   git commit -m "fix: move CTE after INSERT INTO in DQ dataset loaders"

4. Push the branch to GitHub (creates a new remote branch)
   git push -u origin fix/cte-placement

5. Open a Pull Request on GitHub: fix/cte-placement → main
   gh pr create --title "fix: CTE placement" --fill

6. Review → merge the PR
   gh pr merge --merge

7. Sync local main
   git checkout main
   git pull
```

### Why branch first

- `main` stays clean and always-releasable — never left half-broken.
- A PR gives a review point and documents *why* the change happened.
- Multiple fixes can live in parallel (`fix/...`, `docs/...`, `feature/...`) without interfering.

---

## What NOT to do

**Don't** commit everything to `main`, then push it as a new branch. That flow is backwards:

- The commit already lands on `main`; the "new branch" then doesn't cleanly separate the change.
- You lose the review point, and `main` becomes a dumping ground.

---

## What if I already committed to `main` (before pushing)?

Not a disaster — it's recoverable **as long as the commit hasn't been pushed to GitHub yet**.

### Option A — Accept it (simplest, fine for solo repos)

```bash
git push origin main
```

For a personal/learning repo, committing straight to `main` is acceptable. Just stay disciplined afterward.

### Option B — Recover the branch/PR flow (clean, no history rewrite)

```bash
git branch fix/cte-placement                  # branch pointing at the local commit
git checkout main
git reset --hard origin/main                  # local main back to GitHub state
git checkout fix/cte-placement
git push -u origin fix/cte-placement          # push the branch
gh pr create --title "fix: CTE placement" --fill
gh pr merge --merge
```

Because the commit was never pushed, this only moves the commit onto a branch — no force-push, no rewriting of shared history.

---

## Rule of thumb

| Situation | Flow |
|-----------|------|
| Solo/learning repo, tiny fix | Commit to `main` is acceptable |
| Real-world team repo, any change | Branch → PR → merge, always |
| Already committed locally, not pushed | Option B recovery still possible |

---

## Note

- As of this note, the CTE fix is committed on local `main` (1 commit ahead of `origin/main`), not yet pushed. Either Option A or B above can be applied.
