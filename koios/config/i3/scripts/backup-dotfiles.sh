#!/bin/bash
# Tarball backup of specific config-relevant paths, taken on every i3
# login. Skips creating a new backup if nothing has changed since the
# last one (compared by content hash, not mtime).
#
# Deliberately an ALLOWLIST, not an excludelist: ~/.local/share and
# ~/.local/state hold huge amounts of real application DATA (Steam
# game installs, Minecraft instances, browser profiles) that has
# nothing to do with dotfiles/config and will never reliably be
# excludable by pattern-matching alone — a previous version of this
# script tried excluding known-bad paths under ~/.local/share and
# still produced a 309GB tarball because it silently included 343GB of
# Steam's steamapps/common (the actual installed games) that nobody
# had thought to exclude. Listing exactly what to include is the only
# way to guarantee this stays a small, fast, actual config backup.

BACKUP_DIR="$HOME/backups"
mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
TARBALL="$BACKUP_DIR/dotfiles-${TIMESTAMP}.tar.gz"
LATEST_HASH_FILE="$BACKUP_DIR/.last-backup-hash"
LOG_FILE="$BACKUP_DIR/backup.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "=== Backup run started ==="

# Explicit list of what actually gets backed up. Add to this list
# deliberately when you start tracking a new app's config — do not
# widen it to "all of .local/share" again.
INCLUDE_PATHS=(
    ".config"
    ".local/bin"
    ".local/share/gtksourceview-4"
)

EXCLUDE_ARGS=(
    -not -path "*/Cache/*"
    -not -path "*/cache/*"
    -not -path "*/CachedData/*"
    -not -path "*/.git/*"
    -not -path "*/vesktop/sessionData/*"
    -not -name "*.lock"
    -not -name "*.sock"
    -not -name "*~"
)

compute_hash() {
    for p in "${INCLUDE_PATHS[@]}"; do
        [ -e "$HOME/$p" ] && find "$HOME/$p" -type f "${EXCLUDE_ARGS[@]}" 2>/dev/null
    done | sort | xargs -d '\n' sha256sum 2>/dev/null | sha256sum | awk '{print $1}'
}

log "Hashing tracked config paths..."
CURRENT_HASH=$(compute_hash)
log "Current hash: $CURRENT_HASH"

LAST_HASH=""
if [ -f "$LATEST_HASH_FILE" ]; then
    LAST_HASH=$(cat "$LATEST_HASH_FILE")
    log "Last backup hash: $LAST_HASH"
else
    log "No previous backup hash found (first run)."
fi

if [ "$CURRENT_HASH" = "$LAST_HASH" ] && [ -n "$LAST_HASH" ]; then
    log "No changes since last backup — skipping. Nothing to do."
    exit 0
fi

log "Changes detected (or first run) — creating tarball: $TARBALL"

# Only tar paths that actually exist, so a missing optional dir doesn't
# make tar exit non-zero.
EXISTING_PATHS=()
for p in "${INCLUDE_PATHS[@]}"; do
    [ -e "$HOME/$p" ] && EXISTING_PATHS+=("$p")
done

tar -czf "$TARBALL" \
    -C "$HOME" \
    --exclude="*/Cache" \
    --exclude="*/cache" \
    --exclude="*/CachedData" \
    --exclude="*/Code Cache" \
    --exclude="*/GPUCache" \
    --exclude="vesktop/sessionData" \
    "${EXISTING_PATHS[@]}" 2>>"$LOG_FILE"

TAR_STATUS=$?

if [ $TAR_STATUS -eq 0 ]; then
    echo "$CURRENT_HASH" > "$LATEST_HASH_FILE"
    SIZE=$(du -h "$TARBALL" | cut -f1)
    log "Backup created successfully: $TARBALL ($SIZE)"
else
    log "ERROR: tar exited with status $TAR_STATUS — removing partial tarball."
    rm -f "$TARBALL"
fi

log "=== Backup run finished ==="
