
function prepare_files() {
    log_info "Preparing files";
    cp ../VERSION $packer_tmp_dir;
}

prepare_files;