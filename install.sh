#!/usr/bin/env bash
# ==============================================
# Dotfiles Installer - Arch Linux + Qtile
# ==============================================
# Uso:
#   ./install.sh              Instalación completa
#   ./install.sh --packages   Solo instalar paquetes
#   ./install.sh --stow       Solo aplicar symlinks
#   ./install.sh --fonts      Solo configurar fuentes
#   ./install.sh --shell      Solo configurar zsh
#   ./install.sh --services   Solo habilitar servicios
#   ./install.sh --uninstall  Deshacer symlinks de stow
#   ./install.sh --dry-run    Mostrar qué se haría sin ejecutar
#
# Se pueden combinar flags:
#   ./install.sh --packages --stow
#
# Paquetes selectivos:
#   ./install.sh --packages --only base,fonts

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_FILE="$DOTFILES_DIR/packages.txt"
PACKAGES_DIR="$DOTFILES_DIR/packages"
DRY_RUN=false

# --- Colores ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; }

run() {
    if $DRY_RUN; then
        echo -e "${YELLOW}[DRY-RUN]${NC} $*"
    else
        "$@"
    fi
}

# --- Módulos de stow (orden determinista) ---
STOW_MODULES=(
    alacritty
    bat
    btop
    dunst
    fontconfig
    git
    nvim
    picom
    qtile
    redshift
    rofi
    thunar
    tmux
    wallpapers
    zsh
)

# ==============================================
# Funciones de instalación
# ==============================================

check_arch() {
    if [ ! -f /etc/arch-release ]; then
        error "Este script está diseñado para Arch Linux."
        exit 1
    fi
    success "Arch Linux detectado."
}

check_yay() {
    if ! command -v yay &>/dev/null; then
        warn "yay no encontrado. Instalando yay..."
        run sudo pacman -S --needed --noconfirm base-devel git
        local tmpdir
        tmpdir=$(mktemp -d)
        git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
        cd "$tmpdir/yay"
        run makepkg -si --noconfirm
        cd "$DOTFILES_DIR"
        rm -rf "$tmpdir"
        success "yay instalado correctamente."
    else
        success "yay ya está instalado."
    fi
}

check_vim_not_installed() {
    info "Verificando que vim no esté instalado..."
    if pacman -Qi vim &>/dev/null; then
        warn "Se detectó vim instalado. Este entorno usa neovim exclusivamente."
        run sudo pacman -Rns --noconfirm vim
        success "vim desinstalado correctamente."
    else
        success "vim no está instalado (correcto)."
    fi
    if pacman -Qi gvim &>/dev/null; then
        warn "Se detectó gvim instalado. Desinstalándolo..."
        run sudo pacman -Rns --noconfirm gvim
        success "gvim desinstalado correctamente."
    fi
}

# Lee paquetes de un archivo, ignorando comentarios y líneas vacías
_read_packages() {
    local file="$1"
    local packages=()
    while IFS= read -r line; do
        line=$(echo "$line" | sed 's/#.*//' | xargs)
        [ -z "$line" ] && continue
        packages+=("$line")
    done < "$file"
    echo "${packages[@]}"
}

