# ============================================
# Qtile - Mouse bindings
# ============================================

from libqtile.config import Click, Drag
from libqtile.lazy import lazy
from settings.keys import mod

mouse = [
    # Super + Click izquierdo: mover ventana flotante
    Drag(
        [mod], "Button1",
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    # Super + Click derecho: redimensionar ventana flotante
    Drag(
        [mod], "Button3",
        lazy.window.set_size_floating(),
        start=lazy.window.get_size(),
    ),
    # Super + Click medio: traer ventana al frente
    Click(
        [mod], "Button2",
        lazy.window.bring_to_front(),
    ),
]
