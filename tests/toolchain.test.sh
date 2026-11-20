#!/bin/sh
. "$(dirname "$0")/lib.sh"
tc=$root/lib/toolchain.sh
triple=$(sh "$tc" triple)
# The real minisign checks the signatures; the release key is replaced by
# a throwaway one made here.
ms=$(command -v minisign) || {
	echo "  toolchain: the tests need minisign on PATH (sh lib/toolchain.sh minisign <dir> fetches the pinned one)" >&2
	exit 1
}
minisign -G -W -p "$SHIM/test.pub" -s "$SHIM/test.key" > /dev/null
minisign -G -W -p "$SHIM/other.pub" -s "$SHIM/other.key" > /dev/null
# inst <args>: install, trusting the throwaway key, with this minisign
inst() { sh "$tc" install --release-key "$SHIM/test.pub" --minisign "$ms" "$@"; }

state '{repos: {"nabi-lang/nabi": {releases: [
	{tag_name: "v0.20.0", prerelease: false, draft: false},
	{tag_name: "v0.3.0-rc.2", prerelease: true, draft: true},
	{tag_name: "v0.3.0-rc.1", prerelease: true, draft: false},
	{tag_name: "v0.2.12-rc.1", prerelease: false, draft: false},
	{tag_name: "v0.2.11-rc.1", prerelease: true, draft: false},
	{tag_name: "v0.2.10", prerelease: false, draft: true},
	{tag_name: "v0.2.9", prerelease: false, draft: false},
	{tag_name: "v0.2.1", prerelease: false, draft: false},
	{tag_name: "v0.2.0", prerelease: false, draft: false},
	{tag_name: "v0.1.6", prerelease: false, draft: false}]}}}'

t_case "pin from nabi.nabion"
printf 'Package {\n    name: "x",\n    toolchain: "0.2",\n}\n' > "$SHIM/nabi.nabion"
eq "$(sh "$tc" pin "$SHIM/nabi.nabion")" 0.2
printf 'Package {\n    name: "x",\n}\n' > "$SHIM/none.nabion"
err=$(sh "$tc" pin "$SHIM/none.nabion" 2>&1) && fail "no pin accepted"
has "$err" 'add toolchain: "0.2"'

t_case "resolve"
eq "$(sh "$tc" resolve 0.2)" 0.2.9 "series: newest final, drafts and 0.20 left out"
eq "$(sh "$tc" resolve 0.2.1)" 0.2.1 exact
eq "$(sh "$tc" resolve 0.3.0-rc.1)" 0.3.0-rc.1 prerelease
eq "$(sh "$tc" resolve 0.2.11-rc.1)" 0.2.11-rc.1 "prerelease of a series"
eq "$(sh "$tc" kind 0.3.0-rc.1)" pre
err=$(sh "$tc" resolve 0.3.0-rc.2 2>&1) && fail "a draft prerelease resolved"
has "$err" 'no published nabi release matches toolchain "0.3.0-rc.2"'
err=$(sh "$tc" resolve 0.3 2>&1) && fail "series 0.3 resolved to its rc"
has "$err" 'no published nabi release matches toolchain "0.3"'
err=$(sh "$tc" resolve 0.2.10 2>&1) && fail "a draft resolved"
has "$err" 'no published nabi release matches toolchain "0.2.10"'
err=$(sh "$tc" resolve 0.4 2>&1) && fail "0.4 resolved"
for bad in "0" "0.2.x" "^0.2" "v0.2" "0.2.0-beta" "0.2.0-rc" "0.2.0-rc.1.1" "0.2-rc.1"; do
	err=$(sh "$tc" resolve "$bad" 2>&1) && fail "pin $bad accepted"
	has "$err" 'write a series ("0.2")'
done