install_packages() {
    local only_categories="${1:-}"
    local packages=()

    if [ -n "$only_categories" ]; then
        # Instalar solo categorías específicas
        IFS=',' read -ra cats <<< "$only_categories"
        for cat in "${cats[@]}"; do
            local cat_file="$PACKAGES_DIR/${cat}.txt"
            if [ -f "$cat_file" ]; then
                info "Leyendo paquetes de packages/${cat}.txt..."
                while IFS= read -r line; do
                    line=$(echo "$line" | sed 's/#.*//' | xargs)
                    [ -z "$line" ] && continue
                    packages+=("$line")
                done < "$cat_file"
            else
                warn "Categoría no encontrada: ${cat} (packages/${cat}.txt)"
            fi
        done
    else
        # Instalar todos los paquetes
        info "Instalando paquetes desde packages.txt..."
        while IFS= read -r line; do
            line=$(echo "$line" | sed 's/#.*//' | xargs)
            [ -z "$line" ] && continue
            packages+=("$line")
        done < "$PACKAGES_FILE"
    fi

    if [ ${#packages[@]} -gt 0 ]; then
        run yay -S --needed --noconfirm "${packages[@]}"
        success "Paquetes instalados correctamente (${#packages[@]} paquetes)."

        # Verificar neovim con LuaJIT
        if command -v nvim &>/dev/null; then
            if nvim --version | grep -q "LuaJIT"; then
                success "Neovim instalado con soporte LuaJIT."
            else
                warn "Neovim no tiene soporte LuaJIT."
            fi
        fi
    else
        warn "No se encontraron paquetes para instalar."
    fi
}

install_ohmyzsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        success "Oh My Zsh ya está instalado."
    else
        info "Instalando Oh My Zsh..."
        run sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        success "Oh My Zsh instalado correctamente."
    fi

    local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        info "Instalando zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    fi

    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        info "Instalando zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    fi

    success "Oh My Zsh y plugins configurados."
}

install_lazyvim() {
    if [ -d "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
        warn "Respaldando configuración de nvim existente..."
        mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak.$(date +%s)"
    fi
    for dir in "$HOME/.local/share/nvim" "$HOME/.local/state/nvim" "$HOME/.cache/nvim"; do
        if [ -d "$dir" ] && [ ! -L "$dir" ]; then
            warn "Respaldando $dir..."
            mv "$dir" "${dir}.bak.$(date +%s)"
        fi
    done
    success "Entorno preparado para LazyVim."
}

install_fonts() {
    info "Actualizando caché de fuentes..."
    run fc-cache -fv >/dev/null 2>&1
    success "Caché de fuentes actualizada."

    local nerd_count
    nerd_count=$(fc-list | grep -ci "nerd" || true)
    if [ "$nerd_count" -gt 0 ]; then
        success "Nerd Fonts detectadas: $nerd_count entradas."
    else
        warn "No se detectaron Nerd Fonts."
    fi

    local fa_count
    fa_count=$(fc-list | grep -ci "awesome" || true)
    if [ "$fa_count" -gt 0 ]; then
        success "Font Awesome detectada: $fa_count entradas."
    else
        warn "No se detectó Font Awesome."
    fi
}

create_stow_dirs() {
    info "Creando directorios necesarios para stow..."
    run mkdir -p "$HOME/.config"
    run mkdir -p "$HOME/.local/share"
    success "Directorios creados."
}

apply_stow() {
    info "Aplicando dotfiles con GNU Stow..."
    cd "$DOTFILES_DIR"

    for module in "${STOW_MODULES[@]}"; do
        if [ -d "$module" ]; then
            run stow -D "$module" 2>/dev/null || true
            run stow "$module"
            success "Aplicado: $module"
        else
            warn "Módulo no encontrado: $module"
        fi
    done

    success "Todos los dotfiles aplicados."
}

remove_stow() {
    info "Deshaciendo symlinks de stow..."
    cd "$DOTFILES_DIR"

    for module in "${STOW_MODULES[@]}"; do
        if [ -d "$module" ]; then
            run stow -D "$module" 2>/dev/null || true
            success "Removido: $module"
        fi
    done

    success "Todos los symlinks removidos."
}

set_zsh_shell() {
    if [ "$SHELL" != "$(which zsh)" ]; then
        info "Cambiando shell predeterminado a Zsh..."
        run chsh -s "$(which zsh)"
        success "Shell cambiado a Zsh. Reinicia sesión para aplicar."
    else
        success "Zsh ya es el shell predeterminado."
    fi
}

enable_services() {
    info "Habilitando servicios del sistema..."

    if systemctl list-unit-files | grep -q docker.service; then
        run sudo systemctl enable docker.service
        run sudo systemctl start docker.service
        if ! groups "$USER" | grep -q docker; then
            run sudo usermod -aG docker "$USER"
            warn "Se agregó $USER al grupo docker. Reinicia sesión para aplicar."
        fi
        success "Docker habilitado."
    fi

    if systemctl list-unit-files | grep -q NetworkManager.service; then
        run sudo systemctl enable NetworkManager.service
        success "NetworkManager habilitado."
    fi
}

setup_lockscreen() {
    if command -v betterlockscreen &>/dev/null; then
        local wallpaper="$HOME/.config/wallpapers/wallpaper.jpg"
        if [ -f "$wallpaper" ]; then
            info "Cacheando imagen para betterlockscreen..."
            run betterlockscreen -u "$wallpaper" 2>/dev/null
            success "Lockscreen configurado."
        else
            warn "No se encontró wallpaper. Ejecuta 'betterlockscreen -u <imagen>' manualmente."
        fi
    else
        warn "betterlockscreen no encontrado."
    fi
}

setup_gitconfig_local() {
    local local_file="$HOME/.gitconfig.local"
    if [ ! -f "$local_file" ]; then
        info "Creando ~/.gitconfig.local con datos personales..."
        if [ -t 0 ]; then
            # Terminal interactivo: preguntar datos
            echo ""
            read -rp "  Nombre para git (Enter para omitir): " git_name
            read -rp "  Email para git (Enter para omitir): " git_email
            echo ""
            if [ -n "$git_name" ] || [ -n "$git_email" ]; then
                {
                    echo "[user]"
                    [ -n "$git_name" ] && echo "    name = $git_name"
                    [ -n "$git_email" ] && echo "    email = $git_email"
                } > "$local_file"
                success "~/.gitconfig.local creado."
            else
                warn "No se configuró ~/.gitconfig.local. Créalo manualmente."
            fi
        else
            warn "No hay terminal interactivo. Crea ~/.gitconfig.local manualmente con [user] name/email."

        fi
    else
        success "~/.gitconfig.local ya existe."
    fi
}

set_permissions() {
    info "Configurando permisos..."
    chmod +x "$DOTFILES_DIR/qtile/.config/qtile/autostart.sh" 2>/dev/null || true
    success "Permisos configurados."
}

# ==============================================
# Verificación post-instalación
# ==============================================

verify_installation() {
    echo ""
    echo -e "${BOLD}=== Verificación post-instalación ===${NC}"
    echo ""
    local errors=0

    # Verificar symlinks de stow
    info "Verificando symlinks..."
    for module in "${STOW_MODULES[@]}"; do
        case "$module" in
            git)
                if [ -L "$HOME/.gitconfig" ]; then
                    success "  $module: symlink OK"
                else
                    warn "  $module: symlink NO encontrado (~/.gitconfig)"
                    ((errors++)) || true
                fi
                ;;
            zsh)
                if [ -L "$HOME/.zshrc" ]; then
                    success "  $module: symlink OK"
                else
                    warn "  $module: symlink NO encontrado (~/.zshrc)"
                    ((errors++)) || true
                fi
                ;;
            tmux)
                if [ -L "$HOME/.tmux.conf" ]; then
                    success "  $module: symlink OK"
                else
                    warn "  $module: symlink NO encontrado (~/.tmux.conf)"
                    ((errors++)) || true
                fi
                ;;
            *)
                if [ -L "$HOME/.config/$module" ] || [ -d "$HOME/.config/$module" ]; then
                    success "  $module: symlink OK"
                else
                    warn "  $module: symlink NO encontrado (~/.config/$module)"
                    ((errors++)) || true
                fi
                ;;
        esac
    done

    # Verificar shell
    if [ "$SHELL" = "$(which zsh 2>/dev/null)" ]; then
        success "Shell: zsh activo"
    else
        warn "Shell: no es zsh (actual: $SHELL)"
        ((errors++)) || true
    fi

    # Verificar comandos esenciales
    for cmd in nvim stow git zsh bat btop fzf rg fd alacritty qtile; do
        if command -v "$cmd" &>/dev/null; then
            success "Comando: $cmd disponible"
        else
            warn "Comando: $cmd NO encontrado"
            ((errors++)) || true
        fi
    done

    # Verificar fuentes
    local nerd_count
    nerd_count=$(fc-list | grep -ci "nerd" || true)
    if [ "$nerd_count" -gt 0 ]; then
        success "Fuentes: $nerd_count Nerd Fonts instaladas"
    else
        warn "Fuentes: no se detectaron Nerd Fonts"
        ((errors++)) || true
    fi

    # Verificar servicios
    if systemctl is-active --quiet docker 2>/dev/null; then
        success "Servicio: docker activo"
    else
        warn "Servicio: docker no activo"
        ((errors++)) || true
    fi

    if systemctl is-enabled --quiet NetworkManager 2>/dev/null; then
        success "Servicio: NetworkManager habilitado"
    else
        warn "Servicio: NetworkManager no habilitado"
        ((errors++)) || true
    fi

    # Verificar gitconfig.local
    if [ -f "$HOME/.gitconfig.local" ]; then
        success "Git: ~/.gitconfig.local existe"
    else
        warn "Git: ~/.gitconfig.local no existe (configura tu nombre/email)"
        ((errors++)) || true
    fi

    echo ""
    if [ "$errors" -eq 0 ]; then
        echo -e "${GREEN}${BOLD}Verificación completa: todo OK${NC}"
    else
        echo -e "${YELLOW}${BOLD}Verificación completa: $errors advertencias${NC}"
    fi
    echo ""
}

