#!/usr/bin/env bash
# Install global Claude Code skills for Elixir/Phoenix/Ash development
# Works on Linux, macOS, Windows (Git Bash/WSL)
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/BehedgeFund/claude-skills/main/install.sh | bash
#   # or
#   git clone https://github.com/BehedgeFund/claude-skills.git && cd claude-skills && ./install.sh

set -e

SKILLS_DIR="${HOME}/.claude/skills"

echo "Installing Claude Code skills to ${SKILLS_DIR}..."

# Detect source - are we running from inside the cloned repo?
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -d "${SCRIPT_DIR}/skills" ]; then
  # Running from cloned repo
  SOURCE_DIR="${SCRIPT_DIR}/skills"
else
  # Running via curl - clone to temp dir
  TEMP_DIR=$(mktemp -d)
  trap "rm -rf ${TEMP_DIR}" EXIT
  git clone --depth 1 https://github.com/BehedgeFund/claude-skills.git "${TEMP_DIR}"
  SOURCE_DIR="${TEMP_DIR}/skills"
fi

# Create skills directory
mkdir -p "${SKILLS_DIR}"

# Copy each skill
INSTALLED=0
for skill_dir in "${SOURCE_DIR}"/*/; do
  skill_name=$(basename "${skill_dir}")
  target="${SKILLS_DIR}/${skill_name}"

  if [ -d "${target}" ]; then
    echo "  Updating: ${skill_name}"
    rm -rf "${target}"
  else
    echo "  Installing: ${skill_name}"
  fi

  cp -r "${skill_dir}" "${target}"
  INSTALLED=$((INSTALLED + 1))
done

echo ""
echo "Done! Installed ${INSTALLED} skills to ${SKILLS_DIR}"
echo ""
echo "Available skills:"
for skill_dir in "${SKILLS_DIR}"/*/; do
  skill_name=$(basename "${skill_dir}")
  echo "  /${skill_name}"
done
echo ""
echo "Open any Elixir project with Claude Code and run /setup-project to bootstrap it."
