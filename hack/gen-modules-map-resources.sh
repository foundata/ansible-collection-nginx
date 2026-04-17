#!/usr/bin/env bash
# Bash required for: arrays (indexed), safe empty-array handling
#
# Generate YAML for the __run_nginx_modules_map_resources variable by querying
# the local package manager for NGINX dynamic-module packages and their files.
#
# Supported package managers:
#   - apt    (Debian/Ubuntu) : libnginx-mod-*
#   - dnf    (Fedora/RHEL)   : nginx-mod-*
#   - zypper (SUSE)          : nginx-module-*
#
# Environment overrides (package name globs):
#   PKG_PATTERN_APT    (default: 'libnginx-mod-*')
#   PKG_PATTERN_DNF    (default: 'nginx-mod-*')
#   PKG_PATTERN_ZYPPER (default: 'nginx-module-*')
#
# Quick run with copy & paste on test systems:
#   rm -f /tmp/gen-modules-map-resources.sh && \
#     nano /tmp/gen-modules-map-resources.sh && \
#     chmod +x /tmp/gen-modules-map-resources.sh && \
#     /tmp/gen-modules-map-resources.sh
#
# SPDX-FileCopyrightText: 2026, foundata GmbH (https://foundata.com)
# SPDX-License-Identifier: GPL-3.0-or-later

# --- BOILERPLATE START v1.1.0 ---
# Consistent environment for predictable tool and shell behavior
export PATH="${PATH:-'/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'}"
if command -v locale >/dev/null 2>&1; then
  for locale_candidate in 'C.UTF-8' 'C.utf8' 'en_US.UTF-8' 'UTF-8' 'C'; do
    if LC_ALL="${locale_candidate}" locale charmap >/dev/null 2>&1; then
      export LC_ALL="${locale_candidate}"
      break
    fi
  done
else
  export LC_ALL='C'
fi
readonly LC_ALL
unset locale_candidate
set -u                                                      # no uninitialized vars
set -o 2>/dev/null | grep -Fq 'pipefail' && set +o pipefail # disable, non-POSIX

# Config msg() messages (override via environment or inline where needed)
: "${DEBUG:=0}"          # 0: No debug messages. 1: Print debug messages.
: "${MSG_TIMESTAMP:=0}"  # 0: No timestamp (TS) prefix 1: Unix TS. 2: ISO TS
: "${MSG_SCRIPTNAME:=0}" # 0: No scriptname prefix. 1: Enable scriptname prefix

# Formatting codes (ANSI if STDOUT is TTY and NO_COLOR empty; empty otherwise)
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  x1b=$(printf '\033') # escape byte (0x1b) (shown as ^[ in most editors)
  # terminfo|termcap comments for reference; alternative for ancient systems:
  # FMT_FOO="$(tput terminfo_foo 2>/dev/null || tput termcap_foo 2>/dev/null)"
  FMT_RESET="${x1b}(B${x1b}[m" # sgr0|me (G0 charset/US-ASCII, attributes reset)
  FMT_BOLD="${x1b}[1m"         # bold|md
  FMT_UL="${x1b}[4m"           # smul|us
  FMT_SO="${x1b}[7m"           # smso|so (standout, reverse video)
  FMT_RED="${x1b}[31m"         # setaf N|AF N (1=red)
  FMT_GREEN="${x1b}[32m"       # setaf N|AF N (2=green)
  FMT_YELLOW="${x1b}[33m"      # setaf N|AF N (3=yellow)
  FMT_BLUE="${x1b}[34m"        # setaf N|AF N (4=blue)
  unset x1b
else
  FMT_RESET='' FMT_BOLD='' FMT_UL='' FMT_SO='' FMT_RED='' FMT_GREEN='' FMT_YELLOW='' FMT_BLUE=''
fi
# shellcheck disable=SC2034 # boilerplate vars, needed "on stockpile"
readonly FMT_RESET FMT_BOLD FMT_UL FMT_SO FMT_RED FMT_GREEN FMT_YELLOW FMT_BLUE

