#!/bin/bash
# ============================================================
# Cancer Survey App - Linux Auto Installer
# Developer: Raj Gautam
# Website: Cancer.ser
# ============================================================

set -e

# ---------- Colors ----------
GREEN='\033[0;32m'
PINK='\033[1;35m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ---------- Banner ----------
clear
echo -e "${GREEN}"
cat << "EOF"
  ██████╗ █████╗ ███╗   ██╗ ██████╗███████╗██████╗    ███████╗███████╗██████╗ 
 ██╔════╝██╔══██╗████╗  ██║██╔════╝██╔════╝██╔══██╗   ██╔════╝██╔════╝██╔══██╗
 ██║     ███████║██╔██╗ ██║██║     █████╗  ██████╔╝   ███████╗█████╗  ██████╔╝
 ██║     ██╔══██║██║╚██╗██║██║     ██╔══╝  ██╔══██╗   ╚════██║██╔══╝  ██╔══██╗
 ╚██████╗██║  ██║██║ ╚████║╚██████╗███████╗██║  ██║   ███████║███████╗██║  ██║
  ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝╚═╝  ╚═╝   ╚══════╝╚══════╝╚═╝  ╚═╝
EOF
echo -e "${NC}"
echo -e "${PINK}          🎗️  Cancer Survey App Installer  🎗️${NC}"
echo -e "${CYAN}          Developer: Raj Gautam | Cancer.ser${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo ""

# ---------- Detect Distribution ----------
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        DISTRO_LIKE=$ID_LIKE
    else
        DISTRO="unknown"
    fi
}

detect_distro
echo -e "${YELLOW}🔍 Detected OS: ${DISTRO}${NC}"

# ---------- Check Root / Sudo ----------
SUDO=""
if [ "$EUID" -ne 0 ]; then
    if command -v sudo &> /dev/null; then
        SUDO="sudo"
    else
        echo -e "${RED}❌ This script requires root privileges or sudo.${NC}"
        exit 1
    fi
fi

# ---------- Install Python & Tkinter ----------
install_python() {
    echo -e "${BLUE}📦 Installing Python 3 and Tkinter...${NC}"

    case "$DISTRO" in
        ubuntu|debian|linuxmint|pop|kali|raspbian)
            $SUDO apt-get update -qq
            $SUDO apt-get install -y python3 python3-pip python3-tk python3-venv wget curl
            ;;
        fedora|rhel|centos)
            $SUDO dnf install -y python3 python3-pip python3-tkinter wget curl
            ;;
        arch|manjaro|endeavouros)
            $SUDO pacman -Sy --noconfirm python tk wget curl
            ;;
        opensuse*|suse)
            $SUDO zypper install -y python3 python3-pip python3-tk wget curl
            ;;
        alpine)
            $SUDO apk add python3 py3-pip py3-tkinter wget curl
            ;;
        *)
            # Fallback
            if [ -n "$DISTRO_LIKE" ]; then
                case "$DISTRO_LIKE" in
                    *debian*) $SUDO apt-get update -qq && $SUDO apt-get install -y python3 python3-tk wget curl ;;
                    *fedora*|*rhel*) $SUDO dnf install -y python3 python3-tkinter wget curl ;;
                    *arch*) $SUDO pacman -Sy --noconfirm python tk wget curl ;;
                    *) echo -e "${RED}⚠️  Unknown distro. Please install Python 3 + Tkinter manually.${NC}" ;;
                esac
            else
                echo -e "${RED}⚠️  Unknown distro. Please install Python 3 + Tkinter manually.${NC}"
            fi
            ;;
    esac

    echo -e "${GREEN}✅ Python & Tkinter ready${NC}"
}

# ---------- Verify Python ----------
check_python() {
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}❌ Python3 not found.${NC}"
        exit 1
    fi
    PY_VERSION=$(python3 --version)
    echo -e "${GREEN}✅ Found: ${PY_VERSION}${NC}"

    # Test tkinter
    if ! python3 -c "import tkinter" &> /dev/null; then
        echo -e "${YELLOW}⚠️  Tkinter missing. Installing...${NC}"
        install_python
    fi
}

