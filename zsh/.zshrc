# ============================================
# Zsh - Configuracion con Oh My Zsh
# ============================================

# --- Oh My Zsh ---
export ZSH="$HOME/.oh-my-zsh"

# Tema
ZSH_THEME="agnoster"

# Plugins
plugins=(
    git
    docker
    docker-compose
    fzf
    z
    sudo
    extract
    command-not-found
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# --- Variables de entorno ---
export EDITOR="nvim"
export VISUAL="nvim"
export TERMINAL="alacritty"
export BROWSER="brave"
export LANG="es_BO.UTF-8"
export LC_ALL="es_BO.UTF-8"

# Path
export PATH="$HOME/.local/bin:$PATH"

# --- Historial ---
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY  # Comparte historial entre sesiones (implica INC_APPEND)

# --- Opciones de Zsh ---
setopt AUTO_CD
setopt CORRECT
setopt NO_BEEP
setopt EXTENDED_GLOB
setopt INTERACTIVE_COMMENTS

# --- fzf ---
export FZF_DEFAULT_OPTS="
  --height 40%
  --layout=reverse
  --border
  --color=bg+:#3c3836,bg:#282828,spinner:#fb4934,hl:#928374
  --color=fg:#ebdbb2,header:#928374,info:#8ec07c,pointer:#fb4934
  --color=marker:#fb4934,fg+:#ebdbb2,prompt:#fb4934,hl+:#fb4934
"
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"

# --- bat ---
export BAT_THEME="gruvbox-dark"

# --- Aliases personalizados ---
[ -f ~/.zsh_aliases ] && source ~/.zsh_aliases

# --- Keybindings ---
bindkey -v  # Modo vi
bindkey '^R' history-incremental-search-backward
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^W' backward-kill-word       # Ctrl+W: borrar palabra anterior
bindkey '^[^?' backward-kill-word     # Alt+Backspace (secuencia más común)
bindkey '^[^H' backward-kill-word     # Alt+Backspace (variante)

export PATH="$HOME/.opencode/bin:$PATH"

# Java — Android Studio
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk"
export PATH="$JAVA_HOME/bin:$PATH"

