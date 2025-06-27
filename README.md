# yank-file-path.nvim

[![CI](https://github.com/neumachen/yank-file-path.nvim/actions/workflows/ci.yml/badge.svg)](https://github.com/neumachen/yank-file-path.nvim/actions/workflows/ci.yml)

A Neovim plugin that provides convenient commands to copy (yank) file paths to the system clipboard. Supports various path formats including relative paths, absolute paths, and file names only.

## Features

- 🚀 Copy current file path in multiple formats
- 📁 Copy multiple buffer paths at once
- 🔧 Customizable separators for multiple paths
- 📋 Automatic clipboard integration
- 🔔 Visual feedback with notifications
- 📚 Comprehensive documentation

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "neumachen/yank-file-path.nvim",
    config = function()
        require("yank-file-path").setup({
            -- Optional: customize root markers for root-relative paths
            root_markers = { ".git", ".hg", "package.json", "Cargo.toml", "pyproject.toml" }
        })
    end,
}
```

Or with minimal configuration:

```lua
{
    "neumachen/yank-file-path.nvim",
    -- Plugin loads automatically with default settings
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
    "neumachen/yank-file-path.nvim",
    config = function()
        require("yank-file-path").setup({
            -- Optional: customize root markers
            root_markers = { ".git", "package.json", "go.mod" }
        })
    end
}
```

Or with minimal configuration:

```lua
use "neumachen/yank-file-path.nvim"
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'neumachen/yank-file-path.nvim'

" Add to your init.lua or init.vim:
lua << EOF
require("yank-file-path").setup({
    -- Optional: customize root markers
    root_markers = { ".git", "package.json", "go.mod" }
})
EOF
```

Or with minimal configuration (uses defaults):

```vim
Plug 'neumachen/yank-file-path.nvim'
```

## Commands

### Single File Commands

| Command | Description | Example Output |
|---------|-------------|----------------|
| `:YankRelativeFilePath` | Copy relative file path | `src/main.lua` |
| `:YankAbsoluteFilePath` | Copy absolute file path | `/home/user/project/src/main.lua` |
| `:YankRelativeFilePathFromHome` | Copy path relative to home | `~/project/src/main.lua` |
| `:YankFileName` | Copy just the filename | `main.lua` |
| `:YankRootRelativeFilePath` | Copy path relative to project root | `src/main.lua` |
| `:YankFilePath` | Alias for `:YankRelativeFilePath` | `src/main.lua` |

### Multiple Files Commands

| Command | Description | Default Separator |
|---------|-------------|-------------------|
| `:YankAllRelativeFilePaths [separator]` | Copy all relative paths | space |
| `:YankAllAbsoluteFilePaths [separator]` | Copy all absolute paths | space |
| `:YankAllRelativeFilePathsFromHome [separator]` | Copy all paths from home | space |
| `:YankAllFileNames [separator]` | Copy all filenames | space |
| `:YankAllRootRelativeFilePaths [separator]` | Copy all root-relative paths | space |

## Usage Examples

### Basic Usage

```vim
" Copy current file's relative path
:YankRelativeFilePath

" Copy current file's absolute path
:YankAbsoluteFilePath

" Copy just the filename
:YankFileName
```

### Multiple Files with Custom Separators

```vim
" Copy all relative paths separated by newlines
:YankAllRelativeFilePaths \n

" Copy all filenames separated by commas
:YankAllFileNames ,

" Copy all absolute paths separated by tabs
:YankAllAbsoluteFilePaths \t
```

### Special Separators

- `\n` - newline character
- `\t` - tab character
- Any other string is used as-is (e.g., `,`, ` | `, etc.)

## Key Mappings (Optional)

You can create your own key mappings for frequently used commands:

```lua
-- Example key mappings
vim.keymap.set('n', '<leader>yp', ':YankRelativeFilePath<CR>', { desc = 'Yank relative file path' })
vim.keymap.set('n', '<leader>yP', ':YankAbsoluteFilePath<CR>', { desc = 'Yank absolute file path' })
vim.keymap.set('n', '<leader>yn', ':YankFileName<CR>', { desc = 'Yank filename' })
vim.keymap.set('n', '<leader>ya', ':YankAllRelativeFilePaths<CR>', { desc = 'Yank all relative paths' })
```

## Configuration

The plugin works out of the box without any configuration. All commands are automatically available after the plugin is loaded.

### Custom Root Markers

You can customize the root markers used for root-relative path detection:

```lua
-- Using lazy.nvim
{
    "neumachen/yank-file-path.nvim",
    config = function()
        require("yank-file-path").setup({
            root_markers = { ".git", ".hg", "package.json", "Cargo.toml", "pyproject.toml" }
        })
    end,
}

-- Or call setup directly
require("yank-file-path").setup({
    root_markers = { ".git", "package.json", "go.mod" }
})
```

### Default Root Markers

The plugin comes with these default root markers:
- `.git`
- `.hg` 
- `.svn`
- `package.json`
- `Cargo.toml`
- `go.mod`
- `pyproject.toml`
- `Makefile`

### Runtime Configuration

You can also change root markers at runtime:

```lua
require("yank-file-path").set_root_markers({ ".git", "custom.toml" })
```

### Notifications

The plugin uses `vim.notify()` for user feedback:
- **INFO level**: Successful copy operations
- **WARN level**: Warnings (e.g., when no buffers are found)

## Development

### Running Tests

The plugin includes comprehensive tests using [plenary.nvim](https://github.com/nvim-lua/plenary.nvim):

```bash
# Run all tests
nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"
```

### Project Structure

```
yank-file-path.nvim/
├── doc/
│   └── yank-file-path.txt      # Vim help documentation
├── plugin/
│   └── yank-file-path.lua      # Main plugin code
├── tests/
│   ├── yank-file-path_spec.lua # Test suite
│   └── minimal_init.lua        # Minimal init for testing
├── LICENSE                     # MIT License
└── README.md                   # This file
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Setup

1. Clone the repository
2. Install [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) for testing
3. Run tests to ensure everything works
4. Make your changes
5. Add tests for new functionality
6. Ensure all tests pass

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by the need for quick file path copying in Neovim workflows
- Built with modern Neovim Lua APIs
- Thanks to the Neovim community for excellent plugin development resources

## Similar Plugins

If this plugin doesn't meet your needs, you might want to check out:
- [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua) - File explorer with copy path functionality
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - Fuzzy finder with path copying features

---

**Happy yanking! 🎯**
