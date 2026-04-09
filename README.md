# Dotfiles - Arch Linux + Qtile

Dotfiles personales para Arch Linux con Qtile como window manager, gestionados con [GNU Stow](https://www.gnu.org/software/stow/).

## Componentes

| Componente | Descripción |
|-----------|-------------|
| **Qtile** | Window manager (tiling) con barra integrada |
| **Alacritty** | Terminal emulador GPU-accelerated |
| **Zsh + Oh My Zsh** | Shell con plugins y autocompletado |
| **Neovim (LazyVim)** | Editor de texto/código |
| **Rofi** | Lanzador de aplicaciones |
| **Picom** | Compositor (transparencias, sombras) |
| **Tmux** | Multiplexor de terminal |
| **Git** | Control de versiones con aliases útiles |
| **Dunst** | Daemon de notificaciones de escritorio |
| **Bat** | Reemplazo de `cat` con resaltado de sintaxis |
| **Btop** | Monitor de recursos del sistema |
| **Thunar** | Administrador de archivos |
| **Redshift** | Filtro de luz azul nocturna |
| **Fontconfig** | Configuración de renderizado de fuentes |
| **Betterlockscreen** | Bloqueo de pantalla con wallpaper |
| **Viewnior** | Visor de imágenes ligero |
| **Docker** | Aliases vía plugin de Oh My Zsh |
| **Java 17** | JDK para desarrollo Android (Android Studio) |
| **Galculator** | Calculadora de escritorio GTK |
| **Mise** | Runtime version manager para lenguajes |

**Tema:** Gruvbox (consistente en todos los componentes)

## Requisitos

- Arch Linux (o derivado)
- [yay](https://github.com/Jguer/yay) (AUR helper, se instala automáticamente si no existe)
- Git

## Instalación

```bash
# 1. Clonar el repositorio
git clone https://github.com/elmerfreddy/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Ejecutar la instalación completa
chmod +x install.sh
./install.sh
```

### Instalación selectiva

```bash
# Solo paquetes base (zsh, neovim, git, CLI tools)
./install.sh --packages --only base

# Solo paquetes de escritorio
./install.sh --packages --only desktop

# Solo aplicar symlinks
./install.sh --stow

# Combinar pasos
./install.sh --packages --stow --fonts

# Ver qué haría sin ejecutar
./install.sh --dry-run

# Verificar el estado de la instalación
./install.sh --verify
```

### Usando Make

```bash
make help              # Ver todos los comandos disponibles
make install           # Instalación completa
make packages-base     # Solo paquetes base
make stow              # Solo symlinks
make verify            # Verificar instalación
make unstow            # Deshacer symlinks
make update            # Actualizar paquetes y re-aplicar stow
```

### Qué hace `install.sh`

1. Verifica que el sistema sea Arch Linux
2. Instala `yay` (AUR helper) si no está presente
3. **Desinstala vim/gvim** si están presentes (este entorno usa neovim exclusivamente)
4. Instala todos los paquetes desde `packages.txt` vía `yay`
5. Actualiza caché de fuentes y verifica Nerd Fonts
6. Instala Oh My Zsh y plugins externos (autosuggestions, syntax-highlighting)
7. Prepara el entorno para LazyVim (respaldando configuración previa de nvim)
8. Configura permisos de ejecución en scripts
9. Aplica todos los dotfiles con GNU Stow (symlinks a `$HOME`)
10. Configura `~/.gitconfig.local` con datos personales (interactivo)
11. Cachea el wallpaper para betterlockscreen
12. Cambia el shell predeterminado a Zsh
13. Habilita servicios del sistema: Docker, NetworkManager
14. Ejecuta verificación post-instalación

### Display manager

Este setup usa **SDDM** como display manager. Si no lo tienes instalado:

```bash
yay -S sddm
systemctl enable sddm
```

Alternativamente, puedes usar `xinit` agregando `exec qtile start` a `~/.xinitrc` y corriendo `startx`.

### Post-instalación

Después de ejecutar `install.sh`:

1. Cierra sesión y vuelve a iniciar
2. Selecciona **Qtile** como window manager en SDDM (o ejecuta `startx`)
3. Abre Neovim (`nvim`) para que LazyVim instale plugins automáticamente
4. Se incluyen wallpapers de ejemplo en `~/.config/wallpapers/` (`wallpaper.jpg` se usa por defecto)
5. Usa `lxappearance` para seleccionar el tema GTK (arc-gtk-theme + papirus-icon-theme)

> **Nota:** Si instalaste via `stow` sin usar `install.sh`, ejecuta manualmente:
> ```bash
> betterlockscreen -u ~/.config/wallpapers/wallpaper.jpg
> ```
> Esto cachea el wallpaper para el bloqueo de pantalla. Sin este paso, `xss-lock` fallará silenciosamente.

### Redshift — ubicación geográfica

El archivo `~/.config/redshift.conf` tiene coordenadas hardcodeadas. Edítalas para tu ciudad:

```bash
# Ejemplo para Lima, Perú
# En ~/.config/redshift.conf:
[redshift]
lat=...
lon=...
```

Puedes obtener tus coordenadas en [latlong.net](https://www.latlong.net).

### Configuración por equipo

Los datos personales de git se almacenan en `~/.gitconfig.local` (no se sube al repositorio):

```bash
# Se crea automáticamente durante la instalación, o manualmente:
cat > ~/.gitconfig.local << 'EOF'
[user]
    name = Tu Nombre
    email = tu@email.com
EOF
```

## Uso manual con Stow

```bash
cd ~/dotfiles

# Aplicar un módulo específico
stow alacritty
stow qtile
stow zsh

# Aplicar todos los módulos
stow */

# Eliminar symlinks de un módulo
stow -D alacritty

# Eliminar todos los symlinks
./install.sh --uninstall
```

## Paquetes por categoría

Los paquetes se organizan en `packages/` para instalación selectiva:

| Archivo | Contenido |
|---------|-----------|
| `packages/base.txt` | Esenciales: zsh, neovim, git, bat, fzf, ripgrep... |
| `packages/desktop.txt` | Escritorio: qtile, xorg, picom, rofi, audio, temas... |
| `packages/dev.txt` | Desarrollo: docker, java, mise, gitg |
| `packages/fonts.txt` | Nerd Fonts, Font Awesome, fuentes del sistema |
| `packages.txt` | Lista completa (todos los anteriores) |

## Keybindings de Qtile

### Navegación

| Atajo | Acción |
|-------|--------|
| `Super + h/j/k/l` | Navegar entre ventanas (vim-style) |
| `Super + n` | Siguiente ventana |

### Mover ventanas

| Atajo | Acción |
|-------|--------|
| `Super + Shift + h/l` | Mover ventana izquierda/derecha |
| `Super + Shift + j/k` | Mover ventana abajo/arriba |

### Redimensionar ventanas

| Atajo | Acción |
|-------|--------|
| `Super + Control + h/l` | Crecer ventana izquierda/derecha |
| `Super + Control + j/k` | Crecer ventana abajo/arriba |
| `Super + Shift + n` | Normalizar tamaños |

### Ventanas y layout

| Atajo | Acción |
|-------|--------|
| `Super + q` | Cerrar ventana |
| `Super + f` | Toggle fullscreen |
| `Super + Space` | Toggle floating |
| `Super + m` | Toggle minimize |
| `Super + Tab` | Siguiente layout |
| `Super + Shift + Tab` | Layout anterior |

### Workspaces

| Atajo | Acción |
|-------|--------|
| `Super + [1-9]` | Cambiar workspace |
| `Super + Shift + [1-9]` | Mover ventana a workspace |

### Aplicaciones

| Atajo | Acción |
|-------|--------|
| `Super + Enter` | Abrir Alacritty |
| `Super + d` | Rofi (lanzador de aplicaciones) |
| `Super + r` | Rofi (ejecutar comando) |
| `Super + e` | Thunar (file manager) |
| `Super + b` | Brave (navegador) |
| `Super + p` | Arandr (configuración de pantallas) |
| `Super + Shift + x` | Bloquear pantalla |

### Screenshots

| Atajo | Acción |
|-------|--------|
| `Print` | Screenshot completo |
| `Super + Shift + s` | Screenshot por selección |

### Hardware

| Atajo | Acción |
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

| Atajo | Acción |
|-------|--------|
| `Super + Shift + r` | Recargar configuración |
| `Super + Shift + q` | Cerrar Qtile (logout) |

## Estructura

```
dotfiles/
├── install.sh              # Instalador principal
├── Makefile                 # Interfaz Make
├── packages.txt             # Lista completa de paquetes
├── packages/                # Paquetes por categoría
│   ├── base.txt
│   ├── desktop.txt
│   ├── dev.txt
│   └── fonts.txt
├── .stow-local-ignore       # Archivos ignorados por stow
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
│   ├── .gitconfig           # Config compartida (incluye .gitconfig.local)
│   └── .gitignore_global
├── nvim/.config/nvim/
│   ├── init.lua
│   └── lua/
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
│   └── wallpaper.jpg
└── zsh/
    ├── .zshrc
    └── .zsh_aliases
```

## Notas de configuración

### Thunar — archivos auto-generados

`thunar/accels.scm` y `thunar/uca.xml` son generados automáticamente por la GUI de Thunar cuando cambias atajos o acciones personalizadas. Si ves diffs inesperados en estos archivos después de usar Thunar, es comportamiento normal — Thunar regenera su formato al guardar.

## Troubleshooting

### Los wallpapers no se muestran

**Problema**: Después de ejecutar `stow wallpapers`, no aparecen los wallpapers en `~/.config/wallpapers/`

**Solución**: Stow requiere que el directorio padre (`~/.config/`) exista antes de crear los symlinks.

```bash
mkdir -p ~/.config
cd ~/dotfiles
stow wallpapers
ls -la ~/.config/wallpapers/
```

**Nota**: El script `install.sh` crea estos directorios automáticamente.

### Stow falla con otros módulos

```bash
mkdir -p ~/.config ~/.local/share
cd ~/dotfiles
stow <módulo>
```

### El fondo de pantalla no persiste después de reiniciar

1. Verifica el symlink: `ls -la ~/.config/wallpapers/`
2. Verifica autostart: `ls -la ~/.config/qtile/autostart.sh`
3. Reinicia Qtile: `Super + Shift + r`
4. Para cambiar el wallpaper, edita `~/.config/qtile/autostart.sh`

### Verificar la instalación

```bash
./install.sh --verify
# o
make verify
```
