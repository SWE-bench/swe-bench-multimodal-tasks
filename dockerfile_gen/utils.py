"""
Inlined utilities from swebench — makes this package fully standalone.
"""

from hashlib import blake2b

from .constants import REPO_BASE_COMMIT_BRANCH


def generate_heredoc_delimiter(content: str) -> str:
    delimiter = f"EOF_{blake2b(content.encode()).hexdigest()[:12]}"
    while delimiter in content:
        delimiter = (
            f"EOF_{blake2b(content.encode() + delimiter.encode()).hexdigest()[:12]}"
        )
    return delimiter


def make_heredoc_run_command(commands: list[str]) -> str:
    """Create a heredoc-style RUN command from a list of shell commands."""
    if not commands:
        return ""
    heredoc_content = "\n".join(["#!/bin/bash", "set -euxo pipefail", *commands])
    delimiter = generate_heredoc_delimiter(heredoc_content)
    return f"RUN <<{delimiter}\n{heredoc_content}\n{delimiter}\n"


def git_clone_timesafe(repo: str, base_commit: str, workdir: str) -> list[str]:
    """Generate shell commands to clone a repo and remove references to future information."""
    branch = REPO_BASE_COMMIT_BRANCH.get(repo, {}).get(base_commit, "")
    if branch:
        clone_cmd = f"git clone -o origin --branch {branch} --single-branch https://github.com/{repo} {workdir}"
    else:
        # Fetch just the base commit. A full clone bakes every historical version of
        # committed artifacts into the image -- carbon's .git alone is 7.8GB of a 9.2GB
        # /testbed because Yarn zero-installs commits dependency zips. Falls back to a
        # full clone if the host refuses a by-SHA fetch.
        # lighthouse's build stamps a version via `git describe`, which needs a tag
        # reachable from HEAD. A shallow fetch has no such tag (the nearest is ~300
        # commits back) and separately fetched tags land on their own shallow
        # branches, so only full history works. Its .git is 399MB, unlike carbon's
        # 7.8GB. The prune below still drops every tag newer than the base commit.
        if repo == "GoogleChrome/lighthouse":
            clone_cmd = f"git clone -o origin https://github.com/{repo} {workdir}"
        else:
            clone_cmd = (
                f"(mkdir -p {workdir} && cd {workdir} && git init -q . "
                f"&& git remote add origin https://github.com/{repo} "
                f"&& git fetch -q --depth 1 origin {base_commit} "
                f"&& git reset -q --hard FETCH_HEAD) "
                f"|| (rm -rf {workdir} && git clone -o origin https://github.com/{repo} {workdir})"
            )
    return [
        clone_cmd,
        f"cd {workdir}",
        f"git reset --hard {base_commit}",
        "git remote remove origin",
        f"BASE_COMMIT=$(git rev-parse {base_commit}^{{commit}})",
        # Retain only tags whose target commit is an ancestor of the task's base.
        # Commit timestamps are attacker-controlled and therefore cannot define the
        # history boundary: a backdated descendant would otherwise remain reachable.
        # Deleting every tag is not viable because some projects derive their version
        # from an older reachable tag during tests.
        'for tag in $(git tag -l); do TAG_COMMIT=$(git rev-parse -q --verify "$tag^{commit}" 2>/dev/null || true); if [ -z "$TAG_COMMIT" ] || ! git merge-base --is-ancestor "$TAG_COMMIT" "$BASE_COMMIT"; then git tag -d "$tag" >/dev/null 2>&1 || true; fi; done',
        "git branch | grep -v '^\\*' | xargs -r git branch -D || true",
        # These pseudo-refs are not covered by `git reflog expire`; leaving the old
        # reset/fetch tips behind exposes identifiers outside the permitted graph.
        "rm -f .git/ORIG_HEAD .git/FETCH_HEAD",
        "git reflog expire --expire=now --all",
        # Physically drop the now-unreachable future commits; without this they
        # stay in the pack and are readable via git cat-file / fsck.
        "git gc --prune=now --aggressive",
        # Assert both reference reachability and physical object storage. The second
        # check catches an unreachable future commit that a failed gc left readable
        # through `git cat-file`, even though `git log --all` cannot see it.
        'EXTRA_REF_COMMITS=$(git rev-list --all --not "$BASE_COMMIT" | wc -l)',
        '[ "$EXTRA_REF_COMMITS" -eq 0 ] || exit 1',
        'EXTRA_STORED_COMMITS=$(comm -23 <(git cat-file --batch-all-objects --batch-check="%(objecttype) %(objectname)" | awk \'$1 == "commit" {print $2}\' | sort) <(git rev-list "$BASE_COMMIT" | sort) | wc -l)',
        '[ "$EXTRA_STORED_COMMITS" -eq 0 ] || exit 1',
        'UNREACHABLE_OBJECTS=$(git fsck --unreachable --no-reflogs 2>/dev/null | wc -l)',
        '[ "$UNREACHABLE_OBJECTS" -eq 0 ] || exit 1',
        # chmod last: `git reset --hard` above re-creates working-tree files as
        # root-owned 0644, so chmod'ing before it left committed lockfiles
        # unwritable by chromeuser and npm install failed with EACCES.
        f"chmod -R 777 {workdir}",
        "cd - || true",
    ]


def get_modified_files(patch: str) -> list[str]:
    """Get the list of modified files in a patch."""
    from unidiff import PatchSet

    source_files = [
        f.source_file for f in PatchSet(patch) if f.source_file != "/dev/null"
    ]
    return [x[2:] for x in source_files if x.startswith("a/")]
