#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <version> <output_dir>" >&2
  exit 1
fi

VERSION="$1"
OUTPUT_DIR="$2"
PROJECT="Voxt.xcodeproj"
SCHEME="Voxt"
DERIVED_DATA_DIR="${OUTPUT_DIR}/DerivedData"
APP_PATH="${DERIVED_DATA_DIR}/Build/Products/Release/Voxt.app"
PKG_PATH="${OUTPUT_DIR}/Voxt-${VERSION}.pkg"
ZIP_PATH="${OUTPUT_DIR}/Voxt-${VERSION}-macOS.zip"

mkdir -p "${OUTPUT_DIR}"

echo "Building ${SCHEME} (${VERSION})..."
xcodebuild \
  -project "${PROJECT}" \
  -scheme "${SCHEME}" \
  -configuration Release \
  -derivedDataPath "${DERIVED_DATA_DIR}" \
  clean build

if [[ ! -d "${APP_PATH}" ]]; then
  echo "Built app not found at ${APP_PATH}" >&2
  exit 1
fi

echo "Packaging installer..."
productbuild \
  --component "${APP_PATH}" /Applications \
  "${PKG_PATH}"

echo "Packaging app zip..."
ditto -c -k --sequesterRsrc --keepParent "${APP_PATH}" "${ZIP_PATH}"

echo "Created:"
echo "  ${PKG_PATH}"
echo "  ${ZIP_PATH}"
