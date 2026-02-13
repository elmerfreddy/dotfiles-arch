#!/usr/bin/env bash
# ==============================================
# Dotfiles Installer - Arch Linux + Qtile
# ==============================================

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_FILE="$DOTFILES_DIR/packages.txt"

# --- Colores ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# --- Verificar que estamos en Arch Linux ---
check_arch() {
    if [ ! -f /etc/arch-release ]; then
        error "Este script esta disenado para Arch Linux."
        exit 1
    fi
    success "Arch Linux detectado."
}

# --- Verificar que vim NO este instalado ---
check_vim_not_installed() {
    info "Verificando que vim no este instalado..."
    
    # Verificar si vim esta instalado
    if pacman -Qi vim &>/dev/null; then
        warn "Se detecto vim instalado. Este entorno usa neovim exclusivamente."
        warn "Desinstalando vim..."
        
        # Desinstalar vim
        sudo pacman -Rns --noconfirm vim
        
        success "vim desinstalado correctamente."
    else
        success "vim no esta instalado (correcto)."
    fi
    
    # Verificar tambien gvim (GUI version)
    if pacman -Qi gvim &>/dev/null; then
        warn "Se detecto gvim instalado. Desinstalandolo..."
        sudo pacman -Rns --noconfirm gvim
        success "gvim desinstalado correctamente."
    fi
}

# --- Verificar/instalar yay ---
check_yay() {
    if ! command -v yay &>/dev/null; then
        warn "yay no encontrado. Instalando yay..."
        sudo pacman -S --needed --noconfirm base-devel git
        local tmpdir
        tmpdir=$(mktemp -d)
        git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
        cd "$tmpdir/yay"
        makepkg -si --noconfirm
        cd "$DOTFILES_DIR"
        rm -rf "$tmpdir"
        success "yay instalado correctamente."
    else
        success "yay ya esta instalado."
    fi
}

