# 🎗️ Cancer Survey App

### `Cancer.ser` — A Comprehensive Cancer Screening & Health History Survey

**Developer:** [Raj Gautam](mailto:raj@cancer.ser) · **Project:** Cancer.ser · **Version:** 1.0.0 · **License:** MIT

---

![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows-blue)
![Python](https://img.shields.io/badge/python-3.7%2B-green)
![License](https://img.shields.io/badge/license-MIT-pink)
![Version](https://img.shields.io/badge/version-1.0.0-red)

---

## 📖 Overview

**Cancer Survey App** is a modern, cross-platform desktop application that delivers a **20-question cancer screening and health history survey**. Built with Python and Tkinter, it features a cinematic dark theme with animated backgrounds in green, pink, blue, and red accents. Each submission is automatically saved as a structured **JSON** file for easy analysis, archiving, and integration with research pipelines.

Designed for **patients, caregivers, healthcare professionals, and researchers**, the app prioritizes:

- 🔒 **Privacy-first** — all data stays on the local machine
- 🎨 **Cinematic UX** — smooth animations, dark theme, accessible typography
- 📊 **Structured Output** — clean JSON schema, ready for analytics
- 🌐 **Multilingual** — Hindi + English question wording
- ⚡ **Zero Configuration** — single command launch (`cancer`)

> ⚠️ **Disclaimer:** This application is for **informational and awareness purposes only**. It is **not** a substitute for professional medical advice, diagnosis, or treatment. Always consult a qualified healthcare provider.

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🩺 **20-Question Survey** | Structured across 4 medically-relevant sections |
| 🎨 **Cinematic Dark Theme** | Animated floating orbs in green, pink, blue, and red |
| 💾 **Auto JSON Save** | Every submission saved to `~/cancer_survey_results/` |
| 🔐 **Fully Offline** | No network calls, no telemetry, no cloud |
| 🚀 **Simple Command** | Launch with just `cancer` |
| 🌏 **Bilingual** | Hindi + English question text |
| 🖥️ **Cross-Platform** | Linux (.deb), macOS (.app), Windows (.cmd) |
| 🎛️ **Mixed Input Types** | Radio buttons, radio + text, multi-line text areas |
| 📱 **Responsive UI** | Resizable window, mouse-wheel scroll, adaptive layout |
| 🎁 **Desktop Integration** | App menu entry, icon, and shortcuts |

---

## 📋 Survey Structure

### Section 1 — Personal & Family Medical History
1. Personal cancer diagnosis history
2. Family cancer history (blood relatives)
3. Family member details & cancer type
4. Multiple family members with same cancer type
5. Early diagnosis (< 50 years) in family
6. Genetic testing (BRCA1, BRCA2, Lynch Syndrome)

### Section 2 — Lifestyle & Risk Factors
7. Tobacco / smoking status
8. Tobacco quantity & duration
9. Alcohol consumption per week
10. Occupational / environmental exposure
11. Physical activity level
12. HPV / Hepatitis B/C infection history

### Section 3 — Current Symptoms & Physical Changes
13. Unexplained weight loss (last 6 months)
14. New / unusual lumps
15. Mole or wound changes
16. Persistent cough / hoarseness / breathlessness
17. Bowel / bladder habit changes
18. Chronic fatigue unrelieved by rest

### Section 4 — Screening & Awareness
19. Last cancer screening (mammogram, Pap smear, colonoscopy, PSA)
20. Awareness of cancer symptoms & screening importance

---

## 📦 Installation

### 🐧 Linux (Debian / Ubuntu / Mint / Pop!_OS / Kali)

**One-line install:**

```bash
git clone https://github.com/rajgautam/cancer-survey.git
cd cancer-survey
chmod +x cancer.sh
./cancer.sh
```

**Or build & install the `.deb` manually:**

```bash
chmod +x build_deb.sh
./build_deb.sh
sudo apt install ./cancer-survey_1.0.0_all.deb
```

**Prerequisites:**
```bash
sudo apt install python3 python3-tk dpkg-dev
```

---

### 🍎 macOS (Intel & Apple Silicon)

```bash
chmod +x install_cancer_survey_mac.sh
./install_cancer_survey_mac.sh
```

**Prerequisites:**
- macOS 11 (Big Sur) or later
- Xcode Command Line Tools (script auto-installs)
- Homebrew (script auto-installs)

The installer creates a native **`Cancer Survey.app`** in `/Applications/`.

---

### 🪟 Windows (10 / 11)

1. Download `install.cmd` and `uninstall.cmd`
2. Place them in any folder (e.g., `C:\CancerSetup\`)
3. **Double-click `install.cmd`**
4. Follow the on-screen prompts

**Prerequisites:**
- Python 3.7+ installed from [python.org](https://www.python.org/downloads/)
- ⚠️ During Python install, check **"Add Python to PATH"** and **"tcl/tk and IDLE"**

---

## 🚀 Usage

### Launch the App

```bash
cancer
```

**Or launch from:**
- 🖥️ **Application Menu** → Search "Cancer Survey"
- 🖱️ **Desktop shortcut** (Windows / macOS)
- ⌨️ **Spotlight** (macOS): `⌘ + Space` → "Cancer Survey"

### Complete the Survey

1. Answer all 20 questions (Q1 is required)
2. Click **"सर्वेक्षण सबमिट करें"**
3. JSON file auto-saved
4. Optionally reset for a new survey

### View Results

**Linux / macOS:**
```bash
ls -lh ~/cancer_survey_results/
cat ~/cancer_survey_results/survey_*.json | python3 -m json.tool
```

**Windows (PowerShell):**
```powershell
Get-ChildItem $env:USERPROFILE\cancer_survey_results\*.json
explorer $env:USERPROFILE\cancer_survey_results
```

---

## 📁 JSON Output Schema

Each submission produces a **timestamped JSON file**:

```
~/cancer_survey_results/survey_YYYYMMDD_HHMMSS.json
```

### Example

```json
{
  "id": "survey_20251016_143022",
  "app": "cancer",
  "version": "1.0.0",
  "developer": "Raj Gautam",
  "project": "Cancer.ser",
  "timestamp": "2025-10-16 14:30:22",
  "summary": {
    "total_questions": 20,
    "answered": 18,
    "skipped": 2
  },
  "sections": [
    {
      "title": "व्यक्तिगत और पारिवारिक चिकित्सा इतिहास",
      "title_en": "Personal & Family Medical History",
      "answers": {
        "q1": {
          "question": "क्या आपको कभी किसी भी प्रकार के कैंसर का निदान हुआ है?",
          "answer": "हाँ",
          "details": "स्तन कैंसर, 45 वर्ष की आयु"
        },
        "q2": {
          "question": "क्या आपके किसी रक्त संबंधी को कैंसर हुआ है?",
          "answer": "हाँ",
          "details": ""
        }
      }
    }
  ],
  "footer": {
    "generator": "Cancer Survey App",
    "platform": "Linux",
    "python": "3.11.2"
  }
}
```

### Schema Reference

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique survey ID (`survey_YYYYMMDD_HHMMSS`) |
| `app` | string | App identifier (`cancer`) |
| `version` | string | Semantic version |
| `developer` | string | Author name |
| `timestamp` | string | ISO-like timestamp |
| `summary.total_questions` | int | Total question count (20) |
| `summary.answered` | int | Questions with non-empty answers |
| `summary.skipped` | int | Questions left blank |
| `sections[]` | array | Four section objects |
| `sections[].answers{}` | object | Map of question ID → answer object |
| `footer.platform` | string | OS platform |
| `footer.python` | string | Python version used |

---

## 🧰 Project Structure

```
cancer-survey/
├── cancer.sh                         # Linux installer (interactive)
├── build_deb.sh                      # Linux .deb builder
├── install_cancer_survey_mac.sh      # macOS installer
├── uninstall_cancer_survey_mac.sh    # macOS uninstaller
├── install.cmd                       # Windows installer
├── uninstall.cmd                     # Windows uninstaller
├── cancer_survey.py                  # Main application (shared)
├── README.md                         # This file
├── LICENSE                           # MIT License
└── CHANGELOG.md                      # Release notes
```

---

## 🗑️ Uninstalling

### Linux
```bash
sudo apt remove cancer-survey
# Or with full purge:
sudo apt purge cancer-survey
```

### macOS
```bash
chmod +x uninstall_cancer_survey_mac.sh
./uninstall_cancer_survey_mac.sh
```

### Windows
Double-click `uninstall.cmd`

> 💾 **Your JSON results are never deleted** on uninstall — they remain safe in `~/cancer_survey_results/` (or `%USERPROFILE%\cancer_survey_results\` on Windows).

---

## 🔒 Privacy & Security

- ✅ **100% Offline** — No network requests, ever
- ✅ **No Telemetry** — Zero analytics or tracking
- ✅ **No Cloud Storage** — Everything stays local
- ✅ **No Account Required** — Use immediately
- ✅ **Open Source** — Full source code auditable

Your responses are stored **only** on your own device, in a plain JSON file you fully control.

---

## 🛠️ Building from Source

### Linux (.deb)

```bash
./build_deb.sh
# Output: cancer-survey_1.0.0_all.deb
```

### macOS (.app)

```bash
./install_cancer_survey_mac.sh
# Output: /Applications/Cancer Survey.app
```

### Windows (.cmd launcher)

Run `install.cmd` — it writes the Python app and creates a `cancer.cmd` launcher.

---

## 🧪 Compatibility Matrix

| Platform | Version | Status |
|----------|---------|--------|
| Ubuntu | 20.04 / 22.04 / 24.04 | ✅ |
| Debian | 10 / 11 / 12 | ✅ |
| Linux Mint | 20 / 21 / 22 | ✅ |
| Pop!_OS | 20.04+ | ✅ |
| Kali Linux | 2022+ | ✅ |
| macOS | 11 Big Sur – 15 Sequoia | ✅ |
| macOS (Apple Silicon) | M1 / M2 / M3 | ✅ |
| Windows | 10 / 11 | ✅ |

**Requirements:**
- Python 3.7 or higher
- Tkinter (bundled with Python on most platforms)
- ~10 MB disk space

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. **Fork** the repository
2. **Create a branch**: `git checkout -b feature/amazing-feature`
3. **Commit**: `git commit -m 'Add amazing feature'`
4. **Push**: `git push origin feature/amazing-feature`
5. **Open a Pull Request**

### Guidelines
- Follow PEP 8 style
- Add comments for complex logic
- Update README if adding features
- Test on at least 2 platforms

---

## 📜 Changelog

### v1.0.0 — 2025-10-16
- 🎉 Initial release
- 📝 20-question survey across 4 sections
- 🎨 Cinematic dark theme with animated orbs
- 💾 JSON auto-save with structured schema
- 📦 Packages for Linux (.deb), macOS (.app), Windows (.cmd)
- 🌏 Bilingual (Hindi + English)

See [CHANGELOG.md](CHANGELOG.md) for the full history.

---

## 📄 License

This project is licensed under the **MIT License**.

```
MIT License

Copyright (c) 2025 Raj Gautam

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

See [LICENSE](LICENSE) for the full text.

---

## 👨‍💻 Author

**Raj Gautam**
- 🌐 Project: [Cancer.ser](https://cancer.ser)
- 📧 Email: [raj@cancer.ser](mailto:raj@cancer.ser)
- 💼 GitHub: [@rajgautam](https://github.com/rajgautam)

---

## 🙏 Acknowledgments

- 🎗️ All cancer patients, survivors, and their families
- 🩺 Healthcare professionals who reviewed the survey content
- 🌏 Open-source community (Python, Tkinter, Debian, Homebrew)

---

## 📞 Support

- 🐛 **Bug Reports:** [Open an issue](https://github.com/rajgautam/cancer-survey/issues)
- 💡 **Feature Requests:** [Start a discussion](https://github.com/rajgautam/cancer-survey/discussions)
- 📖 **Documentation:** [Wiki](https://github.com/rajgautam/cancer-survey/wiki)

---

<div align="center">

### 🎗️ You Are Not Alone. 💙

**Made with ❤️ by [Raj Gautam](https://cancer.ser)**

© 2025 Cancer.ser · All rights reserved

</div>
