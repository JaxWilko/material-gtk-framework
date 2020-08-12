#!/usr/bin/env bash

usage() {
    cat << NOTICE
    OPTIONS
    -h                  show this message
    -v                  print verbose info
    -f                  force asset recompilation
    -c                  compile theme
    -i                  install theme
    -o                  install icons
    -is                 automatically set the theme/icons active after install
    -t [theme-name]     create a new theme template file
    -n [theme-name]     create a new theme template file
    -x [style-name]     create a new theme style
    -d [/path/to/dir]   install theme to a specific directory
    -p [/path/to/dir]   install icons to a specific directory
NOTICE
}

say() {
    [ "$VERBOSE" ] || [ "$2" ] && echo "==> $1"
}

PROJ_DIR=$(cd $(dirname "${0}") && pwd)

VERBOSE=""
FORCE=""
INSTALL=""
COMPILE=""
SET_THEME_ACTIVE=""
INSTALL_ICONS=""
THEME_DIR=""
ICON_DIR=""
NEW_THEME=""
NEW_THEME_STYLES=""
THEME_NAME="palenight"

while getopts hvficost:n:d:p:x: opts; do
    case ${opts} in
        h) usage && exit 0 ;;
        v) VERBOSE=1 ;;
        f) FORCE=1 ;;
        i) INSTALL=1 ;;
        c) COMPILE=1 ;;
        s) SET_THEME_ACTIVE=1 ;;
        o) INSTALL_ICONS=1 ;;
        d) THEME_DIR=${OPTARG} ;;
        p) ICON_DIR=${OPTARG} ;;
        t) THEME_NAME=${OPTARG} ;;
        n) NEW_THEME=${OPTARG} ;;
        x) NEW_THEME_STYLES=${OPTARG} ;;
        *);;
    esac
done

if [ ! -f "${PROJ_DIR}/themes/${THEME_NAME}.sh" ]; then
    say "Could not find theme ${THEME_NAME}" "true"
    exit 1
fi

if [ "$THEME_DIR" ] && [ ! -d "$THEME_DIR" ]; then
    say "${THEME_DIR} does not exists, please create it then run this script again"
    exit 1
fi

if [ "$NEW_THEME" ]; then
    if [ -f "${PROJ_DIR}/themes/${NEW_THEME}.sh" ]; then
        say "Theme ${NEW_THEME} already exists, please pick another name" "true"
        exit 1
    fi
    cp "${PROJ_DIR}/themes/palenight.sh" "${PROJ_DIR}/themes/${NEW_THEME}.sh"
    exit 0
fi

if [ "$NEW_THEME_STYLES" ]; then
    if [ -d "${PROJ_DIR}/src/${NEW_THEME_STYLES}" ]; then
        say "Theme styles ${NEW_THEME_STYLES} already exists, please pick another name" "true"
        exit 1
    fi
    cp -r "${PROJ_DIR}/src/material" "${PROJ_DIR}/src/${NEW_THEME_STYLES}"
    exit 0
fi

if [ "$COMPILE" ]; then
    FLAG="-t ${THEME_NAME}"
    [[ "$VERBOSE" ]] && FLAG="$FLAG -v"
    [[ "$FORCE" ]] && FLAG="$FLAG -f"

    sh -c "${PROJ_DIR}/scripts/compile.sh $FLAG"

    EXIT_CODE=$?

    if [ ! $EXIT_CODE -eq 0 ]; then
        say "Compile failed, exiting" "true"
        exit 1
    fi
fi

if [ "$INSTALL" ]; then
    FLAG="-t ${THEME_NAME}"
    [[ "$VERBOSE" ]] && FLAG="$FLAG -v"
    [[ "$SET_THEME_ACTIVE" ]] && FLAG="$FLAG -s"
    [[ "$INSTALL_ICONS" ]] && FLAG="$FLAG -o"
    [[ "$THEME_DIR" ]] && FLAG="$FLAG -d ${THEME_DIR}"
    [[ "$ICON_DIR" ]] && FLAG="$FLAG -p ${ICON_DIR}"

    sh -c "${PROJ_DIR}/scripts/install.sh $FLAG"

    EXIT_CODE=$?

    if [ ! $EXIT_CODE -eq 0 ]; then
        say "Install failed, exiting" "true"
        exit 1
    fi
fi