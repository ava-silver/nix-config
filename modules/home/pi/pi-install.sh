# Build the Pi binary from the npm package in ~/.pi/agent/extensions/node_modules: pi-install
#
# A bytecode-compiled binary starts about 40% faster than the GitHub release binary, and extensions
# still load from disk. The binary and the assets it reads from its own directory live at one fixed
# path, ~/.pi/bin, so allowlists can name ~/.pi/bin/pi. The version is whatever extensions/package.json
# pins; Pi's /update command bumps the pin, then runs this.
set -euo pipefail

root="${PI_INSTALL_DIR:-$HOME/.pi/bin}"
modules="${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}/extensions/node_modules"
pkg="$modules/@earendil-works/pi-coding-agent"
version=$(jq -r .version "$pkg/package.json")

if [[ "$(jq -r .version "$root/package.json" 2>/dev/null || true)" == "$version" && -x "$root/pi" ]]; then
  echo "pi $version already installed at $root"
  exit 0
fi

os=$(uname -s | tr '[:upper:]' '[:lower:]')
mkdir -p "$(dirname "$root")"
tmp=$(mktemp -d "$(dirname "$root")/.pi-install.XXXXXX")
trap 'rm -rf "$tmp"' EXIT
out="$tmp/pi"

(cd "$pkg" && bun build --compile --bytecode --format esm \
  --no-compile-autoload-bunfig --no-compile-autoload-dotenv \
  ./dist/bun/cli.js ./dist/utils/image-resize-worker.js ./dist/extensions/codemode/worker.js \
  --outfile "$out/pi")

# The assets the binary reads from its own directory. This mirrors Pi's release build, which differs
# from the compile above only by lacking --bytecode:
# https://github.com/earendil-works/pi/blob/main/scripts/build-binaries.sh
cp -R "$pkg/package.json" "$pkg/README.md" "$pkg/CHANGELOG.md" "$pkg/docs" "$pkg/examples" "$out"
cp -R "$pkg/dist/core/export-html" "$out/export-html"
cp "$modules/@silvia-odwyer/photon-node/photon_rs_bg.wasm" "$out"
mkdir "$out/theme" "$out/assets"
cp "$pkg"/dist/modes/interactive/theme/*.json "$out/theme"
cp "$pkg"/dist/modes/interactive/assets/*.png "$out/assets"
mkdir -p "$out/native/$os"
cp -R "$modules/@earendil-works/pi-tui/native/$os/prebuilds" "$out/native/$os"

# Running instances keep their open binary; the old directory is deleted with the temp dir.
[[ ! -e "$root" ]] || mv "$root" "$tmp/previous"
mv "$out" "$root"

echo "pi $version installed at $root"
