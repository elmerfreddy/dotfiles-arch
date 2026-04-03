# ============================================
# Qtile - Screens (pantallas y barras)
# ============================================

from libqtile.config import Screen
from libqtile import bar
from settings.theme import colors
from settings.widgets import primary_widgets

screens = [
    Screen(
        top=bar.Gap(2),
        left=bar.Gap(2),
        right=bar.Gap(2),
        bottom=bar.Bar(
            primary_widgets(),
            size=28,
            background=colors["bg"],
            border_width=[2, 0, 0, 0],
            border_color=colors["bg1"],
            margin=[1, 4, 4, 4],  # top, right, bottom, left
            opacity=0.95,
        ),
    ),
]
