# Dotfiles - Arch Linux + Qtile

Dotfiles personales para Arch Linux con Qtile como window manager, gestionados con [GNU Stow](https://www.gnu.org/software/stow/).

## Componentes

| Componente | Descripcion |
|-----------|-------------|
| **Qtile** | Window manager (tiling) con barra integrada |
| **Alacritty** | Terminal emulador GPU-accelerated |
| **Zsh + Oh My Zsh** | Shell con plugins y autocompletado |
| **Neovim (LazyVim)** | Editor de texto/codigo |
| **Rofi** | Lanzador de aplicaciones |
| **Picom** | Compositor (transparencias, sombras) |
| **Tmux** | Multiplexor de terminal |
| **Git** | Control de versiones |
| **Docker** | Aliases via plugin de Oh My Zsh |

**Tema:** Gruvbox (consistente en todos los componentes)

## Requisitos

- Arch Linux (o derivado)
- [yay](https://github.com/Jguer/yay) (AUR helper)
- Git

## Instalacion

```bash
# 1. Clonar el repositorio
git clone https://github.com/TU_USUARIO/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Ejecutar el script de instalacion
chmod +x install.sh
./install.sh
```

El script `install.sh` se encarga de:
1. Instalar todos los paquetes necesarios via `yay`
2. Instalar Oh My Zsh y sus plugins externos
3. Instalar LazyVim para Neovim
4. Aplicar todos los dotfiles con GNU Stow

## Uso manual con Stow

Si prefieres aplicar los dotfiles manualmente:

```bash
cd ~/dotfiles

# Aplicar un modulo especifico
stow alacritty
stow qtile
stow zsh
stow nvim
stow git
stow picom
stow rofi
stow tmux
stow btop
stow bat
stow thunar

# Aplicar todos los modulos
stow */

# Eliminar symlinks de un modulo
stow -D alacritty
```

## Keybindings de Qtile

| Atajo | Accion |
|-------|--------|
| `Super + Enter` | Abrir Alacritty |
| `Super + d` | Rofi (lanzador) |
| `Super + q` | Cerrar ventana |
| `Super + h/j/k/l` | Navegar entre ventanas |
| `Super + Shift + h/l` | Redimensionar ventana |
| `Super + [1-9]` | Cambiar workspace |
| `Super + Shift + [1-9]` | Mover ventana a workspace |
| `Super + Tab` | Cambiar layout |
| `Super + f` | Fullscreen |
| `Super + Space` | Toggle floating |
| `Super + e` | Thunar (file manager) |
| `Super + Shift + r` | Restart Qtile |
| `Super + Shift + q` | Logout |

## Estructura

```
dotfiles/
├── install.sh
├── packages.txt
├── alacritty/.config/alacritty/
├── qtile/.config/qtile/
│   ├── config.py
│   ├── autostart.sh
│   └── settings/
├── zsh/
├── nvim/.config/nvim/
├── git/
├── picom/.config/picom/
├── rofi/.config/rofi/
├── tmux/
├── btop/.config/btop/
├── bat/.config/bat/
└── thunar/.config/Thunar/
```
