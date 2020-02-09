

function prepare_files() {
    log_info "Preparing files";
    cd $infraxys_packer_module_directory;
    local VERSION="$(cat VERSION)";
    cp VERSION $packer_tmp_dir;
}

prepare_files;