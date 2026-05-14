# ============================================
# Qtile - Configuracion principal
# ============================================
# Documentacion: https://docs.qtile.org/

import os
import subprocess
from libqtile import bar, hook

# Monkey-patch: guard Bar._actual_draw against finalize/draw race
# (qtile 0.35.0 + cffi 2.0 + Python 3.14 bug: drawer deleted before queued callback fires)
# Idempotent: skip re-patching on qtile restart (same process, config re-import)
if not getattr(bar.Bar._actual_draw, "_is_safe_patch", False):
    _original_actual_draw = bar.Bar._actual_draw

    def _safe_actual_draw(self):
        if not hasattr(self, "drawer"):
            return
        _original_actual_draw(self)

    _safe_actual_draw._is_safe_patch = True
    bar.Bar._actual_draw = _safe_actual_draw

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
reconfigure_screens = False  # avoids draw-after-finalize race on bar reconfigure
auto_minimize = True
wl_input_rules = None
