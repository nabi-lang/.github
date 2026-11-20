#!/bin/sh
# Resolve and install a nabi toolchain from GitHub releases. Never reads a
# site: the pipeline must work while nabi-lang.org is down or mid-deploy.
#
#   toolchain.sh pin <nabi.nabion>             print its toolchain: pin
#   toolchain.sh kind <pin>                  series, exact or pre
#   toolchain.sh resolve <pin>               newest release the pin accepts
#   toolchain.sh triple                      this host's target triple
#   toolchain.sh minisign <dir>              fetch the pinned minisign into
#                                            <dir>, print the binary's path
#   toolchain.sh install [--home <dir>] [--no-attest]
#       [--release-key <file>] [--minisign <binary>]
#       (--version <pin> | --pin-file <nabi.nabion> | --candidate-run <id>)
#
# A pin is MAJOR.MINOR (newest final release of that series),
# MAJOR.MINOR.PATCH (exactly that) or X.Y.Z-rc.N (that prerelease). A
# series never resolves to a prerelease. install prints "version=<v>" and
# "bin=<dir>" lines.
#
# A release install checks, failing closed: SHA256SUMS.minisig verifies
# SHA256SUMS with the release key and its trusted comment names the
# version; the archive's SHA-256 is its line in SHA256SUMS; and, unless
# --no-attest, gh attestation verify. A candidate run's dist-* artifacts
# are not signed yet, so they are checked against their .sha256 only.
#
# --release-key (a minisign public key file in place of the release key)
# and --minisign (a binary in place of the pinned one) are for the tests
# and hosts without a pinned minisign; each use logs a warning. Both are
# options, never environment: install-nabi does not pass them, so what a
# job trusts cannot be changed by a variable set elsewhere.
#
# Environment: NABI_REPO (nabi-lang/nabi), NABI_DIST (release download base),
# GH_TOKEN for gh.
set -eu
lib=$(cd "$(dirname "$0")" && pwd)
. "$lib/retry.sh"
. "$lib/gh.sh"

: "${NABI_REPO:=nabi-lang/nabi}"
: "${NABI_DIST:=https://github.com/$NABI_REPO/releases}"

# The release key, nabi-lang/nabi keys/release.pub, key id B33E6FE61BE5314C.
# On a rotation, change it here and in the README (install-nabi), together
# with keys/release.pub, install.sh, install.ps1 and the toolchain's
# built-in key in the nabi repository.
release_key=RWRMMeUb5m8+s0rEtzbR47dmyrMdlGyGQSvWUn/Ob5QYh0GHgs1GvJEs

# minisign 0.12, from https://github.com/jedisct1/minisign/releases. Each
# SHA-256 was taken from an archive whose .minisig verified with the
# author's key RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3;
# the same pins as nabi's .github/actions/setup-minisign. The macOS build is
# arm64 only.
minisign_v=0.12
minisign_linux=9a599b48ba6eb7b1e80f12f36b94ceca7c00b7a5173c95c3efc88d9822957e73
minisign_win=37b600344e20c19314b2e82813db2bfdcc408b77b876f7727889dbd46d539479
minisign_mac=89000b19535765f9cffc65a65d64a820f433ef6db8020667f7570e06bf6aac63

die() {
	echo "::error::install-nabi: $*" >&2
	exit 1
}

pin_of() {
	[ -f "$1" ] || die "$1 does not exist"
	_p=$(sed -n 's/^[[:space:]]*toolchain:[[:space:]]*"\([^"]*\)".*/\1/p' "$1" | head -n 1)
	[ -n "$_p" ] || die "$1 pins no toolchain; add toolchain: \"0.2\" to its Package"
	echo "$_p"
}

# pin_kind <pin>: series, exact or pre; fails on anything else.
pin_kind() {
	if echo "$1" | grep -Eq '^[0-9]+\.[0-9]+$'; then
		echo series
	elif echo "$1" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
		echo exact
	elif echo "$1" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+-rc\.[0-9]+$'; then
		echo pre
	else
		die "toolchain \"$1\" is not a pin; write a series (\"0.2\"), a release (\"0.2.1\") or a prerelease (\"0.3.0-rc.1\")"
	fi
}

