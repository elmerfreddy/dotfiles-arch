# ==============================================
# Dotfiles - Makefile
# ==============================================

.PHONY: help install packages packages-base packages-desktop packages-dev packages-fonts stow unstow fonts shell services verify dry-run update clean check

help: ## Mostrar esta ayuda
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## Instalación completa
	@./install.sh

packages: ## Instalar todos los paquetes
	@./install.sh --packages

packages-base: ## Instalar solo paquetes base
	@./install.sh --packages --only base

packages-desktop: ## Instalar solo paquetes de escritorio
	@./install.sh --packages --only desktop

packages-dev: ## Instalar solo paquetes de desarrollo
	@./install.sh --packages --only dev

packages-fonts: ## Instalar solo fuentes
	@./install.sh --packages --only fonts

stow: ## Aplicar symlinks con GNU Stow
	@./install.sh --stow

unstow: ## Deshacer symlinks de stow
	@./install.sh --uninstall

fonts: ## Actualizar caché de fuentes
	@./install.sh --fonts

shell: ## Configurar Oh My Zsh y shell
	@./install.sh --shell

services: ## Habilitar servicios del sistema
	@./install.sh --services

verify: ## Verificar estado de la instalación
	@./install.sh --verify

dry-run: ## Simular instalación completa
	@./install.sh --dry-run

update: ## Actualizar paquetes y re-aplicar stow
	@./install.sh --packages --stow --fonts

check: ## Validar sintaxis y simular instalación completa (sin efectos)
	@bash -n install.sh
	@zsh -n zsh/.zshrc && zsh -n zsh/.zsh_aliases
	@./install.sh --dry-run >/dev/null
	@./install.sh --dry-run --packages --only base >/dev/null
	@echo "check: OK"

clean: unstow ## Alias de unstow