###
# Print formatted messages to STDOUT or STDERR.
# Options:
#   -e, --error     Print error message (bold red) to STDERR.
#   -w, --warning   Print warning message (bold yellow) to STDERR.
#   -s, --success   Print success message (bold green) to STDOUT.
#   -i, --info      Print info message (bold blue) to STDOUT.
#   -d, --debug     Print debug message (standout) to STDOUT (only if DEBUG=1).
# Globals:
#   DEBUG          - If 0, suppresses -d/--debug messages.
#   MSG_TIMESTAMP  - 1: Enable unix timestamp as prefix.
#                    2: Enable ISO timestamp as prefix.
#   MSG_SCRIPTNAME - 1: Enable script name as prefix.
# Arguments:
#   $1 - Optional flag (see "Options").
#   $@ - Message to print.
# Outputs:
#   Formatted message to STDOUT or STDERR depending on flag.
msg() {
  local _msg_fd='1' _msg_color='' _msg_prefix='' _msg_fmt=''
  case "${1:-}" in
    '-e' | '--error')
      _msg_fd='2'
      _msg_color="${FMT_BOLD}${FMT_RED}"
      ;;
    '-w' | '--warning')
      _msg_fd='2'
      _msg_color="${FMT_BOLD}${FMT_YELLOW}"
      ;;
    '-s' | '--success')
      _msg_fd='1'
      _msg_color="${FMT_BOLD}${FMT_GREEN}"
      ;;
    '-i' | '--info')
      _msg_fd='1'
      _msg_color="${FMT_BOLD}${FMT_BLUE}"
      ;;
    '-d' | '--dbg' | '--debug')
      [ "${DEBUG:-0}" = 0 ] && return 0
      _msg_fd='1'
      _msg_color="${FMT_SO}"
      ;;
    *) false ;;
  esac && shift
  case "${MSG_TIMESTAMP:-0}" in
    '1') _msg_prefix="[$(date '+%s')] " ;;                  # non-POSIX but widely available: %s
    '2') _msg_prefix="[$(date '+%Y-%m-%dT%H:%M:%S%z')] " ;; # non-POSIX but widely available: z
    *) ;;
  esac
  case "${MSG_SCRIPTNAME:-0}" in
    '1') _msg_prefix="[${0##*/}] ${_msg_prefix}" ;;
    *) ;;
  esac
  _msg_fmt="${_msg_color}${_msg_prefix}$*${FMT_RESET}"
  [ "${_msg_fd}" = '2' ] && printf '%s\n' "${_msg_fmt}" >&2 || printf '%s\n' "${_msg_fmt}"
}

###
# Manage cleanup commands on exit/interrupt (LIFO order).
# Globals:
#   _TRAP_STACK - Newline-separated list of commands (newest first).
#                 Modified by push/pop/run operations.
# Arguments:
#   $1      - Action: push (add to stack), pop (remove last (no execute)),
#             or run (execute all & clear).
#   $2      - Command to register (required for push).
# Returns:
#   0 on success, 1 on invalid usage.
# Example:
#   trap_stack push 'rm -rf "/tmp/mydir"'
#   trap_stack pop
#   trap_stack run
_TRAP_STACK=''
trap_stack() {
  case "${1:-}" in
    'push')
      # linebreak is needed (stack delimiter)
      _TRAP_STACK="${2:?Command required}${_TRAP_STACK:+
${_TRAP_STACK}}"
      trap 'trap_stack run' EXIT
      trap 'trap_stack run; exit 130' INT
      trap 'trap_stack run; exit 143' TERM
      ;;
    'pop')
      _TRAP_STACK="$(printf '%s\n' "${_TRAP_STACK}" | tail -n +2)"
      [ -z "${_TRAP_STACK}" ] && trap - EXIT INT TERM
      ;;
    'run')
      while [ -n "${_TRAP_STACK}" ]; do
        eval "$(printf '%s\n' "${_TRAP_STACK}" | head -n 1)" || true
        _TRAP_STACK="$(printf '%s\n' "${_TRAP_STACK}" | tail -n +2)"
      done
      trap - EXIT INT TERM
      ;;
    *)
      printf 'Usage: trap_stack push|pop|run [cmd]\n' >&2
      return 1
      ;;
  esac
}

