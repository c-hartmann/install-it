#! /usr/bin/env bash

# install.sh

### a hopefully usefull and mostly generic
### installer script for KDE extensions

### for more info on this please see:
### https://github.com/c-hartmann/kde-install.sh

### usage: install [--remove]


# shellcheck disable=SC2034
ME="install.sh"

MY_PATH="${BASH_SOURCE[0]}"
MY_FILE="${MY_PATH##*/}"
MY_NAME="${MY_FILE%%.*}"

### where we live (also required to find install tar archive on uninstall)
SCRIPT_DIR="$(dirname "$(readlink -m "$0")")"

### archives used herein
MY_INSTALL_UPDATE_TAR_GZ="$SCRIPT_DIR/install-update.tar.gz"
MY_INSTALL_PROTECT_TAR_GZ="$SCRIPT_DIR/install-protect.tar.gz"

### things that can't be accomplished via an archive, go into the extra script
MY_INSTALL_EXTRAS="install-extras.sh"
MY_UN_INSTALL_EXTRAS="uninstall-extras.sh"

### cosmetic sugar
MY_TITEL="Dolphin User Service Menu Installer"
MY_ICON="install"



### this should run within a terminal and some gui application
declare gui=false
declare cli=false

### install base dir is either system wide or personaly
base_dir_root="/usr"          # this is risky business
base_dir_user="$HOME/.local"  # outbreaks from here with install-extras.sh only
BASE_INSTALL_DIR="$base_dir_user"

### desktop notifications will vanish after seconds
notification_timeout=4000


### _init_cmd "$@"
### return command mode (install (default) or remove)
_init_cmd ()
{
	### this defaults to install. so uninstal/remove must be triggered
	### explicitly. either by the name of this command (might exitst as
	### a symlink), or by command option
	if [[ $# -gt 0 ]]; then
		if [[ $1 =~ --remove|--delete|--uninstall|--deinstall ]]; then
			printf '%s' 'remove'
			return 0
		elif [[ $1 =~ --install ]]; then
			printf '%s' 'install'
			return 0
		fi
	### beside the option to call this as install[.sh] "--remove" we might operate
	### below false flag as [un|de]install[.sh] (f.i. existing as a symbolic link)
	elif [[ "${MY_NAME}" =~ ^uninstall.* ]]; then
		printf '%s' 'remove'
	elif [[ "${MY_NAME}" =~ ^deinstall.* ]]; then
		printf '%s' 'remove'
	### otherwiese assume install mode
	else
		printf '%s' 'install'
	fi
}

### _init_run_mode FD
### wrapper that sets gui or cli mode from terminal type
_init_run_mode ()
{
	local fd=$1
	if [[ ! -t $fd ]]; then
		# running via service menu
		gui=true
		cli=false
	else
		# running from command line
		gui=false
		cli=true
	fi
}

### _init_base_install_dir EUID
### set base install dir to system wide if we run as root
_init_base_install_dir ()
{
	_euid=$1
	[[ $_euid -eq 0 ]] && BASE_INSTALL_DIR="$base_dir_root"
}

### _notify _message
### wrapper that respects gui or cli mode
_notify ()
{
	$gui && notify-send --app-name="${MY_TITLE}" --icon="${MY_ICON}" --expire-time=$notification_timeout "$@"
	$cli && printf "\n%s\n" "$@" >&2
}

### _error_exit _message
### even more simple error handling
_error_exit ()
{
	local error_str="$1"
	$gui && kdialog --error "$error_str: $*" --ok-label "So Sad"
	$cli && printf "\n%s: %s\n\n" "$error_str" "$1"
	# shellcheck disable=SC2086
	exit ${2:-1}
}

### _install_or_update -
### install or update all base files but protect user modified. remove only empty directories
_install_or_update ()
{
	echo running in: "$SCRIPT_DIR" >&2
	### extract archive if present
	if [[ -f "$MY_INSTALL_UPDATE_TAR_GZ" ]]; then
		printf '%s\n' 'Files to install or update:' >&2
		# shellcheck disable=SC2086
		tar \
			--directory="$BASE_INSTALL_DIR" \
			--extract \
			--verbose \
			--file "$MY_INSTALL_UPDATE_TAR_GZ" >&2
		return 0
	else
		return 1
	fi
}

### _install_or_protect -
### install all base files but protect user modified
### TODO get correct do-not-overwrite tar option
_install_or_protect ()
{
	printf '%s\n' "running in: $SCRIPT_DIR" >&2
	### extract archive if present (write files if not present)
	# shellcheck disable=SC2086
	if [[ -f "$MY_INSTALL_PROTECT_TAR_GZ" ]]; then
		printf '%s\n' 'Files to install or protect:' >&2
		# shellcheck disable=SC2086
		tar \
			--directory="$HOME" \
			--extract \
			--skip-old-files \
			--verbose \
			--file "$MY_INSTALL_PROTECT_TAR_GZ" >&2
	fi
}

### _remove -
### remove all base files but protect user modified. remove only empty directories
_remove ()
{
	printf '%s\n' "running in: $SCRIPT_DIR" >&2
	printf '%s\n' "reading from: $SCRIPT_DIR/$MY_INSTALL_UPDATE_TAR_GZ" >&2
	# shellcheck disable=SC2086 disable=SC2162
	if [[ -f "$SCRIPT_DIR/$MY_INSTALL_UPDATE_TAR_GZ" ]]; then
		printf '%s\n' 'files to remove:...' >&2
		while read _target; do
			_target="$BASE_INSTALL_DIR/${_target#./}"
			printf 'removing: %s\n' "$_target" >&2
			test -f "$_target" && rm "$_target"
			test -d "$_target" && rmdir "$_target"
			### tac allows me to delete files before their containing directories
		done < <(tar tf "$SCRIPT_DIR/$MY_INSTALL_UPDATE_TAR_GZ" | tac)
		sleep 1
		return 0
	else
		return 1
	fi
}

### _main "$@"
### welcome to the installation circus
_main ()
{
	local stdin=0

	# if running inside a terminal, stdin is connected to this terminal
	_init_run_mode $stdin

	# this is made for installations inside users home, but might work global
	_init_base_install_dir $EUID

	# command is optional (defaults to 'install')
	declare -l _cmd
	_cmd=$(_init_cmd "$@")

	# a "log" file
	_tf="$(mktemp)"

	# choose actions by command effective
	case $_cmd in
		install)
			### files that are installed or updated
			_install_or_update 2>"$_tf" # || _error_exit 'oops... no installation archive found' 1
			### files to install but NOT to update
			_install_or_protect 2>"$_tf"
			### source extras if present
			# shellcheck disable=SC1090
			if [[ -f "$MY_INSTALL_EXTRAS" ]]; then
				. "$MY_INSTALL_EXTRAS"
			fi
			# some motivating feedback
			#_notify "installed"
		;;
		remove)
 			_remove 2>"$_tf" || _error_exit 'oops... something went wrong with deinstallation' 2
			### source extras if present
			# shellcheck disable=SC1090
			if [[ -f "$MY_UN_INSTALL_EXTRAS" ]]; then
				. "$MY_UN_INSTALL_EXTRAS"
			fi
			#_notify "removed"
		;;
		*)
			_error_exit 'oops... something went totaly wrong (unsupported command argument)' 3
		;;
	esac
}

_main "$@"
