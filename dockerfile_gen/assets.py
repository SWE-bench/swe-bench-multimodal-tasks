"""Mirror the binary assets a task's tests need.

Some tasks compare rendering against a baseline image, which a text patch cannot
carry. The dataset lists those files under ``image_assets`` as {path, url} pairs,
and the harness stages them into the container after applying the patch.

Keeping a copy with the task means an evaluation does not depend on a url still
being reachable years later. Assets live at ``tasks/<instance_id>/test_assets/<path>``,
mirroring where they land in the repository under test.

The images a problem statement links to are mirrored too, at
``tasks/<instance_id>/problem_assets/<n>-<name>``, where ``n`` is the entry's
position in ``image_assets.problem_statement``. They are the pictures a model is
shown, and the Dockerfile COPYs them into the image, so a rotted url cannot make
one go missing. The index prefix keeps them ordered and distinct, since 19
instances link to different images that share a filename.

    python -m dockerfile_gen.assets                 # fetch whatever is missing
    python -m dockerfile_gen.assets --force         # re-download everything
    python -m dockerfile_gen.assets -i <instance_id>
"""

from __future__ import annotations

import urllib.request
from argparse import ArgumentParser
from pathlib import Path, PurePosixPath
from urllib.parse import urlparse

from .tasks import TASKS_DIR, load_task, task_dirs

TIMEOUT = 60
PROBLEM_ASSETS_DIR = "problem_assets"
# a dead url often answers 200 with a login or error page, so check what arrived
IMAGE_MAGIC = (
    b"\x89PNG",
    b"\xff\xd8",
    b"GIF8",
    b"RIFF",
    b"<svg",
    b"\x00\x00\x01\x00",
    b"II*\x00",  # little-endian TIFF
    b"MM\x00*",  # big-endian TIFF
)


# the kinds the harness stages into the container, and where they are kept
STAGED_KINDS = ("test_patch", "patch")
TEST_ASSETS_DIR = "test_assets"


def _entries(instance: dict) -> list[dict]:
    """The assets staged at eval time: both test_patch and patch binaries.

    problem_statement assets go to problem_assets/ instead, and reach the container
    at build time via COPY rather than being staged here.
    """
    assets = instance.get("image_assets") or {}
    return [
        e
        for kind in STAGED_KINDS
        for e in assets.get(kind) or []
        if isinstance(e, dict) and e.get("path") and e.get("url")
    ]


def _problem_image_targets(task_dir: Path, instance: dict) -> list[tuple[Path, str]]:
    """Where each problem-statement image is kept, and the url it came from."""
    entries = (instance.get("image_assets") or {}).get("problem_statement") or []
    targets = []
    for i, entry in enumerate(entries):
        url = entry if isinstance(entry, str) else entry.get("url", "")
        if not url:
            continue
        name = PurePosixPath(urlparse(url).path).name or "image"
        targets.append((task_dir / PROBLEM_ASSETS_DIR / f"{i}-{name}", url))
    return targets


def _download(url: str, dest: Path, expect_image: bool = True) -> None:
    with urllib.request.urlopen(url, timeout=TIMEOUT) as resp:
        data = resp.read()
    if expect_image and not data.lstrip()[:8].startswith(IMAGE_MAGIC):
        raise ValueError(f"not an image, got {data.lstrip()[:16]!r}")
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_bytes(data)


def fetch_assets(
    tasks_dir: Path = TASKS_DIR,
    instance_ids: list[str] | None = None,
    force: bool = False,
) -> tuple[int, int, list[str]]:
    wanted = set(instance_ids or [])
    fetched = skipped = 0
    failed: list[str] = []

    for task_dir in task_dirs(tasks_dir):
        if wanted and task_dir.name not in wanted:
            continue
        instance = load_task(task_dir)
        for entry in _entries(instance):
            dest = task_dir / TEST_ASSETS_DIR / entry["path"]
            if dest.is_file() and not force:
                skipped += 1
                continue
            try:
                _download(entry["url"], dest)
                fetched += 1
            except Exception as e:  # noqa: BLE001 - report every failure, keep going
                failed.append(f"{task_dir.name} {entry['path']}: {type(e).__name__} {e}")

        for dest, url in _problem_image_targets(task_dir, instance):
            if dest.is_file() and not force:
                skipped += 1
                continue
            try:
                _download(url, dest)
                fetched += 1
            except Exception as e:  # noqa: BLE001 - a dead url is worth reporting, not fatal
                failed.append(f"{task_dir.name} {dest.name}: {type(e).__name__} {e}")
    return fetched, skipped, failed


def main() -> None:
    parser = ArgumentParser(description=__doc__)
    parser.add_argument("-i", "--instance", dest="instance_ids", nargs="+", default=None)
    parser.add_argument("--force", action="store_true", help="re-download existing files")
    args = parser.parse_args()

    fetched, skipped, failed = fetch_assets(
        instance_ids=args.instance_ids, force=args.force
    )
    print(f"fetched {fetched}, already present {skipped}, failed {len(failed)}")
    for line in failed:
        print(f"  {line}")


if __name__ == "__main__":
    main()
