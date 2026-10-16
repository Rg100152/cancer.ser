#!/bin/bash
# ============================================================
#  Cancer Survey App - Installer
#  Command:   cancer
#  JSON:      ~/cancer_survey_results/survey_*.json
#  Developer: Raj Gautam
#  Project:   Cancer.ser
# ============================================================

set -e

G='\033[0;32m'; P='\033[1;35m'; B='\033[0;34m'
R='\033[0;31m'; C='\033[0;36m'; Y='\033[1;33m'
BD='\033[1m'; NC='\033[0m'

PKG="cancer-survey"
VER="1.0.0"
ROOT="$(pwd)/_build/${PKG}_${VER}_all"
DEB="$(pwd)/${PKG}_${VER}_all.deb"

clear
echo -e "${G}${BD}"
cat << "EOF"
   ██████╗ █████╗ ███╗   ██╗ ██████╗███████╗██████╗ 
  ██╔════╝██╔══██╗████╗  ██║██╔════╝██╔════╝██╔══██╗
  ██║     ███████║██╔██╗ ██║██║     █████╗  ██████╔╝
  ██║     ██╔══██║██║╚██╗██║██║     ██╔══╝  ██╔══██╗
  ╚██████╗██║  ██║██║ ╚████║╚██████╗███████╗██║  ██║
   ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝╚═╝  ╚═╝
EOF
echo -e "${NC}"
echo -e "${P}${BD}     🎗️  Cancer Survey App  🎗️${NC}"
echo -e "${C}     Command: cancer  |  JSON Output${NC}"
echo -e "${B}════════════════════════════════════════════${NC}\n"

echo -e "${Y}1${NC}) Build + Install"
echo -e "${Y}2${NC}) Build only"
echo -e "${Y}3${NC}) Install existing .deb"
echo -e "${Y}4${NC}) Uninstall"
echo -e "${Y}5${NC}) Exit"
read -p "$(echo -e ${C}"Choice [1-5]: "${NC})" CH

need_build() { [ "$CH" = "1" ] || [ "$CH" = "2" ]; }
if need_build && ! command -v dpkg-deb &>/dev/null; then
    echo -e "${R}❌ Install: sudo apt install dpkg-dev${NC}"; exit 1
fi

