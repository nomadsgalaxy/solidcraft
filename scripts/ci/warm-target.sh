#!/usr/bin/env bash
# Self-hosted runner only: keep a job's Cargo build directory between runs, outside the
# checkout (actions/checkout's clean would delete it). Usage: warm-target.sh NAME [--link]
#   default  sets CARGO_TARGET_DIR for the rest of the job
#   --link   links ./target to it instead, for jobs whose test binaries must keep
#            checkout-relative paths (env!("CARGO_BIN_EXE_*") in the nextest archive)
# Each self-hosted runner has its own /home/runner/work, so two never share a directory.
set -euo pipefail
name=${1:?usage: warm-target.sh NAME [--link]}
dir=/home/runner/work/cargo-target/$name
# Start over when it has grown past 40 GB: old dependency versions pile up.
if [ -d "$dir" ] && [ "$(du -sm "$dir" | cut -f1)" -gt 40000 ]; then
  echo "warm-target: $dir is over 40 GB, starting a fresh build"
  rm -rf "$dir"
fi
mkdir -p "$dir"
if [ "${2:-}" = --link ]; then
  rm -rf target
  ln -s "$dir" target
else
  echo "CARGO_TARGET_DIR=$dir" >> "$GITHUB_ENV"
fi
echo "warm-target: $dir ($(du -sh "$dir" | cut -f1))"