resolve() {
	_k=$(pin_kind "$1")
	_rels=$(gh_releases "$NABI_REPO") || die "cannot list the releases of $NABI_REPO"
	case $_k in
	series)
		_v=$(printf '%s\n' "$_rels" | awk -v p="v$1." '$2 == "false" && $3 == "false" && index($1, p) == 1 && $1 !~ /-/ { print substr($1, 2) }' |
			sort -t . -k 1,1n -k 2,2n -k 3,3n | tail -n 1)
		;;
	*)
		_v=$(printf '%s\n' "$_rels" | awk -v t="v$1" '$1 == t && $3 == "false" { print substr($1, 2) }')
		;;
	esac
	[ -n "$_v" ] || die "no published nabi release matches toolchain \"$1\" in $NABI_REPO"
	echo "$_v"
}

# win_arch: the Windows machine's architecture. Git Bash may be an x64
# build emulated on arm64 Windows, whose uname -m says x86_64.
win_arch() {
	case ${RUNNER_ARCH:-} in
	ARM64) echo aarch64 && return ;;
	X64) echo x86_64 && return ;;
	esac
	# Set in a 32-bit process on 64-bit Windows; the machine's value.
	_w=${PROCESSOR_ARCHITEW6432:-}
	if [ -z "$_w" ]; then
		# The registry holds the machine's value; an emulated process's own
		# PROCESSOR_ARCHITECTURE says AMD64.
		_w=$(MSYS2_ARG_CONV_EXCL='*' reg query 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' /v PROCESSOR_ARCHITECTURE 2> /dev/null |
			awk '$1 == "PROCESSOR_ARCHITECTURE" { print $3 }' | tr -d '\r') || _w=
	fi
	[ -n "$_w" ] || _w=${PROCESSOR_ARCHITECTURE:-}
	case $_w in
	ARM64) echo aarch64 ;;
	AMD64) echo x86_64 ;;
	*) die "no nabi toolchain for the ${_w:-unknown} Windows architecture" ;;
	esac
}

triple() {
	case $(uname -s) in
	MINGW* | MSYS* | CYGWIN*)
		_a=$(win_arch)
		echo "$_a-pc-windows-msvc"
		return
		;;
	esac
	case $(uname -m) in
	arm64 | aarch64) _a=aarch64 ;;
	x86_64 | amd64) _a=x86_64 ;;
	*) die "no nabi toolchain for the $(uname -m) architecture" ;;
	esac
	case $(uname -s) in
	Darwin) echo "$_a-apple-darwin" ;;
	Linux)
		if ls /lib/ld-musl-* > /dev/null 2>&1; then
			echo "$_a-unknown-linux-musl"
		else
			echo "$_a-unknown-linux-gnu"
		fi
		;;
	FreeBSD)
		[ "$_a" = x86_64 ] || die "no nabi toolchain for FreeBSD on $_a"
		echo "$_a-unknown-freebsd"
		;;
	*) die "no nabi toolchain for $(uname -s)" ;;
	esac
}

sha256_of() {
	if command -v sha256sum > /dev/null 2>&1; then
		sha256sum "$1" | awk '{ print $1 }'
	elif command -v sha256 > /dev/null 2>&1; then
		sha256 -q "$1"
	else
		shasum -a 256 "$1" | awk '{ print $1 }'
	fi
}

# minisign_fetch <dir>: the pinned minisign for this host in <dir>; prints
# the binary's path.
minisign_fetch() {
	_mt=$(triple)
	case $_mt in
	*-linux-*) _ma=minisign-$minisign_v-linux.tar.gz _mh=$minisign_linux _mb=minisign-linux/${_mt%%-*}/minisign ;;
	*-windows-*) _ma=minisign-$minisign_v-win64.zip _mh=$minisign_win _mb=minisign-win64/${_mt%%-*}/minisign.exe ;;
	aarch64-apple-darwin) _ma=minisign-$minisign_v-macos.zip _mh=$minisign_mac _mb=minisign ;;
	*) die "no pinned minisign for $_mt; run toolchain.sh install with --minisign <path of minisign $minisign_v>" ;;
	esac
	mkdir -p "$1"
	download "https://github.com/jedisct1/minisign/releases/download/$minisign_v/$_ma" "$1/$_ma"
	_got=$(sha256_of "$1/$_ma")
	[ "$_got" = "$_mh" ] ||
		die "$_ma has SHA-256 $_got, not the pinned $_mh; nothing was installed (a damaged or altered download; try again)"
	unpack "$1/$_ma" "$1"
	[ -f "$1/$_mb" ] || die "$_ma has no $_mb"
	chmod +x "$1/$_mb"
	echo "$1/$_mb"
}