t_case "host triple"
# fake_host <uname -s> <uname -m> [<reg's PROCESSOR_ARCHITECTURE>]
fake_host() {
	# shellcheck disable=SC2016 # literal script
	printf '#!/bin/sh\ncase $1 in -s) echo %s ;; -m) echo %s ;; esac\n' "$1" "$2" > "$SHIM/bin/uname"
	if [ -n "${3:-}" ]; then
		printf '#!/bin/sh\nprintf "\\r\\nHKEY_LOCAL_MACHINE\\\\x\\r\\n    PROCESSOR_ARCHITECTURE    REG_SZ    %s\\r\\n"\n' "$3" > "$SHIM/bin/reg"
	else
		printf '#!/bin/sh\nexit 1\n' > "$SHIM/bin/reg"
	fi
	chmod +x "$SHIM/bin/uname" "$SHIM/bin/reg"
}
host() { # <env...>: toolchain.sh triple, without the runner's own
	env -u RUNNER_ARCH -u PROCESSOR_ARCHITEW6432 -u PROCESSOR_ARCHITECTURE "$@" sh "$tc" triple
}
fake_host FreeBSD amd64
eq "$(host)" x86_64-unknown-freebsd
fake_host FreeBSD arm64
err=$(host 2>&1) && fail "FreeBSD arm64 accepted"
has "$err" "no nabi toolchain for FreeBSD on aarch64"
fake_host MINGW64_NT-10.0-26100 x86_64 ARM64
eq "$(host)" aarch64-pc-windows-msvc "emulated Git Bash on arm64, from the registry"
eq "$(host RUNNER_ARCH=X64)" x86_64-pc-windows-msvc "RUNNER_ARCH first"
fake_host MINGW64_NT-10.0-26100 x86_64
eq "$(host RUNNER_ARCH=ARM64)" aarch64-pc-windows-msvc "RUNNER_ARCH"
eq "$(host PROCESSOR_ARCHITEW6432=ARM64 PROCESSOR_ARCHITECTURE=AMD64)" aarch64-pc-windows-msvc
eq "$(host PROCESSOR_ARCHITECTURE=AMD64)" x86_64-pc-windows-msvc
err=$(host PROCESSOR_ARCHITECTURE=x86 2>&1) && fail "x86 Windows accepted"
has "$err" "no nabi toolchain for the x86 Windows architecture"
rm -f "$SHIM/bin/uname" "$SHIM/bin/reg"

# fake_release <version> <dir>: an archive for this host plus .sha256
# (all a candidate run has); sign_release makes it a release
fake_release() {
	_s=$SHIM/src/nabi-$1-$triple
	mkdir -p "$_s/bin"
	cat > "$_s/bin/nabic" << EOS
#!/bin/sh
echo "nabic $1"
EOS
	cat > "$_s/bin/nabi" << 'EOS'
#!/bin/sh
[ "$1" = -q ] && shift
case "$1 $2" in
"toolchain install") mkdir -p "$NABI_HOME/toolchains/$3" && cp -R "$5/." "$NABI_HOME/toolchains/$3/" ;;
"toolchain default") mkdir -p "$NABI_HOME/bin" && printf '#!/bin/sh\necho "nabi %s"\n' "$3" > "$NABI_HOME/bin/nabi" && chmod +x "$NABI_HOME/bin/nabi" ;;
*) exit 9 ;;
esac
EOS
	chmod +x "$_s/bin/nabi" "$_s/bin/nabic"
	mkdir -p "$2"
	case $triple in
	*windows*) (cd "$SHIM/src" && zip -qr "$2/nabi-$1-$triple.zip" "nabi-$1-$triple") && _a=$2/nabi-$1-$triple.zip ;;
	*) tar -czf "$2/nabi-$1-$triple.tar.gz" -C "$SHIM/src" "nabi-$1-$triple" && _a=$2/nabi-$1-$triple.tar.gz ;;
	esac
	if command -v sha256sum > /dev/null; then _h=$(sha256sum "$_a" | cut -d' ' -f1); else _h=$(shasum -a 256 "$_a" | cut -d' ' -f1); fi
	echo "$_h *$(basename "$_a")" > "$_a.sha256"
}
# sign_release <version> <dir> [<key> [<signed version>]]: SHA256SUMS of
# the archives in <dir>, and its .minisig with the trusted comment the
# release pipeline writes
sign_release() {
	(cd "$2" && for _f in nabi-*.tar.gz nabi-*.tar.xz nabi-*.zip; do
		[ ! -f "$_f" ] || printf '%s  %s\n' "$(cut -d' ' -f1 "$_f.sha256")" "$_f"
	done) > "$2/SHA256SUMS"
	rm -f "$2/SHA256SUMS.minisig"
	minisign -S -s "${3:-$SHIM/test.key}" -m "$2/SHA256SUMS" -x "$2/SHA256SUMS.minisig" \
		-t "nabi ${4:-$1} SHA256SUMS" < /dev/null > /dev/null
}
dl=$SHIM/http/github.com/nabi-lang/nabi/releases/download
fake_release 0.2.9 "$dl/v0.2.9"
sign_release 0.2.9 "$dl/v0.2.9"
rel=$dl/v0.2.9
ar=$(cd "$rel" && ls nabi-0.2.9-*)
ar=$(echo "$ar" | grep -v sha256)
# keep <file>: save a release file, restored by put_back
keep() { cp "$rel/$1" "$SHIM/kept.$1"; }
put_back() { cp "$SHIM/kept.$1" "$rel/$1"; }

