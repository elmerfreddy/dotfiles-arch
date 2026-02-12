# ============================================
# Qtile - Groups (Workspaces)
# ============================================

from libqtile.config import Group, Key
from libqtile.lazy import lazy
from settings.keys import keys, mod

# Grupos con iconos (requiere Nerd Font)
groups = [
    Group("1", label=""),    # Terminal
    Group("2", label=""),    # Navegador
    Group("3", label=""),    # Codigo
    Group("4", label=""),    # Archivos
    Group("5", label=""),    # Chat
    Group("6", label=""),    # Musica
    Group("7", label=""),    # Config
    Group("8", label=""),    # Docker
    Group("9", label=""),    # Misc
]

for g in groups:
    keys.extend([
        # Cambiar al workspace
        Key(
            [mod], g.name,
            lazy.group[g.name].toscreen(),
            desc=f"Cambiar al grupo {g.name}",
        ),
        # Mover ventana al workspace
        Key(
            [mod, "shift"], g.name,
            lazy.window.togroup(g.name, switch_group=True),
            desc=f"Mover ventana al grupo {g.name}",
        ),
    ])