# ==============================================
# Instalación completa
# ==============================================

full_install() {
    check_arch
    check_yay
    check_vim_not_installed
    install_packages ""
    install_fonts
    install_ohmyzsh
    install_lazyvim
    set_permissions
    create_stow_dirs
    apply_stow
    setup_gitconfig_local
    setup_lockscreen
    set_zsh_shell
    enable_services
    verify_installation
}

# ==============================================
# Ayuda
# ==============================================

show_help() {
    echo -e "${BOLD}Dotfiles Installer - Arch Linux + Qtile${NC}"
    echo ""
    echo "Uso: ./install.sh [opciones]"
    echo ""
    echo "Sin opciones ejecuta la instalación completa."
    echo ""
    echo "Opciones:"
    echo "  --packages          Instalar paquetes del sistema"
    echo "  --only <cats>       Con --packages, instalar solo categorías (base,desktop,dev,fonts)"
    echo "  --stow              Aplicar symlinks con GNU Stow"
    echo "  --fonts             Configurar caché de fuentes"
    echo "  --shell             Instalar Oh My Zsh y configurar zsh"
    echo "  --services          Habilitar servicios (docker, NetworkManager)"
    echo "  --verify            Verificar estado de la instalación"
    echo "  --uninstall         Deshacer symlinks de stow"
    echo "  --dry-run           Mostrar qué se haría sin ejecutar"
    echo "  --help              Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  ./install.sh                          # Instalación completa"
    echo "  ./install.sh --packages --only base   # Solo paquetes base"
    echo "  ./install.sh --stow --fonts           # Solo symlinks y fuentes"
    echo "  ./install.sh --dry-run --packages     # Ver qué paquetes se instalarían"
    echo "  ./install.sh --verify                 # Verificar instalación"
    echo "  ./install.sh --uninstall              # Deshacer symlinks"
}

