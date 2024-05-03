-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("i", "jj", "<esc>")
vim.keymap.set("n", "<leader>a=", ":Tabularize /=<CR>")

-- vim.g.NERDSpaceDelims = 1
-- vim.api.nvim_set_keymap('n', ',cs', '<plug>NERDCommenterToggle', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('x', ',cs', '<plug>NERDCommenterToggle<CR>', { noremap = true, silent = true })