# --- Instalar paquetes desde packages.txt ---
install_packages() {
    info "Instalando paquetes desde packages.txt..."
    local packages=()
    while IFS= read -r line; do
        # Ignorar lineas vacias y comentarios
        line=$(echo "$line" | sed 's/#.*//' | xargs)
        [ -z "$line" ] && continue
        packages+=("$line")
    done < "$PACKAGES_FILE"

    if [ ${#packages[@]} -gt 0 ]; then
        yay -S --needed --noconfirm "${packages[@]}"
        success "Paquetes instalados correctamente."
        
        # Verificar que neovim tenga soporte Lua
        if command -v nvim &>/dev/null; then
            info "Verificando soporte Lua en neovim..."
            if nvim --version | grep -q "LuaJIT"; then
                success "Neovim instalado con soporte LuaJIT."
            else
                error "Neovim no tiene soporte LuaJIT. Verifica la instalacion."
                exit 1
            fi
        fi
    else
        warn "No se encontraron paquetes para instalar."
    fi
}

# --- Instalar Oh My Zsh ---
install_ohmyzsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        success "Oh My Zsh ya esta instalado."
    else
        info "Instalando Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        success "Oh My Zsh instalado correctamente."
    fi

    # Plugins externos
    local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        info "Instalando zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
        success "zsh-autosuggestions instalado."
    fi

    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        info "Instalando zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
        success "zsh-syntax-highlighting instalado."
    fi

    success "Oh My Zsh y plugins configurados."
}

# --- Instalar LazyVim ---
install_lazyvim() {
    if [ -d "$HOME/.config/nvim" ] && [ -f "$HOME/.config/nvim/lazyvim.json" ]; then
        success "LazyVim parece estar ya configurado (se aplicara con stow)."
    else
        info "LazyVim se configurara al aplicar los dotfiles con stow."
    fi

    # Limpiar cache de nvim si existe una instalacion previa diferente
    if [ -d "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
        warn "Respaldando configuracion de nvim existente..."
        mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak.$(date +%s)"
    fi

    # Limpiar datos/cache de nvim previos
    for dir in "$HOME/.local/share/nvim" "$HOME/.local/state/nvim" "$HOME/.cache/nvim"; do
        if [ -d "$dir" ] && [ ! -L "$dir" ]; then
            warn "Respaldando $dir..."
            mv "$dir" "${dir}.bak.$(date +%s)"
        fi
    done

    success "Entorno preparado para LazyVim."
}

# --- Instalar y actualizar cache de fuentes ---
install_fonts() {
    info "Actualizando cache de fuentes..."
    fc-cache -fv >/dev/null 2>&1
    success "Cache de fuentes actualizada."

    # Verificar que las Nerd Fonts se instalaron
    local nerd_count
    nerd_count=$(fc-list | grep -ci "nerd" || true)
    if [ "$nerd_count" -gt 0 ]; then
        success "Nerd Fonts detectadas: $nerd_count entradas en fc-list."
    else
        warn "No se detectaron Nerd Fonts. Verifica la instalacion de paquetes."
    fi

    # Verificar Font Awesome
    local fa_count
    fa_count=$(fc-list | grep -ci "awesome" || true)
    if [ "$fa_count" -gt 0 ]; then
        success "Font Awesome detectada: $fa_count entradas en fc-list."
    else
        warn "No se detecto Font Awesome. Verifica la instalacion de paquetes."
    fi

    # Listar familias Nerd Font instaladas
    info "Familias Nerd Font disponibles:"
    fc-list | grep -i "nerd" | awk -F: '{print $2}' | sort -u | while read -r font; do
        echo -e "  ${GREEN}>${NC}$font"
    done
}

# --- Aplicar dotfiles con stow ---
apply_stow() {
    info "Aplicando dotfiles con GNU Stow..."
    cd "$DOTFILES_DIR"

    local modules=(
        alacritty
        qtile
        zsh
        nvim
        git
        picom
        rofi
        tmux
        btop
        bat
        thunar
        dunst
        fontconfig
        redshift
    )

    for module in "${modules[@]}"; do
        if [ -d "$module" ]; then
            # Eliminar symlinks previos si existen
            stow -D "$module" 2>/dev/null || true
            stow "$module"
            success "Aplicado: $module"
        else
            warn "Modulo no encontrado: $module"
        fi
    done

    success "Todos los dotfiles aplicados."
}

# --- Cambiar shell a zsh ---
set_zsh_shell() {
    if [ "$SHELL" != "$(which zsh)" ]; then
        info "Cambiando shell predeterminado a Zsh..."
        chsh -s "$(which zsh)"
        success "Shell cambiado a Zsh. Reinicia sesion para aplicar."
    else
        success "Zsh ya es el shell predeterminado."
    fi
}

# --- Habilitar servicios ---
enable_services() {
    info "Habilitando servicios del sistema..."

    # Docker
    if systemctl list-unit-files | grep -q docker.service; then
        sudo systemctl enable docker.service
        sudo systemctl start docker.service
        # Agregar usuario al grupo docker
        if ! groups "$USER" | grep -q docker; then
            sudo usermod -aG docker "$USER"
            warn "Se agrego $USER al grupo docker. Reinicia sesion para aplicar."
        fi
        success "Docker habilitado."
    fi

    # NetworkManager
    if systemctl list-unit-files | grep -q NetworkManager.service; then
        sudo systemctl enable NetworkManager.service
        success "NetworkManager habilitado."
    fi

    # Geoclue2 (detección de ubicación para redshift)
    if systemctl list-unit-files | grep -q geoclue.service; then
        sudo systemctl enable geoclue.service
        sudo systemctl start geoclue.service
        success "Geoclue2 habilitado."
    fi
}

# --- Hacer ejecutable autostart de qtile ---
set_permissions() {
    info "Configurando permisos..."
    chmod +x "$DOTFILES_DIR/qtile/.config/qtile/autostart.sh" 2>/dev/null || true
    success "Permisos configurados."
}

# ==============================================
# Main
# ==============================================
main() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  Dotfiles Installer - Arch Linux + Qtile${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""

    check_arch
    check_yay
    check_vim_not_installed
    install_packages
    install_fonts
    install_ohmyzsh
    install_lazyvim
    set_permissions
    apply_stow
    set_zsh_shell
    enable_services

    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Instalacion completada!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "Pasos finales:"
    echo -e "  1. Cierra sesion y vuelve a iniciar"
    echo -e "  2. Selecciona Qtile como window manager en tu display manager"
    echo -e "  3. Abre Neovim (nvim) para que LazyVim instale plugins automaticamente"
    echo -e "  4. Edita ${YELLOW}~/.gitconfig${NC} con tu nombre y email"
    echo ""
}

main "$@"
