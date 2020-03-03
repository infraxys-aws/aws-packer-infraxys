#!/usr/bin/env bash

. ../env;

set -euo pipefail;

backup_filename="infraxys-full-backup-$(date +%Y%m%d%H%M%S).tgz";

target_directory="$LOCAL_DIR/backups/full";
mkdir -p "$target_directory";

restart_infraxys="true";
[[ $# -gt 0 ]] && restart_infraxys="$1";

if [ "$restart_infraxys" == "true" ]; then
    ./stop.sh;
fi;

echo "Creating full backup $target_directory/$backup_filename";
cd "$LOCAL_DIR/data";
tar -czf $target_directory/$backup_filename *;
cd -;

if [ "$restart_infraxys" == "true" ]; then
    ./up.sh
fi;
