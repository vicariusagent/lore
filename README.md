# Local OCR Record Extractor (LORE)

**LORE** (Local OCR Record Extractor) is a self-contained, 100% local web application for extracting structured tabular data from multi-page PDFs directly inside browser memory. It uses Optical Character Recognition (OCR)—technology that reads and recognizes text within document images—alongside native PDF text parsing to export records into **Excel (.xlsx)** workbooks or **CSV** files without sending data to external servers or cloud APIs.

All vendor libraries, WebAssembly (WASM) binaries, and OCR language models are pre-bundled directly within the repository—no setup scripts, package installations, or active internet connection required.

---

## Execution Modes & Browser Rules

Serve LORE from a local HTTP origin in every browser. The current PDF.js release is an ES module, and the OCR engine uses local Web Workers and WebAssembly files; browsers restrict loading these assets from `file://` URLs.

```bash
cd local-ocr-record-extractor
python3 -m http.server 8080
# Open http://localhost:8080 in Chrome, Edge, Firefox, or another browser
```

---

## Upstream Dependencies & Verified Links

The versions below were the latest releases identified as of **August 31, 2026**. Runtime libraries and model files are pre-bundled under `vendor/`; LORE does not load them from a CDN while processing documents.

| Dependency | Pinned version and release date | What it provides |
| --- | --- | --- |
| [PDF.js / `pdfjs-dist`](https://github.com/mozilla/pdf.js/releases/tag/v6.3.289) | `6.3.289` — **2026-08-29** | PDF parsing, vector text extraction, and canvas rendering. This release uses the `.mjs` module build and worker. |
| [Tesseract.js](https://github.com/naptha/tesseract.js/releases/tag/v7.0.0) | `7.0.0` — **2025-12-15** | JavaScript OCR worker interface. The v7 release adds faster recognition builds and drops Node.js 14 support. |
| [Tesseract.js Core](https://github.com/naptha/tesseract.js-core/releases/tag/v7.0.0) | `7.0.0` — **2025-12-11** | WebAssembly OCR engine. The updater uses the LSTM build for compatibility with LORE's OEM 1 setting. |
| [English data package](https://www.npmjs.com/package/@tesseract.js-data/eng) | `@tesseract.js-data/eng@1.0.0`; model `4.0.0_best_int` — package published **2023** (upstream lists the year, not an exact date) | Integerized best English LSTM model distributed for Tesseract.js. |
| [SheetJS CE](https://docs.sheetjs.com/docs/getting-started/installation/standalone/) | `0.20.3` — **2024-07-12** | Spreadsheet workbook creation and `.xlsx` export. This release includes improved Numbers/ODS merge-cell parsing and NaN/infinity handling. |

---

## Updating Dependencies

`update-dependencies.sh` downloads the exact versions listed above and fails if a request returns an HTTP error. Updating the pins requires an internet connection; the app continues to process documents offline after the refreshed files are bundled.

The checked-in vendor files remain usable as a fallback until the updater is run. Run it once after pulling this update to replace those snapshots with the pinned versions shown above.

To update dependencies:

1. Check each upstream project's release notes and choose compatible, stable versions.
2. Change the version constants and asset URLs in `update-dependencies.sh`. Keep PDF.js and its worker on the same version, and keep Tesseract.js, its core, and its language model compatible.
3. Run the script from the project root:

   ```bash
   chmod +x update-dependencies.sh
   ./update-dependencies.sh
   ```

4. Verify the downloaded filenames match the paths in `index.html`, update the version and release-date table above, then check native PDF extraction, OCR, CSV, and XLSX export in a browser served over HTTP.

The updater writes each download to a temporary file and replaces the vendored file only after a successful download. Review dependency changes before committing the refreshed `vendor/` assets.

---

## Repository Structure

```text
local-ocr-record-extractor/
├── index.html                  # UI, state engine, pre-flight validation & grid parser
├── README.md                   # System documentation & operating guide
├── update-dependencies.sh      # Fetch pinned vendor releases
└── vendor/                     # Pre-bundled offline assets (no download needed)
    ├── eng.traineddata.gz      # English OCR language model dataset
    ├── pdf.min.mjs             # PDF.js ES module API script
    ├── pdf.worker.min.mjs      # PDF.js module worker
    ├── tesseract-core-lstm.wasm.js # Tesseract LSTM WebAssembly engine
    ├── tesseract.min.js        # Tesseract.js main script
    ├── worker.min.js           # Tesseract.js worker thread
    └── xlsx.full.min.js        # SheetJS standalone library

```

---

## Features & Technical Architecture

* **100% Local Processing:** Operates completely offline with zero network calls, tracking, or external API transmission.
* **Optical Character Recognition (OCR):** Translates visual pixels in scanned or image-based PDFs into selectable, structured spreadsheet text using local WebAssembly binaries.
* **Rectangular Grid Normalization:** Automatically pads sparse or uneven rows with empty strings (`""`) to guarantee uniform column counts in Excel.
* **Proportional Y-Tolerance Scaling:** Dynamic line-grouping algorithms (`Y_TOLERANCE = 6 * scale`) maintain consistent row alignment across different DPI render scales (1.5x–3.0x).
* **V8 RAM Optimization:** Immediately flushes active canvas bitmaps (`canvas.width = 0; canvas.height = 0`) after processing to trigger immediate browser memory reclamation.
* **UTF-8 Byte Order Mark (BOM):** Prepends `\uFEFF` to CSV exports for clean rendering of special characters and currency symbols (`$`, `€`, `£`) in Microsoft Excel.

---

## Processing Capabilities

| Metric | Native Vector Engine | WASM OCR Engine |
| --- | --- | --- |
| **Best For** | Born-digital PDFs with selectable text | Scanned documents, photos, or image-only PDFs |
| **Execution Method** | Direct `file://` or HTTP | Requires local HTTP server (`http://localhost:8080`) |
| **Processing Speed** | ~1–2 sec / 100 pages | ~1–4 sec / page (depends on selected DPI scale) |
| **Memory Footprint** | Low (~50 MB RAM) | Moderate (~1.5 GB – 3 GB RAM during active WASM jobs) |
| **Recommended Scope** | Large multi-page documents (1,000+ pgs) | Batch ranges (e.g., 1–25 pages) for peak memory safety |

---

## Operating Instructions

1. **Launch Application:**
* Open `http://localhost:8080` in Chrome, Edge, or Brave, **or**
* Double-click `index.html` to open directly in Firefox.


2. **Ingest Document:** Drag and drop a PDF into the drop zone. Pre-flight validation will automatically inspect the file for encryption, corruption, and page count limits.
3. **Choose Engine:**
* **Native Vector Text Layer:** For standard, text-selectable PDFs.
* **WASM OCR Engine:** For scanned documents or image PDFs.


4. **Set Parameters:** Specify page ranges if necessary (e.g., `1-5, 8`) and select your target export format (**Excel .xlsx** or **CSV**).
5. **Extract & Export:** Click **Process Document** to run the parser, then click **Export LORE Record** to download your structured spreadsheet.