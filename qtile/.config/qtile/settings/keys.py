# ============================================
# Qtile - Keybindings
# ============================================

from libqtile.config import Key
from libqtile.lazy import lazy

mod = "mod4"  # Super key
terminal = "alacritty"

keys = [
    # ---- Navegacion entre ventanas (estilo vim) ----
    Key([mod], "h", lazy.layout.left(), desc="Mover foco a la izquierda"),
    Key([mod], "l", lazy.layout.right(), desc="Mover foco a la derecha"),
    Key([mod], "j", lazy.layout.down(), desc="Mover foco abajo"),
    Key([mod], "k", lazy.layout.up(), desc="Mover foco arriba"),
    Key([mod], "n", lazy.layout.next(), desc="Siguiente ventana"),

    # ---- Mover ventanas ----
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Mover ventana a la izquierda"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Mover ventana a la derecha"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Mover ventana abajo"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Mover ventana arriba"),

    # ---- Redimensionar ventanas ----
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Crecer ventana izquierda"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Crecer ventana derecha"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Crecer ventana abajo"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Crecer ventana arriba"),
    Key([mod, "shift"], "n", lazy.layout.normalize(), desc="Normalizar tamanos"),

    # ---- Layout ----
    Key([mod], "Tab", lazy.next_layout(), desc="Siguiente layout"),
    Key([mod, "shift"], "Tab", lazy.prev_layout(), desc="Layout anterior"),

    # ---- Ventanas ----
    Key([mod], "q", lazy.window.kill(), desc="Cerrar ventana"),
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc="Toggle fullscreen"),
    Key([mod], "space", lazy.window.toggle_floating(), desc="Toggle floating"),
    Key([mod], "m", lazy.window.toggle_minimize(), desc="Toggle minimize"),

    # ---- Aplicaciones ----
    Key([mod], "Return", lazy.spawn(terminal), desc="Abrir terminal"),
    Key([mod], "d", lazy.spawn("rofi -show drun"), desc="Rofi launcher"),
    Key([mod], "r", lazy.spawn("rofi -show run"), desc="Rofi run"),
    Key([mod], "e", lazy.spawn("thunar"), desc="File manager"),
    Key([mod], "b", lazy.spawn("brave"), desc="Navegador web"),
    Key([mod], "p", lazy.spawn("arandr"), desc="Configuracion de pantallas"),

    # ---- Screenshots ----
    Key([], "Print", lazy.spawn("scrot '%Y-%m-%d_%H-%M-%S.png' -e 'mv $f ~/Pictures/'"), desc="Screenshot completo"),
    Key([mod], "Print", lazy.spawn("scrot -s '%Y-%m-%d_%H-%M-%S.png' -e 'mv $f ~/Pictures/'"), desc="Screenshot seleccion"),

    # ---- Audio ----
    Key([], "XF86AudioRaiseVolume", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%"), desc="Subir volumen"),
    Key([], "XF86AudioLowerVolume", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%"), desc="Bajar volumen"),
    Key([], "XF86AudioMute", lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle"), desc="Mute"),

    # ---- Brillo ----
    Key([], "XF86MonBrightnessUp", lazy.spawn("brightnessctl set +10%"), desc="Subir brillo"),
    Key([], "XF86MonBrightnessDown", lazy.spawn("brightnessctl set 10%-"), desc="Bajar brillo"),

    # ---- Qtile ----
    Key([mod, "shift"], "r", lazy.reload_config(), desc="Recargar configuracion"),
    Key([mod, "shift"], "q", lazy.shutdown(), desc="Cerrar Qtile"),
]
