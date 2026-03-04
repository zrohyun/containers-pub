#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATE_TAG="$(date -u +%Y%m%d)"
RUN_TS="$(date -u +%Y%m%dT%H%M%SZ)"
LOCAL_TAG="24.04-local-${DATE_TAG}"
JOB_NAME="$(basename "${BASH_SOURCE[0]}" .sh)"

LOG_DIR="${ROOT_DIR}/_hub/_data/logs"
LOG_FILE="${LOG_DIR}/${JOB_NAME}_${RUN_TS}.log"
mkdir -p "${LOG_DIR}"

exec > >(tee -a "${LOG_FILE}") 2>&1

IMAGE="base-ubuntu-apt-brew:${LOCAL_TAG}"

SECONDS=0
DURATION_BUILD=0
DURATION_VERIFY=0

print_summary() {
  local total_elapsed="${SECONDS}"

  echo
  echo "===== Build/Verify Duration Summary (seconds) ====="
  printf "%-24s %6ss\n" "build: ubuntu-apt-brew" "${DURATION_BUILD}"
  printf "%-24s %6ss\n" "verify: ubuntu-apt-brew" "${DURATION_VERIFY}"
  printf "%-24s %6ss\n" "script total" "${total_elapsed}"
  echo "log file: ${LOG_FILE}"
  echo "===================================================="
}

on_exit() {
  local exit_code=$?
  print_summary
  if [ "${exit_code}" -ne 0 ]; then
    echo "[ERROR] script failed with exit code ${exit_code}" >&2
  fi
}
trap on_exit EXIT

if ! command -v docker >/dev/null 2>&1; then
  echo "[ERROR] docker CLI not found. Install Docker first." >&2
  exit 1
fi

cd "${ROOT_DIR}"

echo "[info] log path: ${LOG_FILE}"

echo "[1/1] Build apt-brew image"
step_start="${SECONDS}"
docker build \
  -f docker/ubuntu-apt-brew/Dockerfile \
  -t "${IMAGE}" \
  .
DURATION_BUILD=$((SECONDS - step_start))

echo "[verify] apt-brew image"
step_start="${SECONDS}"
docker run --rm "${IMAGE}" bash -lc 'apt-get --version >/dev/null && git --version >/dev/null && curl --version >/dev/null && brew --version | head -n1'
DURATION_VERIFY=$((SECONDS - step_start))

echo "Done. Built image:"
echo "- ${IMAGE}"