###
# Check if commands are available.
# Options:
#   -r  Required mode: exit with error if any command is missing.
# Arguments:
#   $@ - Command names to check.
# Returns:
#   0 if all commands exist.
#   1 if any missing (or exit 1 if -r is set)
check_cmd() {
  local required=0
  [ "${1}" = "-r" ] && required=1 && shift
  for cmd; do
    command -v "${cmd}" >/dev/null 2>&1 && continue
    [ "${required}" = 1 ] || return 1
    msg -e "Required command not found: ${cmd}"
    exit 1
  done
}

###
# Run a command that should never fail. If the command fails, print an error
# and exit immediately.
# Arguments:
#   $@ - Command and arguments to execute.
# Outputs:
#   Error message to STDERR on failure.
# Returns:
#   0 on success.
#   >0 (the original exitcode of the command) on failure.
ensure() {
  local exit_code
  "$@"
  exit_code="$?"
  if [ "${exit_code}" -ne 0 ]; then
    msg -e "Command failed (exit code ${exit_code}): $*"
    exit "${exit_code}"
  fi
  return 0
}

# Convenience wrappers (see the used functions for documentation)
require_cmd() { check_cmd -r "$@"; }
# --- BOILERPLATE END v1.1.0 ---

###
# Derive the canonical Ansible module key from an .so filename.
#
# Strips the directory, ".so" suffix, "_module" suffix, and the "ngx_" prefix:
#   ngx_http_perl_module.so          -> http_perl
#   ngx_stream_module.so             -> stream
#   ngx_nchan_module.so              -> nchan
#   ndk_http_module.so               -> ndk_http
#   ngx_http_brotli_filter_module.so -> http_brotli_filter
# Arguments:
#   $1 - Path or filename of the .so file.
# Outputs:
#   Canonical key to STDOUT.
so_to_key() {
  local base="${1##*/}" # strip directory (basename without subprocess)
  base="${base%.so}"
  base="${base%_module}"
  case "${base}" in
    ngx_*) base="${base#ngx_}" ;;
    *) ;;
  esac
  printf '%s\n' "${base}"
}

###
# Write a single module YAML block into the temporary output directory.
#
# Determines whether to emit a "symlink" or "load_module" conf_files entry
# based on whether the package provides a module load .conf file in the
# platform's standard directory.
#
# Globals:
#   tmpdir_gen - Path to the temporary directory for per-key YAML fragments.
# Arguments:
#   $1     - Canonical module key.
#   $2     - Package name.
#   $3     - Package manager identifier (apt, dnf, zypper).
#   $4...  - File paths (.conf and .so) provided by the package.
# Outputs:
#   Writes a file "${tmpdir_gen}/${key}.yml".
emit_module_block() {
  local key="${1}"
  local pkg="${2}"
  local mgr="${3}"
  shift 3

  local confs=()
  local sos=()
  local f
  for f in "$@"; do
    case "${f}" in
      *.conf) confs+=("${f}") ;;
      *.so) sos+=("${f}") ;;
      *) ;;
    esac
  done

  # Filter confs to module load configs in the platform-specific directory.
  # Auxiliary .conf files (e.g. /etc/nginx/modsecurity.conf) are ignored.
  local module_confs=()
  for f in "${confs[@]+"${confs[@]}"}"; do
    case "${mgr}" in
      'apt')
        case "${f}" in
          /usr/share/nginx/modules-available/*.conf) module_confs+=("${f}") ;;
          *) ;;
        esac
        ;;
      'dnf' | 'zypper')
        case "${f}" in
          /usr/share/nginx/modules/*.conf) module_confs+=("${f}") ;;
          *) ;;
        esac
        ;;
    esac
  done

  # Determine conf_files entry: type, target, and filename.
  local cf_filename cf_type cf_target
  if [ "${#module_confs[@]}" -gt 0 ]; then
    cf_type='symlink'
    cf_target="${module_confs[0]}"
    local cf_basename="${cf_target##*/}"
    case "${mgr}" in
      'apt') cf_filename="50-${cf_basename}" ;;
      *) cf_filename="${cf_basename}" ;;
    esac
  else
    cf_type='load_module'
    cf_target="${sos[0]}"
    cf_filename="mod-$(printf '%s' "${key}" | tr '_' '-').conf"
  fi

  {
    printf '  %s:\n' "${key}"
    printf '    conf_files:\n'
    printf '      - name: "%s"\n' "${cf_filename}"
    printf '        type: "%s"\n' "${cf_type}"
    printf '        target: "%s"\n' "${cf_target}"
    if [ -n "${pkg}" ]; then
      printf '    packages:\n'
      printf '      - "%s"\n' "${pkg}"
    else
      printf '    packages: []\n'
    fi
  } >"${tmpdir_gen}/${key}.yml"
}

