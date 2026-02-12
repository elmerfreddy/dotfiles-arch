#!/usr/bin/env bash
# ============================================
# Qtile - Autostart script
# Se ejecuta una vez al iniciar Qtile
# ============================================

# Compositor
picom --daemon &

# Wallpaper
feh --bg-fill --no-fehbg ~/.config/wallpapers/wallpaper.jpg 2>/dev/null || \
feh --bg-fill --no-fehbg /usr/share/backgrounds/archlinux/simple.png 2>/dev/null &

# Politica de autenticacion
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# Tray applets
nm-applet &
volumeicon &

# Notificaciones
dunst &

# Configurar cursor
xsetroot -cursor_name left_ptr &
