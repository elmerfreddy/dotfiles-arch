# ============================================
# Qtile - Configuracion principal
# ============================================
# Documentacion: https://docs.qtile.org/

import os
import subprocess
from libqtile import hook

# Nota: el monkey-patch de Bar._actual_draw se retiró.
# Qtile 0.37 ya protege _actual_draw contra drawer finalizado
# (bar.py: guard `if not hasattr(self, "drawer"): return` tras resetear _draw_queued).

from settings.keys import keys
from settings.groups import groups
from settings.layouts import layouts, floating_layout
from settings.screens import screens
from settings.mouse import mouse
from settings.widgets import widget_defaults, extension_defaults


@hook.subscribe.startup_once
def autostart():
    """Ejecutar script de autostart al iniciar Qtile."""
    script = os.path.expanduser("~/.config/qtile/autostart.sh")
    if os.path.isfile(script):
        subprocess.Popen([script])


# Configuracion general
dgroups_key_binder = None
dgroups_app_rules = []
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True  # autorandr (mod+shift+p) requiere reconfigurar barras al cambiar salidas
auto_minimize = True
wl_input_rules = None