###
# Process the file list of a single package: group .conf/.so files and emit
# one YAML fragment per .so-derived module key.
# Globals:
#   tmpdir_gen - Path to the temporary directory for per-key YAML fragments.
# Arguments:
#   $1     - Package name.
#   $2     - Package manager identifier (apt, dnf, zypper).
#   $3...  - File paths (.conf and .so) from the package.
process_package() {
  local pkg="${1}"
  local mgr="${2}"
  shift 2
  local files=("$@")

  local confs=()
  local sos=()
  local f
  for f in "${files[@]}"; do
    case "${f}" in
      *.conf) confs+=("${f}") ;;
      # Only accept NGINX dynamic modules (*_module.so). This filters out
      # unrelated .so files like Perl XS bindings (e.g. auto/nginx/nginx.so).
      *_module.so) sos+=("${f}") ;;
      *) ;;
    esac
  done

  # Without .so files the canonical module key cannot be derived reliably.
  if [ "${#sos[@]}" -eq 0 ]; then
    msg -d "Skipping '${pkg}': no .so files found"
    return 0
  fi

  local key
  for f in "${sos[@]}"; do
    key="$(so_to_key "${f}")"
    # Each module key gets its own YAML block; conf files from the package
    # are included in every block (they belong to the package, not a
    # specific .so).
    emit_module_block "${key}" "${pkg}" "${mgr}" "${confs[@]+"${confs[@]}"}" "${f}"
  done
}

# ---------------------------------------------------------------------------
# APT (Debian / Ubuntu)
# ---------------------------------------------------------------------------

###
# Ensure apt metadata and apt-file cache are current.
# Returns:
#   0 on success, 1 if prerequisites are missing.
apt_prepare() {
  check_cmd 'apt-cache' || return 1
  msg -i 'Refreshing APT metadata ...'
  ensure apt-get update -qq
  if ! check_cmd 'apt-file'; then
    msg -i "Installing 'apt-file' (required for APT file listing) ..."
    ensure apt-get install -y -qq apt-file
  fi
  msg -i 'Updating apt-file cache ...'
  ensure apt-file update
}

###
# List available NGINX module package names (APT).
# Globals:
#   PKG_PATTERN_APT
# Outputs:
#   One package name per line to STDOUT.
apt_pkg_names() {
  # apt-cache pkgnames outputs all known names; filter with the glob
  # converted to a regex (replace * with .*).
  local pattern
  pattern="$(printf '%s' "${PKG_PATTERN_APT}" | sed 's/\*/.*/')"
  apt-cache pkgnames \
    | grep -E "^${pattern}\$" \
    | sort -u
}

###
# List .conf and .so files provided by a package (APT, via apt-file).
# Arguments:
#   $1 - Package name.
# Outputs:
#   One file path per line to STDOUT.
apt_pkg_files() {
  local pkg="${1}"
  apt-file list "${pkg}" 2>/dev/null \
    | cut -d: -f2- \
    | sed 's/^ //' \
    | grep -E '\.(conf|so)$' \
    | sort -u || true
}

