-- Default key mappings for yank-file-path plugin
-- Pattern: <leader>y + format + modifiers
-- Formats: r(elative), a(bsolute), f(ilename), h(ome), o(root)
-- Modifiers: l(ine), r(ange), a(ll)

local function setup_mappings()
  local opts = { noremap = true, silent = true }

  -- Single file mappings
  vim.keymap.set('n', '<leader>yr', ':YankFilePath relative<CR>',
                 vim.tbl_extend('force', opts, { desc = 'Yank relative file path' }))
  vim.keymap.set('n', '<leader>ya', ':YankFilePath absolute<CR>',
                 vim.tbl_extend('force', opts, { desc = 'Yank absolute file path' }))
  vim.keymap.set('n', '<leader>yf', ':YankFilePath filename<CR>',
                 vim.tbl_extend('force', opts, { desc = 'Yank filename only' }))
  vim.keymap.set('n', '<leader>yh', ':YankFilePath home<CR>',
                 vim.tbl_extend('force', opts, { desc = 'Yank home-relative path' }))
  vim.keymap.set('n', '<leader>yo', ':YankFilePath root<CR>',
                 vim.tbl_extend('force', opts, { desc = 'Yank root-relative path' }))

  -- Single file with line number
  vim.keymap.set('n', '<leader>yrl', ':YankFilePath relative --line<CR>',
                 vim.tbl_extend('force', opts, { desc = 'Yank relative path with line' }))
  vim.keymap.set('n', '<leader>yal', ':YankFilePath absolute --line<CR>',
                 vim.tbl_extend('force', opts, { desc = 'Yank absolute path with line' }))
  vim.keymap.set('n', '<leader>yfl', ':YankFilePath filename --line<CR>',
                 vim.tbl_extend('force', opts, { desc = 'Yank filename with line' }))
  vim.keymap.set('n', '<leader>yhl', ':YankFilePath home --line<CR>',
                 vim.tbl_extend('force', opts, { desc = 'Yank home-relative path with line' }))
  vim.keymap.set('n', '<leader>yol', ':YankFilePath root --line<CR>',
                 vim.tbl_extend('force', opts, { desc = 'Yank root-relative path with line' }))

  -- Single file with range (works with visual selection)
  vim.keymap.set('n', '<leader>yrr', ':YankFilePath relative --range<CR>',
                 vim.tbl_extend('force', opts, { desc = 'Yank relative path with range' }))
  vim.keymap.set('v', '<leader>yrr', ':YankFilePath relative --range<CR>',
                 vim.tbl_extend('force', opts, { desc = 'Yank relative path with range' }))
  vim.keymap.set('n', '<leader>yar', ':YankFilePath absolute --range<CR>',
                 vim.tbl_extend('force', opts, { desc = 'Yank absolute path with range' }))
  vim.keymap.set('v', '<leader>yar', ':YankFilePath absolute --range<CR>',
                 vim.tbl_extend('force', opts, { desc = 'Yank absolute path with range' }))
  vim.keymap.set('n', '<leader>yfr', ':YankFilePath filename --range<CR>',
                 vim.tbl_extend('force', opts, { desc = 'Yank filename with range' }))
  vim.keymap.set('v', '<leader>yfr', ':YankFilePath filename --range<CR>',
                 vim.tbl_extend('force', opts, { desc = 'Yank filename with range' }))
  vim.keymap.set('n', '<leader>yhr', ':YankFilePath home --range<CR>',
                 vim.tbl_extend('force', opts, { desc = 'Yank home-relative path with range' }))
  vim.keymap.set('v', '<leader>yhr', ':YankFilePath home --range<CR>',
                 vim.tbl_extend('force', opts, { desc = 'Yank home-relative path with range' }))
  vim.keymap.set('n', '<leader>yor', ':YankFilePath root --range<CR>',
                 vim.tbl_extend('force', opts, { desc = 'Yank root-relative path with range' }))
  vim.keymap.set('v', '<leader>yor', ':YankFilePath root --range<CR>',
                 vim.tbl_extend('force', opts, { desc = 'Yank root-relative path with range' }))

  -- All buffers
  vim.keymap.set('n', '<leader>yra', ':YankFilePath --all relative<CR>',
                 vim.tbl_extend('force', opts, { desc = 'Yank all relative paths' }))
  vim.keymap.set('n', '<leader>yaa', ':YankFilePath --all absolute<CR>',
                 vim.tbl_extend('force', opts, { desc = 'Yank all absolute paths' }))
  vim.keymap.set('n', '<leader>yfa', ':YankFilePath --all filename<CR>',
                 vim.tbl_extend('force', opts, { desc = 'Yank all filenames' }))
  vim.keymap.set('n', '<leader>yha', ':YankFilePath --all home<CR>',
                 vim.tbl_extend('force', opts, { desc = 'Yank all home-relative paths' }))
  vim.keymap.set('n', '<leader>yoa', ':YankFilePath --all root<CR>',
                 vim.tbl_extend('force', opts, { desc = 'Yank all root-relative paths' }))

  -- All buffers with newline separator (common use case)
  vim.keymap.set('n', '<leader>yran', ':YankFilePath --all relative --separator="\\n"<CR>',
                 vim.tbl_extend('force', opts, { desc = 'Yank all relative paths (newlines)' }))
  vim.keymap.set('n', '<leader>yaan', ':YankFilePath --all absolute --separator="\\n"<CR>',
                 vim.tbl_extend('force', opts, { desc = 'Yank all absolute paths (newlines)' }))
  vim.keymap.set('n', '<leader>yfan', ':YankFilePath --all filename --separator="\\n"<CR>',
                 vim.tbl_extend('force', opts, { desc = 'Yank all filenames (newlines)' }))
  vim.keymap.set('n', '<leader>yhan', ':YankFilePath --all home --separator="\\n"<CR>',
                 vim.tbl_extend('force', opts, { desc = 'Yank all home-relative paths (newlines)' }))
  vim.keymap.set('n', '<leader>yoan', ':YankFilePath --all root --separator="\\n"<CR>',
                 vim.tbl_extend('force', opts, { desc = 'Yank all root-relative paths (newlines)' }))
end

return {
  setup_mappings = setup_mappings,
}
