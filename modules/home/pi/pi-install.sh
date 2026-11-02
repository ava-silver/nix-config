# Install a Pi release binary from GitHub: pi-install [version]
#
# Without a version, installs the version pinned for @earendil-works/pi-coding-agent in
# ~/.pi/agent/extensions/package.json. The release (the binary and the assets it reads from its own
# directory) lives at one fixed path, ~/.pi/bin, so allowlists can name ~/.pi/bin/pi.
# To roll back, run `pi-install <older version>`.
set -euo pipefail

root="${PI_INSTALL_DIR:-$HOME/.pi/bin}"
agent="${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}"
version="${1:-$(jq -r '.devDependencies["@earendil-works/pi-coding-agent"]' "$agent/extensions/package.json")}"

case "$(uname -s)-$(uname -m)" in
  Darwin-arm64) target=darwin-arm64 ;;
  Darwin-x86_64) target=darwin-x64 ;;
  Linux-aarch64 | Linux-arm64) target=linux-arm64 ;;
  Linux-x86_64) target=linux-x64 ;;
  *) echo "pi-install: unsupported platform $(uname -s)-$(uname -m)" >&2; exit 1 ;;
esac

installed=$(jq -r .version "$root/package.json" 2>/dev/null || true)
if [[ "$installed" == "$version" && -x "$root/pi" ]]; then
  echo "pi $version already installed at $root"
  exit 0
fi

base="https://github.com/earendil-works/pi/releases/download/v$version"
archive="pi-$target.tar.gz"
mkdir -p "$(dirname "$root")"
tmp=$(mktemp -d "$(dirname "$root")/.pi-install.XXXXXX")
trap 'rm -rf "$tmp"' EXIT

curl -fsSL --retry 3 -o "$tmp/$archive" "$base/$archive"
curl -fsSL --retry 3 -o "$tmp/SHA256SUMS" "$base/SHA256SUMS"
(cd "$tmp" && grep " $archive\$" SHA256SUMS | sha256sum -c --quiet -)
mkdir "$tmp/extracted"
tar -xzf "$tmp/$archive" -C "$tmp/extracted"

# Running instances keep their open binary; the old directory is deleted with the temp dir.
[[ ! -e "$root" ]] || mv "$root" "$tmp/previous"
mv "$tmp/extracted/pi" "$root"

echo "pi $version installed at $root"
