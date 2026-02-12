# ============================================
# Qtile - Layouts
# ============================================

from libqtile import layout
from libqtile.config import Match
from settings.theme import colors

# Configuracion compartida para los layouts
layout_defaults = {
    "border_width": 2,
    "margin": 6,
    "border_focus": colors["blue_bright"],
    "border_normal": colors["bg2"],
}

layouts = [
    # MonadTall: una ventana principal a la izquierda, el resto apilado a la derecha
    layout.MonadTall(
        **layout_defaults,
        single_border_width=0,
        single_margin=0,
    ),
    # Max: cada ventana ocupa toda la pantalla
    layout.Max(),
    # Columns: columnas redimensionables libremente
    layout.Columns(
        **layout_defaults,
        border_focus_stack=colors["aqua_bright"],
        border_on_single=False,
    ),
    # Floating: se configura abajo
]

# Reglas para ventanas que siempre deben ser flotantes
floating_layout = layout.Floating(
    border_width=2,
    border_focus=colors["orange_bright"],
    border_normal=colors["bg2"],
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),
        Match(wm_class="makebranch"),
        Match(wm_class="maketag"),
        Match(wm_class="ssh-askpass"),
        Match(title="branchdialog"),
        Match(title="pinentry"),
        Match(wm_class="pavucontrol"),
        Match(wm_class="lxappearance"),
        Match(wm_class="arandr"),
        Match(wm_class="feh"),
        Match(wm_class="Galculator"),
    ],
)
