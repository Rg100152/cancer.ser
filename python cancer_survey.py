"""
Cancer Survey Application (Cancer.ser)
Developer: Raj Gautam
Theme: Cinematic Dark with Green, Pink, Blue, Red accents
"""

import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
import json
from datetime import datetime


# ==================== COLOR PALETTE ====================
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


# ==================== SURVEY QUESTIONS DATA ====================
SECTIONS = [
    {
        "title": "व्यक्तिगत और पारिवारिक चिकित्सा इतिहास",
        "title_en": "Personal & Family Medical History",
        "icon": "👤",
        "color": GREEN,
        "questions": [
            {
                "id": "q1",
                "text": "1. क्या आपको कभी किसी भी प्रकार के कैंसर का निदान (Diagnosis) हुआ है?",
                "type": "radio_with_text",
                "options": ["हाँ", "नहीं"],
                "extra_placeholder": "यदि हाँ, तो कैंसर का प्रकार और निदान के समय उम्र लिखें",
                "required": True
            },
            {
                "id": "q2",
                "text": "2. क्या आपके किसी भी रक्त संबंधी (माता-पिता, भाई-बहन, बच्चे, दादा-दादी) को कैंसर हुआ है?",
                "type": "radio",
                "options": ["हाँ", "नहीं", "मुझे नहीं पता"]
            },
            {
                "id": "q3",
                "text": "3. यदि परिवार में कैंसर का इतिहास है, तो किस रिश्तेदार को और किस प्रकार का कैंसर हुआ था?",
                "type": "text_area",
                "placeholder": "लागू होने पर लिखें..."
            },
            {
                "id": "q4",
                "text": "4. क्या आपके परिवार में एक से अधिक रिश्तेदारों को एक ही प्रकार का कैंसर हुआ है?",
                "type": "radio",
                "options": ["हाँ", "नहीं", "मुझे नहीं पता"]
            },
            {
                "id": "q5",
                "text": "5. क्या आपके परिवार में किसी को 50 वर्ष की आयु से पहले कैंसर का निदान हुआ था?",
                "type": "radio",
                "options": ["हाँ", "नहीं", "मुझे नहीं पता"]
            },
            {
                "id": "q6",
                "text": "6. क्या आपने कभी कैंसर से जुड़े जीनों (BRCA1, BRCA2, Lynch Syndrome) की जांच के लिए जेनेटिक टेस्ट कराया है?",
                "type": "radio",
                "options": ["हाँ", "नहीं", "हाँ, और परिणाम सकारात्मक थे"]
            }
        ]
    },
    {
        "title": "जीवनशैली और जोखिम कारक",
        "title_en": "Lifestyle & Risk Factors",
        "icon": "❤️",
        "color": PINK,
        "questions": [
            {
                "id": "q7",
                "text": "7. आपकी तंबाकू/धूम्रपान की वर्तमान स्थिति क्या है?",
                "type": "radio",
                "options": ["कभी धूम्रपान नहीं किया", "पहले करता था, अब छोड़ दिया", "वर्तमान में सेवन करता हूँ"]
            },
            {
                "id": "q8",
                "text": "8. यदि सेवन करते हैं (या करते थे), तो प्रतिदिन कितनी मात्रा और कितने वर्षों से?",
                "type": "text_area",
                "placeholder": "जैसे: 10 सिगरेट प्रतिदिन, 15 वर्षों से"
            },
            {
                "id": "q9",
                "text": "9. आप सप्ताह में औसतन कितनी बार शराब का सेवन करते हैं?",
                "type": "radio",
                "options": ["बिल्कुल नहीं", "सप्ताह में 1 से 7 ड्रिंक्स", "सप्ताह में 8 या अधिक ड्रिंक्स"]
            },
            {
                "id": "q10",
                "text": "10. क्या आप काम/घर पर एस्बेस्टस, बेंजीन, आर्सेनिक, या अत्यधिक रेडिएशन के संपर्क में आते हैं?",
                "type": "radio",
                "options": ["हाँ", "नहीं", "मुझे यकीन नहीं है"]
            },
            {
                "id": "q11",
                "text": "11. आपका सामान्य शारीरिक गतिविधि का स्तर क्या है?",
                "type": "radio",
                "options": ["निष्क्रिय (कम या कोई व्यायाम नहीं)", "मध्यम (सप्ताह में 150 मिनट तक हल्की वॉक/योग)", "अत्यधिक सक्रिय (नियमित भारी व्यायाम/खेल)"]
            },
            {
                "id": "q12",
                "text": "12. क्या आपको कभी HPV या हेपेटाइटिस बी/सी का संक्रमण हुआ है?",
                "type": "radio",
                "options": ["हाँ", "नहीं", "मुझे नहीं पता"]
            }
        ]
    },
    {
        "title": "वर्तमान लक्षण और शारीरिक बदलाव",
        "title_en": "Current Symptoms & Physical Changes",
        "icon": "🔬",
        "color": BLUE,
        "questions": [
            {
                "id": "q13",
                "text": "13. क्या पिछले 6 महीनों में बिना प्रयास के अचानक वजन में भारी कमी आई है?",
                "type": "radio",
                "options": ["हाँ", "नहीं"]
            },
            {
                "id": "q14",
                "text": "14. क्या शरीर के किसी हिस्से में (स्तन, बगल, गर्दन, अंडकोष) कोई नई, असामान्य या सख्त गांठ महसूस हुई है?",
                "type": "radio",
                "options": ["हाँ", "नहीं"]
            },
            {
                "id": "q15",
                "text": "15. क्या किसी तिल या मस्से के आकार, रंग या बनावट में बदलाव आया है, या कोई घाव ठीक नहीं हो रहा?",
                "type": "radio",
                "options": ["हाँ", "नहीं"]
            },
            {
                "id": "q16",
                "text": "16. क्या 3-4 सप्ताह से अधिक खांसी, आवाज में भारीपन, या सांस फूलने की समस्या बनी हुई है?",
                "type": "radio",
                "options": ["हाँ", "नहीं"]
            },
            {
                "id": "q17",
                "text": "17. क्या मल-मूत्र त्यागने की आदतों में अचानक लंबा बदलाव आया है (कब्ज, दस्त, मल में खून)?",
                "type": "radio",
                "options": ["हाँ", "नहीं"]
            },
            {
                "id": "q18",
                "text": "18. क्या बिना भारी काम के भी लगातार अत्यधिक थकान और कमजोरी महसूस होती है, जो आराम से ठीक नहीं होती?",
                "type": "radio",
                "options": ["हाँ", "नहीं"]
            }
        ]
    },
    {
        "title": "नियमित स्क्रीनिंग और जागरूकता",
        "title_en": "Screening & Awareness",
        "icon": "🛡️",
        "color": RED,
        "questions": [
            {
                "id": "q19",
                "text": "19. आपने पिछली बार कैंसर स्क्रीनिंग जांच (मैमोग्राम, पैप स्मीयर, कोलोनोस्कोपी, प्रोस्टेट) कब करवाई थी?",
                "type": "radio",
                "options": ["पिछले 1 वर्ष के भीतर", "पिछले 1 से 3 वर्ष के भीतर", "3 वर्ष से अधिक समय पहले", "कभी नहीं करवाई"]
            },
            {
                "id": "q20",
                "text": "20. क्या आप कैंसर के शुरुआती लक्षणों और नियमित स्क्रीनिंग के महत्व के बारे में पर्याप्त जानकारी रखते हैं?",
                "type": "radio",
                "options": ["हाँ, पूरी तरह जागरूक हूँ", "बुनियादी जानकारी है, और जानना चाहता हूँ", "बिल्कुल जानकारी नहीं है"]
            }
        ]
    }
]


