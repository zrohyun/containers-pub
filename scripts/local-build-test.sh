#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATE_TAG="$(date -u +%Y%m%d)"
RUN_TS="$(date -u +%Y%m%dT%H%M%SZ)"
LOCAL_BASE_TAG="24.04-local-${DATE_TAG}"
LOCAL_OWNER="local"
JOB_NAME="$(basename "${BASH_SOURCE[0]}" .sh)"

LOG_DIR="${ROOT_DIR}/_hub/_data/logs"
LOG_FILE="${LOG_DIR}/${JOB_NAME}_${RUN_TS}.log"
mkdir -p "${LOG_DIR}"

exec > >(tee -a "${LOG_FILE}") 2>&1

APT_IMAGE="base-ubuntu-apt:${LOCAL_BASE_TAG}"
BREW_IMAGE="base-ubuntu-brew:${LOCAL_BASE_TAG}"
APT_BREW_IMAGE="base-ubuntu-apt-brew:${LOCAL_BASE_TAG}"

SECONDS=0
DURATION_BUILD_APT=0
DURATION_BUILD_BREW=0
DURATION_BUILD_APT_BREW=0
DURATION_VERIFY_APT=0
DURATION_VERIFY_BREW=0
DURATION_VERIFY_APT_BREW=0

print_summary() {
  local total_elapsed="${SECONDS}"
  local build_total=$((DURATION_BUILD_APT + DURATION_BUILD_BREW + DURATION_BUILD_APT_BREW))
  local verify_total=$((DURATION_VERIFY_APT + DURATION_VERIFY_BREW + DURATION_VERIFY_APT_BREW))

  echo
  echo "===== Build/Verify Duration Summary (seconds) ====="
  printf "%-24s %6ss\n" "build: ubuntu-apt" "${DURATION_BUILD_APT}"
  printf "%-24s %6ss\n" "build: ubuntu-brew" "${DURATION_BUILD_BREW}"
  printf "%-24s %6ss\n" "build: ubuntu-apt-brew" "${DURATION_BUILD_APT_BREW}"
  printf "%-24s %6ss\n" "verify: ubuntu-apt" "${DURATION_VERIFY_APT}"
  printf "%-24s %6ss\n" "verify: ubuntu-brew" "${DURATION_VERIFY_BREW}"
  printf "%-24s %6ss\n" "verify: ubuntu-apt-brew" "${DURATION_VERIFY_APT_BREW}"
  printf "%-24s %6ss\n" "build subtotal" "${build_total}"
  printf "%-24s %6ss\n" "verify subtotal" "${verify_total}"
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

echo "[1/3] Build apt image"
step_start="${SECONDS}"
docker build \
  -f docker/ubuntu-apt/Dockerfile \
  -t "${APT_IMAGE}" \
  .
DURATION_BUILD_APT=$((SECONDS - step_start))

echo "[2/3] Build brew image"
step_start="${SECONDS}"
docker build \
  -f docker/ubuntu-brew/Dockerfile \
  -t "${BREW_IMAGE}" \
  .
DURATION_BUILD_BREW=$((SECONDS - step_start))

# apt-brew Dockerfile references ghcr.io/${IMAGE_OWNER}/base-ubuntu-apt:${BASE_TAG}
# so we add a local alias to the just-built apt image.
docker tag "${APT_IMAGE}" "ghcr.io/${LOCAL_OWNER}/base-ubuntu-apt:${LOCAL_BASE_TAG}"

echo "[3/3] Build apt-brew image (from local apt base alias)"
step_start="${SECONDS}"
docker build \
  -f docker/ubuntu-apt-brew/Dockerfile \
  --build-arg IMAGE_OWNER="${LOCAL_OWNER}" \
  --build-arg BASE_TAG="${LOCAL_BASE_TAG}" \
  -t "${APT_BREW_IMAGE}" \
  .
DURATION_BUILD_APT_BREW=$((SECONDS - step_start))

echo "[verify] apt image"
step_start="${SECONDS}"
docker run --rm "${APT_IMAGE}" bash -lc 'apt-get --version >/dev/null && echo apt-ok'
DURATION_VERIFY_APT=$((SECONDS - step_start))

echo "[verify] brew image"
step_start="${SECONDS}"
docker run --rm "${BREW_IMAGE}" bash -lc 'brew --version | head -n1'
DURATION_VERIFY_BREW=$((SECONDS - step_start))

echo "[verify] apt-brew image"
step_start="${SECONDS}"
docker run --rm "${APT_BREW_IMAGE}" bash -lc 'apt-get --version >/dev/null && brew --version | head -n1'
DURATION_VERIFY_APT_BREW=$((SECONDS - step_start))

echo "Done. Built images:"
echo "- ${APT_IMAGE}"
echo "- ${BREW_IMAGE}"
echo "- ${APT_BREW_IMAGE}"
