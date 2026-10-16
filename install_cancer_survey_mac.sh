#!/bin/bash
# ============================================================
# Cancer Survey App - macOS Auto Installer
# Developer: Raj Gautam
# Website: Cancer.ser
# Supports: Intel & Apple Silicon (M1/M2/M3)
# ============================================================

set -e

# ---------- Colors ----------
GREEN='\033[0;32m'
PINK='\033[1;35m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

# ---------- Banner ----------
clear
echo -e "${GREEN}${BOLD}"
cat << "EOF"
  ██████╗ █████╗ ███╗   ██╗ ██████╗███████╗██████╗    ███████╗███████╗██████╗ 
 ██╔════╝██╔══██╗████╗  ██║██╔════╝██╔════╝██╔══██╗   ██╔════╝██╔════╝██╔══██╗
 ██║     ███████║██╔██╗ ██║██║     █████╗  ██████╔╝   ███████╗█████╗  ██████╔╝
 ██║     ██╔══██║██║╚██╗██║██║     ██╔══╝  ██╔══██╗   ╚════██║██╔══╝  ██╔══██╗
 ╚██████╗██║  ██║██║ ╚████║╚██████╗███████╗██║  ██║   ███████║███████╗██║  ██║
  ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝╚═╝  ╚═╝   ╚══════╝╚══════╝╚═╝  ╚═╝
EOF
echo -e "${NC}"
echo -e "${PINK}${BOLD}          🎗️  Cancer Survey App - macOS Installer  🎗️${NC}"
echo -e "${CYAN}          Developer: Raj Gautam  |  Cancer.ser${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo ""

# ---------- Detect macOS & Architecture ----------
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ This script is for macOS only.${NC}"
    exit 1
fi

MACOS_VERSION=$(sw_vers -productVersion)
ARCH=$(uname -m)
echo -e "${YELLOW}🔍 macOS Version: ${MACOS_VERSION}${NC}"
echo -e "${YELLOW}🖥️  Architecture: ${ARCH}$([ "$ARCH" = "arm64" ] && echo " (Apple Silicon)" || echo " (Intel)")${NC}"
echo ""

# ---------- Check Command Line Tools ----------
if ! xcode-select -p &> /dev/null; then
    echo -e "${YELLOW}⚠️  Xcode Command Line Tools not found. Installing...${NC}"
    xcode-select --install || true
    echo -e "${YELLOW}   Please complete the installation popup, then re-run this script.${NC}"
    exit 0
fi
echo -e "${GREEN}✅ Xcode Command Line Tools installed${NC}"

