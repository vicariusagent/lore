#!/usr/bin/env bash
set -euo pipefail

VENDOR_DIR="vendor"
PDFJS_VERSION="6.3.289"
TESSERACT_VERSION="7.0.0"
TESSERACT_CORE_VERSION="7.0.0"
ENG_DATA_PACKAGE_VERSION="1.0.0"
ENG_DATA_MODEL_VERSION="4.0.0_best_int"
SHEETJS_VERSION="0.20.3"

mkdir -p "$VENDOR_DIR"
temp_file=""

cleanup() {
    if [[ -n "$temp_file" && -f "$temp_file" ]]; then
        rm -f "$temp_file"
    fi
}
trap cleanup EXIT

download() {
    local url="$1"
    local destination="$2"

    temp_file="$(mktemp "$VENDOR_DIR/.download.XXXXXX")"
    curl --fail --location --silent --show-error "$url" --output "$temp_file"
    mv "$temp_file" "$destination"
    temp_file=""
    echo "✓ $(basename "$destination")"
}

echo "Updating LORE vendor dependencies to the pinned releases..."

download "https://cdn.jsdelivr.net/npm/pdfjs-dist@${PDFJS_VERSION}/build/pdf.min.mjs" "$VENDOR_DIR/pdf.min.mjs"
download "https://cdn.jsdelivr.net/npm/pdfjs-dist@${PDFJS_VERSION}/build/pdf.worker.min.mjs" "$VENDOR_DIR/pdf.worker.min.mjs"

download "https://cdn.jsdelivr.net/npm/tesseract.js@${TESSERACT_VERSION}/dist/tesseract.min.js" "$VENDOR_DIR/tesseract.min.js"
download "https://cdn.jsdelivr.net/npm/tesseract.js@${TESSERACT_VERSION}/dist/worker.min.js" "$VENDOR_DIR/worker.min.js"
download "https://cdn.jsdelivr.net/npm/tesseract.js-core@${TESSERACT_CORE_VERSION}/tesseract-core-lstm.wasm.js" "$VENDOR_DIR/tesseract-core-lstm.wasm.js"

download "https://cdn.jsdelivr.net/npm/@tesseract.js-data/eng@${ENG_DATA_PACKAGE_VERSION}/${ENG_DATA_MODEL_VERSION}/eng.traineddata.gz" "$VENDOR_DIR/eng.traineddata.gz"

download "https://cdn.sheetjs.com/xlsx-${SHEETJS_VERSION}/package/dist/xlsx.full.min.js" "$VENDOR_DIR/xlsx.full.min.js"

echo "All pinned vendor dependencies were downloaded successfully."
