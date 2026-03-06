#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-.}"

# Resolve paths
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
KIT_SRC="${SCRIPT_DIR}/kit"
TARGET_DIR="$(cd -- "${TARGET_DIR}" && pwd)"

backup_path() {
  local path="$1"
  if [ -e "$path" ]; then
    if [ ! -e "${path}.bak" ]; then
      mv "$path" "${path}.bak"
    else
      mv "$path" "${path}.bak.$(date +%Y%m%d_%H%M%S)"
    fi
  fi
}

ensure_dir() {
  mkdir -p "$1"
}

ensure_file() {
  local path="$1"
  if [ ! -f "$path" ]; then
    : > "$path"
  fi
}

copy_always() {
  local src="$1"
  local dest="$2"
  ensure_dir "$(dirname -- "$dest")"
  backup_path "$dest"
  cp -p "$src" "$dest"
  INSTALLED+=("$dest")
}

append_gitignore_line() {
  local line="$1"
  local file="$2"
  if [ ! -f "$file" ]; then
    : > "$file"
  fi
  if ! grep -Fqx "$line" "$file"; then
    printf "%s\n" "$line" >> "$file"
    INSTALLED+=("$file")
  fi
}

ensure_makefile() {
  local mk="$1"
  if [ ! -f "$mk" ]; then
    cat > "$mk" <<'MK'
.PHONY: test

test:
	@./scripts/test.sh
MK
    INSTALLED+=("$mk")
    return 0
  fi

  # Only add operator-test target if missing.
  if ! grep -Eq "^operator-test:" "$mk"; then
    {
      printf "\n.PHONY: operator-test\n\n"
      printf "operator-test:\n\t@./scripts/test.sh\n"
    } >> "$mk"
    INSTALLED+=("$mk")
  fi
}

main() {
  if [ ! -d "$KIT_SRC" ]; then
    echo "ERROR: kit source not found: $KIT_SRC" >&2
    exit 1
  fi

  INSTALLED=()

  # a) Directories
  ensure_dir "$TARGET_DIR/.ai/approvals"
  ensure_dir "$TARGET_DIR/.ai/transcripts"
  ensure_dir "$TARGET_DIR/scripts"

  # b) LAST_RUN_ID
  ensure_file "$TARGET_DIR/.ai/LAST_RUN_ID"

  # c) Triggers (always replace, backup existing)
  copy_always "$KIT_SRC/.ai/TRIGGER_CLAUDE_RUN.md" "$TARGET_DIR/.ai/TRIGGER_CLAUDE_RUN.md"
  copy_always "$KIT_SRC/.ai/TRIGGER_CODEX_REVIEW.md" "$TARGET_DIR/.ai/TRIGGER_CODEX_REVIEW.md"

  # d) Scripts (always replace, backup existing)
  copy_always "$KIT_SRC/scripts/ai_pack.sh" "$TARGET_DIR/scripts/ai_pack.sh"
  copy_always "$KIT_SRC/scripts/ai_gate.sh" "$TARGET_DIR/scripts/ai_gate.sh"
  copy_always "$KIT_SRC/scripts/test.sh" "$TARGET_DIR/scripts/test.sh"

  # e) chmod
  chmod +x "$TARGET_DIR/scripts"/*.sh

  # f) .gitignore lines
  append_gitignore_line '.ai/packets/' "$TARGET_DIR/.gitignore"
  append_gitignore_line '!.ai/transcripts/' "$TARGET_DIR/.gitignore"
  append_gitignore_line '!.ai/transcripts/**' "$TARGET_DIR/.gitignore"

  # g) Makefile
  ensure_makefile "$TARGET_DIR/Makefile"

  # h) Summary
  echo "Installed/updated:"
  for p in "${INSTALLED[@]}"; do
    # Print paths relative to TARGET_DIR when possible
    if [[ "$p" == "$TARGET_DIR"/* ]]; then
      echo "- ${p#${TARGET_DIR}/}"
    else
      echo "- $p"
    fi
  done
}

main "$@"