# ---------- Check / Install Homebrew ----------
if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}🍺 Homebrew not found. Installing...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add brew to PATH for Apple Silicon
    if [ "$ARCH" = "arm64" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        if ! grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
        fi
    fi
else
    echo -e "${GREEN}✅ Homebrew already installed: $(brew --version | head -1)${NC}"
fi

# ---------- Install Python 3 + Tkinter ----------
echo -e "${BLUE}📦 Installing Python 3 and Tkinter...${NC}"
brew install python-tk@3.12 2>/dev/null || brew install python-tk 2>/dev/null || brew install python-tk@3.11 2>/dev/null || true

# Ensure python3 is available
if ! command -v python3 &> /dev/null; then
    brew install python@3.12
fi

PY_VERSION=$(python3 --version)
echo -e "${GREEN}✅ ${PY_VERSION}${NC}"

# Verify tkinter
if ! python3 -c "import tkinter" &> /dev/null; then
    echo -e "${RED}❌ Tkinter missing. Trying alternate install...${NC}"
    brew install python-tk@3.12 2>/dev/null || brew install tcl-tk python-tk 2>/dev/null || true
    if ! python3 -c "import tkinter" &> /dev/null; then
        echo -e "${RED}❌ Could not install Tkinter. Please run: brew install python-tk${NC}"
        exit 1
    fi
fi
echo -e "${GREEN}✅ Tkinter ready${NC}"
echo ""

# ---------- Setup App Directories ----------
APP_SUPPORT="$HOME/Library/Application Support/CancerSurvey"
APP_BIN="$HOME/.local/bin"
LAUNCH_AGENTS="$HOME/Library/LaunchAgents"
APPLICATIONS_DIR="/Applications"

mkdir -p "$APP_SUPPORT" "$APP_BIN"

echo -e "${BLUE}📁 Installing to: ${APP_SUPPORT}${NC}"

# ---------- Create the App Python File ----------
cat > "$APP_SUPPORT/cancer_survey.py" << 'PYEOF'
"""
Cancer Survey Application (Cancer.ser)
Developer: Raj Gautam
Theme: Cinematic Dark with Green, Pink, Blue, Red accents
macOS Edition
"""

import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
import json
from datetime import datetime
import math
import os

BG_DARK = "#0b0f17"
CARD_BG = "#121928"
CARD_BG_LIGHT = "#1a2333"
GREEN = "#00c9a7"
GREEN_LIGHT = "#6ef0d0"
PINK = "#ff6b9d"
PINK_LIGHT = "#ff9ec7"
BLUE = "#4a9eff"
BLUE_LIGHT = "#7cb9ff"
RED = "#ff4d6d"
RED_LIGHT = "#ff7a8a"
TEXT_PRIMARY = "#eef5ff"
TEXT_SECONDARY = "#a8bdd4"
BORDER_COLOR = "#2a3548"

SECTIONS = [
    {
        "title": "व्यक्तिगत और पारिवारिक चिकित्सा इतिहास",
        "icon": "👤",
        "color": GREEN,
        "questions": [
            {"id": "q1", "text": "1. क्या आपको कभी किसी भी प्रकार के कैंसर का निदान हुआ है?",
             "type": "radio_with_text", "options": ["हाँ", "नहीं"],
             "extra_placeholder": "यदि हाँ, तो कैंसर का प्रकार और निदान के समय उम्र लिखें",
             "required": True},
            {"id": "q2", "text": "2. क्या आपके किसी रक्त संबंधी को कैंसर हुआ है?",
             "type": "radio", "options": ["हाँ", "नहीं", "मुझे नहीं पता"]},
            {"id": "q3", "text": "3. यदि परिवार में कैंसर का इतिहास है, तो किस रिश्तेदार को और किस प्रकार का कैंसर हुआ?",
             "type": "text_area", "placeholder": "लागू होने पर लिखें..."},
            {"id": "q4", "text": "4. क्या परिवार में एक से अधिक रिश्तेदारों को एक ही प्रकार का कैंसर हुआ है?",
             "type": "radio", "options": ["हाँ", "नहीं", "मुझे नहीं पता"]},
            {"id": "q5", "text": "5. क्या परिवार में किसी को 50 वर्ष से पहले कैंसर का निदान हुआ था?",
             "type": "radio", "options": ["हाँ", "नहीं", "मुझे नहीं पता"]},
            {"id": "q6", "text": "6. क्या आपने जेनेटिक टेस्ट (BRCA1, BRCA2, Lynch) कराया है?",
             "type": "radio", "options": ["हाँ", "नहीं", "हाँ, और परिणाम सकारात्मक थे"]}
        ]
    },
    {
        "title": "जीवनशैली और जोखिम कारक",
        "icon": "❤️",
        "color": PINK,
        "questions": [
            {"id": "q7", "text": "7. आपकी तंबाकू/धूम्रपान की स्थिति क्या है?",
             "type": "radio", "options": ["कभी नहीं किया", "पहले करता था, अब छोड़ दिया", "वर्तमान में सेवन करता हूँ"]},
            {"id": "q8", "text": "8. यदि सेवन करते हैं, तो प्रतिदिन मात्रा और वर्ष?",
             "type": "text_area", "placeholder": "जैसे: 10 सिगरेट प्रतिदिन, 15 वर्षों से"},
            {"id": "q9", "text": "9. सप्ताह में औसतन कितनी बार शराब का सेवन?",
             "type": "radio", "options": ["बिल्कुल नहीं", "1 से 7 ड्रिंक्स", "8 या अधिक ड्रिंक्स"]},
            {"id": "q10", "text": "10. क्या आप हानिकारक रसायनों/रेडिएशन के संपर्क में हैं?",
             "type": "radio", "options": ["हाँ", "नहीं", "मुझे यकीन नहीं"]},
            {"id": "q11", "text": "11. आपका शारीरिक गतिविधि का स्तर?",
             "type": "radio", "options": ["निष्क्रिय", "मध्यम", "अत्यधिक सक्रिय"]},
            {"id": "q12", "text": "12. क्या आपको कभी HPV या हेपेटाइटिस बी/सी हुआ?",
             "type": "radio", "options": ["हाँ", "नहीं", "मुझे नहीं पता"]}
        ]
    },
    {
        "title": "वर्तमान लक्षण और शारीरिक बदलाव",
        "icon": "🔬",
        "color": BLUE,
        "questions": [
            {"id": "q13", "text": "13. पिछले 6 महीनों में अचानक वजन में भारी कमी?", "type": "radio", "options": ["हाँ", "नहीं"]},
            {"id": "q14", "text": "14. शरीर में कोई नई, असामान्य या सख्त गांठ?", "type": "radio", "options": ["हाँ", "नहीं"]},
            {"id": "q15", "text": "15. तिल/मस्से में बदलाव या घाव जो ठीक नहीं हो रहा?", "type": "radio", "options": ["हाँ", "नहीं"]},
            {"id": "q16", "text": "16. 3-4 सप्ताह से अधिक खांसी, आवाज में भारीपन, सांस फूलना?", "type": "radio", "options": ["हाँ", "नहीं"]},
            {"id": "q17", "text": "17. मल-मूत्र त्यागने की आदतों में लंबा बदलाव?", "type": "radio", "options": ["हाँ", "नहीं"]},
            {"id": "q18", "text": "18. लगातार अत्यधिक थकान जो आराम से ठीक न हो?", "type": "radio", "options": ["हाँ", "नहीं"]}
        ]
    },
    {
        "title": "नियमित स्क्रीनिंग और जागरूकता",
        "icon": "🛡️",
        "color": RED,
        "questions": [
            {"id": "q19", "text": "19. पिछली बार कैंसर स्क्रीनिंग कब करवाई?",
             "type": "radio", "options": ["1 वर्ष के भीतर", "1-3 वर्ष", "3+ वर्ष", "कभी नहीं"]},
            {"id": "q20", "text": "20. क्या आप कैंसर के लक्षणों और स्क्रीनिंग के बारे में जागरूक हैं?",
             "type": "radio", "options": ["पूरी तरह जागरूक", "बुनियादी जानकारी", "जानकारी नहीं"]}
        ]
    }
]


class CancerSurveyApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Cancer.ser | कैंसर सर्वेक्षण - Raj Gautam")
        self.root.configure(bg=BG_DARK)
        self.root.geometry("1000x750")
        self.root.minsize(800, 600)
        self.center_window(1000, 750)

        self.answers = {}
        self.radio_vars = {}
        self.extra_text_entries = {}
        self.text_areas = {}
        self.animation_step = 0
        self.animating = True

        # macOS menu bar
        self.setup_menu()

        self.setup_styles()
        self.create_main_layout()
        self.build_header()
        self.build_progress_bar()
        self.build_scrollable_form()
        self.build_footer()

        self.animate_background()

    def setup_menu(self):
        """Native macOS menu bar."""
        menubar = tk.Menu(self.root)

        # App menu (macOS style)
        app_menu = tk.Menu(menubar, tearoff=0)
        app_menu.add_command(label="About Cancer Survey",
                             command=self.show_about)
        app_menu.add_separator()
        app_menu.add_command(label="Quit", command=self.on_closing,
                             accelerator="Cmd+Q")
        menubar.add_cascade(label="Cancer Survey", menu=app_menu)

        # Help menu
        help_menu = tk.Menu(menubar, tearoff=0)
        help_menu.add_command(label="Open Results Folder",
                              command=self.open_results_folder)
        help_menu.add_command(label="About Developer",
                              command=self.show_about)
        menubar.add_cascade(label="Help", menu=help_menu)

        self.root.config(menu=menubar)

    def show_about(self):
        messagebox.showinfo(
            "About Cancer Survey",
            "🎗️  Cancer Survey Application\n"
            "Version 1.0 (macOS Edition)\n\n"
            "A comprehensive 20-question survey for cancer screening,\n"
            "risk factors, symptoms, and awareness.\n\n"
            "💻 Developed by: Raj Gautam\n"
            "🌐 Project: Cancer.ser\n"
            "🎨 Theme: Cinematic Dark (Green • Pink • Blue • Red)"
        )

    def open_results_folder(self):
        folder = os.path.expanduser("~/cancer_survey_results")
        os.makedirs(folder, exist_ok=True)
        os.system(f'open "{folder}"')

    def center_window(self, width, height):
        screen_w = self.root.winfo_screenwidth()
        screen_h = self.root.winfo_screenheight()
        x = (screen_w - width) // 2
        y = (screen_h - height) // 2
        self.root.geometry(f"{width}x{height}+{x}+{y}")

    def setup_styles(self):
        style = ttk.Style()
        # Use 'aqua' theme on macOS for native scrollbar, but override colors
        try:
            style.theme_use("clam")
        except:
            pass
        style.configure("Dark.Vertical.TScrollbar",
                        background=CARD_BG_LIGHT, troughcolor=BG_DARK,
                        bordercolor=BG_DARK, arrowcolor=GREEN,
                        darkcolor=CARD_BG_LIGHT, lightcolor=CARD_BG_LIGHT)
        style.map("Dark.Vertical.TScrollbar", background=[("active", GREEN)])

    def create_main_layout(self):
        self.bg_canvas = tk.Canvas(self.root, bg=BG_DARK, highlightthickness=0)
        self.bg_canvas.place(x=0, y=0, relwidth=1, relheight=1)

        self.main_card = tk.Frame(self.root, bg=CARD_BG,
                                  highlightbackground=BORDER_COLOR,
                                  highlightthickness=1)
        self.main_card.place(relx=0.5, rely=0.5, anchor="center",
                             relwidth=0.92, relheight=0.94)

        self.inner_frame = tk.Frame(self.main_card, bg=CARD_BG)
        self.inner_frame.pack(fill="both", expand=True, padx=30, pady=20)

    def build_header(self):
        header = tk.Frame(self.inner_frame, bg=CARD_BG)
        header.pack(fill="x", pady=(0, 15))

        badge = tk.Label(header, text="🎗️  कैंसर जागरूकता सर्वेक्षण  ",
                         font=("Helvetica", 11, "bold"),
                         bg="#0f2a24", fg=GREEN_LIGHT, padx=15, pady=6)
        badge.pack(pady=(0, 8))

        title = tk.Label(header, text="🩺  कैंसर स्क्रीनिंग एवं स्वास्थ्य इतिहास",
                         font=("Helvetica", 22, "bold"),
                         bg=CARD_BG, fg=GREEN_LIGHT)
        title.pack(pady=(4, 2))

        subtitle = tk.Label(header, text="20 प्रश्न  •  गोपनीय  •  सुरक्षित",
                            font=("Helvetica", 12),
                            bg=CARD_BG, fg=TEXT_SECONDARY)
        subtitle.pack()

        dev = tk.Label(header, text="💻  Developed by Raj Gautam  •  macOS Edition",
                       font=("Helvetica", 9, "italic"),
                       bg=CARD_BG, fg=PINK_LIGHT)
        dev.pack(pady=(6, 0))

        tk.Frame(header, bg=BORDER_COLOR, height=1).pack(fill="x", pady=(10, 0))

    def build_progress_bar(self):
        progress_frame = tk.Frame(self.inner_frame, bg=CARD_BG)
        progress_frame.pack(fill="x", pady=(0, 12))

        self.progress_canvas = tk.Canvas(progress_frame, height=6,
                                         bg=CARD_BG, highlightthickness=0)
        self.progress_canvas.pack(fill="x")

        self.root.after(200, lambda: self.draw_progress_bar(0.75))

    def draw_progress_bar(self, fraction):
        self.progress_canvas.delete("all")
        width = self.progress_canvas.winfo_width()
        if width < 10:
            width = 800
        height = 6
        segments = 4
        gap = 8
        seg_width = (width - (gap * (segments - 1))) / segments
        colors = [GREEN, PINK, BLUE, RED]
        for i in range(segments):
            x1 = i * (seg_width + gap)
            x2 = x1 + seg_width
            color = colors[i] if (i / segments) < fraction else BORDER_COLOR
            self.progress_canvas.create_rectangle(x1, 0, x2, height,
                                                  fill=color, outline=color)

    def build_scrollable_form(self):
        container = tk.Frame(self.inner_frame, bg=CARD_BG)
        container.pack(fill="both", expand=True)

        self.form_canvas = tk.Canvas(container, bg=CARD_BG, highlightthickness=0)
        self.form_canvas.pack(side="left", fill="both", expand=True)

        scrollbar = ttk.Scrollbar(container, orient="vertical",
                                  command=self.form_canvas.yview,
                                  style="Dark.Vertical.TScrollbar")
        scrollbar.pack(side="right", fill="y")
        self.form_canvas.configure(yscrollcommand=scrollbar.set)

        self.form_frame = tk.Frame(self.form_canvas, bg=CARD_BG)
        self.form_canvas_window = self.form_canvas.create_window(
            (0, 0), window=self.form_frame, anchor="nw")

        self.form_frame.bind("<Configure>", self.on_form_configure)
        self.form_canvas.bind("<Configure>", self.on_canvas_configure)

        # macOS trackpad/mouse scrolling
        self.form_canvas.bind_all("<MouseWheel>", self.on_mousewheel)
        self.form_canvas.bind_all("<Button-4>", self.on_mousewheel)
        self.form_canvas.bind_all("<Button-5>", self.on_mousewheel)

        self.build_all_sections()
        self.build_action_buttons()

    def build_all_sections(self):
        for section in SECTIONS:
            self.build_section(section)

    def build_section(self, section):
        section_frame = tk.Frame(self.form_frame, bg=CARD_BG)
        section_frame.pack(fill="x", pady=(0, 15), padx=5)

        header_frame = tk.Frame(section_frame, bg=CARD_BG)
        header_frame.pack(fill="x", pady=(0, 10))

        icon_label = tk.Label(header_frame, text=section["icon"],
                              font=("Apple Color Emoji", 16),
                              bg=section["color"], fg=BG_DARK,
                              width=3, height=1)
        icon_label.pack(side="left", padx=(0, 10))

        title_label = tk.Label(header_frame, text=section["title"],
                               font=("Helvetica", 15, "bold"),
                               bg=CARD_BG, fg=section["color"])
        title_label.pack(side="left")

        for q in section["questions"]:
            self.build_question(section_frame, q, section["color"])

        tk.Frame(section_frame, bg=BORDER_COLOR, height=1).pack(fill="x", pady=(10, 0))

    def build_question(self, parent, question, color):
        q_frame = tk.Frame(parent, bg=CARD_BG)
        q_frame.pack(fill="x", pady=(8, 4), padx=(10, 0))

        q_label = tk.Label(q_frame, text=question["text"],
                           font=("Helvetica", 12, "bold"),
                           bg=CARD_BG, fg=TEXT_PRIMARY,
                           wraplength=750, justify="left", anchor="w")
        q_label.pack(fill="x", pady=(0, 6))

        q_type = question["type"]

        if q_type == "radio":
            self.build_radio_options(q_frame, question, color)

        elif q_type == "radio_with_text":
            self.build_radio_options(q_frame, question, color)
            extra_var = tk.StringVar()
            extra_entry = tk.Entry(q_frame, textvariable=extra_var,
                                   font=("Helvetica", 11),
                                   bg=CARD_BG_LIGHT, fg=TEXT_SECONDARY,
                                   insertbackground=GREEN, relief="flat",
                                   highlightthickness=1,
                                   highlightbackground=BORDER_COLOR,
                                   highlightcolor=color)
            extra_entry.pack(fill="x", pady=(6, 0), padx=(0, 5), ipady=5)
            ph = question.get("extra_placeholder", "")
            extra_entry.insert(0, ph)

            def on_focus_in(event, e=extra_entry, p=ph):
                if e.get() == p:
                    e.delete(0, tk.END)
                    e.config(fg=TEXT_PRIMARY)

            def on_focus_out(event, e=extra_entry, p=ph):
                if not e.get().strip():
                    e.insert(0, p)
                    e.config(fg=TEXT_SECONDARY)

            extra_entry.bind("<FocusIn>", on_focus_in)
            extra_entry.bind("<FocusOut>", on_focus_out)
            self.extra_text_entries[question["id"]] = (extra_entry, extra_var)

        elif q_type == "text_area":
            text_area = scrolledtext.ScrolledText(q_frame, height=3,
                                                  font=("Helvetica", 11),
                                                  bg=CARD_BG_LIGHT, fg=TEXT_PRIMARY,
                                                  insertbackground=GREEN,
                                                  relief="flat",
                                                  highlightthickness=1,
                                                  highlightbackground=BORDER_COLOR,
                                                  highlightcolor=color,
                                                  wrap="word")
            text_area.pack(fill="x", pady=(4, 0), padx=(0, 5))
            self.text_areas[question["id"]] = text_area

    def build_radio_options(self, parent, question, color):
        var = tk.StringVar()
        self.radio_vars[question["id"]] = var
        options_frame = tk.Frame(parent, bg=CARD_BG)
        options_frame.pack(fill="x", pady=(0, 4))
        for option in question["options"]:
            rb = tk.Radiobutton(options_frame, text=option, variable=var,
                                value=option, font=("Helvetica", 11),
                                bg=CARD_BG, fg=TEXT_SECONDARY,
                                selectcolor=CARD_BG_LIGHT,
                                activebackground=CARD_BG,
                                activeforeground=TEXT_PRIMARY,
                                highlightthickness=0, bd=0,
                                padx=8, pady=4, cursor="hand2")
            rb.pack(side="left", padx=(0, 15))

    def build_action_buttons(self):
        btn_frame = tk.Frame(self.form_frame, bg=CARD_BG)
        btn_frame.pack(fill="x", pady=(20, 10), padx=5)

        reset_btn = tk.Button(btn_frame, text="↺  रीसेट करें",
                              font=("Helvetica", 12, "bold"),
                              bg=CARD_BG_LIGHT, fg=TEXT_SECONDARY,
                              activebackground=BORDER_COLOR,
                              activeforeground=TEXT_PRIMARY,
                              relief="flat", bd=0, padx=25, pady=10,
                              cursor="hand2", command=self.reset_form)
        reset_btn.pack(side="left", padx=(0, 10))

        submit_btn = tk.Button(btn_frame, text="✈  सर्वेक्षण सबमिट करें",
                               font=("Helvetica", 13, "bold"),
                               bg=GREEN, fg=BG_DARK,
                               activebackground=GREEN_LIGHT,
                               activeforeground=BG_DARK,
                               relief="flat", bd=0, padx=35, pady=10,
                               cursor="hand2", command=self.submit_survey)
        submit_btn.pack(side="left", fill="x", expand=True)

        privacy = tk.Label(self.form_frame,
                           text="🔒  आपके उत्तर पूरी तरह गोपनीय हैं।",
                           font=("Helvetica", 9), bg=CARD_BG, fg=TEXT_SECONDARY)
        privacy.pack(pady=(5, 0))

    def build_footer(self):
        footer = tk.Frame(self.inner_frame, bg=CARD_BG)
        footer.pack(fill="x", side="bottom", pady=(8, 0))
        tk.Frame(footer, bg=BORDER_COLOR, height=1).pack(fill="x", pady=(0, 6))
        tk.Label(footer,
                 text="💻 Designed & Developed with ❤️ by Raj Gautam  •  Cancer.ser",
                 font=("Helvetica", 9), bg=CARD_BG, fg=TEXT_SECONDARY).pack()

    def on_form_configure(self, event):
        self.form_canvas.configure(scrollregion=self.form_canvas.bbox("all"))

    def on_canvas_configure(self, event):
        self.form_canvas.itemconfig(self.form_canvas_window, width=event.width)

    def on_mousewheel(self, event):
        # macOS uses event.delta (trackpad-friendly)
        if event.num == 5 or event.delta < 0:
            self.form_canvas.yview_scroll(1, "units")
        elif event.num == 4 or event.delta > 0:
            self.form_canvas.yview_scroll(-1, "units")

    def submit_survey(self):
        for section in SECTIONS:
            for q in section["questions"]:
                if q.get("required"):
                    var = self.radio_vars.get(q["id"])
                    if var and not var.get():
                        messagebox.showwarning("अपूर्ण उत्तर",
                                               f"कृपया अनिवार्य प्रश्न का उत्तर दें:\n\n{q['text']}")
                        return

        self.answers = {}
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        for section in SECTIONS:
            for q in section["questions"]:
                qid = q["id"]
                qtype = q["type"]
                if qtype == "radio":
                    self.answers[qid] = self.radio_vars[qid].get() or "उत्तर नहीं दिया"
                elif qtype == "radio_with_text":
                    radio_val = self.radio_vars[qid].get() or "उत्तर नहीं दिया"
                    extra_entry, _ = self.extra_text_entries.get(qid, (None, None))
                    extra_val = ""
                    if extra_entry:
                        val = extra_entry.get()
                        ph = q.get("extra_placeholder", "")
                        if val != ph:
                            extra_val = val
                    self.answers[qid] = {"answer": radio_val, "details": extra_val}
                elif qtype == "text_area":
                    w = self.text_areas.get(qid)
                    self.answers[qid] = w.get("1.0", "end-1c").strip() if w else ""

        summary = (f"धन्यवाद! आपका सर्वेक्षण सफलतापूर्वक सबमिट हो गया है।\n\n"
                   f"📅 दिनांक: {timestamp}\n"
                   f"✅ उत्तर दिए गए: {self.count_answered()}/20\n\n"
                   f"आप अकेले नहीं हैं। 💙")
        messagebox.showinfo("सर्वेक्षण सबमिट", summary)

        self.save_to_file(timestamp)

        if messagebox.askyesno("नया सर्वेक्षण", "क्या आप नया सर्वेक्षण शुरू करना चाहेंगे?"):
            self.reset_form()

    def count_answered(self):
        count = 0
        for section in SECTIONS:
            for q in section["questions"]:
                qid = q["id"]
                qtype = q["type"]
                if qtype == "radio":
                    if self.radio_vars.get(qid) and self.radio_vars[qid].get():
                        count += 1
                elif qtype == "radio_with_text":
                    if self.radio_vars.get(qid) and self.radio_vars[qid].get():
                        count += 1
                elif qtype == "text_area":
                    w = self.text_areas.get(qid)
                    if w and w.get("1.0", "end-1c").strip():
                        count += 1
        return count

    def save_to_file(self, timestamp):
        try:
            home = os.path.expanduser("~")
            out_dir = os.path.join(home, "cancer_survey_results")
            os.makedirs(out_dir, exist_ok=True)
            filename = os.path.join(out_dir,
                                    f"cancer_survey_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json")
            data = {"survey": "Cancer.ser Survey",
                    "developer": "Raj Gautam",
                    "platform": "macOS",
                    "timestamp": timestamp,
                    "answers": self.answers}
            with open(filename, "w", encoding="utf-8") as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            messagebox.showinfo("सहेजा गया", f"परिणाम सहेजा गया:\n{filename}")
        except Exception as e:
            messagebox.showerror("फ़ाइल त्रुटि", f"परिणाम सहेजने में त्रुटि:\n{str(e)}")

    def reset_form(self):
        for var in self.radio_vars.values():
            var.set("")
        for qid, (entry, var) in self.extra_text_entries.items():
            ph = ""
            for section in SECTIONS:
                for q in section["questions"]:
                    if q["id"] == qid:
                        ph = q.get("extra_placeholder", "")
            entry.delete(0, tk.END)
            entry.insert(0, ph)
            entry.config(fg=TEXT_SECONDARY)
            var.set("")
        for widget in self.text_areas.values():
            widget.delete("1.0", tk.END)
        self.form_canvas.yview_moveto(0)

    def animate_background(self):
        if not self.animating:
            return
        self.animation_step += 0.02
        self.bg_canvas.delete("orb")
        width = self.bg_canvas.winfo_width() or 1000
        height = self.bg_canvas.winfo_height() or 750

        orbs = [
            (width * 0.15 + math.sin(self.animation_step) * 60,
             height * 0.1 + math.cos(self.animation_step * 0.7) * 40, 120, GREEN),
            (width * 0.85 + math.cos(self.animation_step * 0.8) * 70,
             height * 0.85 + math.sin(self.animation_step * 0.6) * 50, 140, PINK),
            (width * 0.6 + math.sin(self.animation_step * 0.5) * 80,
             height * 0.4 + math.cos(self.animation_step * 0.9) * 60, 100, BLUE),
            (width * 0.2 + math.cos(self.animation_step * 0.7) * 50,
             height * 0.75 + math.sin(self.animation_step * 0.8) * 55, 90, RED),
        ]
        for x, y, radius, color in orbs:
            for i in range(8, 0, -1):
                r = radius * i / 8
                blended = self.blend_colors(color, BG_DARK, i / 8)
                self.bg_canvas.create_oval(x - r, y - r, x + r, y + r,
                                           fill=blended, outline="", tags="orb")
        self.root.after(50, self.animate_background)

    def blend_colors(self, color1, color2, ratio):
        r1, g1, b1 = int(color1[1:3], 16), int(color1[3:5], 16), int(color1[5:7], 16)
        r2, g2, b2 = int(color2[1:3], 16), int(color2[3:5], 16), int(color2[5:7], 16)
        r = int(r1 * ratio + r2 * (1 - ratio))
        g = int(g1 * ratio + g2 * (1 - ratio))
        b = int(b1 * ratio + b2 * (1 - ratio))
        return f"#{r:02x}{g:02x}{b:02x}"

    def on_closing(self):
        self.animating = False
        self.root.destroy()


def main():
    root = tk.Tk()
    app = CancerSurveyApp(root)
    root.protocol("WM_DELETE_WINDOW", app.on_closing)
    root.mainloop()


if __name__ == "__main__":
    main()
PYEOF

chmod +x "$APP_SUPPORT/cancer_survey.py"
echo -e "${GREEN}✅ Python application installed${NC}"

# ---------- Create CLI Launcher ----------
LAUNCHER="$APP_BIN/cancer-survey"
cat > "$LAUNCHER" << 'LAUNCHER_EOF'
#!/bin/bash
PYTHON_BIN=$(command -v python3)
if [ -z "$PYTHON_BIN" ]; then
    PYTHON_BIN="/opt/homebrew/bin/python3"
fi
"$PYTHON_BIN" "$HOME/Library/Application Support/CancerSurvey/cancer_survey.py" "$@"
LAUNCHER_EOF

chmod +x "$LAUNCHER"
echo -e "${GREEN}✅ CLI launcher: cancer-survey${NC}"

# ---------- Create macOS .app Bundle ----------
APP_BUNDLE="$APPLICATIONS_DIR/Cancer Survey.app"
APP_MACOS="$APP_BUNDLE/Contents/MacOS"
APP_RESOURCES="$APP_BUNDLE/Contents/Resources"

# Check if /Applications is writable
if [ ! -w "$APPLICATIONS_DIR" ]; then
    echo -e "${YELLOW}⚠️  /Applications is not writable. Installing to ~/Applications instead.${NC}"
    APP_BUNDLE="$HOME/Applications/Cancer Survey.app"
    mkdir -p "$HOME/Applications"
    APP_MACOS="$APP_BUNDLE/Contents/MacOS"
    APP_RESOURCES="$APP_BUNDLE/Contents/Resources"
fi

mkdir -p "$APP_MACOS" "$APP_RESOURCES"

# Info.plist
cat > "$APP_BUNDLE/Contents/Info.plist" << 'PLIST_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>Cancer Survey</string>
    <key>CFBundleDisplayName</key>
    <string>Cancer Survey</string>
    <key>CFBundleIdentifier</key>
    <string>com.rajgautam.cancersurvey</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleExecutable</key>
    <string>CancerSurvey</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.13</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSRequiresAquaSystemAppearance</key>
    <false/>
    <key>NSHumanReadableCopyright</key>
    <string>© 2025 Raj Gautam · Cancer.ser</string>
</dict>
</plist>
PLIST_EOF

# Main executable inside the .app
cat > "$APP_MACOS/CancerSurvey" << 'APP_EXEC_EOF'
#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_SUPPORT="$HOME/Library/Application Support/CancerSurvey"
PYTHON_BIN=$(command -v python3)
if [ -z "$PYTHON_BIN" ]; then
    for p in /opt/homebrew/bin/python3 /usr/local/bin/python3 /usr/bin/python3; do
        [ -x "$p" ] && PYTHON_BIN="$p" && break
    done
fi
exec "$PYTHON_BIN" "$APP_SUPPORT/cancer_survey.py"
APP_EXEC_EOF

chmod +x "$APP_MACOS/CancerSurvey"

# ---------- Generate a Simple Icon (using sips/Python, no external deps) ----------
# Create a simple colored square PNG with Python + Tkinter's PhotoImage
python3 - << 'ICON_GEN_EOF' 2>/dev/null || true
import os
try:
    import tkinter as tk
    root = tk.Tk()
    root.withdraw()
    # Create a 512x512 icon using tkinter PhotoImage
    size = 512
    img = tk.PhotoImage(width=size, height=size)
    # Fill with a dark background
    img.put("#0b0f17", to=(0, 0, size, size))
    # Green circle
    for y in range(size):
        for x in range(size):
            dx, dy = x - size//2, y - size//2
            d = (dx*dx + dy*dy) ** 0.5
            if d < size * 0.42:
                # Gradient from green to pink
                r = int(0x00 + (0xff - 0x00) * (y / size))
                g = int(0xc9 + (0x6b - 0xc9) * (x / size))
                b = int(0xa7 + (0x9d - 0xa7) * (d / (size * 0.42)))
                color = f"#{r:02x}{g:02x}{b:02x}"
                img.put(color, to=(x, y, x+1, y+1))
    icon_path = os.path.expanduser("~/.cache/cancer_survey_icon.png")
    os.makedirs(os.path.dirname(icon_path), exist_ok=True)
    try:
        img.write(icon_path, format="png")
    except:
        pass
    root.destroy()
except Exception:
    pass
ICON_GEN_EOF

# Copy icon if generated
ICON_SRC="$HOME/.cache/cancer_survey_icon.png"
if [ -f "$ICON_SRC" ]; then
    cp "$ICON_SRC" "$APP_RESOURCES/AppIcon.png"
    # Create .icns (best-effort)
    if command -v sips &> /dev/null && command -v iconutil &> /dev/null; then
        ICONSET="$APP_RESOURCES/AppIcon.iconset"
        mkdir -p "$ICONSET"
        for s in 16 32 64 128 256 512; do
            sips -z $s $s "$ICON_SRC" --out "$ICONSET/icon_${s}x${s}.png" &>/dev/null || true
            sips -z $((s*2)) $((s*2)) "$ICON_SRC" --out "$ICONSET/icon_${s}x${s}@2x.png" &>/dev/null || true
        done
        iconutil -c icns "$ICONSET" -o "$APP_RESOURCES/AppIcon.icns" &>/dev/null || true
        rm -rf "$ICONSET"
    fi
fi

echo -e "${GREEN}✅ .app bundle created: ${APP_BUNDLE}${NC}"

# ---------- Add to PATH (zsh/bash) ----------
add_to_path() {
    local rc_file="$1"
    if [ -f "$rc_file" ] || [ "$rc_file" = "$HOME/.zshrc" ]; then
        if ! grep -q 'CancerSurvey installer' "$rc_file" 2>/dev/null; then
            echo '' >> "$rc_file"
            echo '# Added by CancerSurvey installer' >> "$rc_file"
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc_file"
            echo -e "${YELLOW}⚠️  Added ~/.local/bin to PATH in $rc_file${NC}"
        fi
    fi
}

add_to_path "$HOME/.zshrc"
[ -f "$HOME/.bash_profile" ] && add_to_path "$HOME/.bash_profile"

# ---------- Remove Quarantine Attribute (if any) ----------
xattr -dr com.apple.quarantine "$APP_BUNDLE" 2>/dev/null || true
xattr -dr com.apple.quarantine "$APP_SUPPORT" 2>/dev/null || true

# ---------- Success ----------
echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}          ✅  Installation Complete!  ✅${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}📁 App location:${NC}       $APP_SUPPORT"
echo -e "${CYAN}🚀 Terminal command:${NC}   ${GREEN}cancer-survey${NC}"
echo -e "${CYAN}🖥️  Launch from:${NC}        Applications → 'Cancer Survey'"
echo -e "${CYAN}💾 Results saved to:${NC}    ~/cancer_survey_results/"
echo ""
echo -e "${PINK}Developer: Raj Gautam  |  Cancer.ser${NC}"
echo ""

# ---------- Ask to Launch ----------
read -p "$(echo -e ${YELLOW}"Do you want to launch the app now? (y/n): "${NC})" -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}🚀 Launching Cancer Survey...${NC}"
    open "$APP_BUNDLE"
fi