# ---------------------------------------------------------------------------
# DNF (Fedora / RHEL / AlmaLinux / CentOS)
# ---------------------------------------------------------------------------

###
# Ensure dnf metadata cache is current.
# Returns:
#   0 on success, 1 if prerequisites are missing.
dnf_prepare() {
  check_cmd 'dnf' || return 1
  msg -i 'Refreshing DNF metadata cache ...'
  dnf -q makecache >/dev/null 2>&1 || true
}

###
# List available NGINX module package names (DNF).
# Globals:
#   PKG_PATTERN_DNF
# Outputs:
#   One package name per line to STDOUT.
dnf_pkg_names() {
  # --queryformat avoids arch/version suffixes in the output.
  # The glob is passed as a single argument for dnf to interpret.
  # Trailing \n required: dnf5 does not append newlines between entries.
  dnf repoquery --queryformat '%{name}\n' "${PKG_PATTERN_DNF}" 2>/dev/null \
    | sort -u
}

###
# List .conf and .so files provided by a package (DNF, via repoquery).
# Arguments:
#   $1 - Package name.
# Outputs:
#   One file path per line to STDOUT.
dnf_pkg_files() {
  local pkg="${1}"
  # No -q: dnf5 (Fedora 41+) suppresses repoquery results with -q.
  dnf repoquery -l "${pkg}" 2>/dev/null \
    | grep -E '\.(conf|so)$' \
    | sort -u || true
}

# ---------------------------------------------------------------------------
# Zypper (openSUSE / SLES)
# ---------------------------------------------------------------------------

###
# Ensure zypper metadata is current.
# Returns:
#   0 on success, 1 if prerequisites are missing.
zypper_prepare() {
  check_cmd 'zypper' || return 1
  require_cmd 'rpm'
  msg -i 'Refreshing zypper metadata ...'
  zypper --non-interactive refresh >/dev/null 2>&1 || true
}

###
# List available NGINX module package names (zypper).
# Globals:
#   PKG_PATTERN_ZYPPER
# Outputs:
#   One package name per line to STDOUT.
zypper_pkg_names() {
  # zypper search -s output is a table with "|" separators.
  # Extract the second column (Name), trim whitespace, filter by pattern.
  local pattern
  pattern="$(printf '%s' "${PKG_PATTERN_ZYPPER}" | sed 's/\*/.*/')"
  zypper --non-interactive search -s "${PKG_PATTERN_ZYPPER}" 2>/dev/null \
    | awk -F'|' 'NR > 2 { gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2 }' \
    | grep -E "^${pattern}\$" \
    | sort -u
}

###
# List .conf and .so files provided by a package (zypper).
#
# Zypper has no built-in "list files in uninstalled package" command.
# Strategy: download the RPM into a temporary directory, then query with rpm.
# Arguments:
#   $1 - Package name.
# Outputs:
#   One file path per line to STDOUT.
zypper_pkg_files() {
  local pkg="${1}"
  local dl_dir
  dl_dir="$(mktemp -d)"
  trap_stack 'push' "rm -rf '${dl_dir}'"

  if ! zypper --non-interactive --pkg-cache-dir "${dl_dir}" \
    download "${pkg}" >/dev/null 2>&1; then
    msg -w "Failed to download package '${pkg}', skipping"
    trap_stack 'pop'
    rm -rf "${dl_dir}"
    return 0
  fi

  # The downloaded RPM may be nested in subdirectories.
  find "${dl_dir}" -type f -name '*.rpm' -print0 \
    | xargs -0 -r rpm -qpl 2>/dev/null \
    | grep -E '\.(conf|so)$' \
    | sort -u || true

  trap_stack 'pop'
  rm -rf "${dl_dir}"
}

