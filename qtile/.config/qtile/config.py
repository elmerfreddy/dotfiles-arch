# ============================================
# Qtile - Configuracion principal
# ============================================
# Documentacion: https://docs.qtile.org/

import os
import subprocess
from libqtile import hook

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


@hook.subscribe.screens_reconfigured
def screens_reconfigured():
    """Sanear referencias de grupos tras reconfigurar pantallas.

    Se ejecuta DESPUÉS de que qtile actualiza su estado interno de
    pantallas. Limpia grupos con .screen obsoleto y resetea
    previous_group de las pantallas activas si apunta a un grupo
    en estado inconsistente.
    """
    from libqtile import qtile

    active_screens = set(qtile.screens)

    for group in qtile.groups:
        if group.screen is not None and group.screen not in active_screens:
            group.screen = None

    for scr in qtile.screens:
        prev = getattr(scr, 'previous_group', None)
        if prev is not None:
            if prev.screen is None or prev.screen not in active_screens:
                scr.previous_group = None


# Configuracion general
dgroups_key_binder = None
dgroups_app_rules = []
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True
auto_minimize = True
wl_input_rules = None
wmname = "LG3D"  # Compatibilidad con Java
