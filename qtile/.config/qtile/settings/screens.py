# ============================================
# Qtile - Screens (pantallas y barras)
# ============================================

from libqtile.config import Screen
from libqtile import bar
from settings.theme import colors
from settings.widgets import primary_widgets

screens = [
    Screen(
        bottom=bar.Bar(
            primary_widgets(),
            size=28,
            background=colors["bg"],
            border_width=[2, 0, 0, 0],
            border_color=colors["bg1"],
            margin=[0, 6, 4, 6],  # top, right, bottom, left
            opacity=0.95,
        ),
    ),
]
