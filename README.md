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
| **Picom** | Compositor (transparencias, sombras, blur) |
| **Tmux** | Multiplexor de terminal |
| **Git** | Control de versiones con aliases útiles |
| **Dunst** | Daemon de notificaciones de escritorio |
| **Bat** | Reemplazo de `cat` con resaltado de sintaxis |
| **Btop** | Monitor de recursos del sistema |
| **Thunar** | Administrador de archivos con automontaje |
| **Xarchiver** | Visor/extractor de archivos comprimidos integrado en Thunar (.tar, .zip, .7z) |
| **Redshift** | Filtro de luz azul nocturna (modo manual) |
| **Fontconfig** | Configuración de renderizado de fuentes |
| **Betterlockscreen** | Bloqueo de pantalla con wallpaper |
| **Viewnior** | Visor de imágenes ligero |
| **Mpv** | Reproductor de video/audio |
| **Feh** | Visor de imágenes / setter de wallpaper |
| **Flameshot** | Screenshots con selección y anotaciones |
| **Udiskie** | Automontaje de dispositivos USB (systray) |
| **Autorandr** | Perfiles automáticos de monitores |
| **Polkit-gnome** | Agente de autenticación GTK |
| **Docker** | Contenedores + aliases vía plugin de Oh My Zsh |
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
git clone https://github.com/elmerfreddy/dotfiles-arch.git ~/dotfiles
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

# Ver qué haría sin ejecutar (solo o combinado con otros flags)
./install.sh --dry-run
./install.sh --dry-run --packages --only base

# Verificar el estado de la instalación (exit 1 si algo falla)
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
make check             # Validar sintaxis + simular instalación (sin efectos)
```

### Qué hace `install.sh`

1. Verifica que el sistema sea Arch Linux y que no se ejecute como root
2. Instala `yay` (AUR helper) si no está presente
3. Instala todos los paquetes desde `packages/*.txt` vía `yay`
4. Actualiza caché de fuentes y verifica Nerd Fonts
5. Instala Oh My Zsh y plugins externos (commits fijados en `install.sh`)
6. Respalda `~/.config/nvim` solo si existe un directorio real (nunca toca data/state/cache)
7. Configura permisos de ejecución en scripts
8. Aplica todos los dotfiles con GNU Stow (preflight de conflictos; aborta sin cambios si hay conflicto)
9. Configura `~/.gitconfig.local` con datos personales (interactivo)
10. Cachea el wallpaper para betterlockscreen
11. Cambia el shell predeterminado a Zsh
12. Habilita servicios: Docker (grupo docker solo con confirmación), NetworkManager
13. Ejecuta verificación post-instalación (exit 1 si falla)

> **Seguridad:** Oh My Zsh y plugins zsh se clonan en commits fijados (variables
> `*_COMMIT` al inicio de `install.sh`). Actualizarlos es deliberado: cambia el pin,
> no ocurre en cada instalación.

### Display manager

Este setup usa **LightDM** como display manager. Si no lo tienes instalado:

```bash
yay -S lightdm lightdm-gtk-greeter
systemctl enable lightdm
```

Alternativamente, puedes usar **SDDM**:

```bash
yay -S sddm
systemctl enable sddm
```

O `xinit`, agregando `exec qtile start` a `~/.xinitrc` y corriendo `startx`.

### Post-instalación

Después de ejecutar `install.sh`:

1. Cierra sesión y vuelve a iniciar
2. Selecciona **Qtile** como window manager en tu display manager (LightDM/SDDM, o ejecuta `startx`)
3. Abre Neovim (`nvim`) para que LazyVim instale plugins automáticamente
4. Se incluyen wallpapers de ejemplo en `~/.config/wallpapers/` (`wallpaper.jpg` se usa por defecto)
5. Usa `lxappearance` para seleccionar el tema GTK (arc-gtk-theme + papirus-icon-theme)

> **Nota:** Si instalaste via `stow` sin usar `install.sh`, ejecuta manualmente:
> ```bash
> betterlockscreen -u ~/.config/wallpapers/wallpaper.jpg
> ```
> Esto cachea el wallpaper para el bloqueo de pantalla. Sin este paso, `xss-lock` fallará silenciosamente.

### Redshift — ubicación geográfica

El archivo `~/.config/redshift.conf` está configurado para **La Paz, Bolivia** con `location-provider=manual`. Para otra ciudad, edita `lat` y `lon` en la sección `[manual]`:

```ini
[manual]
lat=-12.04   # Lima, Perú
lon=-77.03
```

Obtén tus coordenadas en [latlong.net](https://www.latlong.net).

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

Stow debe apuntar siempre al repo y a `$HOME` explícitamente (si el repo no está
directamente bajo `$HOME`, el target por defecto de stow sería incorrecto):

```bash
cd ~/dotfiles

# Aplicar un módulo específico
stow --dir=. --target="$HOME" qtile

# Re-aplicar (idempotente, simula primero ante conflictos)
stow --dir=. --target="$HOME" -R zsh

# Eliminar symlinks de un módulo
stow --dir=. --target="$HOME" -D alacritty

# Aplicar todos los módulos (usa la lista del installer, NO 'stow */')
./install.sh --stow

# Eliminar todos los symlinks
./install.sh --uninstall
```

> `stow */` aplica también `packages/` y otros directorios que no son módulos —
> no lo uses. `install.sh --stow` hace preflight de todos los módulos y aborta
> sin cambios si detecta un archivo preexistente que no es symlink propio.

## Paquetes por categoría

Los paquetes se organizan en `packages/` para instalación selectiva:

| Archivo | Contenido |
|---------|-----------|
| `packages/base.txt` | Esenciales: zsh, neovim, git, bat, fzf, ripgrep, p7zip, zip... |
| `packages/desktop.txt` | Escritorio: qtile, xorg, picom, rofi, audio, temas, mpv, thunar-archive-plugin... |
| `packages/dev.txt` | Desarrollo: docker, java, mise, gitg |
| `packages/fonts.txt` | Nerd Fonts, Font Awesome, fuentes del sistema |

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
| `Super + Shift + m` | Restaurar todas las ventanas minimizadas del grupo |
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
| `Super + p` | Arandr (configuración de pantallas, GUI) |
| `Super + Shift + p` | Autorandr (aplicar perfil de monitores automático) |
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
│   ├── wallpaper.jpg          # Wallpaper por defecto
│   ├── forest.jpg
│   ├── mountains.jpg
│   └── night-sky.jpg
└── zsh/
    ├── .zshrc                 # Config principal + Oh My Zsh + fzf + mise
    └── .zsh_aliases           # Aliases: git, docker, pacman, qtile, CLI tools
```

## Notas de configuración

### Thunar — archivos auto-generados

`thunar/.config/Thunar/accels.scm` y `thunar/.config/Thunar/uca.xml` son generados automáticamente por la GUI de Thunar cuando cambias atajos o acciones personalizadas. Si ves diffs inesperados en estos archivos después de usar Thunar, es comportamiento normal — Thunar regenera su formato al guardar.

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
