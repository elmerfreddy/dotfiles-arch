-- ============================================
-- Neovim - Keymaps personalizados
-- Estos se aplican sobre los de LazyVim
-- ============================================

local map = vim.keymap.set

-- Mejor movimiento entre splits
map("n", "<C-h>", "<C-w>h", { desc = "Ir al split izquierdo" })
map("n", "<C-j>", "<C-w>j", { desc = "Ir al split inferior" })
map("n", "<C-k>", "<C-w>k", { desc = "Ir al split superior" })
map("n", "<C-l>", "<C-w>l", { desc = "Ir al split derecho" })

-- Redimensionar splits con flechas
map("n", "<C-Up>", ":resize +2<CR>", { desc = "Agrandar split horizontal" })
map("n", "<C-Down>", ":resize -2<CR>", { desc = "Reducir split horizontal" })
map("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Reducir split vertical" })
map("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Agrandar split vertical" })

-- Mover lineas en modo visual
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Mover linea abajo" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Mover linea arriba" })

-- Mantener cursor centrado al buscar
map("n", "n", "nzzzv", { desc = "Siguiente resultado centrado" })
map("n", "N", "Nzzzv", { desc = "Resultado anterior centrado" })

-- Mejor indentacion en visual
map("v", "<", "<gv", { desc = "Indentar izquierda" })
map("v", ">", ">gv", { desc = "Indentar derecha" })

-- Limpiar highlights de busqueda
map("n", "<Esc>", ":noh<CR>", { desc = "Limpiar highlights" })

-- Guardar rapido
map("n", "<C-s>", ":w<CR>", { desc = "Guardar archivo" })
map("i", "<C-s>", "<Esc>:w<CR>a", { desc = "Guardar archivo (insert)" })