# check_signed <archive> <dir>: SHA256SUMS and SHA256SUMS.minisig in <dir>
# verify with the release key, are for version $_v, and list the
# archive's SHA-256.
check_signed() {
	if [ -n "$_keyfile" ]; then
		[ -f "$_keyfile" ] || die "--release-key $_keyfile does not exist; give a minisign public key file"
		echo "::warning::install-nabi: checking with $(sed -n 's/^untrusted comment: //p' "$_keyfile") from --release-key, not the nabi release key B33E6FE61BE5314C" >&2
		set -- "$1" "$2" -p "$_keyfile"
	else
		set -- "$1" "$2" -P "$release_key"
	fi
	if [ -n "$_msbin" ]; then
		echo "::warning::install-nabi: checking with $_msbin from --minisign, not the pinned minisign $minisign_v" >&2
		_ms=$_msbin
	else
		_ms=$(minisign_fetch "$2/minisign") || exit 1
	fi
	_mo=$("$_ms" -V "$3" "$4" -m "$2/SHA256SUMS" -x "$2/SHA256SUMS.minisig" 2>&1) ||
		die "SHA256SUMS.minisig of nabi $_v does not verify with the release key, so nothing was installed: $_mo"
	_mo=$(printf '%s\n' "$_mo" | tr -d '\r')
	printf '%s\n' "$_mo" | grep -qxF "Trusted comment: nabi $_v SHA256SUMS" ||
		die "SHA256SUMS.minisig is signed, but not for nabi $_v, so nothing was installed: $_mo"
	_n=$(basename "$1")
	_want=$(awk -v n="$_n" '$2 == n || $2 == "*" n { print tolower($1); exit }' "$2/SHA256SUMS")
	[ -n "$_want" ] || die "the SHA256SUMS of nabi $_v lists no $_n, so it cannot be checked"
	_got=$(sha256_of "$1")
	[ "$_got" = "$_want" ] || die "$_n has SHA-256 $_got, but the signed SHA256SUMS says $_want"
}

check_sum() {
	[ -f "$2" ] || die "$(basename "$1") has no .sha256 beside it, so it cannot be checked"
	_want=$(awk '{ print tolower($1); exit }' "$2")
	_got=$(sha256_of "$1")
	[ "$_got" = "$_want" ] || die "$(basename "$1") has SHA-256 $_got, but its .sha256 says $_want"
}

download() {
	retry -- curl -fsSL --proto '=https,file' -o "$2" "$1" || die "cannot download $1"
}

unpack() {
	case $1 in
	*.zip)
		if command -v unzip > /dev/null 2>&1; then
			unzip -q "$1" -d "$2"
		else
			"${SYSTEMROOT:-C:/Windows}/System32/tar.exe" -xf "$1" -C "$2"
		fi
		;;
	*.tar.xz) tar -xJf "$1" -C "$2" ;;
	*) tar -xzf "$1" -C "$2" ;;
	esac || die "cannot unpack $1"
}

# native_path <path>: a path nabi.exe understands on Windows.
native_path() {
	if command -v cygpath > /dev/null 2>&1; then cygpath -w "$1"; else echo "$1"; fi
}

