#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <version> <pkg_path> <download_url> [minimum_supported_version] [release_notes] [output_path]" >&2
  exit 1
fi

VERSION="$1"
PKG_PATH="$2"
DOWNLOAD_URL="$3"
MIN_VERSION="${4:-$VERSION}"
RELEASE_NOTES="${5:-See CHANGELOG.md for details.}"
OUTPUT_PATH="${6:-updates/appcast.json}"
PUBLISHED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

if [[ ! -f "${PKG_PATH}" ]]; then
  echo "Package file does not exist: ${PKG_PATH}" >&2
  exit 1
fi

SHA256="$(shasum -a 256 "${PKG_PATH}" | awk '{print $1}')"

mkdir -p "$(dirname "${OUTPUT_PATH}")"
cat > "${OUTPUT_PATH}" <<EOF
{
  "version": "${VERSION}",
  "minimumSupportedVersion": "${MIN_VERSION}",
  "downloadURL": "${DOWNLOAD_URL}",
  "releaseNotes": "${RELEASE_NOTES}",
  "publishedAt": "${PUBLISHED_AT}",
  "sha256": "${SHA256}"
}
EOF

echo "Wrote ${OUTPUT_PATH}"
