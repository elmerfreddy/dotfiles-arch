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
#   ./install.sh --verify     Verificar instalación (exit 1 si falla)
#   ./install.sh --uninstall  Deshacer symlinks de stow
#   ./install.sh --dry-run    Simular instalación completa (sin efectos)
#
# Se pueden combinar flags:
#   ./install.sh --packages --stow
#
# Paquetes selectivos:
#   ./install.sh --packages --only base,fonts

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_DIR="$DOTFILES_DIR/packages"
DRY_RUN=false

# --- Pins de fuentes remotas (actualizar deliberadamente, no en cada run) ---
# yay: el PKGBUILD del AUR fija versión y sha256 del fuente (verificado por makepkg).
YAY_REPO="https://aur.archlinux.org/yay.git"
# Oh My Zsh: commit específico de master (obtener con: git ls-remote <repo> HEAD)
OMZ_REPO="https://github.com/ohmyzsh/ohmyzsh.git"
OMZ_COMMIT="9112b53fa8b5ab556c7c893aa8be8a247ac512a0"
# Plugins zsh: commits de tags estables
ZSH_AUTOSUGGESTIONS_REPO="https://github.com/zsh-users/zsh-autosuggestions.git"
ZSH_AUTOSUGGESTIONS_COMMIT="e52ee8ca55bcc56a17c828767a3f98f22a68d4eb"  # v0.7.1
ZSH_SYNTAX_HIGHLIGHTING_REPO="https://github.com/zsh-users/zsh-syntax-highlighting.git"
ZSH_SYNTAX_HIGHLIGHTING_COMMIT="00a5fd11eb9d1c163fb49da5310c8f4b09fb3022"  # 0.8.0-alpha1

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

