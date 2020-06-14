
function prepare_files() {
    log_info "Preparing files";
    for f in $(find "$INSTANCE_DIR" -maxdepth 1 -type f -name \*_VERSION); do
        log_info "Copying $f";
        cat "$f"
        cp "$f" $packer_tmp_dir/;
    done;
}

prepare_files;