#!/usr/bin/env bash
set -euo pipefail

VENDOR_DIR="vendor"

echo "🚀 Updating LORE vendor dependencies to latest stable releases..."

# Ensure target folder exists
mkdir -p "$VENDOR_DIR"

# PDF.js (Latest stable build via jsDelivr)
echo "→ Fetching latest PDF.js..."
curl -sSL "https://cdn.jsdelivr.net/npm/pdfjs-dist@latest/build/pdf.min.js" -o "$VENDOR_DIR/pdf.min.js"
curl -sSL "https://cdn.jsdelivr.net/npm/pdfjs-dist@latest/build/pdf.worker.min.js" -o "$VENDOR_DIR/pdf.worker.min.js"

# Tesseract.js & Core WASM (Latest releases via unpkg @latest)
echo "→ Fetching latest Tesseract.js scripts & WASM binary..."
curl -sSL "https://unpkg.com/tesseract.js@latest/dist/tesseract.min.js" -o "$VENDOR_DIR/tesseract.min.js"
curl -sSL "https://unpkg.com/tesseract.js@latest/dist/worker.min.js" -o "$VENDOR_DIR/worker.min.js"
curl -sSL "https://unpkg.com/tesseract.js-core@latest/tesseract-core.wasm.js" -o "$VENDOR_DIR/tesseract-core.wasm.js"

# Tesseract trained language model (Latest LSTM English dataset)
echo "→ Fetching latest English language model..."
curl -sSL "https://raw.githubusercontent.com/naptha/tessdata/gh-pages/4.0.0_best/eng.traineddata.gz" -o "$VENDOR_DIR/eng.traineddata.gz"

# SheetJS (Latest release via official CDN)
echo "→ Fetching latest SheetJS (xlsx)..."
curl -sSL "https://cdn.sheetjs.com/xlsx-latest/package/dist/xlsx.full.min.js" -o "$VENDOR_DIR/xlsx.full.min.js"

echo "✅ All vendor dependencies updated to latest binaries!"