# Clona (si falta) y deja el repo en el commit fijado. Aborta si no coincide.
# En dry-run solo reporta la intención.
ensure_repo_ref() {
    local repo_url="$1" dest="$2" ref="$3"
    if $DRY_RUN; then
        echo -e "${YELLOW}[DRY-RUN]${NC} git: $dest @ ${ref:0:12}"
        return 0
    fi
    if [ ! -d "$dest/.git" ]; then
        git clone --quiet --filter=blob:none "$repo_url" "$dest"
    fi
    local head
    head="$(git -C "$dest" rev-parse HEAD 2>/dev/null || true)"
    if [ "$head" != "$ref" ]; then
        git -C "$dest" fetch --quiet --depth 1 origin "$ref"
        git -C "$dest" checkout --quiet --detach "$ref"
    fi
    head="$(git -C "$dest" rev-parse HEAD)"
    if [ "$head" != "$ref" ]; then
        error "No se pudo fijar $repo_url en ${ref:0:12} (HEAD: ${head:0:12})."
        return 1
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

STOW_OPTS=(--dir="$DOTFILES_DIR" --target="$HOME")

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

check_root() {
    if [ "$(id -u)" -eq 0 ]; then
        error "No ejecutar como root: stow y configuración operan sobre \$HOME del usuario."
        error "Los comandos que lo necesitan ya usan sudo."
        exit 1
    fi
}

check_yay() {
    if ! command -v yay &>/dev/null; then
        warn "yay no encontrado. Instalando yay (AUR; makepkg verifica integridad del fuente)..."
        run sudo pacman -S --needed --noconfirm base-devel git
        if $DRY_RUN; then
            echo -e "${YELLOW}[DRY-RUN]${NC} git clone $YAY_REPO && makepkg -si"
            return 0
        fi
        local tmpdir
        tmpdir="$(mktemp -d)"
        git clone --quiet "$YAY_REPO" "$tmpdir/yay"
        info "AUR yay @ $(git -C "$tmpdir/yay" rev-parse --short HEAD)"
        (
            cd "$tmpdir/yay"
            makepkg -si --noconfirm
        )
        rm -rf "$tmpdir"
        command -v yay &>/dev/null || { error "yay no quedó instalado."; return 1; }
        success "yay instalado correctamente."
    else
        success "yay ya está instalado."
    fi
}

install_packages() {
    local only_categories="${1:-}"
    local packages=()
    local files_to_read=()

    if [ -n "$only_categories" ]; then
        IFS=',' read -ra cats <<< "$only_categories"
        for cat in "${cats[@]}"; do
            local cat_file="$PACKAGES_DIR/${cat}.txt"
            if [ -f "$cat_file" ]; then
                info "Leyendo paquetes de packages/${cat}.txt..."
                files_to_read+=("$cat_file")
            else
                error "Categoría desconocida: '${cat}' (no existe packages/${cat}.txt)."
                error "Categorías válidas: $(cd "$PACKAGES_DIR" && ls *.txt | sed 's/\.txt$//' | tr '\n' ' ')"
                return 1
            fi
        done
    else
        info "Instalando paquetes desde packages/*.txt..."
        for f in "$PACKAGES_DIR"/*.txt; do
            [ -f "$f" ] && files_to_read+=("$f")
        done
    fi

    for f in "${files_to_read[@]}"; do
        while IFS= read -r line; do
            line="${line%%#*}"
            line="$(echo "$line" | xargs)"
            [ -z "$line" ] && continue
            packages+=("$line")
        done < "$f"
    done

    # Deduplicar preservando orden (repos repetidos entre categorías)
    local seen=" " unique=()
    for p in "${packages[@]}"; do
        case " $seen " in
            *" $p "*) warn "Paquete duplicado omitido: $p" ;;
            *) unique+=("$p"); seen+="$p " ;;
        esac
    done
    packages=("${unique[@]}")

    if [ ${#packages[@]} -eq 0 ]; then
        error "No se encontraron paquetes para instalar."
        return 1
    fi

    run yay -S --needed --noconfirm "${packages[@]}"
    success "Paquetes instalados correctamente (${#packages[@]} paquetes)."

    if command -v nvim &>/dev/null; then
        if nvim --version | grep -q "LuaJIT"; then
            success "Neovim instalado con soporte LuaJIT."
        else
            warn "Neovim no tiene soporte LuaJIT."
        fi
    fi
}

install_ohmyzsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        success "Oh My Zsh ya está instalado."
    elif $DRY_RUN; then
        echo -e "${YELLOW}[DRY-RUN]${NC} clonar $OMZ_REPO @ ${OMZ_COMMIT:0:12} y ejecutar install.sh"
    else
        info "Instalando Oh My Zsh (commit fijado ${OMZ_COMMIT:0:12})..."
        local tmpdir
        tmpdir="$(mktemp -d)"
        if ensure_repo_ref "$OMZ_REPO" "$tmpdir/ohmyzsh" "$OMZ_COMMIT"; then
            env KEEP_ZSHRC=yes sh "$tmpdir/ohmyzsh/tools/install.sh" --unattended
        else
            rm -rf "$tmpdir"
            return 1
        fi
        rm -rf "$tmpdir"
        success "Oh My Zsh instalado correctamente."
    fi

    local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        info "Instalando zsh-autosuggestions (v0.7.1)..."
        ensure_repo_ref "$ZSH_AUTOSUGGESTIONS_REPO" \
            "$ZSH_CUSTOM/plugins/zsh-autosuggestions" "$ZSH_AUTOSUGGESTIONS_COMMIT"
    fi

    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        info "Instalando zsh-syntax-highlighting (0.8.0-alpha1)..."
        ensure_repo_ref "$ZSH_SYNTAX_HIGHLIGHTING_REPO" \
            "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" "$ZSH_SYNTAX_HIGHLIGHTING_COMMIT"
    fi

    success "Oh My Zsh y plugins configurados."
}

# Respaldar SOLO un ~/.config/nvim real (conflicto con stow).
# Nunca tocar ~/.local/share|state|cache de nvim: no entran en conflicto
# con el módulo y moverlos destruye plugins/undo/estado del usuario.
prepare_nvim_target() {
    local nvim_cfg="$HOME/.config/nvim"
    if [ -d "$nvim_cfg" ] && [ ! -L "$nvim_cfg" ]; then
        warn "Existe ~/.config/nvim real (no symlink). Respaldando..."
        run mv "$nvim_cfg" "${nvim_cfg}.bak.$(date +%s)"
    fi
    success "Entorno preparado para stow de nvim."
}

install_fonts() {
    info "Actualizando caché de fuentes..."
    run fc-cache -f >/dev/null 2>&1
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
    success "Directorios creados."
}

# Preflight de TODOS los módulos antes de tocar ninguno:
# aborta sin cambios si cualquier módulo tiene conflicto.
apply_stow() {
    info "Aplicando dotfiles con GNU Stow (target: \$HOME)..."
    local missing=0

    for module in "${STOW_MODULES[@]}"; do
        if [ ! -d "$DOTFILES_DIR/$module" ]; then
            warn "Módulo no encontrado: $module"
            missing=1
        fi
    done
    [ "$missing" -eq 1 ] && { error "Faltan módulos; revisa STOW_MODULES."; return 1; }

    if ! $DRY_RUN; then
        local conflicts=0
        for module in "${STOW_MODULES[@]}"; do
            local sim
            if ! sim="$(stow "${STOW_OPTS[@]}" --no -R "$module" 2>&1)"; then
                error "Conflicto Stow en módulo '$module':"
                echo "$sim" | grep -E '^\s+\*|WARNING' | sed 's/^/    /'
                conflicts=1
            fi
        done
        if [ "$conflicts" -eq 1 ]; then
            error "Stow abortado SIN cambios. Causa típica: archivo/directorio real"
            error "preexistente en \$HOME donde el módulo quiere enlazar."
            error "Resuelve moviendo tu archivo a un backup y reintenta, o elimina el symlink manual."
            return 1
        fi
    fi

    for module in "${STOW_MODULES[@]}"; do
        run stow "${STOW_OPTS[@]}" -R "$module"
        success "Aplicado: $module"
    done

    success "Todos los dotfiles aplicados."
}

remove_stow() {
    info "Deshaciendo symlinks de stow..."
    local failed=0

    for module in "${STOW_MODULES[@]}"; do
        if [ -d "$DOTFILES_DIR/$module" ]; then
            if run stow "${STOW_OPTS[@]}" -D "$module"; then
                success "Removido: $module"
            else
                warn "No se pudo remover: $module"
                failed=1
            fi
        fi
    done

    if [ "$failed" -eq 1 ]; then
        error "Algunos módulos no se removieron (ejecuta con -v para detalle)."
        return 1
    fi
    success "Todos los symlinks removidos."
}

set_zsh_shell() {
    local zsh_path
    zsh_path="$(command -v zsh 2>/dev/null || true)"
    if [ -z "$zsh_path" ]; then
        warn "zsh no encontrado en PATH. Instala zsh primero."
        return 1
    fi
    local current_shell
    current_shell="$(getent passwd "$(id -un)" | cut -d: -f7)"
    if [ "$current_shell" != "$zsh_path" ]; then
        if ! grep -qx "$zsh_path" /etc/shells; then
            warn "$zsh_path no está en /etc/shells. Añadiéndolo..."
            run sudo sh -c "echo '$zsh_path' >> /etc/shells"
        fi
        info "Cambiando shell predeterminado a Zsh..."
        run chsh -s "$zsh_path"
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
        if ! id -nG | tr ' ' '\n' | grep -qx docker; then
            if [ -t 0 ]; then
                echo ""
                read -rp "  ¿Añadir $(id -un) al grupo docker? (equivale a acceso root en el host) [y/N] " ans
                case "$ans" in
                    y|Y)
                        run sudo usermod -aG docker "$(id -un)"
                        warn "Añadido al grupo docker. Reinicia sesión para aplicar."
                        ;;
                    *)
                        info "Omitido. Para hacerlo manualmente: sudo usermod -aG docker $(id -un)"
                        ;;
                esac
                echo ""
            else
                warn "No interactivo: no se añadió al grupo docker."
                warn "Manual: sudo usermod -aG docker $(id -un)"
            fi
        fi
        success "Docker habilitado."
    fi

    if systemctl list-unit-files | grep -q NetworkManager.service; then
        run sudo systemctl enable --now NetworkManager.service
        success "NetworkManager habilitado e iniciado."
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
    if [ -f "$local_file" ]; then
        success "~/.gitconfig.local ya existe."
        return 0
    fi
    if $DRY_RUN; then
        echo -e "${YELLOW}[DRY-RUN]${NC} Se preguntaría nombre/email para ~/.gitconfig.local"
        return 0
    fi
    info "Creando ~/.gitconfig.local con datos personales..."
    if [ -t 0 ]; then
        echo ""
        read -rp "  Nombre para git (Enter para omitir): " git_name || git_name=""
        read -rp "  Email para git (Enter para omitir): " git_email || git_email=""
        echo ""
        if [ -n "${git_name:-}" ] || [ -n "${git_email:-}" ]; then
            {
                echo "[user]"
                [ -n "${git_name:-}" ] && echo "    name = $git_name"
                [ -n "${git_email:-}" ] && echo "    email = $git_email"
            } > "$local_file"
            success "~/.gitconfig.local creado."
        else
            warn "No se configuró ~/.gitconfig.local. Créalo manualmente."
        fi
    else
        warn "No hay terminal interactivo. Crea ~/.gitconfig.local manualmente con [user] name/email."
    fi
}

set_permissions() {
    info "Configurando permisos..."
    run chmod +x "$DOTFILES_DIR/qtile/.config/qtile/autostart.sh"
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

    # Cada archivo de cada módulo debe existir en $HOME y resolver al archivo del repo
    info "Verificando symlinks..."
    for module in "${STOW_MODULES[@]}"; do
        local mod_dir="$DOTFILES_DIR/$module"
        if [ ! -d "$mod_dir" ]; then
            warn "  $module: no existe en el repo"
            ((errors++)) || true
            continue
        fi
        local bad=0 total=0
        while IFS= read -r -d '' f; do
            local rel tgt
            rel="${f#"$mod_dir"/}"
            tgt="$HOME/$rel"
            total=$((total + 1))
            if [ ! -e "$tgt" ] && [ ! -L "$tgt" ]; then
                bad=$((bad + 1))
                continue
            fi
            if [ "$(readlink -f "$tgt" 2>/dev/null || true)" != "$(readlink -f "$f")" ]; then
                bad=$((bad + 1))
            fi
        done < <(find "$mod_dir" -type f \
                    ! -path '*/__pycache__/*' \
                    ! -name '*.pyc' ! -name '*.pyo' \
                    ! -name '.stow-local-ignore' -print0)
        if [ "$bad" -eq 0 ]; then
            success "  $module: $total archivos OK"
        else
            warn "  $module: $bad/$total archivos mal enlazados"
            ((errors++)) || true
        fi
    done

    # Verificar shell de la cuenta (no de la sesión)
    local current_shell
    current_shell="$(getent passwd "$(id -un)" | cut -d: -f7)"
    if [ "$current_shell" = "$(command -v zsh 2>/dev/null || true)" ]; then
        success "Shell: zsh activo"
    else
        warn "Shell: no es zsh (actual: $current_shell)"
        ((errors++)) || true
    fi

    # Verificar comandos esenciales
    local cmd
    for cmd in nvim stow git zsh bat btop fzf rg fd alacritty qtile \
               feh picom dunst rofi flameshot udiskie betterlockscreen \
               playerctl brightnessctl autorandr; do
        if command -v "$cmd" &>/dev/null; then
            success "Comando: $cmd disponible"
        else
            warn "Comando: $cmd NO encontrado"
            ((errors++)) || true
        fi
    done

    # Verificar binario polkit-gnome
    local polkit_bin="/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"
    if [ -x "$polkit_bin" ]; then
        success "Polkit: agente GTK disponible"
    else
        warn "Polkit: agente GTK no encontrado ($polkit_bin)"
        ((errors++)) || true
    fi

    # Verificar fuentes
    local nerd_count
    nerd_count=$(fc-list 2>/dev/null | grep -ci "nerd" || true)
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
        echo ""
        return 0
    else
        echo -e "${YELLOW}${BOLD}Verificación completa: $errors fallos${NC}"
        echo ""
        return 1
    fi
}

# ==============================================
# Instalación completa
# ==============================================

full_install() {
    check_arch
    check_yay
    install_packages ""
    install_fonts
    install_ohmyzsh
    prepare_nvim_target
    set_permissions
    create_stow_dirs
    apply_stow
    setup_gitconfig_local
    setup_lockscreen
    set_zsh_shell
    enable_services
    if ! $DRY_RUN; then
        verify_installation
    else
        info "[DRY-RUN] Se ejecutaría la verificación post-instalación."
    fi
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
    echo "  --dry-run           Simular sin efectos (solo = simular instalación completa)"
    echo "  --help              Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  ./install.sh                          # Instalación completa"
    echo "  ./install.sh --packages --only base   # Solo paquetes base"
    echo "  ./install.sh --stow --fonts           # Solo symlinks y fuentes"
    echo "  ./install.sh --dry-run --packages     # Ver qué paquetes se instalarían"
    echo "  ./install.sh --dry-run                # Simular instalación completa"
    echo "  ./install.sh --verify                 # Verificar instalación (exit 1 si falla)"
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

    check_root

    # Sin argumentos (o solo --dry-run): instalación completa
    if [ $# -eq 0 ]; then
        full_install
        print_final_steps
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
            --only)
                shift
                if [ $# -eq 0 ] || [ -z "$1" ]; then
                    error "--only requiere una lista de categorías (ej: base,fonts)."
                    return 1
                fi
                only_categories="$1"
                ;;
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

    if [ -n "$only_categories" ] && ! $do_packages; then
        error "--only solo tiene sentido junto con --packages."
        return 1
    fi

    check_arch

    local any_action=false
    $do_uninstall && any_action=true
    $do_packages   && any_action=true
    $do_fonts      && any_action=true
    $do_shell      && any_action=true
    $do_stow       && any_action=true
    $do_services   && any_action=true
    $do_verify     && any_action=true

    # Solo --dry-run: simular instalación completa
    if ! $any_action && $DRY_RUN; then
        full_install
        print_final_steps
        return 0
    fi

    if $do_uninstall; then
        remove_stow
        return 0
    fi

    if $do_packages; then
        check_yay
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
        prepare_nvim_target
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

print_final_steps() {
    if $DRY_RUN; then
        echo -e "${YELLOW}[DRY-RUN] Simulación completada. No se modificó nada.${NC}"
        return 0
    fi
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
}

main "$@"
