# ============================================
# Qtile - Groups (Workspaces)
# ============================================

from libqtile.config import Group, Key
from libqtile.lazy import lazy
from settings.keys import keys, mod

# Grupos con números
groups = [
    Group("1", label="1"),    # Terminal
    Group("2", label="2"),    # Navegador
    Group("3", label="3"),    # Codigo
    Group("4", label="4"),    # Archivos
    Group("5", label="5"),    # Chat
    Group("6", label="6"),    # Musica
    Group("7", label="7"),    # Config
    Group("8", label="8"),    # Docker
    Group("9", label="9"),    # Misc
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
