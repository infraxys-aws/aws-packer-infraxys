#!/usr/bin/env bash

. ../env;

if [ "$SILENT" != "true" ]; then
    read -p "Are you sure you want to stop all Docker containers? [y/N] " answer;
    if [ "$answer" != "y" ]; then
        exit 1;
    fi;
fi;

stop;