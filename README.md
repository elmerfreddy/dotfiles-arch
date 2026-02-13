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
| **Git** | Control de versiones con aliases utiles |
| **Dunst** | Daemon de notificaciones de escritorio |
| **Bat** | Reemplazo de `cat` con resaltado de sintaxis |
| **Btop** | Monitor de recursos del sistema |
| **Thunar** | Administrador de archivos |
| **Redshift** | Filtro de luz azul nocturna |
| **Fontconfig** | Configuracion de renderizado de fuentes |
| **Betterlockscreen** | Bloqueo de pantalla con wallpaper |
| **Viewnior** | Visor de imagenes ligero |
| **Docker** | Aliases via plugin de Oh My Zsh |

**Tema:** Gruvbox (consistente en todos los componentes)

## Requisitos

- Arch Linux (o derivado)
- [yay](https://github.com/Jguer/yay) (AUR helper, se instala automaticamente si no existe)
- Git

## Instalacion

```bash
# 1. Clonar el repositorio
git clone https://github.com/elmerfreddy/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Ejecutar el script de instalacion
chmod +x install.sh
./install.sh
```

### Que hace `install.sh`

1. Verifica que el sistema sea Arch Linux
2. Instala `yay` (AUR helper) si no esta presente
3. **Desinstala vim/gvim** si estan presentes (este entorno usa neovim exclusivamente)
4. Instala todos los paquetes desde `packages.txt` via `yay`
5. Actualiza cache de fuentes y verifica Nerd Fonts
6. Instala Oh My Zsh y plugins externos (autosuggestions, syntax-highlighting)
7. Prepara el entorno para LazyVim (respaldando configuracion previa de nvim)
8. Configura permisos de ejecucion en scripts
9. Aplica todos los dotfiles con GNU Stow (symlinks a `$HOME`)
10. Cachea el wallpaper para betterlockscreen
11. Cambia el shell predeterminado a Zsh
12. Habilita servicios del sistema: Docker, NetworkManager
13. Agrega al usuario al grupo `docker`

### Post-instalacion

Despues de ejecutar `install.sh`:

1. Cierra sesion y vuelve a iniciar
2. Selecciona **Qtile** como window manager en tu display manager
3. Abre Neovim (`nvim`) para que LazyVim instale plugins automaticamente
4. Edita `~/.gitconfig` con tu nombre y email
5. Se incluyen wallpapers de ejemplo en `~/.config/wallpapers/` (`wallpaper.jpg` se usa por defecto)
6. Usa `lxappearance` para seleccionar el tema GTK (arc-gtk-theme + papirus-icon-theme)

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
stow dunst
stow fontconfig
stow redshift
stow wallpapers

# Aplicar todos los modulos
stow */

# Eliminar symlinks de un modulo
stow -D alacritty
```

## Keybindings de Qtile

### Navegacion

| Atajo | Accion |
|-------|--------|
| `Super + h/j/k/l` | Navegar entre ventanas (vim-style) |
| `Super + n` | Siguiente ventana |

### Mover ventanas

| Atajo | Accion |
|-------|--------|
| `Super + Shift + h/l` | Mover ventana izquierda/derecha |
| `Super + Shift + j/k` | Mover ventana abajo/arriba |

### Redimensionar ventanas

| Atajo | Accion |
|-------|--------|
| `Super + Control + h/l` | Crecer ventana izquierda/derecha |
| `Super + Control + j/k` | Crecer ventana abajo/arriba |
| `Super + Shift + n` | Normalizar tamanos |

### Ventanas y layout

| Atajo | Accion |
|-------|--------|
| `Super + q` | Cerrar ventana |
| `Super + f` | Toggle fullscreen |
| `Super + Space` | Toggle floating |
| `Super + m` | Toggle minimize |
| `Super + Tab` | Siguiente layout |
| `Super + Shift + Tab` | Layout anterior |

### Workspaces

| Atajo | Accion |
|-------|--------|
| `Super + [1-9]` | Cambiar workspace |
| `Super + Shift + [1-9]` | Mover ventana a workspace |

### Aplicaciones

| Atajo | Accion |
|-------|--------|
| `Super + Enter` | Abrir Alacritty |
| `Super + d` | Rofi (lanzador de aplicaciones) |
| `Super + r` | Rofi (ejecutar comando) |
| `Super + e` | Thunar (file manager) |
| `Super + b` | Brave (navegador) |
| `Super + p` | Arandr (configuracion de pantallas) |
| `Super + Shift + x` | Bloquear pantalla |

### Screenshots

| Atajo | Accion |
|-------|--------|
| `Print` | Screenshot completo |
| `Super + Print` | Screenshot por seleccion |

### Hardware

| Atajo | Accion |
|-------|--------|
| `XF86AudioRaiseVolume` | Subir volumen |
| `XF86AudioLowerVolume` | Bajar volumen |
| `XF86AudioMute` | Mute |
| `XF86AudioPlay` | Play/Pause |
| `XF86AudioNext` | Siguiente pista |
| `XF86AudioPrev` | Pista anterior |
| `XF86MonBrightnessUp` | Subir brillo |
| `XF86MonBrightnessDown` | Bajar brillo |

### Qtile

| Atajo | Accion |
|-------|--------|
| `Super + Shift + r` | Recargar configuracion |
| `Super + Shift + q` | Cerrar Qtile (logout) |

## Estructura

```
dotfiles/
├── install.sh
├── packages.txt
├── alacritty/.config/alacritty/
│   └── alacritty.toml
├── bat/.config/bat/
│   └── config
├── btop/.config/btop/
│   └── btop.conf
├── dunst/.config/dunst/
│   └── dunstrc
├── fontconfig/.config/fontconfig/
│   └── fonts.conf
├── git/
│   ├── .gitconfig
│   └── .gitignore_global
├── nvim/.config/nvim/
│   ├── init.lua
│   └── lua/
│       ├── config/
│       └── plugins/
├── picom/.config/picom/
│   └── picom.conf
├── qtile/.config/qtile/
│   ├── config.py
│   ├── autostart.sh
│   └── settings/
├── redshift/.config/
│   └── redshift.conf
├── rofi/.config/rofi/
│   ├── config.rasi
│   └── themes/
├── thunar/.config/Thunar/
│   ├── accels.scm
│   └── uca.xml
├── tmux/
│   └── .tmux.conf
├── wallpapers/.config/wallpapers/
│   └── (wallpaper.jpg)
└── zsh/
    ├── .zshrc
    └── .zsh_aliases
```
