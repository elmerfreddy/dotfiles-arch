# ============================================
# Qtile - Widgets para la barra
# ============================================

from libqtile import widget
from settings.theme import colors

# Fuente por defecto
widget_defaults = dict(
    font="JetBrainsMono Nerd Font",
    fontsize=13,
    padding=3,
    foreground=colors["fg"],
    background=colors["bg"],
)

extension_defaults = widget_defaults.copy()


def separator():
    return widget.Sep(
        linewidth=1,
        padding=10,
        foreground=colors["bg3"],
        background=colors["bg"],
    )


def spacer(length=10):
    return widget.Spacer(length=length)


def primary_widgets():
    """Widgets para la barra principal."""
    return [
        spacer(6),

        # Logo / Layout actual
        widget.CurrentLayoutIcon(
            scale=0.65,
            foreground=colors["fg"],
            background=colors["bg"],
        ),

        spacer(4),

        # Grupos / Workspaces
        widget.GroupBox(
            fontsize=16,
            margin_y=3,
            margin_x=4,
            padding_y=5,
            padding_x=3,
            borderwidth=3,
            active=colors["fg"],
            inactive=colors["bg4"],
            rounded=False,
            highlight_color=colors["bg1"],
            highlight_method="line",
            this_current_screen_border=colors["blue_bright"],
            this_screen_border=colors["blue"],
            other_current_screen_border=colors["aqua"],
            other_screen_border=colors["bg3"],
            urgent_alert_method="line",
            urgent_border=colors["red_bright"],
            foreground=colors["fg"],
            background=colors["bg"],
        ),

        separator(),

        # Nombre de la ventana actual
        widget.WindowName(
            foreground=colors["fg2"],
            background=colors["bg"],
            max_chars=50,
        ),

        # --- Zona derecha ---

        # Systray
        widget.Systray(
            background=colors["bg"],
            padding=5,
        ),

        separator(),

        # CPU
        widget.TextBox(
            text=" ",
            fontsize=15,
            foreground=colors["yellow_bright"],
        ),
        widget.CPU(
            format="{load_percent}%",
            foreground=colors["yellow_bright"],
            update_interval=2,
        ),

        separator(),

        # Memoria
        widget.TextBox(
            text="󰍛 ",
            fontsize=15,
            foreground=colors["aqua_bright"],
        ),
        widget.Memory(
            format="{MemUsed:.0f}{mm}",
            measure_mem="M",
            foreground=colors["aqua_bright"],
            update_interval=2,
        ),

        separator(),

        # Volumen
        widget.TextBox(
            text="󰕾 ",
            fontsize=15,
            foreground=colors["purple_bright"],
        ),
        widget.PulseVolume(
            foreground=colors["purple_bright"],
            limit_max_volume=True,
            step=5,
        ),

        separator(),

        # Red
        widget.TextBox(
            text="󰖩 ",
            fontsize=15,
            foreground=colors["blue_bright"],
        ),
        widget.Net(
            format="{down:.0f}{down_suffix} ↓↑ {up:.0f}{up_suffix}",
            foreground=colors["blue_bright"],
            update_interval=2,
        ),

        separator(),

        # Fecha y hora
        widget.TextBox(
            text=" ",
            fontsize=15,
            foreground=colors["orange_bright"],
        ),
        widget.Clock(
            format="%d/%m/%Y  %H:%M",
            foreground=colors["orange_bright"],
        ),

        spacer(6),
    ]
