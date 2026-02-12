# ============================================
# Qtile - Screens (pantallas y barras)
# ============================================

from libqtile.config import Screen
from libqtile import bar
from settings.theme import colors
from settings.widgets import primary_widgets

screens = [
    Screen(
        top=bar.Bar(
            primary_widgets(),
            size=28,
            background=colors["bg"],
            border_width=[0, 0, 2, 0],
            border_color=colors["bg1"],
            margin=[4, 6, 0, 6],  # top, right, bottom, left
            opacity=0.95,
        ),
    ),
]
