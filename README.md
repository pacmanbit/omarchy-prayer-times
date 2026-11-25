# Islamic Prayer Times Bar Widget & CLI

A lightweight, zero-dependency **Islamic Prayer Times** widget and CLI for **Omarchy 4.0**, **Waybar**, **Polybar**, and any Linux status bar — featuring a **3-state dynamic color system**, daily offline caching, and automatic Adhan desktop notifications.

Defaults to **Al-Karak, Jordan** using the official **Ministry of Awqaf, Islamic Affairs and Holy Places, Jordan** (`method=JORDAN` via AlAdhan API), and is configurable for any city worldwide.

---

## Features

- **3-State Dynamic Color System**:
  - **NOW** (first 20 minutes of Salah): Vibrant Emerald Green (`#50FA7B`) → `󱡖 Fajr NOW (+5m)`
  - **CLOSE** (within 30 minutes before Salah): Warm Amber (`#FAB387`) → `󱡖 Dhuhr 12:24 (18m)`
  - **FAR** (more than 30 minutes away): Theme default foreground → `󱡖 Asr 15:17`
- **Automatic Adhan Desktop Notification** (`notify-send`) once when each prayer enters the `NOW` window.
- **Interactive Controls**:
  - **Hover**: Full daily timetable (`Fajr`, `Sunrise`, `Dhuhr`, `Asr`, `Maghrib`, `Isha`) in English & Arabic (`الفجر`, `الشروق`, `الظهر`, `العصر`, `المغرب`, `العشاء`).
  - **Left-Click**: Sends a desktop notification with today's full schedule.
  - **Right-Click**: Forces a live cache refresh from the AlAdhan API.
- **Zero External Python Dependencies**: Pure Python 3 standard library + optional `notify-send` (`libnotify`) and a Nerd Font glyph (`󱡖`).
- **Offline Daily Caching**: Fetches once per day and caches in `~/.cache/prayer-times/timings_cache.json`.

---

## Installation

### Option 1: Omarchy 4.0 Native Plugin (One Command)

Once published to GitHub, any Omarchy user can install it directly with:

```bash
omarchy plugin add https://github.com/pacmanbit/omarchy-prayer-times.git --enable --yes
```

Or install locally from a cloned copy:

```bash
git clone https://github.com/pacmanbit/omarchy-prayer-times.git
cd omarchy-prayer-times
./install.sh --omarchy-plugin --city "Al-Karak" --country "Jordan" --method "JORDAN"
```

### Option 2: Waybar / Polybar / Hyprland / Standalone CLI

```bash
git clone https://github.com/pacmanbit/omarchy-prayer-times.git
cd omarchy-prayer-times
./install.sh --waybar --city "Al-Karak" --country "Jordan" --method "JORDAN"
```

Then include [waybar/config.jsonc](waybar/config.jsonc) and [waybar/style.css](waybar/style.css) in your Waybar setup.

---

## Configuration

Edit `~/.config/prayer-times.json`:

```json
{
  "city": "Al-Karak",
  "country": "Jordan",
  "method": "JORDAN",
  "now_window": 20,
  "close_threshold": 30,
  "now_color": "#50FA7B",
  "close_color": "#FAB387"
}
```

Or pass inline plugin settings in `~/.config/omarchy/shell.json`:

```json
{
  "id": "pacmanbit.prayer-times",
  "city": "Amman",
  "country": "Jordan",
  "method": "JORDAN"
}
```

### Common AlAdhan Calculation Methods
- `JORDAN` — Ministry of Awqaf, Jordan
- `MWL` — Muslim World League
- `ISNA` — Islamic Society of North America
- `MAKKAH` — Umm Al-Qura University, Makkah
- `EGYPT` — Egyptian General Authority of Survey
- `TURKEY` — Diyanet İşleri Başkanlığı

---

## CLI Usage

```bash
prayer-times                  # Waybar/Omarchy JSON output
prayer-times --plain          # Plain text (for Polybar / tmux)
prayer-times --table          # Print full daily timetable
prayer-times --notify         # Trigger desktop notification
prayer-times --refresh        # Force API refresh
prayer-times --city London --country UK --method MWL --table
```