class CancerSurveyApp:
    """Main application class for Cancer Survey GUI."""

    def __init__(self, root):
        self.root = root
        self.root.title("Cancer.ser | कैंसर सर्वेक्षण - Raj Gautam")
        self.root.configure(bg=BG_DARK)
        self.root.geometry("1000x750")
        self.root.minsize(800, 600)

        # Center the window
        self.center_window(1000, 750)

        # Data storage
        self.answers = {}
        self.radio_vars = {}
        self.extra_text_entries = {}
        self.text_areas = {}

        # Animation state
        self.animation_step = 0
        self.animating = True

        # Build UI
        self.setup_styles()
        self.create_main_layout()
        self.build_header()
        self.build_progress_bar()
        self.build_scrollable_form()
        self.build_footer()

        # Start animations
        self.animate_background()
        self.fade_in_widgets()

    # ==================== UTILITY METHODS ====================
    def center_window(self, width, height):
        """Center the window on screen."""
        screen_w = self.root.winfo_screenwidth()
        screen_h = self.root.winfo_screenheight()
        x = (screen_w - width) // 2
        y = (screen_h - height) // 2
        self.root.geometry(f"{width}x{height}+{x}+{y}")

    def setup_styles(self):
        """Configure ttk styles."""
        style = ttk.Style()
        style.theme_use("clam")

        # Scrollbar style
        style.configure(
            "Dark.Vertical.TScrollbar",
            background=CARD_BG_LIGHT,
            troughcolor=BG_DARK,
            bordercolor=BG_DARK,
            arrowcolor=GREEN,
            darkcolor=CARD_BG_LIGHT,
            lightcolor=CARD_BG_LIGHT
        )
        style.map("Dark.Vertical.TScrollbar",
                  background=[("active", GREEN)])

        # Combobox style
        style.configure(
            "Dark.TCombobox",
            fieldbackground=CARD_BG_LIGHT,
            background=CARD_BG_LIGHT,
            foreground=TEXT_PRIMARY,
            arrowcolor=GREEN,
            bordercolor=BORDER_COLOR
        )

    # ==================== LAYOUT BUILDING ====================
    def create_main_layout(self):
        """Create the main container structure."""
        # Background canvas for animated orbs
        self.bg_canvas = tk.Canvas(
            self.root, bg=BG_DARK, highlightthickness=0
        )
        self.bg_canvas.place(x=0, y=0, relwidth=1, relheight=1)

        # Main card frame
        self.main_card = tk.Frame(
            self.root,
            bg=CARD_BG,
            highlightbackground=BORDER_COLOR,
            highlightthickness=1
        )
        self.main_card.place(relx=0.5, rely=0.5, anchor="center",
                             relwidth=0.92, relheight=0.94)

        # Inner padding frame
        self.inner_frame = tk.Frame(self.main_card, bg=CARD_BG)
        self.inner_frame.pack(fill="both", expand=True, padx=30, pady=20)

    def build_header(self):
        """Build the header section."""
        header = tk.Frame(self.inner_frame, bg=CARD_BG)
        header.pack(fill="x", pady=(0, 15))

        # Badge
        badge_frame = tk.Frame(header, bg=CARD_BG)
        badge_frame.pack(pady=(0, 8))

        badge = tk.Label(
            badge_frame,
            text="🎗️  कैंसर जागरूकता सर्वेक्षण  ",
            font=("Segoe UI", 9, "bold"),
            bg="#0f2a24",
            fg=GREEN_LIGHT,
            padx=15, pady=6
        )
        badge.pack()

        # Main title with gradient-like effect (using multiple labels)
        title = tk.Label(
            header,
            text="🩺  कैंसर स्क्रीनिंग एवं स्वास्थ्य इतिहास",
            font=("Segoe UI", 20, "bold"),
            bg=CARD_BG,
            fg=GREEN_LIGHT
        )
        title.pack(pady=(4, 2))

        # Subtitle
        subtitle = tk.Label(
            header,
            text="20 प्रश्न  •  गोपनीय  •  सुरक्षित",
            font=("Segoe UI", 10),
            bg=CARD_BG,
            fg=TEXT_SECONDARY
        )
        subtitle.pack()

        # Developer credit
        dev = tk.Label(
            header,
            text="💻  Developed by Raj Gautam",
            font=("Segoe UI", 8, "italic"),
            bg=CARD_BG,
            fg=PINK_LIGHT
        )
        dev.pack(pady=(6, 0))

        # Separator
        sep = tk.Frame(header, bg=BORDER_COLOR, height=1)
        sep.pack(fill="x", pady=(10, 0))

    def build_progress_bar(self):
        """Build the decorative progress bar."""
        progress_frame = tk.Frame(self.inner_frame, bg=CARD_BG)
        progress_frame.pack(fill="x", pady=(0, 12))

        self.progress_canvas = tk.Canvas(
            progress_frame, height=6, bg=CARD_BG,
            highlightthickness=0
        )
        self.progress_canvas.pack(fill="x")

        # Initial progress bar drawing
        self.draw_progress_bar(0.75)

    def draw_progress_bar(self, fraction):
        """Draw the progress bar with gradient-like segments."""
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
            self.progress_canvas.create_rectangle(
                x1, 0, x2, height,
                fill=color, outline=color
            )

    def build_scrollable_form(self):
        """Build the scrollable form area."""
        # Container for canvas and scrollbar
        container = tk.Frame(self.inner_frame, bg=CARD_BG)
        container.pack(fill="both", expand=True)

        # Canvas
        self.form_canvas = tk.Canvas(
            container, bg=CARD_BG, highlightthickness=0
        )
        self.form_canvas.pack(side="left", fill="both", expand=True)

        # Scrollbar
        scrollbar = ttk.Scrollbar(
            container, orient="vertical",
            command=self.form_canvas.yview,
            style="Dark.Vertical.TScrollbar"
        )
        scrollbar.pack(side="right", fill="y")

        self.form_canvas.configure(yscrollcommand=scrollbar.set)

        # Inner frame for form content
        self.form_frame = tk.Frame(self.form_canvas, bg=CARD_BG)
        self.form_canvas_window = self.form_canvas.create_window(
            (0, 0), window=self.form_frame, anchor="nw"
        )

        # Bind resize events
        self.form_frame.bind("<Configure>", self.on_form_configure)
        self.form_canvas.bind("<Configure>", self.on_canvas_configure)

        # Mouse wheel scrolling
        self.form_canvas.bind_all("<MouseWheel>", self.on_mousewheel)
        self.form_canvas.bind_all("<Button-4>", self.on_mousewheel)
        self.form_canvas.bind_all("<Button-5>", self.on_mousewheel)

        # Build all sections
        self.build_all_sections()
        self.build_action_buttons()

    def build_all_sections(self):
        """Build all survey sections dynamically."""
        for section in SECTIONS:
            self.build_section(section)

    def build_section(self, section):
        """Build a single section with its questions."""
        # Section container
        section_frame = tk.Frame(self.form_frame, bg=CARD_BG)
        section_frame.pack(fill="x", pady=(0, 15), padx=5)

        # Section header
        header_frame = tk.Frame(section_frame, bg=CARD_BG)
        header_frame.pack(fill="x", pady=(0, 10))

        # Icon box
        icon_label = tk.Label(
            header_frame,
            text=section["icon"],
            font=("Segoe UI Emoji", 14),
            bg=section["color"],
            fg=BG_DARK,
            width=3, height=1
        )
        icon_label.pack(side="left", padx=(0, 10))

        # Title
        title_label = tk.Label(
            header_frame,
            text=section["title"],
            font=("Segoe UI", 13, "bold"),
            bg=CARD_BG,
            fg=section["color"]
        )
        title_label.pack(side="left")

        # Questions
        for q in section["questions"]:
            self.build_question(section_frame, q, section["color"])

        # Separator
        sep = tk.Frame(section_frame, bg=BORDER_COLOR, height=1)
        sep.pack(fill="x", pady=(10, 0))

    def build_question(self, parent, question, color):
        """Build a single question widget."""
        q_frame = tk.Frame(parent, bg=CARD_BG)
        q_frame.pack(fill="x", pady=(8, 4), padx=(10, 0))

        # Question text
        q_label = tk.Label(
            q_frame,
            text=question["text"],
            font=("Segoe UI", 10, "bold"),
            bg=CARD_BG,
            fg=TEXT_PRIMARY,
            wraplength=750,
            justify="left",
            anchor="w"
        )
        q_label.pack(fill="x", pady=(0, 6))

        q_type = question["type"]

        if q_type == "radio":
            self.build_radio_options(q_frame, question, color)

        elif q_type == "radio_with_text":
            self.build_radio_options(q_frame, question, color)
            # Extra text field
            extra_var = tk.StringVar()
            extra_entry = tk.Entry(
                q_frame,
                textvariable=extra_var,
                font=("Segoe UI", 9),
                bg=CARD_BG_LIGHT,
                fg=TEXT_PRIMARY,
                insertbackground=GREEN,
                relief="flat",
                highlightthickness=1,
                highlightbackground=BORDER_COLOR,
                highlightcolor=color
            )
            extra_entry.pack(fill="x", pady=(6, 0), padx=(0, 5))
            extra_entry.insert(0, question.get("extra_placeholder", ""))
            extra_entry.config(fg=TEXT_SECONDARY)

            # Placeholder behavior
            def on_focus_in(event, entry=extra_entry, placeholder=question.get("extra_placeholder", "")):
                if entry.get() == placeholder:
                    entry.delete(0, tk.END)
                    entry.config(fg=TEXT_PRIMARY)

            def on_focus_out(event, entry=extra_entry, placeholder=question.get("extra_placeholder", "")):
                if not entry.get().strip():
                    entry.insert(0, placeholder)
                    entry.config(fg=TEXT_SECONDARY)

            extra_entry.bind("<FocusIn>", on_focus_in)
            extra_entry.bind("<FocusOut>", on_focus_out)
            self.extra_text_entries[question["id"]] = (extra_entry, extra_var)

        elif q_type == "text_area":
            text_area = scrolledtext.ScrolledText(
                q_frame,
                height=3,
                font=("Segoe UI", 9),
                bg=CARD_BG_LIGHT,
                fg=TEXT_PRIMARY,
                insertbackground=GREEN,
                relief="flat",
                highlightthickness=1,
                highlightbackground=BORDER_COLOR,
                highlightcolor=color,
                wrap="word"
            )
            text_area.pack(fill="x", pady=(4, 0), padx=(0, 5))
            self.text_areas[question["id"]] = text_area

    def build_radio_options(self, parent, question, color):
        """Build radio button options in a horizontal flow."""
        var = tk.StringVar()
        self.radio_vars[question["id"]] = var

        options_frame = tk.Frame(parent, bg=CARD_BG)
        options_frame.pack(fill="x", pady=(0, 4))

        for i, option in enumerate(question["options"]):
            rb = tk.Radiobutton(
                options_frame,
                text=option,
                variable=var,
                value=option,
                font=("Segoe UI", 9),
                bg=CARD_BG,
                fg=TEXT_SECONDARY,
                selectcolor=CARD_BG_LIGHT,
                activebackground=CARD_BG,
                activeforeground=TEXT_PRIMARY,
                highlightthickness=0,
                bd=0,
                padx=8,
                pady=4,
                cursor="hand2",
                command=lambda c=color: self.on_radio_select(c)
            )
            rb.pack(side="left", padx=(0, 15))

    def on_radio_select(self, color):
        """Handle radio selection - subtle feedback."""
        # Could add a subtle animation here
        pass

    def build_action_buttons(self):
        """Build the submit and reset buttons."""
        btn_frame = tk.Frame(self.form_frame, bg=CARD_BG)
        btn_frame.pack(fill="x", pady=(20, 10), padx=5)

        # Reset button
        reset_btn = tk.Button(
            btn_frame,
            text="↺  रीसेट करें",
            font=("Segoe UI", 10, "bold"),
            bg=CARD_BG_LIGHT,
            fg=TEXT_SECONDARY,
            activebackground=BORDER_COLOR,
            activeforeground=TEXT_PRIMARY,
            relief="flat",
            bd=0,
            padx=25, pady=10,
            cursor="hand2",
            command=self.reset_form
        )
        reset_btn.pack(side="left", padx=(0, 10))

        # Submit button
        submit_btn = tk.Button(
            btn_frame,
            text="✈  सर्वेक्षण सबमिट करें",
            font=("Segoe UI", 11, "bold"),
            bg=GREEN,
            fg=BG_DARK,
            activebackground=GREEN_LIGHT,
            activeforeground=BG_DARK,
            relief="flat",
            bd=0,
            padx=35, pady=10,
            cursor="hand2",
            command=self.submit_survey
        )
        submit_btn.pack(side="left", fill="x", expand=True)

        # Privacy note
        privacy = tk.Label(
            self.form_frame,
            text="🔒  आपके उत्तर पूरी तरह गोपनीय हैं और केवल कैंसर सहायता सुधार के लिए उपयोग किए जाएंगे।",
            font=("Segoe UI", 8),
            bg=CARD_BG,
            fg=TEXT_SECONDARY,
            wraplength=700
        )
        privacy.pack(pady=(5, 0))

    def build_footer(self):
        """Build the footer with developer credit."""
        footer = tk.Frame(self.inner_frame, bg=CARD_BG)
        footer.pack(fill="x", side="bottom", pady=(8, 0))

        sep = tk.Frame(footer, bg=BORDER_COLOR, height=1)
        sep.pack(fill="x", pady=(0, 6))

        footer_label = tk.Label(
            footer,
            text="💻 Designed & Developed with ❤️ by Raj Gautam  •  Cancer.ser",
            font=("Segoe UI", 8),
            bg=CARD_BG,
            fg=TEXT_SECONDARY
        )
        footer_label.pack()

    # ==================== SCROLLING & RESIZE HANDLERS ====================
    def on_form_configure(self, event):
        """Update scroll region when form content changes."""
        self.form_canvas.configure(scrollregion=self.form_canvas.bbox("all"))

    def on_canvas_configure(self, event):
        """Resize the inner form frame to match canvas width."""
        self.form_canvas.itemconfig(
            self.form_canvas_window, width=event.width
        )

    def on_mousewheel(self, event):
        """Handle mouse wheel scrolling."""
        if event.num == 5 or event.delta < 0:
            self.form_canvas.yview_scroll(1, "units")
        elif event.num == 4 or event.delta > 0:
            self.form_canvas.yview_scroll(-1, "units")

    # ==================== FORM ACTIONS ====================
    def submit_survey(self):
        """Validate and submit the survey."""
        # Validate required questions
        for section in SECTIONS:
            for q in section["questions"]:
                if q.get("required"):
                    var = self.radio_vars.get(q["id"])
                    if var and not var.get():
                        messagebox.showwarning(
                            "अपूर्ण उत्तर",
                            f"कृपया अनिवार्य प्रश्न का उत्तर दें:\n\n{q['text']}"
                        )
                        return

        # Collect answers
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
                    extra_entry, extra_var = self.extra_text_entries.get(qid, (None, None))
                    extra_val = ""
                    if extra_entry:
                        val = extra_entry.get()
                        placeholder = q.get("extra_placeholder", "")
                        if val != placeholder:
                            extra_val = val
                    self.answers[qid] = {
                        "answer": radio_val,
                        "details": extra_val
                    }

                elif qtype == "text_area":
                    text_widget = self.text_areas.get(qid)
                    if text_widget:
                        self.answers[qid] = text_widget.get("1.0", "end-1c").strip()
                    else:
                        self.answers[qid] = ""

        # Build summary
        summary = f"धन्यवाद! आपका सर्वेक्षण सफलतापूर्वक सबमिट हो गया है।\n\n"
        summary += f"📅 दिनांक: {timestamp}\n"
        summary += f"📊 कुल प्रश्न: 20\n"
        summary += f"✅ उत्तर दिए गए: {self.count_answered()}\n\n"
        summary += "आप अकेले नहीं हैं। 💙"

        messagebox.showinfo("सर्वेक्षण सबमिट", summary)

        # Save to file
        self.save_to_file(timestamp)

        # Ask to reset
        if messagebox.askyesno("नया सर्वेक्षण", "क्या आप नया सर्वेक्षण शुरू करना चाहेंगे?"):
            self.reset_form()

    def count_answered(self):
        """Count answered questions."""
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
                    widget = self.text_areas.get(qid)
                    if widget and widget.get("1.0", "end-1c").strip():
                        count += 1
        return count

    def save_to_file(self, timestamp):
        """Save survey results to a JSON file."""
        try:
            filename = f"cancer_survey_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
            data = {
                "survey": "Cancer.ser Survey",
                "developer": "Raj Gautam",
                "timestamp": timestamp,
                "answers": self.answers
            }
            with open(filename, "w", encoding="utf-8") as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
        except Exception as e:
            messagebox.showerror("फ़ाइल त्रुटि", f"परिणाम सहेजने में त्रुटि:\n{str(e)}")

    def reset_form(self):
        """Reset all form fields."""
        # Reset radio buttons
        for var in self.radio_vars.values():
            var.set("")

        # Reset extra text entries
        for qid, (entry, var) in self.extra_text_entries.items():
            # Find the question to get placeholder
            placeholder = ""
            for section in SECTIONS:
                for q in section["questions"]:
                    if q["id"] == qid:
                        placeholder = q.get("extra_placeholder", "")
                        break
            entry.delete(0, tk.END)
            entry.insert(0, placeholder)
            entry.config(fg=TEXT_SECONDARY)
            var.set("")

        # Reset text areas
        for widget in self.text_areas.values():
            widget.delete("1.0", tk.END)

        # Scroll to top
        self.form_canvas.yview_moveto(0)

    # ==================== ANIMATIONS ====================
    def animate_background(self):
        """Animate the background with floating orbs."""
        if not self.animating:
            return

        self.animation_step += 0.02
        self.bg_canvas.delete("orb")

        width = self.bg_canvas.winfo_width()
        height = self.bg_canvas.winfo_height()

        if width < 10:
            width = 1000
            height = 750

        import math

        # Orb 1 - Green
        x1 = width * 0.15 + math.sin(self.animation_step) * 60
        y1 = height * 0.1 + math.cos(self.animation_step * 0.7) * 40
        self.draw_orb(x1, y1, 120, GREEN, "orb")

        # Orb 2 - Pink
        x2 = width * 0.85 + math.cos(self.animation_step * 0.8) * 70
        y2 = height * 0.85 + math.sin(self.animation_step * 0.6) * 50
        self.draw_orb(x2, y2, 140, PINK, "orb")

        # Orb 3 - Blue
        x3 = width * 0.6 + math.sin(self.animation_step * 0.5) * 80
        y3 = height * 0.4 + math.cos(self.animation_step * 0.9) * 60
        self.draw_orb(x3, y3, 100, BLUE, "orb")

        # Orb 4 - Red
        x4 = width * 0.2 + math.cos(self.animation_step * 0.7) * 50
        y4 = height * 0.75 + math.sin(self.animation_step * 0.8) * 55
        self.draw_orb(x4, y4, 90, RED, "orb")

        self.root.after(50, self.animate_background)

    def draw_orb(self, x, y, radius, color, tag):
        """Draw a soft glowing orb on the canvas."""
        # Create radial gradient effect with concentric circles
        for i in range(8, 0, -1):
            r = radius * i / 8
            alpha_color = self.blend_colors(color, BG_DARK, i / 8)
            self.bg_canvas.create_oval(
                x - r, y - r, x + r, y + r,
                fill=alpha_color, outline="", tags=tag
            )

    def blend_colors(self, color1, color2, ratio):
        """Blend two hex colors."""
        r1, g1, b1 = int(color1[1:3], 16), int(color1[3:5], 16), int(color1[5:7], 16)
        r2, g2, b2 = int(color2[1:3], 16), int(color2[3:5], 16), int(color2[5:7], 16)
        r = int(r1 * ratio + r2 * (1 - ratio))
        g = int(g1 * ratio + g2 * (1 - ratio))
        b = int(b1 * ratio + b2 * (1 - ratio))
        return f"#{r:02x}{g:02x}{b:02x}"

    def fade_in_widgets(self):
        """Simple fade-in effect for main card (opacity simulation via color)."""
        # Tkinter doesn't support true opacity, so we simulate with color transition
        # The card is already visible; we just ensure it's placed properly
        self.main_card.update_idletasks()

    def on_closing(self):
        """Handle window close."""
        self.animating = False
        self.root.destroy()


# ==================== MAIN ====================
def main():
    root = tk.Tk()
    app = CancerSurveyApp(root)
    root.protocol("WM_DELETE_WINDOW", app.on_closing)
    root.mainloop()


if __name__ == "__main__":
    main()