install() {
	_home=
	_want=
	_pinfile=
	_run=
	_attest=1
	_keyfile=
	_msbin=
	while [ $# -gt 0 ]; do
		case $1 in
		--home) _home=$2 && shift ;;
		--version) _want=$2 && shift ;;
		--pin-file) _pinfile=$2 && shift ;;
		--candidate-run) _run=$2 && shift ;;
		--no-attest) _attest= ;;
		--release-key) _keyfile=$2 && shift ;;
		--minisign) _msbin=$2 && shift ;;
		*) die "unknown option $1" ;;
		esac
		shift
	done
	_n=0
	for _x in "$_want" "$_pinfile" "$_run"; do [ -z "$_x" ] || _n=$((_n + 1)); done
	[ "$_n" -eq 1 ] || die "give exactly one of version, pin or candidate-run"
	_home=${_home:-$HOME/.nabi}
	_t=$(triple)
	_tmp=$(mktemp -d)
	case $_t in *-windows-*) _exts=zip ;; *) _exts="tar.xz tar.gz" ;; esac
	if [ "$(uname -s)" != Darwin ] && ! command -v xz > /dev/null 2>&1; then
		_exts=$(echo "$_exts" | sed 's/tar.xz //')
	fi

	if [ -n "$_run" ]; then
		gh_run_download "$NABI_REPO" "$_run" 'dist-*' "$_tmp/run" ||
			die "cannot download the dist-* artifacts of $NABI_REPO run $_run"
		_ar=
		for _e in $_exts; do
			_ar=$(find "$_tmp/run" -type f -name "nabi-*-$_t.$_e" | head -n 1)
			[ -z "$_ar" ] || break
		done
		[ -n "$_ar" ] || die "run $_run has no $_t archive in its dist-* artifacts"
		_v=$(basename "$_ar" | sed "s/^nabi-\(.*\)-$_t\..*/\1/")
		check_sum "$_ar" "$_ar.sha256"
	else
		if [ -n "$_pinfile" ]; then _want=$(pin_of "$_pinfile"); fi
		_v=$(resolve "$_want")
		_ar=
		for _e in $_exts; do
			_u="$NABI_DIST/download/v$_v/nabi-$_v-$_t.$_e"
			if retry -- curl -fsSL --proto '=https,file' -o "$_tmp/nabi-$_v-$_t.$_e" "$_u" 2> /dev/null; then
				_ar="$_tmp/nabi-$_v-$_t.$_e"
				break
			fi
		done
		[ -n "$_ar" ] || die "nabi $_v has no $_t archive at $NABI_DIST/download/v$_v/"
		for _f in SHA256SUMS SHA256SUMS.minisig; do
			retry -- curl -fsSL --proto '=https,file' -o "$_tmp/$_f" "$NABI_DIST/download/v$_v/$_f" ||
				die "nabi $_v has no $_f at $NABI_DIST/download/v$_v/, so its archive cannot be checked; nothing was installed"
		done
		check_signed "$_ar" "$_tmp"
		if [ -n "$_attest" ]; then
			gh_attest_verify "$_ar" "$NABI_REPO" ||
				die "$(basename "$_ar") has no valid build attestation from $NABI_REPO"
		fi
	fi

	mkdir "$_tmp/files"
	unpack "$_ar" "$_tmp/files"
	_src=$(find "$_tmp/files" -mindepth 2 -maxdepth 2 -name bin -type d | head -n 1)
	[ -n "$_src" ] || die "$(basename "$_ar") is not a nabi toolchain (no bin/)"
	_src=$(dirname "$_src")
	_full=$("$_src/bin/nabic" --version | awk 'NR == 1 { print $2 }') || die "cannot run nabic from $(basename "$_ar")"
	[ "$_full" = "$_v" ] || die "$(basename "$_ar") holds nabi $_full, not $_v"
	mkdir -p "$_home"
	NABI_HOME=$(native_path "$_home") "$_src/bin/nabi" -q toolchain install "$_full" --from "$(native_path "$_src")"
	NABI_HOME=$(native_path "$_home") "$_src/bin/nabi" -q toolchain default "$_full"
	"$_home/bin/nabi" --version > /dev/null || die "the installed $_home/bin/nabi does not run"
	rm -rf "$_tmp"
	echo "version=$_v"
	echo "bin=$_home/bin"
}

cmd=${1:-}
[ $# -eq 0 ] || shift
case $cmd in
pin) pin_of "$1" ;;
kind) pin_kind "$1" ;;
resolve) resolve "$1" ;;
triple) triple ;;
minisign) minisign_fetch "$1" ;;
install) install "$@" ;;
*)
	echo "usage: toolchain.sh pin|kind|resolve|triple|minisign|install ..." >&2
	exit 2
	;;
esac
