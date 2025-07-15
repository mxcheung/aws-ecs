#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Bootstrap all environment components by running each component’s set_up.sh
# ---------------------------------------------------------------------------

find . -type f -name set_up.sh -exec chmod +x {} \;

set -Eeuo pipefail            # -E propagates ERR trap into subshells
shopt -s inherit_errexit      # for Bash ≥ 5.0: pipelines respect -e

SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]:-${0}}")" && pwd)/$(basename "${BASH_SOURCE[0]:-${0}}")"


#---------- Trap -------------------------------------------------------------
trap 'echo "❌ Error in ${SCRIPT_PATH} on line $LINENO → ${BASH_COMMAND}" >&2' ERR

#---------- Log everything ---------------------------------------------------
LOG_DIR="${MY_ENV_ROOT_DIR:?Unset MY_ENV_ROOT_DIR}/logs"
mkdir -p "$LOG_DIR"
exec > >(tee -a "${LOG_DIR}/bootstrap_$(date +%Y%m%d_%H%M%S).log") 2>&1

echo "▶ MY_ENV_ROOT_DIR=$MY_ENV_ROOT_DIR"
echo "▶ AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-<not set>}"
echo "▶ Starting bootstrap at $(date -Iseconds)"
echo

#---------- Components to initialise ----------------------------------------
components=(
  user_credentials
  iam
  codecommit
  ecr
  s3
  sqs
  codebuild
  codepipeline
  event_bridge
)

#---------- Main loop --------------------------------------------------------
for comp in "${components[@]}"; do
  echo "─── ${comp} ─────────────────────────────────────────────"
  (
    cd "${MY_ENV_ROOT_DIR}/${comp}"
    # run in subshell; -E + inherit_errexit keep traps & -e behaviour
    ./set_up.sh
  )
  echo "✓ ${comp} completed"
  echo
done

echo "🎉 All components initialised successfully"
