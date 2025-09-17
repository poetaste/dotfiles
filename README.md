
# Fen's Rice

 Just my own **Gruvbox-flavored Hyprland** setup.
  
 ⚠️ This is not a plug-and-play dotfiles repo — a lot of the paths and scripts are hardcoded to my machine.

---

## Screenshots

### Main
| Normal Desktop | Tiling |
|-----------------|-------|
| ![desktop](screenshots/fetch.png) | ![tiling](screenshots/wuhh.png) |

### Extras
| YaST | Hyprlock |
|------|---------|
| ![yast ig](screenshots/yast.png) | ![hyprlock](screenshots/hyprlock.png) |

---

## Why

I built this because I wanted:
- a **dark, warm look** that doesn’t strain my eyes,
- tiling workflow with **Hyprland**,  
- some small tweaks and scripts that just make sense for *my* daily use.

It’s messy, but it works for me.

---

## What’s Inside

**Core**
- OS: openSUSE Tumbleweed
- WM: [Hyprland](https://github.com/hyprwm/Hyprland)

**Look & Feel**
- Colors: [Gruvbox Dark](https://github.com/morhetz/gruvbox)
- GTK Theme: [Gruvbox Dark Hard](…)
- Icons: [Gruvbox Plus Dark](…)
- Cursor: [ArcAurora](…)

**Apps**
- Bar: Waybar
- Widgets: eww
- Terminal: Kitty
- Fonts: JetBrainsMono Nerd Font, Pacifico, Montserrat

---

## Installation

 ⚠️ This configuration does **not** include an installation guide.  
 It’s highly customized and contains hard-coded paths, so please adapt it to your own setup if you want to use it.

> **Note**
> - **YaST Qt theme fix:** YaST doesn't apply Qt themes in tiling window managers. To fix this, copy `qt-platformtheme.sh` → `/etc/profile.d/` make it executable and copy user's Kvantum and Qt5 config files to `/etc/xdg/Kvantum/` and `/etc/xdg/qt5ct/`

> - **Widget's music player executable:** `MediaControl` → `/usr/local/bin/`

> - **Gruvbox TTY Theme for the funsies:** `gruvbox-tty.service` → `/etc/systemd/system/` and then `# systemctl enable gruvbox-tty.service`

---


