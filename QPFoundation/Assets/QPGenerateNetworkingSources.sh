#!/bin/sh
. ~/.*profile >/dev/null 2>&1

# Locations
WORKDIR="$(pwd)"
BASEDIR="$(cd "$(dirname "$0")"; pwd)"
BASENAME="$(basename "$0")"

# Logs
VERBOSE=0
USAGE=0

# Arguments
GNS_WORKSPACE="${SRCROOT}/${PROJECT_NAME}.xcworkspace"
GNS_SCHEME=""

# Parameters
GNS_PRODNAME=""
GNS_DERIVEDROOT=""
GNS_PRODPATH=""
GNS_PRODLAST=""

# Functions
function usage
{
cat 1>&2 <<@@usage@@
QPFoundation Generate Networking Sources Version 1.0

USAGE: QPGenerateNetworkingSources.sh [-workspace <name.xcworkspace>] -scheme <schemename>

EXAMPLE:
    source \${BUILT_PRODUCTS_DIR}/*/QPFoundation.bundle/QPGenerateNetworkingSources.sh \\
           -workspace "\${SRCROOT}/\${PROJECT_NAME}.xcworkspace" \\
           -scheme QPGenerateNetworkingSources
@@usage@@
}

function display
{
cat <<@@display@@
$@
@@display@@
}

function set_verbose_prefix
{
    VERBOSE_PREFIX="$1"
}

function verbose
{
    if [ "${VERBOSE}" -eq 0 ]; then
        return 0
    fi

    local PREFIX="${VERBOSE_PREFIX}"

    if [ $# -ge 2 ]; then
        PREFIX="$1"
        shift
    fi

    if [ ! -z "${PREFIX}" ]; then
        PREFIX="${PREFIX} "
    fi

    display "$1" | sed "s/^/[$(date '+%Y-%m-%d %H:%M:%S')] [${BASENAME}] [$$] ${PREFIX}/" 1>&2
}

function parse
{
    while [ $# -gt 0 ]; do
        case "$1" in
          -workspace)
            GNS_WORKSPACE="$2"
            shift 2;;
          -scheme)
            GNS_SCHEME="$2"
            shift 2;;
          -v)
            VERBOSE=1
            shift;;
          *)
            USAGE=1
            shift;;
        esac
    done

    if [ -z "${GNS_WORKSPACE}" -o -z "${GNS_SCHEME}" ]; then
        USAGE=1
    fi

    GNS_PRODNAME="${GNS_SCHEME}"
    GNS_DERIVEDROOT="${BUILT_PRODUCTS_DIR}/${GNS_PRODNAME}"
    GNS_PRODPATH="${GNS_DERIVEDROOT}/Build/Products/Debug/${GNS_PRODNAME}"
    GNS_PRODLAST="${GNS_PRODPATH}.last"

    set_verbose_prefix "[LOCATION]"
    verbose "WORKDIR=[${WORKDIR}]"
    verbose "BASEDIR=[${BASEDIR}]"
    verbose "BASENAME=[${BASENAME}]"

    set_verbose_prefix "[ARGUMENT]"
    verbose "GNS_WORKSPACE=[${GNS_WORKSPACE}]"
    verbose "GNS_SCHEME=[${GNS_SCHEME}]"
    verbose "GNS_PRODNAME=[${GNS_PRODNAME}]"
    verbose "GNS_DERIVEDROOT=[${GNS_DERIVEDROOT}]"
    verbose "GNS_PRODPATH=[${GNS_PRODPATH}]"
    verbose "GNS_PRODLAST=[${GNS_PRODLAST}]"

    if [ "${USAGE}" -ne 0 ]; then
        usage
        exit 1
    fi
}

# Preprocessing
parse "$@"

# Building
xcodebuild -workspace "${GNS_WORKSPACE}" \
           -scheme "${GNS_SCHEME}" \
           -destination 'platform=macOS,arch=x86_64' \
           -derivedDataPath "${GNS_DERIVEDROOT}"

if [ ! -f "${GNS_PRODPATH}" ]; then
    echo "[${GNS_PRODNAME}] Product building failed." >&2
    exit 1
fi

# Checks
if [ -f "${GNS_PRODLAST}" ]; then
    diff "${GNS_PRODPATH}" "${GNS_PRODLAST}"
    if [ "$?" -eq 0 ]; then
        echo "[${GNS_PRODNAME}] Nothing to do." >&2
        exit 0
    fi
fi

# Backups
cp -f "${GNS_PRODPATH}" "${GNS_PRODLAST}"

# Execute
echo "[${GNS_PRODNAME}] Generate networking sources ..." >&2
"${GNS_PRODPATH}"