# ---------- Setup App Directory ----------
APP_DIR="$HOME/.local/share/cancer_survey"
BIN_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"

mkdir -p "$APP_DIR" "$BIN_DIR" "$DESKTOP_DIR"

echo -e "${BLUE}📁 Installing to: ${APP_DIR}${NC}"

# ---------- Download / Create App ----------
# The Python app will be written directly (self-contained, no external download needed)
cat > "$APP_DIR/cancer_survey.py" << 'PYEOF'
"""
Cancer Survey Application (Cancer.ser)
Developer: Raj Gautam
Theme: Cinematic Dark with Green, Pink, Blue, Red accents
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

        self.setup_styles()
        self.create_main_layout()
        self.build_header()
        self.build_progress_bar()
        self.build_scrollable_form()
        self.build_footer()

        self.animate_background()

    def center_window(self, width, height):
        screen_w = self.root.winfo_screenwidth()
        screen_h = self.root.winfo_screenheight()
        x = (screen_w - width) // 2
        y = (screen_h - height) // 2
        self.root.geometry(f"{width}x{height}+{x}+{y}")

    def setup_styles(self):
        style = ttk.Style()
        style.theme_use("clam")
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
                         font=("Segoe UI", 9, "bold"),
                         bg="#0f2a24", fg=GREEN_LIGHT, padx=15, pady=6)
        badge.pack(pady=(0, 8))

        title = tk.Label(header, text="🩺  कैंसर स्क्रीनिंग एवं स्वास्थ्य इतिहास",
                         font=("Segoe UI", 20, "bold"),
                         bg=CARD_BG, fg=GREEN_LIGHT)
        title.pack(pady=(4, 2))

        subtitle = tk.Label(header, text="20 प्रश्न  •  गोपनीय  •  सुरक्षित",
                            font=("Segoe UI", 10),
                            bg=CARD_BG, fg=TEXT_SECONDARY)
        subtitle.pack()

        dev = tk.Label(header, text="💻  Developed by Raj Gautam",
                       font=("Segoe UI", 8, "italic"),
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
                              font=("Segoe UI Emoji", 14),
                              bg=section["color"], fg=BG_DARK,
                              width=3, height=1)
        icon_label.pack(side="left", padx=(0, 10))

        title_label = tk.Label(header_frame, text=section["title"],
                               font=("Segoe UI", 13, "bold"),
                               bg=CARD_BG, fg=section["color"])
        title_label.pack(side="left")

        for q in section["questions"]:
            self.build_question(section_frame, q, section["color"])

        tk.Frame(section_frame, bg=BORDER_COLOR, height=1).pack(fill="x", pady=(10, 0))

    def build_question(self, parent, question, color):
        q_frame = tk.Frame(parent, bg=CARD_BG)
        q_frame.pack(fill="x", pady=(8, 4), padx=(10, 0))

        q_label = tk.Label(q_frame, text=question["text"],
                           font=("Segoe UI", 10, "bold"),
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
                                   font=("Segoe UI", 9),
                                   bg=CARD_BG_LIGHT, fg=TEXT_SECONDARY,
                                   insertbackground=GREEN, relief="flat",
                                   highlightthickness=1,
                                   highlightbackground=BORDER_COLOR,
                                   highlightcolor=color)
            extra_entry.pack(fill="x", pady=(6, 0), padx=(0, 5))
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
                                                  font=("Segoe UI", 9),
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
                                value=option, font=("Segoe UI", 9),
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
                              font=("Segoe UI", 10, "bold"),
                              bg=CARD_BG_LIGHT, fg=TEXT_SECONDARY,
                              activebackground=BORDER_COLOR,
                              activeforeground=TEXT_PRIMARY,
                              relief="flat", bd=0, padx=25, pady=10,
                              cursor="hand2", command=self.reset_form)
        reset_btn.pack(side="left", padx=(0, 10))

        submit_btn = tk.Button(btn_frame, text="✈  सर्वेक्षण सबमिट करें",
                               font=("Segoe UI", 11, "bold"),
                               bg=GREEN, fg=BG_DARK,
                               activebackground=GREEN_LIGHT,
                               activeforeground=BG_DARK,
                               relief="flat", bd=0, padx=35, pady=10,
                               cursor="hand2", command=self.submit_survey)
        submit_btn.pack(side="left", fill="x", expand=True)

        privacy = tk.Label(self.form_frame,
                           text="🔒  आपके उत्तर पूरी तरह गोपनीय हैं।",
                           font=("Segoe UI", 8), bg=CARD_BG, fg=TEXT_SECONDARY)
        privacy.pack(pady=(5, 0))

    def build_footer(self):
        footer = tk.Frame(self.inner_frame, bg=CARD_BG)
        footer.pack(fill="x", side="bottom", pady=(8, 0))
        tk.Frame(footer, bg=BORDER_COLOR, height=1).pack(fill="x", pady=(0, 6))
        tk.Label(footer,
                 text="💻 Designed & Developed with ❤️ by Raj Gautam  •  Cancer.ser",
                 font=("Segoe UI", 8), bg=CARD_BG, fg=TEXT_SECONDARY).pack()

    def on_form_configure(self, event):
        self.form_canvas.configure(scrollregion=self.form_canvas.bbox("all"))

    def on_canvas_configure(self, event):
        self.form_canvas.itemconfig(self.form_canvas_window, width=event.width)

    def on_mousewheel(self, event):
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

chmod +x "$APP_DIR/cancer_survey.py"
echo -e "${GREEN}✅ Application installed${NC}"

# ---------- Create Launcher Script ----------
LAUNCHER="$BIN_DIR/cancer-survey"
cat > "$LAUNCHER" << 'LAUNCHER_EOF'
#!/bin/bash
python3 "$HOME/.local/share/cancer_survey/cancer_survey.py" "$@"
LAUNCHER_EOF

chmod +x "$LAUNCHER"
echo -e "${GREEN}✅ Launcher created: cancer-survey${NC}"

# ---------- Create Desktop Entry ----------
DESKTOP_FILE="$DESKTOP_DIR/cancer-survey.desktop"
cat > "$DESKTOP_FILE" << DESKTOP_EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Cancer Survey
Name[hi]=कैंसर सर्वेक्षण
Comment=Cancer Screening & Health History Survey by Raj Gautam
Comment[hi]=कैंसर स्क्रीनिंग और स्वास्थ्य इतिहास सर्वेक्षण
Exec=$BIN_DIR/cancer-survey
Icon=applications-science
Terminal=false
Categories=Education;Medical;Science;
Keywords=cancer;survey;health;medical;
StartupNotify=true
DESKTOP_EOF

chmod +x "$DESKTOP_FILE"
echo -e "${GREEN}✅ Desktop entry created${NC}"

# ---------- Update Desktop Database ----------
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
fi

# ---------- Ensure ~/.local/bin is in PATH ----------
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    SHELL_RC="$HOME/.bashrc"
    [ -n "$ZSH_VERSION" ] && SHELL_RC="$HOME/.zshrc"
    if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$SHELL_RC" 2>/dev/null; then
        echo '' >> "$SHELL_RC"
        echo '# Added by Cancer Survey installer' >> "$SHELL_RC"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
        echo -e "${YELLOW}⚠️  Added ~/.local/bin to PATH in $SHELL_RC${NC}"
        echo -e "${YELLOW}    Run: source $SHELL_RC${NC}"
    fi
fi

# ---------- Success Message ----------
echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}          ✅  Installation Complete!  ✅${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}📁 App location:${NC} $APP_DIR"
echo -e "${CYAN}🚀 Run from terminal:${NC} ${GREEN}cancer-survey${NC}"
echo -e "${CYAN}🖥️  Or launch from Applications menu → 'Cancer Survey'${NC}"
echo -e "${CYAN}💾 Results saved to:${NC} ~/cancer_survey_results/"
echo ""
echo -e "${PINK}Developer: Raj Gautam  |  Cancer.ser${NC}"
echo ""

# ---------- Ask to Run Now ----------
read -p "$(echo -e ${YELLOW}"Do you want to launch the app now? (y/n): "${NC})" -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}🚀 Launching Cancer Survey...${NC}"
    "$LAUNCHER" &
    disown
fi