t_case "install the newest of a pin"
out=$(inst --home "$SHIM/home" --pin-file "$SHIM/nabi.nabion")
has "$out" "version=0.2.9"
has "$out" "bin=$SHIM/home/bin"
eq "$("$SHIM/home/bin/nabi" --version)" "nabi 0.2.9"
eq "$(calls '^GET attestation')" 1 "attestation checked"
eq "$(calls '/v0.2.9/SHA256SUMS(.minisig)?$')" 2 "signed sums fetched"
eq "$(calls '\.sha256$')" 0 "no per-file .sha256 for a release"
eq "$(calls 'tar.xz$')" "$(if command -v xz > /dev/null || [ "$(uname -s)" = Darwin ]; then echo 1; else echo 0; fi)" ".tar.xz tried first"

t_case "a lost network on the download is retried"
echo 1 > "$dl/v0.2.9/nabi-0.2.9-$triple.tar.gz.net"
rm -rf "${SHIM:?}/home"
inst --home "$SHIM/home" --version 0.2.9 > /dev/null 2>&1 || fail "install after a network error"
eq "$(calls '^SLEEP 10$')" 1
rm -f "$dl/v0.2.9/nabi-0.2.9-$triple.tar.gz.net"

t_case "a damaged archive is refused"
keep "$ar"
printf 'x' >> "$rel/$ar"
err=$(inst --home "$SHIM/h2" --version 0.2.9 2>&1) && fail "damaged archive accepted"
has "$err" "but the signed SHA256SUMS says"
[ ! -e "$SHIM/h2/bin/nabi" ] || fail "installed anyway"
put_back "$ar"

t_case "an altered SHA256SUMS is refused"
keep SHA256SUMS
printf '%s  %s\n' 0000000000000000000000000000000000000000000000000000000000000000 "$ar" > "$rel/SHA256SUMS"
err=$(inst --home "$SHIM/h2" --version 0.2.9 2>&1) && fail "altered SHA256SUMS accepted"
has "$err" "does not verify with the release key"
[ ! -e "$SHIM/h2/bin/nabi" ] || fail "installed anyway"
put_back SHA256SUMS

t_case "a signature by another key is refused"
keep SHA256SUMS.minisig
sign_release 0.2.9 "$rel" "$SHIM/other.key"
err=$(inst --home "$SHIM/h2" --version 0.2.9 2>&1) && fail "other key accepted"
has "$err" "does not verify with the release key"
put_back SHA256SUMS.minisig

t_case "the real release key is the default"
err=$(sh "$tc" install --minisign "$ms" --home "$SHIM/h2" --version 0.2.9 2>&1) && fail "test key accepted as the release key"
has "$err" "does not verify with the release key"
grep -q '^release_key=RWRMMeUb5m8+s0rEtzbR47dmyrMdlGyGQSvWUn/Ob5QYh0GHgs1GvJEs$' "$tc" || fail "release key B33E6FE61BE5314C is not embedded"

t_case "the environment cannot change the key or the verifier"
printf '#!/bin/sh\necho "Trusted comment: nabi 0.2.9 SHA256SUMS"\n' > "$SHIM/bin/fake-minisign"
chmod +x "$SHIM/bin/fake-minisign"
err=$(NABI_RELEASE_KEY=$(sed -n 2p "$SHIM/test.pub") \
	sh "$tc" install --minisign "$ms" --home "$SHIM/h2" --version 0.2.9 2>&1) && fail "NABI_RELEASE_KEY trusted"
has "$err" "does not verify with the release key"
err=$(NABI_MINISIGN=$SHIM/bin/fake-minisign \
	sh "$tc" install --release-key "$SHIM/test.pub" --home "$SHIM/h2" --version 0.2.9 2>&1) && fail "NABI_MINISIGN used"
has "$err" "minisign"
hasnt "$err" "fake-minisign"
[ ! -e "$SHIM/h2/bin/nabi" ] || fail "installed anyway"

t_case "an override is logged with its key id"
out=$(inst --home "$SHIM/h10" --version 0.2.9 2>&1)
has "$out" "::warning::install-nabi: checking with minisign public key "
has "$out" "from --release-key, not the nabi release key B33E6FE61BE5314C"
has "$out" "from --minisign, not the pinned minisign 0.12"

t_case "a signature for another version is refused"
keep SHA256SUMS.minisig
sign_release 0.2.9 "$rel" "$SHIM/test.key" 0.2.1
err=$(inst --home "$SHIM/h2" --version 0.2.9 2>&1) && fail "replayed signature accepted"
has "$err" "signed, but not for nabi 0.2.9"
put_back SHA256SUMS.minisig

