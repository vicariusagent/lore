# Local OCR Record Extractor (LORE)

**LORE** (Local OCR Record Extractor) is a self-contained, 100% local web application for extracting structured tabular data from multi-page PDFs directly inside browser memory. It uses Optical Character Recognition (OCR)—technology that reads and recognizes text within document images—alongside native PDF text parsing to export records into **Excel (.xlsx)** workbooks or **CSV** files without sending data to external servers or cloud APIs.

All vendor libraries, WebAssembly (WASM) binaries, and OCR language models are pre-bundled directly within the repository—no setup scripts, package installations, or active internet connection required.

---

## Execution Modes & Browser Rules

Chromium-based browsers (Chrome, Edge, Brave, Arc) restrict Web Workers and WASM loading over `file://` URLs due to same-origin security policies. Depending on your engine choice and browser, launch LORE using one of the methods below:

### Option A: WASM OCR Mode (or Chromium Browsers) — Local Server Required

To use the browser-based WASM OCR engine or run the app in Chrome/Edge, serve the project folder over a local HTTP origin so the browser can execute local Web Worker scripts:

```bash
cd local-ocr-record-extractor
python3 -m http.server 8080
# Open http://localhost:8080 in Chrome, Edge, or Brave

```

### Option B: Native Vector Mode — Direct File Launch

If you are using **Native Vector Text Layer** mode, or opening the app in **Mozilla Firefox**, no local server is required. Simply double-click `index.html` or open it directly in your browser (`file:///.../index.html`).

---

## Upstream Dependencies & Verified Links

All dependencies are pre-populated in the `vendor/` directory. No external installations or downloads are necessary to run the app.

| Library / Asset | Version | Description | Project Home & GitHub |
| --- | --- | --- | --- |
| **PDF.js** | `Latest` (`pdfjs-dist`) | Canvas rendering & vector text extraction engine | [Official Site](https://mozilla.github.io/pdf.js/) • [GitHub Repository](https://www.google.com/search?q=https://github.com/mozilla/pdf.js) |
| **Tesseract.js** | `Latest` (`v5+`) | Pure JavaScript interface for OCR operations | [Official Site](https://tesseract.projectnaptha.com/) • [GitHub Repository](https://www.google.com/search?q=https://github.com/naptha/tesseract.js) |
| **Tesseract Core (WASM)** | `Latest` (`v5+`) | Compiled C++ Tesseract engine via WebAssembly | [GitHub Repository](https://github.com/naptha/tesseract.js-core) |
| **Tesseract Language Data** | `4.0.0_best` | Trained LSTM language model for English (`eng`) | [GitHub Data Repo](https://www.google.com/search?q=https://github.com/naptha/tesseract.js-data) |
| **SheetJS (xlsx)** | `Latest` (`xlsx-latest`) | Spreadsheet parser and `.xlsx` export builder | [Official Site](https://sheetjs.com/) • [GitHub Repository](https://github.com/SheetJS/sheetjs) |

---

## Updating Dependencies

To update pre-bundled vendor libraries directly to their latest upstream releases while maintaining offline readiness, execute the included update script:

```bash
chmod +x update-dependencies.sh
./update-dependencies.sh

```

*Note: The script dynamically pulls floating `@latest` releases from jsDelivr, unpkg, and SheetJS CDNs to keep local binaries current.*

---

## Repository Structure

```text
local-ocr-record-extractor/
├── index.html                  # UI, state engine, pre-flight validation & grid parser
├── README.md                   # System documentation & operating guide
├── update-dependencies.sh      # Fetch & update vendor files to latest releases
└── vendor/                     # Pre-bundled offline assets (no download needed)
    ├── eng.traineddata.gz      # English OCR language model dataset
    ├── pdf.min.js              # PDF.js main API script
    ├── pdf.worker.min.js       # PDF.js background worker thread
    ├── tesseract-core.wasm.js  # Tesseract WebAssembly engine binary
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