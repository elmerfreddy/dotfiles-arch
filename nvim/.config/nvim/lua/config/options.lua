-- ============================================
-- Neovim - Opciones personalizadas
-- Estas opciones se aplican sobre las de LazyVim
-- ============================================

local opt = vim.opt

-- General
opt.clipboard = "unnamedplus"    -- Usar clipboard del sistema
opt.mouse = "a"                  -- Habilitar mouse
opt.number = true                -- Numeros de linea
opt.relativenumber = true        -- Numeros relativos
opt.cursorline = true            -- Resaltar linea actual
opt.signcolumn = "yes"           -- Siempre mostrar signcolumn
opt.termguicolors = true         -- Colores 24-bit
opt.wrap = false                 -- No wrap de lineas

-- Indentacion
opt.tabstop = 4                  -- Tab = 4 espacios
opt.shiftwidth = 4               -- Indentacion = 4 espacios
opt.expandtab = true             -- Tabs como espacios
opt.smartindent = true           -- Indentacion inteligente

-- Busqueda
opt.ignorecase = true            -- Ignorar mayusculas al buscar
opt.smartcase = true             -- Smart case
opt.hlsearch = true              -- Resaltar resultados

-- Rendimiento
opt.updatetime = 250             -- Tiempo para CursorHold
opt.timeoutlen = 300             -- Tiempo para keymaps

-- Splits
opt.splitbelow = true            -- Splits horizontales abajo
opt.splitright = true            -- Splits verticales a la derecha

-- Scroll
opt.scrolloff = 8                -- Lineas de contexto al hacer scroll
opt.sidescrolloff = 8

-- Backup
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true              -- Persistent undo