# ============================================================
build() {
    echo -e "\n${B}🧹 Cleaning...${NC}"
    rm -rf "$(pwd)/_build" "$DEB"
    mkdir -p "$ROOT/DEBIAN" "$ROOT/usr/bin" \
             "$ROOT/usr/share/applications" \
             "$ROOT/usr/share/cancer-survey" \
             "$ROOT/usr/share/icons/hicolor/256x256/apps" \
             "$ROOT/usr/share/pixmaps" \
             "$ROOT/usr/share/doc/$PKG"

    # ---------- Python App ----------
    echo -e "${B}🐍 Writing app...${NC}"
    cat > "$ROOT/usr/share/cancer-survey/cancer_survey.py" << 'PYEOF'
"""Cancer Survey App | Cancer.ser | Developer: Raj Gautam
Saves each submission as JSON to ~/cancer_survey_results/"""
import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
import json, math, os, sys, platform
from datetime import datetime

BG="#0b0f17"; CARD="#121928"; CARD2="#1a2333"
GREEN="#00c9a7"; GREEN_L="#6ef0d0"
PINK="#ff6b9d"; PINK_L="#ff9ec7"
BLUE="#4a9eff"; RED="#ff4d6d"
TXT="#eef5ff"; TXT2="#a8bdd4"; BORDER="#2a3548"

# ---------------- Survey Data ----------------
SECTIONS = [
 {"title":"व्यक्तिगत और पारिवारिक चिकित्सा इतिहास",
  "title_en":"Personal & Family Medical History","icon":"👤","color":GREEN,
  "questions":[
   {"id":"q1","text":"1. क्या आपको कभी किसी भी प्रकार के कैंसर का निदान हुआ है?",
    "type":"radio_with_text","options":["हाँ","नहीं"],
    "extra_placeholder":"यदि हाँ — कैंसर का प्रकार और निदान के समय उम्र",
    "required":True},
   {"id":"q2","text":"2. क्या आपके किसी रक्त संबंधी (माता-पिता, भाई-बहन, बच्चे) को कैंसर हुआ है?",
    "type":"radio","options":["हाँ","नहीं","मुझे नहीं पता"]},
   {"id":"q3","text":"3. यदि परिवार में कैंसर का इतिहास है, तो किस रिश्तेदार को और किस प्रकार का कैंसर?",
    "type":"text_area"},
   {"id":"q4","text":"4. क्या परिवार में एक से अधिक रिश्तेदारों को एक ही प्रकार का कैंसर हुआ है?",
    "type":"radio","options":["हाँ","नहीं","मुझे नहीं पता"]},
   {"id":"q5","text":"5. क्या परिवार में किसी को 50 वर्ष से पहले कैंसर का निदान हुआ था?",
    "type":"radio","options":["हाँ","नहीं","मुझे नहीं पता"]},
   {"id":"q6","text":"6. क्या आपने जेनेटिक टेस्ट (BRCA1, BRCA2, Lynch) कराया है?",
    "type":"radio","options":["हाँ","नहीं","हाँ, सकारात्मक"]}
  ]},
 {"title":"जीवनशैली और जोखिम कारक",
  "title_en":"Lifestyle & Risk Factors","icon":"❤️","color":PINK,
  "questions":[
   {"id":"q7","text":"7. आपकी तंबाकू/धूम्रपान की स्थिति क्या है?",
    "type":"radio","options":["कभी नहीं किया","छोड़ दिया","वर्तमान में सेवन"]},
   {"id":"q8","text":"8. यदि सेवन करते हैं, तो प्रतिदिन मात्रा और वर्ष?",
    "type":"text_area"},
   {"id":"q9","text":"9. सप्ताह में औसतन कितनी बार शराब का सेवन?",
    "type":"radio","options":["बिल्कुल नहीं","1-7 ड्रिंक्स","8+ ड्रिंक्स"]},
   {"id":"q10","text":"10. हानिकारक रसायन/रेडिएशन के संपर्क में?",
    "type":"radio","options":["हाँ","नहीं","यकीन नहीं"]},
   {"id":"q11","text":"11. शारीरिक गतिविधि का स्तर?",
    "type":"radio","options":["निष्क्रिय","मध्यम","अत्यधिक सक्रिय"]},
   {"id":"q12","text":"12. कभी HPV या हेपेटाइटिस B/C का संक्रमण हुआ?",
    "type":"radio","options":["हाँ","नहीं","मुझे नहीं पता"]}
  ]},
 {"title":"वर्तमान लक्षण और शारीरिक बदलाव",
  "title_en":"Current Symptoms & Changes","icon":"🔬","color":BLUE,
  "questions":[
   {"id":"q13","text":"13. पिछले 6 महीनों में अचानक वजन में भारी कमी?","type":"radio","options":["हाँ","नहीं"]},
   {"id":"q14","text":"14. शरीर में कोई नई, असामान्य या सख्त गांठ?","type":"radio","options":["हाँ","नहीं"]},
   {"id":"q15","text":"15. तिल/मस्से में बदलाव या घाव जो ठीक न हो?","type":"radio","options":["हाँ","नहीं"]},
   {"id":"q16","text":"16. 3-4 सप्ताह से खांसी/आवाज भारीपन/सांस फूलना?","type":"radio","options":["हाँ","नहीं"]},
   {"id":"q17","text":"17. मल-मूत्र आदतों में लंबा बदलाव?","type":"radio","options":["हाँ","नहीं"]},
   {"id":"q18","text":"18. लगातार अत्यधिक थकान जो आराम से ठीक न हो?","type":"radio","options":["हाँ","नहीं"]}
  ]},
 {"title":"नियमित स्क्रीनिंग और जागरूकता",
  "title_en":"Screening & Awareness","icon":"🛡️","color":RED,
  "questions":[
   {"id":"q19","text":"19. पिछली बार कैंसर स्क्रीनिंग कब करवाई?",
    "type":"radio","options":["1 वर्ष के भीतर","1-3 वर्ष","3+ वर्ष","कभी नहीं"]},
   {"id":"q20","text":"20. कैंसर के लक्षणों और स्क्रीनिंग के बारे में जागरूकता?",
    "type":"radio","options":["पूरी तरह जागरूक","बुनियादी","जानकारी नहीं"]}
  ]}
]

RESULTS_DIR = os.path.join(os.path.expanduser("~"), "cancer_survey_results")

# ---------------- GUI ----------------
class App:
    def __init__(self, root):
        self.root = root
        root.title("Cancer Survey - Raj Gautam")
        root.configure(bg=BG)
        root.geometry("1000x750"); root.minsize(800, 600)
        sw, sh = root.winfo_screenwidth(), root.winfo_screenheight()
        root.geometry(f"1000x750+{(sw-1000)//2}+{(sh-750)//2}")

        self.rv = {}   # radio vars
        self.et = {}   # extra text (id -> (entry, var, placeholder))
        self.ta = {}   # text areas
        self.step = 0
        self.anim = True

        try:
            s = ttk.Style(); s.theme_use("clam")
            s.configure("D.Vertical.TScrollbar",
                        background=CARD2, troughcolor=BG,
                        bordercolor=BG, arrowcolor=GREEN)
        except Exception: pass

        self.build()
        self.animate()

    def build(self):
        self.cv = tk.Canvas(self.root, bg=BG, highlightthickness=0)
        self.cv.place(x=0, y=0, relwidth=1, relheight=1)

        card = tk.Frame(self.root, bg=CARD,
                        highlightbackground=BORDER, highlightthickness=1)
        card.place(relx=.5, rely=.5, anchor="center",
                   relwidth=.92, relheight=.94)
        inner = tk.Frame(card, bg=CARD)
        inner.pack(fill="both", expand=True, padx=30, pady=20)

        # Header
        h = tk.Frame(inner, bg=CARD); h.pack(fill="x", pady=(0, 15))
        tk.Label(h, text="🎗️  कैंसर जागरूकता सर्वेक्षण  ",
                 font=("Sans", 9, "bold"), bg="#0f2a24", fg=GREEN_L,
                 padx=15, pady=6).pack(pady=(0, 8))
        tk.Label(h, text="🩺  कैंसर स्क्रीनिंग एवं स्वास्थ्य इतिहास",
                 font=("Sans", 20, "bold"), bg=CARD, fg=GREEN_L).pack()
        tk.Label(h, text="20 प्रश्न  •  गोपनीय  •  JSON ऑटो-सेव",
                 font=("Sans", 10), bg=CARD, fg=TXT2).pack()
        tk.Label(h, text="💻  Developed by Raj Gautam",
                 font=("Sans", 8, "italic"), bg=CARD, fg=PINK_L).pack(pady=(6, 0))
        tk.Frame(h, bg=BORDER, height=1).pack(fill="x", pady=(10, 0))

        # Progress
        pf = tk.Frame(inner, bg=CARD); pf.pack(fill="x", pady=(0, 12))
        self.pc = tk.Canvas(pf, height=6, bg=CARD, highlightthickness=0)
        self.pc.pack(fill="x")
        self.root.after(200, self.draw_progress)

        # Scroll
        cont = tk.Frame(inner, bg=CARD); cont.pack(fill="both", expand=True)
        self.fc = tk.Canvas(cont, bg=CARD, highlightthickness=0)
        self.fc.pack(side="left", fill="both", expand=True)
        sb = ttk.Scrollbar(cont, orient="vertical",
                           command=self.fc.yview, style="D.Vertical.TScrollbar")
        sb.pack(side="right", fill="y")
        self.fc.configure(yscrollcommand=sb.set)

        self.ff = tk.Frame(self.fc, bg=CARD)
        self.fcw = self.fc.create_window((0, 0), window=self.ff, anchor="nw")
        self.ff.bind("<Configure>",
                     lambda e: self.fc.configure(scrollregion=self.fc.bbox("all")))
        self.fc.bind("<Configure>",
                     lambda e: self.fc.itemconfig(self.fcw, width=e.width))
        self.fc.bind_all("<MouseWheel>", self.wheel)
        self.fc.bind_all("<Button-4>", self.wheel)
        self.fc.bind_all("<Button-5>", self.wheel)

        for sec in SECTIONS:
            self.section(sec)
        self.buttons()

        # Footer
        f = tk.Frame(inner, bg=CARD); f.pack(fill="x", side="bottom", pady=(8, 0))
        tk.Frame(f, bg=BORDER, height=1).pack(fill="x", pady=(0, 6))
        tk.Label(f, text="💻 Designed & Developed with ❤️ by Raj Gautam  •  Cancer.ser",
                 font=("Sans", 8), bg=CARD, fg=TXT2).pack()

    def draw_progress(self):
        self.pc.delete("all")
        w = self.pc.winfo_width() or 800
        gap = 8; sw_ = (w - gap * 3) / 4
        for i, c in enumerate([GREEN, PINK, BLUE, RED]):
            self.pc.create_rectangle(i*(sw_+gap), 0,
                                     i*(sw_+gap)+sw_, 6,
                                     fill=c, outline=c)

    def section(self, sec):
        sf = tk.Frame(self.ff, bg=CARD); sf.pack(fill="x", pady=(0, 15), padx=5)
        hf = tk.Frame(sf, bg=CARD); hf.pack(fill="x", pady=(0, 10))
        tk.Label(hf, text=sec["icon"], font=("Sans", 14),
                 bg=sec["color"], fg=BG, width=3, height=1).pack(side="left", padx=(0, 10))
        tk.Label(hf, text=sec["title"], font=("Sans", 13, "bold"),
                 bg=CARD, fg=sec["color"]).pack(side="left")
        for q in sec["questions"]:
            self.question(sf, q, sec["color"])
        tk.Frame(sf, bg=BORDER, height=1).pack(fill="x", pady=(10, 0))

    def question(self, p, q, col):
        qf = tk.Frame(p, bg=CARD); qf.pack(fill="x", pady=(8, 4), padx=(10, 0))
        tk.Label(qf, text=q["text"], font=("Sans", 10, "bold"),
                 bg=CARD, fg=TXT, wraplength=750, justify="left",
                 anchor="w").pack(fill="x", pady=(0, 6))
        t = q["type"]

        if t == "radio":
            self.radios(qf, q, col)
        elif t == "radio_with_text":
            self.radios(qf, q, col)
            var = tk.StringVar()
            e = tk.Entry(qf, textvariable=var, font=("Sans", 9),
                         bg=CARD2, fg=TXT2, insertbackground=GREEN,
                         relief="flat", highlightthickness=1,
                         highlightbackground=BORDER, highlightcolor=col)
            e.pack(fill="x", pady=(6, 0), padx=(0, 5))
            ph = q.get("extra_placeholder", ""); e.insert(0, ph)

            def fi(ev, e=e, ph=ph):
                if e.get() == ph:
                    e.delete(0, tk.END); e.config(fg=TXT)
            def fo(ev, e=e, ph=ph):
                if not e.get().strip():
                    e.insert(0, ph); e.config(fg=TXT2)
            e.bind("<FocusIn>", fi); e.bind("<FocusOut>", fo)
            self.et[q["id"]] = (e, var, ph)
        elif t == "text_area":
            ta = scrolledtext.ScrolledText(qf, height=3, font=("Sans", 9),
                                           bg=CARD2, fg=TXT, insertbackground=GREEN,
                                           relief="flat", highlightthickness=1,
                                           highlightbackground=BORDER,
                                           highlightcolor=col, wrap="word")
            ta.pack(fill="x", pady=(4, 0), padx=(0, 5))
            self.ta[q["id"]] = ta

    def radios(self, p, q, col):
        var = tk.StringVar(); self.rv[q["id"]] = var
        f = tk.Frame(p, bg=CARD); f.pack(fill="x", pady=(0, 4))
        for o in q["options"]:
            tk.Radiobutton(f, text=o, variable=var, value=o, font=("Sans", 9),
                           bg=CARD, fg=TXT2, selectcolor=CARD2,
                           activebackground=CARD, activeforeground=TXT,
                           highlightthickness=0, bd=0, padx=8, pady=4,
                           cursor="hand2").pack(side="left", padx=(0, 15))

    def buttons(self):
        bf = tk.Frame(self.ff, bg=CARD); bf.pack(fill="x", pady=(20, 10), padx=5)
        tk.Button(bf, text="↺  रीसेट", font=("Sans", 10, "bold"),
                  bg=CARD2, fg=TXT2, activebackground=BORDER,
                  activeforeground=TXT, relief="flat", bd=0,
                  padx=25, pady=10, cursor="hand2",
                  command=self.reset).pack(side="left", padx=(0, 10))
        tk.Button(bf, text="✈  सबमिट करें (JSON सेव)", font=("Sans", 11, "bold"),
                  bg=GREEN, fg=BG, activebackground=GREEN_L, activeforeground=BG,
                  relief="flat", bd=0, padx=35, pady=10, cursor="hand2",
                  command=self.submit).pack(side="left", fill="x", expand=True)

        # Show results folder path
        tk.Label(self.ff, text=f"💾  JSON सेव: {RESULTS_DIR}",
                 font=("Sans", 8), bg=CARD, fg=GREEN_L).pack(pady=(8, 0))
        tk.Label(self.ff, text="🔒  आपके उत्तर पूरी तरह गोपनीय हैं।",
                 font=("Sans", 8), bg=CARD, fg=TXT2).pack(pady=(2, 0))

    def wheel(self, e):
        if e.num == 5 or e.delta < 0: self.fc.yview_scroll(1, "units")
        elif e.num == 4 or e.delta > 0: self.fc.yview_scroll(-1, "units")

    # ---------- COLLECT + SAVE ----------
    def collect(self):
        """Collect all answers into a structured dict."""
        sections_data = []
        total = 0; answered = 0

        for sec in SECTIONS:
            sec_answers = {}
            for q in sec["questions"]:
                total += 1
                qid = q["id"]; qt = q["type"]
                entry = {"question": q["text"], "answer": "", "details": ""}

                if qt == "radio":
                    v = self.rv[qid].get()
                    if v: entry["answer"] = v; answered += 1
                elif qt == "radio_with_text":
                    v = self.rv[qid].get()
                    if v: entry["answer"] = v; answered += 1
                    if qid in self.et:
                        e, _, ph = self.et[qid]
                        txt = e.get().strip()
                        if txt and txt != ph:
                            entry["details"] = txt
                elif qt == "text_area":
                    w = self.ta.get(qid)
                    if w:
                        txt = w.get("1.0", "end-1c").strip()
                        if txt:
                            entry["answer"] = txt; answered += 1

                sec_answers[qid] = entry

            sections_data.append({
                "title": sec["title"],
                "title_en": sec.get("title_en", ""),
                "answers": sec_answers
            })

        return sections_data, total, answered

    def submit(self):
        # Validate required
        for sec in SECTIONS:
            for q in sec["questions"]:
                if q.get("required"):
                    v = self.rv.get(q["id"])
                    if v and not v.get():
                        messagebox.showwarning("अपूर्ण उत्तर",
                                               f"कृपया अनिवार्य प्रश्न का उत्तर दें:\n\n{q['text']}")
                        return

        now = datetime.now()
        ts = now.strftime("%Y-%m-%d %H:%M:%S")
        sid = "survey_" + now.strftime("%Y%m%d_%H%M%S")

        sections_data, total, answered = self.collect()

        payload = {
            "id": sid,
            "app": "cancer",
            "version": "1.0.0",
            "developer": "Raj Gautam",
            "project": "Cancer.ser",
            "timestamp": ts,
            "summary": {
                "total_questions": total,
                "answered": answered,
                "skipped": total - answered
            },
            "sections": sections_data,
            "footer": {
                "generator": "Cancer Survey App",
                "platform": platform.system(),
                "python": platform.python_version()
            }
        }

        # Save JSON
        try:
            os.makedirs(RESULTS_DIR, exist_ok=True)
            fname = os.path.join(RESULTS_DIR, sid + ".json")
            with open(fname, "w", encoding="utf-8") as f:
                json.dump(payload, f, ensure_ascii=False, indent=2)

            messagebox.showinfo(
                "✅ सबमिट हो गया",
                f"धन्यवाद! आपका सर्वेक्षण सफलतापूर्वक सेव हो गया।\n\n"
                f"📅 दिनांक: {ts}\n"
                f"✅ उत्तर: {answered}/{total}\n\n"
                f"💾 JSON फ़ाइल:\n{fname}\n\n"
                f"आप अकेले नहीं हैं। 💙"
            )
        except Exception as ex:
            messagebox.showerror("फ़ाइल त्रुटि", f"JSON सेव नहीं हो सका:\n{ex}")
            return

        # Ask reset
        if messagebox.askyesno("नया सर्वेक्षण",
                               "क्या आप नया सर्वेक्षण शुरू करना चाहेंगे?"):
            self.reset()

    def reset(self):
        for v in self.rv.values(): v.set("")
        for e, _, ph in self.et.values():
            e.delete(0, tk.END); e.insert(0, ph); e.config(fg=TXT2)
        for w in self.ta.values(): w.delete("1.0", tk.END)
        self.fc.yview_moveto(0)

    def animate(self):
        if not self.anim: return
        self.step += .02
        self.cv.delete("orb")
        w = self.cv.winfo_width() or 1000
        h = self.cv.winfo_height() or 750
        for x, y, r, c in [
            (w*.15+math.sin(self.step)*60, h*.1+math.cos(self.step*.7)*40, 120, GREEN),
            (w*.85+math.cos(self.step*.8)*70, h*.85+math.sin(self.step*.6)*50, 140, PINK),
            (w*.6+math.sin(self.step*.5)*80, h*.4+math.cos(self.step*.9)*60, 100, BLUE),
            (w*.2+math.cos(self.step*.7)*50, h*.75+math.sin(self.step*.8)*55, 90, RED)]:
            for i in range(8, 0, -1):
                rr = r*i/8
                self.cv.create_oval(x-rr, y-rr, x+rr, y+rr,
                                    fill=self.blend(c, BG, i/8),
                                    outline="", tags="orb")
        self.root.after(50, self.animate)

    def blend(self, c1, c2, r):
        a = [int(c1[i:i+2], 16) for i in (1, 3, 5)]
        b = [int(c2[i:i+2], 16) for i in (1, 3, 5)]
        return "#%02x%02x%02x" % tuple(int(a[i]*r + b[i]*(1-r)) for i in range(3))


def main():
    root = tk.Tk()
    app = App(root)
    root.protocol("WM_DELETE_WINDOW",
                  lambda: (setattr(app, "anim", False), root.destroy()))
    root.mainloop()


if __name__ == "__main__":
    main()
PYEOF

    # ---------- `cancer` command ----------
    cat > "$ROOT/usr/bin/cancer" << 'CMD'
#!/bin/bash
exec python3 /usr/share/cancer-survey/cancer_survey.py "$@"
CMD
    chmod 755 "$ROOT/usr/bin/cancer"

    # ---------- Desktop entry ----------
    cat > "$ROOT/usr/share/applications/cancer.desktop" << 'D'
[Desktop Entry]
Version=1.0
Type=Application
Name=Cancer Survey
Name[hi]=कैंसर सर्वेक्षण
Comment=Cancer Screening & Health History - Raj Gautam
Exec=cancer
Icon=cancer
Terminal=false
Categories=Education;Medical;Science;
Keywords=cancer;survey;health;medical;json;
StartupNotify=true
D
    chmod 644 "$ROOT/usr/share/applications/cancer.desktop"

    # ---------- Icon ----------
    cat > "$ROOT/usr/share/icons/hicolor/256x256/apps/cancer.svg" << 'SVG'
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
  <rect width="256" height="256" rx="48" fill="#0b0f17"/>
  <defs>
    <linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#00c9a7"/>
      <stop offset="33%" stop-color="#4a9eff"/>
      <stop offset="66%" stop-color="#ff6b9d"/>
      <stop offset="100%" stop-color="#ff4d6d"/>
    </linearGradient>
  </defs>
  <circle cx="128" cy="128" r="96" fill="url(#g)"/>
  <rect x="112" y="60" width="32" height="136" fill="#fff" rx="8"/>
  <rect x="60" y="112" width="136" height="32" fill="#fff" rx="8"/>
</svg>
SVG
    cp "$ROOT/usr/share/icons/hicolor/256x256/apps/cancer.svg" \
       "$ROOT/usr/share/pixmaps/cancer.svg"

    # ---------- Docs ----------
    cat > "$ROOT/usr/share/doc/$PKG/README" << 'RD'
Cancer Survey - Cancer.ser
Developer: Raj Gautam

Run:        cancer
JSON saved: ~/cancer_survey_results/survey_*.json
Uninstall:  sudo apt remove cancer-survey
RD

    # ---------- control ----------
    SIZE=$(du -sk "$ROOT" | cut -f1)
    cat > "$ROOT/DEBIAN/control" << CTL
Package: cancer-survey
Version: $VER
Architecture: all
Maintainer: Raj Gautam <raj@cancer.ser>
Installed-Size: $SIZE
Depends: python3 (>= 3.7), python3-tk
Section: science
Priority: optional
Homepage: https://cancer.ser
Description: Cancer Screening & Health History Survey
 20-question survey app by Raj Gautam.
 Saves each response as JSON.
 .
 Run with: cancer
CTL
    chmod 644 "$ROOT/DEBIAN/control"

    # ---------- postinst ----------
    cat > "$ROOT/DEBIAN/postinst" << 'PI'
#!/bin/bash
set -e
command -v update-desktop-database &>/dev/null && update-desktop-database -q || true
command -v gtk-update-icon-cache &>/dev/null && gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor || true
command -v xdg-icon-resource &>/dev/null && xdg-icon-resource forceupdate --theme hicolor 2>/dev/null || true
for H in /home/* /root; do
  [ -d "$H" ] && mkdir -p "$H/cancer_survey_results" && \
    chown $(basename $H):$(basename $H) "$H/cancer_survey_results" 2>/dev/null || true
done
echo ""
echo "🎗️  Cancer Survey installed!"
echo "   ▶  Run:    cancer"
echo "   💾  JSON:   ~/cancer_survey_results/"
echo "   💻  Dev:    Raj Gautam"
echo ""
exit 0
PI
    chmod 755 "$ROOT/DEBIAN/postinst"

    cat > "$ROOT/DEBIAN/prerm" << 'PR'
#!/bin/bash
set -e
exit 0
PR
    chmod 755 "$ROOT/DEBIAN/prerm"

    cat > "$ROOT/DEBIAN/postrm" << 'PO'
#!/bin/bash
set -e
[ "$1" = "purge" ] && rm -rf /usr/share/cancer-survey 2>/dev/null || true
command -v gtk-update-icon-cache &>/dev/null && gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor 2>/dev/null || true
command -v update-desktop-database &>/dev/null && update-desktop-database -q 2>/dev/null || true
exit 0
PO
    chmod 755 "$ROOT/DEBIAN/postrm"

    # ---------- Permissions ----------
    find "$ROOT" -type d -exec chmod 755 {} \;
    find "$ROOT" -type f -exec chmod 644 {} \;
    chmod 755 "$ROOT/usr/bin/cancer" \
              "$ROOT/DEBIAN/postinst" \
              "$ROOT/DEBIAN/prerm" \
              "$ROOT/DEBIAN/postrm"

    # ---------- Build ----------
    echo -e "\n${B}🔨 Building .deb...${NC}"
    dpkg-deb --build --root-owner-group "$ROOT" "$DEB" >/dev/null
    echo -e "${G}✅ $(basename "$DEB")  ($(du -h "$DEB" | cut -f1))${NC}"
}
# ============================================================

case "$CH" in
  1) build
     echo -e "\n${B}📥 Installing...${NC}"
     sudo apt install -y "$DEB"
     echo -e "\n${G}${BD}✅ Done! Type: cancer${NC}"
     ;;
  2) build
     echo -e "\n${G}👉 Install:  sudo apt install ./$(basename "$DEB")${NC}"
     ;;
  3) D=$(ls -t ./*.deb 2>/dev/null | head -1)
     [ -z "$D" ] && { echo -e "${R}❌ No .deb found.${NC}"; exit 1; }
     echo -e "${B}📥 Installing $D...${NC}"
     sudo apt install -y "$D"
     echo -e "\n${G}✅ Done! Type: cancer${NC}"
     ;;
  4) echo -e "${B}🗑️  Uninstalling...${NC}"
     sudo apt remove -y cancer-survey || true
     sudo apt purge -y cancer-survey 2>/dev/null || true
     echo -e "${G}✅ Removed. JSON files in ~/cancer_survey_results/ are safe.${NC}"
     ;;
  5) echo -e "${C}Bye! 🎗️  — Raj Gautam${NC}"; exit 0
     ;;
  *) echo -e "${R}Invalid.${NC}"; exit 1
     ;;
esac

echo ""
echo -e "${P}💻 Raj Gautam  |  Cancer.ser${NC}"