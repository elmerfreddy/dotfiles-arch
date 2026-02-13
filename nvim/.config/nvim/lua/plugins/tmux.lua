-- ============================================
-- vim-tmux-navigator
-- Navegacion transparente entre splits de nvim y paneles de tmux
-- ============================================
return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  keys = {
    { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Ir al panel izquierdo" },
    { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Ir al panel inferior" },
    { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Ir al panel superior" },
    { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Ir al panel derecho" },
    { "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "Ir al panel anterior" },
  },
}
