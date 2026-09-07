---
name: skel
description: Guidance for maintaining projects generated from python-packaging/skel templates. Use when updating a project from its skel branch, handling .vars.ini, regenerating template output, pushing skel branches, or resolving merge conflicts from skel updates.
---

# Skel Maintenance

Use this skill when working with repositories based on [`python-packaging/skel`](https://github.com/python-packaging/skel), especially when updating generated project files from the upstream template.

## Core model

- A project using skel has a dedicated `skel` branch.
- `.vars.ini` is the main signal that the repo is using skel.
- Running skel may update `.vars.ini` and then regenerate files from templates.
- The `skel` branch must be pushed after updates; do not leave important skel changes only local.

## Before making changes

1. Inspect the current branch and repo state:

   ```bash
   git status --short --branch
   git branch --list skel
   test -f .vars.ini && sed -n '1,160p' .vars.ini
   ```

2. If `.vars.ini` exists, assume skel may own/generated-manage project boilerplate.
3. If there is no `skel` branch or `.vars.ini`, ask before inventing a skel flow.

## Updating from skel

Typical flow:

```bash
git fetch --all --prune
git switch skel
# usually one of:
~/code/skel/regen-git.py
# or:
~/skel/regen-git.py
# inspect .vars.ini and generated changes
git status --short
git diff
git commit -am "Update from skel"
git push origin skel
```

`regen-git.py` may be interactive. It updates/regenerates the `skel` branch from the skel templates, potentially including `.vars.ini` changes.

Common local skel checkout locations are `~/code/skel` and `~/skel`. Before running `regen-git.py`, generally check that the skel checkout is not stale relative to its upstream:

```bash
cd ~/code/skel  # or ~/skel
git status --short --branch
git fetch --all --prune
git status --short --branch
git log --oneline --decorate --max-count=8 HEAD @{u} 2>/dev/null || true
```

Do not regenerate from a stale skel checkout. It is acceptable to regenerate from a local skel checkout that is newer than upstream if that is intentional. Ask if the checkout is behind upstream, has unclear local changes, or has no configured upstream.

If neither common checkout exists, or the intended skel checkout is unclear, inspect project docs/history before guessing:

```bash
git log --oneline -- .vars.ini
git log --oneline --all --grep=skel
rg -n "skel|\.vars\.ini|cookiecutter|template" README* pyproject.toml .github . || true
```

Ask the user when the regeneration command or intended upstream source is unclear.

## Merging a skel run

When merging/cherry-picking/rebasing skel-generated changes back to the main development branch:

- Tend heavily toward skel's copy as "the new way".
- Treat skel output as canonical for boilerplate/config files unless there is a clear project-specific reason not to.
- Major exception: if the local divergence was intentionally commenting something out, preserve or ask about that intent rather than blindly re-enabling it.
- Do not simply dump conflict markers into files. Conflict markers are especially unmanageable in YAML/TOML/config files.
- Resolve conflicts into valid final files, then show the user the resolved diff.
- Ask if unsure.

Useful conflict workflow:

```bash
git status --short
git diff --name-only --diff-filter=U
```

For each conflicted file:

1. Inspect both sides carefully.
2. Prefer the skel side for regenerated structure/defaults.
3. Preserve intentional local comments/disables where they look meaningful.
4. Produce a clean, syntactically valid file with no conflict markers.
5. Run relevant format/check commands if known.

Check for unresolved markers before finishing:

```bash
rg -n '^(<<<<<<<|=======|>>>>>>>)' .
```

## Communication

- State when you are treating skel output as canonical.
- Point out any intentional-looking local disables/comments you preserved.
- If uncertain whether a local divergence is intentional, ask instead of guessing.