# ==============================================
# Main - Parseo de argumentos
# ==============================================

main() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  Dotfiles Installer - Arch Linux + Qtile${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""

    # Sin argumentos: instalación completa
    if [ $# -eq 0 ]; then
        full_install

        echo ""
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}  Instalación completada!${NC}"
        echo -e "${GREEN}========================================${NC}"
        echo ""
        echo -e "Pasos finales:"
        echo -e "  1. Cierra sesión y vuelve a iniciar"
        echo -e "  2. Selecciona Qtile como window manager en tu display manager"
        echo -e "  3. Abre Neovim (nvim) para que LazyVim instale plugins automáticamente"
        echo ""
        return 0
    fi

    # Parseo de flags
    local do_packages=false
    local do_stow=false
    local do_fonts=false
    local do_shell=false
    local do_services=false
    local do_verify=false
    local do_uninstall=false
    local only_categories=""

    while [ $# -gt 0 ]; do
        case "$1" in
            --packages)   do_packages=true ;;
            --only)       shift; only_categories="$1" ;;
            --stow)       do_stow=true ;;
            --fonts)      do_fonts=true ;;
            --shell)      do_shell=true ;;
            --services)   do_services=true ;;
            --verify)     do_verify=true ;;
            --uninstall)  do_uninstall=true ;;
            --dry-run)    DRY_RUN=true ;;
            --help|-h)    show_help; return 0 ;;
            *)            error "Opción desconocida: $1"; show_help; return 1 ;;
        esac
        shift
    done

    check_arch

    if $do_uninstall; then
        remove_stow
        return 0
    fi

    if $do_packages; then
        check_yay
        check_vim_not_installed
        install_packages "$only_categories"
    fi

    if $do_fonts; then
        install_fonts
    fi

    if $do_shell; then
        install_ohmyzsh
        set_zsh_shell
    fi

    if $do_stow; then
        set_permissions
        create_stow_dirs
        apply_stow
        setup_gitconfig_local
    fi

    if $do_services; then
        enable_services
    fi

    if $do_verify; then
        verify_installation
    fi

    echo ""
    success "Operación completada."
    echo ""
}

main "$@"