###
# Detect the available package manager and process all NGINX module packages.
# Globals:
#   PKG_PATTERN_APT
#   PKG_PATTERN_DNF
#   PKG_PATTERN_ZYPPER
#   tmpdir_gen
# Arguments:
#   $@ - Command line arguments (currently unused).
main() {
  local tmpdir_gen
  tmpdir_gen="$(mktemp -d)"
  trap_stack 'push' "rm -rf '${tmpdir_gen}'"

  # Package name globs (overridable via environment).
  # No inner quotes: inside "${VAR:=...}", single quotes become literal chars.
  : "${PKG_PATTERN_APT:=libnginx-mod-*}"
  : "${PKG_PATTERN_DNF:=nginx-mod-*}"
  : "${PKG_PATTERN_ZYPPER:=nginx-module-*}"

  # Detect available package manager
  local mgr=''
  if check_cmd 'apt-cache'; then
    mgr='apt'
  elif check_cmd 'dnf'; then
    mgr='dnf'
  elif check_cmd 'zypper'; then
    mgr='zypper'
  else
    msg -e 'No supported package manager found (need apt, dnf, or zypper).'
    exit 1
  fi
  msg -i "Detected package manager: ${mgr}"

  # Prepare / refresh metadata
  case "${mgr}" in
    'apt') apt_prepare ;;
    'dnf') dnf_prepare ;;
    'zypper') zypper_prepare ;;
    *) ;;
  esac

  # Iterate over packages, collect file lists, generate per-module YAML
  local pkg_list
  pkg_list="$("${mgr}_pkg_names")" || true

  local pkg files_raw f
  local files=()
  while IFS= read -r pkg; do
    [ -n "${pkg}" ] || continue
    msg -d "Processing package: ${pkg}"

    files_raw="$("${mgr}_pkg_files" "${pkg}")" || true
    if [ -z "${files_raw}" ]; then
      msg -d "  No .conf/.so files found, skipping"
      continue
    fi

    # Read newline-separated file list into an array
    files=()
    while IFS= read -r f; do
      [ -n "${f}" ] || continue
      files+=("${f}")
    done <<<"${files_raw}"

    if [ "${#files[@]}" -eq 0 ]; then
      continue
    fi

    process_package "${pkg}" "${mgr}" "${files[@]}"
  done <<<"${pkg_list}"

  # Also scan the base nginx package for dynamic .so files that are not
  # covered by separate module packages. On SUSE, modules like mail, stream,
  # http_perl, etc. are compiled as dynamic modules but shipped in the base
  # nginx package — they need load_module directives but no extra package
  # install.
  local base_sos_raw base_so base_key
  base_sos_raw="$("${mgr}_pkg_files" 'nginx')" || true
  if [ -n "${base_sos_raw}" ]; then
    while IFS= read -r base_so; do
      [ -n "${base_so}" ] || continue
      # Only consider .so files in the modules directory
      case "${base_so}" in
        */nginx/modules/*.so) ;;
        *) continue ;;
      esac
      base_key="$(so_to_key "${base_so}")"
      # Skip if already handled by a module package
      [ ! -f "${tmpdir_gen}/${base_key}.yml" ] || continue
      msg -d "Base nginx package provides: ${base_so} (key: ${base_key})"
      emit_module_block "${base_key}" '' "${mgr}" "${base_so}"
    done <<<"${base_sos_raw}"
  fi

  # Assemble the final sorted YAML output
  printf '%s\n' '__run_nginx_modules_map_resources:'

  local key_files
  key_files="$(find "${tmpdir_gen}" -maxdepth 1 -type f -name '*.yml' -exec basename {} .yml \; \
    | sort)"

  if [ -z "${key_files}" ]; then
    msg -w 'No modules found.'
    printf '%s\n' '  {}'
  else
    local key
    while IFS= read -r key; do
      cat "${tmpdir_gen}/${key}.yml"
    done <<<"${key_files}"
  fi

  msg -s "Done. Found $(printf '%s' "${key_files}" | grep -c . || true) module(s)."
}

main "$@"
