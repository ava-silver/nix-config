# Install a Pi release binary from GitHub: pi-install [version]
#
# Without a version, installs the version pinned for @earendil-works/pi-coding-agent in
# ~/.pi/agent/extensions/package.json. Releases live in ~/.pi/install/<version>/ and
# ~/.pi/install/current points at the active one; the previous release is kept for rollback.
set -euo pipefail

root="${PI_INSTALL_DIR:-$HOME/.pi/install}"
agent="${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}"
version="${1:-$(jq -r '.devDependencies["@earendil-works/pi-coding-agent"]' "$agent/extensions/package.json")}"

case "$(uname -s)-$(uname -m)" in
  Darwin-arm64) target=darwin-arm64 ;;
  Darwin-x86_64) target=darwin-x64 ;;
  Linux-aarch64 | Linux-arm64) target=linux-arm64 ;;
  Linux-x86_64) target=linux-x64 ;;
  *) echo "pi-install: unsupported platform $(uname -s)-$(uname -m)" >&2; exit 1 ;;
esac

mkdir -p "$root"
previous=$(readlink "$root/current" 2>/dev/null || true)

if [[ ! -x "$root/$version/pi" ]]; then
  base="https://github.com/earendil-works/pi/releases/download/v$version"
  archive="pi-$target.tar.gz"
  tmp=$(mktemp -d "$root/.tmp.XXXXXX")
  trap 'rm -rf "$tmp"' EXIT

  curl -fsSL --retry 3 -o "$tmp/$archive" "$base/$archive"
  curl -fsSL --retry 3 -o "$tmp/SHA256SUMS" "$base/SHA256SUMS"
  (cd "$tmp" && grep " $archive\$" SHA256SUMS | sha256sum -c --quiet -)
  mkdir "$tmp/extracted"
  tar -xzf "$tmp/$archive" -C "$tmp/extracted"
  mv "$tmp/extracted/pi" "$root/$version"
fi

ln -sfn "$version" "$root/current.new"
mv -fT "$root/current.new" "$root/current"

# Keep the active release and the one it replaced. `-type d` skips the `current` symlink.
find "$root" -mindepth 1 -maxdepth 1 -type d ! -name ".tmp.*" ! -name "$version" ! -name "${previous:-.}" -exec rm -rf {} +

echo "pi $version installed at $root/current"
