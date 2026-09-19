#!/bin/bash
# Tarball backup of ~/.config and ~/.local, taken on every i3 login.
# Skips creating a new backup if nothing has changed since the last one
# (compared by content hash, not mtime — mtimes change on every deploy
# even when content doesn't, e.g. after a fresh git checkout).

BACKUP_DIR="$HOME/backups"
mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
TARBALL="$BACKUP_DIR/dotfiles-${TIMESTAMP}.tar.gz"
LATEST_HASH_FILE="$BACKUP_DIR/.last-backup-hash"

# Build a stable content hash across both directories: sort file list so
# ordering doesn't affect the hash, hash each file's content, then hash
# that combined list. Excludes large, easily-regenerated/redownloadable
# data (browser caches, Steam shader/compat caches, thumbnails, trash)
# that changes on every login regardless of real config edits, and would
# otherwise make this slow and bloat the tarball for no backup value.
EXCLUDE_ARGS=(
    -not -path "*/Cache/*"
    -not -path "*/cache/*"
    -not -path "*/CachedData/*"
    -not -path "*/.git/*"
    -not -path "*/Trash/*"
    -not -path "*/thumbnails/*"
    -not -path "*/steam/steamapps/shadercache/*"
    -not -path "*/steam/steamapps/compatdata/*"
    -not -path "*/vesktop/*Cache*"
    -not -path "*/BraveSoftware/*/Cache*"
    -not -path "*/BraveSoftware/*/Code Cache/*"
    -not -path "*/BraveSoftware/*/GPUCache/*"
    -not -name "*.lock"
    -not -name "*.sock"
    -not -name "*~"
)

compute_hash() {
    find "$HOME/.config" "$HOME/.local" \
        -type f \
        "${EXCLUDE_ARGS[@]}" \
        2>/dev/null \
        | sort \
        | xargs -d '\n' sha256sum 2>/dev/null \
        | sha256sum \
        | awk '{print $1}'
}

CURRENT_HASH=$(compute_hash)
LAST_HASH=""
[ -f "$LATEST_HASH_FILE" ] && LAST_HASH=$(cat "$LATEST_HASH_FILE")

if [ "$CURRENT_HASH" = "$LAST_HASH" ] && [ -n "$LAST_HASH" ]; then
    # Nothing changed since the last backup — skip.
    exit 0
fi

tar -czf "$TARBALL" \
    -C "$HOME" \
    --exclude=".config/*/Cache" \
    --exclude=".config/*/cache" \
    --exclude=".config/*/CachedData" \
    --exclude=".config/*/Code Cache" \
    --exclude=".config/*/GPUCache" \
    --exclude=".config/BraveSoftware/*/Cache" \
    --exclude=".config/BraveSoftware/*/Code Cache" \
    --exclude=".config/BraveSoftware/*/GPUCache" \
    --exclude=".config/vesktop/*Cache*" \
    --exclude=".local/share/Trash" \
    --exclude=".local/share/Steam/steamapps/shadercache" \
    --exclude=".local/share/Steam/steamapps/compatdata" \
    --exclude="*/thumbnails" \
    .config .local 2>/dev/null

if [ $? -eq 0 ]; then
    echo "$CURRENT_HASH" > "$LATEST_HASH_FILE"
else
    # tar failed — remove any partial tarball rather than leave junk behind
    rm -f "$TARBALL"
fi
