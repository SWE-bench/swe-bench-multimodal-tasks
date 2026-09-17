# SWE-bench Dockerfiles (Multimodal)

Dockerfile generator for SWE-bench Multimodal benchmark.

## Usage

```bash
# From HuggingFace dataset
dockerfile-gen

# From local JSON/JSONL file
dockerfile-gen

# Specific instances
dockerfile-gen
```

## Output

`Dockerfile`, `eval.sh`, and a restrictive `.dockerignore` are regenerated in place under
`tasks/<instance_id>/`, from that task's `task.yaml`. The build context exposes only the
Dockerfile and public `problem_assets`; gold patches and grading fixtures are excluded.

## Install

```bash
pip install -e .
```

See [`docs/offline-grading.md`](docs/offline-grading.md) for the network-isolated grading
contract and grader-only dependency cache interface.

## Running gold evaluation

Run with modest parallelism, around `-j 4`. Generated evaluation scripts merge stderr
into stdout before enabling shell tracing, so test results and the harness's start/end
markers retain their execution order under Docker and Podman.
