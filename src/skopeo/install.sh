#!/usr/bin/env bash

set -e

if [ "$(id -u)" -ne 0 ]; then
	echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
	exit 1
fi


check_os() {
	# determine OS and store in $OS variable
	if [[ "$(uname)" == "Darwin" ]]; then
		PACKAGER="brew"
	elif type -p dnf >/dev/null; then
		PACKAGER="dnf"
	elif type -p yum >/dev/null; then
		PACKAGER="yum"
	elif type -p apt >/dev/null; then
		PACKAGER="apt"
	elif type -p zypper >/dev/null; then
		PACKAGER="zypper"
	elif [[ -f "/etc/alpine-release" ]]; then
		PACKAGER="apk"
	else
		echo "Unsupported operating"
	fi
	echo "Package binary is: $PACKAGER"
}

# Install based on OS
install() {
	echo installing with package $PACKAGER
	case $PACKAGER in
	"dnf")
		dnf -y install skopeo
		;;
	"apk")
		apk add skopeo
		;;
	"zypper")
		zypper -n install skopeo
		;;
	"apt")
		# Debian Bullseye, Testing or Unstable/Sid
		apt-get -y update
		apt-get -y install skopeo
		;;
	"yum" )
		yum -y install skopeo
		;;
	"brew")
		brew install skopeo
		;;
	*)
		echo "(!) package not supported unsupported"
		exit 1
		;;
	esac
}

check_os
install

echo "Done!"