t_case "a SHA256SUMS without the archive is refused"
keep SHA256SUMS
keep SHA256SUMS.minisig
echo "0000000000000000000000000000000000000000000000000000000000000000  nabi-0.2.9-other.tar.gz" > "$rel/SHA256SUMS"
minisign -S -s "$SHIM/test.key" -m "$rel/SHA256SUMS" -x "$rel/SHA256SUMS.minisig" -t "nabi 0.2.9 SHA256SUMS" < /dev/null > /dev/null
err=$(inst --home "$SHIM/h2" --version 0.2.9 2>&1) && fail "unlisted archive accepted"
has "$err" "lists no $ar"
put_back SHA256SUMS
put_back SHA256SUMS.minisig

t_case "a missing signature is refused"
mv "$rel/SHA256SUMS.minisig" "$SHIM/kept.minisig"
err=$(inst --home "$SHIM/h3" --version 0.2.9 2>&1) && fail "unsigned release accepted"
has "$err" "nabi 0.2.9 has no SHA256SUMS.minisig"
[ ! -e "$SHIM/h3/bin/nabi" ] || fail "installed anyway"
mv "$SHIM/kept.minisig" "$rel/SHA256SUMS.minisig"

t_case "a missing SHA256SUMS is refused"
mv "$rel/SHA256SUMS" "$SHIM/kept.sums"
err=$(inst --home "$SHIM/h3" --version 0.2.9 2>&1) && fail "release without SHA256SUMS accepted"
has "$err" "nabi 0.2.9 has no SHA256SUMS at"
mv "$SHIM/kept.sums" "$rel/SHA256SUMS"

t_case "the pinned minisign is checked before it runs"
case $triple in
*-linux-* | *-windows-* | aarch64-apple-darwin)
	md=$SHIM/http/github.com/jedisct1/minisign/releases/download/0.12
	mkdir -p "$md"
	for f in minisign-0.12-linux.tar.gz minisign-0.12-win64.zip minisign-0.12-macos.zip; do echo fake > "$md/$f"; done
	err=$(sh "$tc" minisign "$SHIM/ms" 2>&1) && fail "a fake minisign accepted"
	has "$err" "not the pinned"
	err=$(sh "$tc" install --release-key "$SHIM/test.pub" --home "$SHIM/h3" --version 0.2.9 2>&1) && fail "installed with a fake minisign"
	has "$err" "not the pinned"
	[ ! -e "$SHIM/h3/bin/nabi" ] || fail "installed anyway"
	rm -rf "$md"
	err=$(sh "$tc" minisign "$SHIM/ms" 2>&1) && fail "no minisign download accepted"
	has "$err" "cannot download https://github.com/jedisct1/minisign/releases/download/0.12/"
	;;
*)
	err=$(sh "$tc" minisign "$SHIM/ms" 2>&1) && fail "a host without a pin"
	has "$err" "no pinned minisign for $triple"
	;;
esac

t_case "a prerelease installs only by its exact pin"
fake_release 0.3.0-rc.1 "$dl/v0.3.0-rc.1"
sign_release 0.3.0-rc.1 "$dl/v0.3.0-rc.1"
out=$(inst --home "$SHIM/h8" --version 0.3.0-rc.1)
has "$out" "version=0.3.0-rc.1"
eq "$("$SHIM/h8/bin/nabi" --version)" "nabi 0.3.0-rc.1"
fake_release 0.2.11-rc.1 "$dl/v0.2.11-rc.1"
sign_release 0.2.11-rc.1 "$dl/v0.2.11-rc.1"
out=$(inst --home "$SHIM/h9" --version 0.2)
has "$out" "version=0.2.9" "a series never takes its rc"

t_case "a failed attestation is refused, unless turned off"
touch "$SHIM/attest-fail"
err=$(inst --home "$SHIM/h4" --version 0.2 2>&1) && fail "bad attestation accepted"
has "$err" "no valid build attestation"
inst --home "$SHIM/h4" --version 0.2 --no-attest > /dev/null || fail "--no-attest"
rm -f "$SHIM/attest-fail"

t_case "a version without an archive"
err=$(inst --home "$SHIM/h5" --version 0.2.1 2>&1) && fail "installed nothing"
has "$err" "nabi 0.2.1 has no $triple archive"

t_case "candidate run artifacts"
fake_release 0.2.10 "$SHIM/runs/77/dist-host"
out=$(inst --home "$SHIM/h6" --candidate-run 77)
has "$out" "version=0.2.10"
eq "$(calls '^GET attestation')" 0 "artifacts carry no attestation"
err=$(inst --home "$SHIM/h7" --candidate-run 78 2>&1) && fail "run 78"
has "$err" "cannot download the dist-* artifacts"

t_case "exactly one source"
err=$(inst --version 0.2 --candidate-run 77 2>&1) && fail "two sources"
has "$err" "exactly one of"
