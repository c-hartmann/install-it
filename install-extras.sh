#! /usr/bin/env bash

# shellcheck disable=SC2034
ME="install-extras.sh"

MY_PATH="${BASH_SOURCE[0]}"
MY_FILE="${MY_PATH##*/}"
MY_NAME="${MY_FILE%%.*}"

### archives used herein
MY_INSTALL_UPDATE_TAR_GZ="install-update.tar.gz"
MY_INSTALL_KEEP_TAR_GZ="install-protect.tar.gz"

MY_TITEL="Dolphin User Service Menu Extra Installer"
MY_ICON="uninstall"



### _get_first_user_bin_dir_from_path ( $PATH )
### install-extras.sh might use this to create files or symlinks in variable places
_get_first_user_bin_dir_from_path ()
{
	local _path="$1"
	local _first=""
	_first="$( printf '%s' "$_path" | tr ':' '\n' | grep -e "^${HOME}/" | head -1 )"
	if [[ -d "$_first" ]]; then
		printf '%s' "$_first"
	else
		printf '%s' "${DEFAULT_USER_BIN_DIR}"
	fi
}

### _check_user_bin_dir <user-bin-dir>
### lookout for user bin/ - create if not existing
_check_user_bin_dir ()
{
	local _user_bin_dir="$1"
	test -d "$_user_bin_dir" || mkdir "$_user_bin_dir"
	test -d "$_user_bin_dir" && return 0 || return 1
}

_check_user_bin_dir_in_path ()
{
	local _user_bin_dir="$1"
	local _path="${2:-$PATH}"
	printf '%s' "${_path}" | tr ':' '\n' | grep -q -e "^${_user_bin_dir}$"
}

_main ()
{
	local _user_bin_dir
	_user_bin_dir="$(_get_first_user_bin_dir_from_path "$PATH")"

	_check_user_bin_dir "$_user_bin_dir" || _error_exit "user bin dir does not exists or could not be created: $_user_bin_dir"

	_check_user_bin_dir_in_path "$_user_bin_dir" "$PATH" || _notify "user bin dir is not in your binary search \$PATH: $_user_bin_dir"

	### things that could be done here...

	### copy just installed files to somewhere or create symlinks to it

	### init something

	### basicly all the things that can not accomplished through an archive of files

	### TODO can symlinks go throug a tar archive? probably yes
}

_main
