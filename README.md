# yank-file-path.nvim

[![CI](https://github.com/neumachen/yank-file-path.nvim/actions/workflows/ci.yml/badge.svg)](https://github.com/neumachen/yank-file-path.nvim/actions/workflows/ci.yml)

A Neovim plugin that provides convenient commands to copy (yank) file paths to the system clipboard. Supports various path formats including relative paths, absolute paths, and file names only.

## Features

- 🚀 Copy current file path in multiple formats (relative, absolute, from home, filename only)
- 🎯 Copy file paths relative to project root (auto-detects .git by default, configurable)
- 📍 Copy file paths with current line numbers or ranges for precise referencing
- 📁 Copy multiple buffer paths at once with customizable separators
- 🔧 Configurable root markers for project detection
- 📋 Automatic system clipboard integration
- 🔔 Visual feedback with notifications
- ⚙️ Runtime configuration support
- 🎹 Default key mappings with `<leader>y` prefix (configurable)
- 📚 Comprehensive documentation and help files
- 🧪 Fully tested with comprehensive test suite
- ⚡ Unified command interface with `YankFilePath` supporting all functionality

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "neumachen/yank-file-path.nvim",
    config = function()
        require("yank-file-path").setup({
            -- Optional: customize root markers for root-relative paths
            root_markers = { ".git", "package.json", "Cargo.toml", "pyproject.toml" },
            -- Optional: disable default key mappings
            enable_default_mappings = true
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
            root_markers = { ".git", "package.json", "go.mod" },
            -- Optional: disable default key mappings
            enable_default_mappings = true
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
    root_markers = { ".git", "package.json", "go.mod" },
    -- Optional: disable default key mappings
    enable_default_mappings = true
})
EOF
```

Or with minimal configuration (uses defaults):

```vim
Plug 'neumachen/yank-file-path.nvim'
```

## Commands

### Main Command

The plugin provides a unified command interface:

**`:YankFilePath [format] [options]`**

**Format options:**
- `relative` - Copy relative file path (default)
- `absolute` - Copy absolute file path  
- `filename` - Copy filename only
- `home` - Copy path relative to home directory (~)
- `root` - Copy path relative to project root

**Options:**
- `--line` - Include current line number
- `--range` - Include line range (works with visual selection)
- `--all` - Copy paths from all loaded buffers
- `--separator=<sep>` - Custom separator for multiple paths (default: space)
- `--root=<marker>` - Specific root marker to search for (default: .git)

**Examples:**
```vim
:YankFilePath relative
:YankFilePath absolute --line
:YankFilePath filename --range
:YankFilePath root --root=package.json
:YankFilePath --all relative --separator="\n"
```

### Legacy Commands (for backward compatibility)

| Command | Description | Example Output |
|---------|-------------|----------------|
| `:YankRelativeFilePath` | Copy relative file path | `src/main.lua` |
| `:YankAbsoluteFilePath` | Copy absolute file path | `/home/user/project/src/main.lua` |
| `:YankRelativeFilePathFromHome` | Copy path relative to home | `~/project/src/main.lua` |
| `:YankFileName` | Copy just the filename | `main.lua` |
| `:YankRootRelativeFilePath` | Copy path relative to project root | `src/main.lua` |

### Legacy Commands with Line Numbers

| Command | Description | Example Output |
|---------|-------------|----------------|
| `:YankRelativeFilePathWithLine` | Copy relative file path with line number | `src/main.lua:42` |
| `:YankAbsoluteFilePathWithLine` | Copy absolute file path with line number | `/home/user/project/src/main.lua:42` |
| `:YankRelativeFilePathFromHomeWithLine` | Copy path relative to home with line number | `~/project/src/main.lua:42` |
| `:YankFileNameWithLine` | Copy filename with line number | `main.lua:42` |
| `:YankRootRelativeFilePathWithLine` | Copy path relative to project root with line number | `src/main.lua:42` |

### Legacy Multiple Files Commands

| Command | Description | Default Separator |
|---------|-------------|-------------------|
| `:YankAllRelativeFilePaths [separator]` | Copy all relative paths | space |
| `:YankAllAbsoluteFilePaths [separator]` | Copy all absolute paths | space |
| `:YankAllRelativeFilePathsFromHome [separator]` | Copy all paths from home | space |
| `:YankAllFileNames [separator]` | Copy all filenames | space |
| `:YankAllRootRelativeFilePaths [separator]` | Copy all root-relative paths | space |

## Usage Examples

### Basic Usage (New Unified Command)

```vim
" Copy current file's relative path
:YankFilePath relative

" Copy current file's absolute path
:YankFilePath absolute

" Copy just the filename
:YankFilePath filename

" Copy path relative to project root
:YankFilePath root

" Copy path relative to home directory
:YankFilePath home
```

### With Line Numbers and Ranges

```vim
" Copy relative path with current line number
:YankFilePath relative --line

" Copy absolute path with line range (works with visual selection)
:YankFilePath absolute --range

" Copy filename with current line number
:YankFilePath filename --line
```

### Multiple Files

```vim
" Copy all relative paths (space-separated)
:YankFilePath --all relative

" Copy all relative paths separated by newlines
:YankFilePath --all relative --separator="\n"

" Copy all filenames separated by commas
:YankFilePath --all filename --separator=","

" Copy all absolute paths separated by tabs
:YankFilePath --all absolute --separator="\t"
```

### Custom Root Markers

```vim
" Use package.json as root marker instead of .git
:YankFilePath root --root=package.json

" Copy all paths relative to Cargo.toml root
:YankFilePath --all root --root=Cargo.toml --separator="\n"
```

### Legacy Commands (still supported)

```vim
" Copy current file's relative path
:YankRelativeFilePath

" Copy current file's absolute path
:YankAbsoluteFilePath

" Copy just the filename
:YankFileName

" Copy all relative paths separated by newlines
:YankAllRelativeFilePaths \n
```

### Special Separators

- `\n` - newline character
- `\t` - tab character
- Any other string is used as-is (e.g., `,`, ` | `, etc.)

## Key Mappings

### Default Key Mappings

The plugin automatically sets up key mappings using the pattern `<leader>y` + format + modifiers:

**Format letters:**
- `r` = relative path
- `a` = absolute path  
- `f` = filename only
- `h` = home-relative path (~)
- `o` = root-relative path (project root)

**Modifier letters:**
- `l` = include line number
- `r` = include range (works with visual selection)
- `a` = all buffers
- `n` = newline separator (when combined with `a`)

**Single file mappings:**
```vim
<leader>yr   " Yank relative file path
<leader>ya   " Yank absolute file path
<leader>yf   " Yank filename only
<leader>yh   " Yank home-relative path
<leader>yo   " Yank root-relative path
```

**Single file with line number:**
```vim
<leader>yrl  " Yank relative path with line number
<leader>yal  " Yank absolute path with line number
<leader>yfl  " Yank filename with line number
<leader>yhl  " Yank home-relative path with line number
<leader>yol  " Yank root-relative path with line number
```

**Single file with range (normal and visual mode):**
```vim
<leader>yrr  " Yank relative path with range
<leader>yar  " Yank absolute path with range
<leader>yfr  " Yank filename with range
<leader>yhr  " Yank home-relative path with range
<leader>yor  " Yank root-relative path with range
```

**All buffers (space-separated):**
```vim
<leader>yra  " Yank all relative paths
<leader>yaa  " Yank all absolute paths
<leader>yfa  " Yank all filenames
<leader>yha  " Yank all home-relative paths
<leader>yoa  " Yank all root-relative paths
```

**All buffers (newline-separated):**
```vim
<leader>yran " Yank all relative paths (newlines)
<leader>yaan " Yank all absolute paths (newlines)
<leader>yfan " Yank all filenames (newlines)
<leader>yhan " Yank all home-relative paths (newlines)
<leader>yoan " Yank all root-relative paths (newlines)
```

### Custom Key Mappings

You can disable the default mappings and create your own:

```lua
-- Disable default mappings
require("yank-file-path").setup({
    enable_default_mappings = false
})

-- Set your own mappings using the new unified command
vim.keymap.set('n', '<leader>yp', ':YankFilePath relative<CR>', { desc = 'Yank relative file path' })
vim.keymap.set('n', '<leader>yP', ':YankFilePath absolute<CR>', { desc = 'Yank absolute file path' })
vim.keymap.set('n', '<leader>yf', ':YankFilePath filename<CR>', { desc = 'Yank filename only' })
vim.keymap.set('n', '<leader>yh', ':YankFilePath home<CR>', { desc = 'Yank home-relative path' })
vim.keymap.set('n', '<leader>yo', ':YankFilePath root<CR>', { desc = 'Yank root-relative path' })

-- With line numbers
vim.keymap.set('n', '<leader>ypl', ':YankFilePath relative --line<CR>', { desc = 'Yank relative path with line' })
vim.keymap.set('n', '<leader>yPl', ':YankFilePath absolute --line<CR>', { desc = 'Yank absolute path with line' })

-- With ranges (works in visual mode too)
vim.keymap.set({'n', 'v'}, '<leader>ypr', ':YankFilePath relative --range<CR>', { desc = 'Yank relative path with range' })
vim.keymap.set({'n', 'v'}, '<leader>yPr', ':YankFilePath absolute --range<CR>', { desc = 'Yank absolute path with range' })

-- All buffers
vim.keymap.set('n', '<leader>yap', ':YankFilePath --all relative<CR>', { desc = 'Yank all relative paths' })
vim.keymap.set('n', '<leader>yaP', ':YankFilePath --all absolute<CR>', { desc = 'Yank all absolute paths' })
vim.keymap.set('n', '<leader>yan', ':YankFilePath --all relative --separator="\\n"<CR>', { desc = 'Yank all paths (newlines)' })
```

### Using with Which-Key Plugin

If you use [which-key.nvim](https://github.com/folke/which-key.nvim), you can organize the mappings:

```lua
local wk = require("which-key")

wk.register({
  y = {
    name = "Yank File Paths",
    r = { ":YankFilePath relative<CR>", "Relative path" },
    a = { ":YankFilePath absolute<CR>", "Absolute path" },
    f = { ":YankFilePath filename<CR>", "Filename only" },
    h = { ":YankFilePath home<CR>", "Home-relative path" },
    o = { ":YankFilePath root<CR>", "Root-relative path" },
  },
}, { prefix = "<leader>" })
```


## Configuration

The plugin works out of the box without any configuration. All commands are automatically available after the plugin is loaded.

### Configuration Options

```lua
require("yank-file-path").setup({
    -- Root markers for project detection (default: { ".git" })
    root_markers = { ".git", "package.json", "go.mod" },
    
    -- Enable/disable default key mappings (default: true)
    enable_default_mappings = true
})
```

### Custom Root Markers

You can customize the root markers used for root-relative path detection:

```lua
-- Using lazy.nvim
{
    "neumachen/yank-file-path.nvim",
    config = function()
        require("yank-file-path").setup({
            root_markers = { ".git", "package.json", "Cargo.toml", "pyproject.toml" }
        })
    end,
}

-- Or call setup directly
require("yank-file-path").setup({
    root_markers = { ".git", "package.json", "go.mod" }
})
```

### Default Root Markers

The plugin defaults to using only `.git` as the root marker. This provides consistent behavior and errors clearly when no root is found.

### Runtime Configuration

You can also change root markers at runtime:

```lua
require("yank-file-path").set_root_markers({ ".git", "custom.toml" })
```

### Per-Command Root Markers

You can specify a custom root marker for individual commands:

```vim
" Use package.json as root marker for this command
:YankFilePath root --root=package.json

" Use Cargo.toml for all buffers
:YankFilePath --all root --root=Cargo.toml --separator="\n"
```

### Error Handling

The plugin now provides strict error handling:
- **Root not found**: When using `root` format, the plugin will error if no root marker is found
- **Clear error messages**: Specific error messages indicate which root marker was searched for
- **No fallbacks**: The plugin no longer falls back to relative paths when root is not found

### Notifications

The plugin uses `vim.notify()` for user feedback:
- **INFO level**: Successful copy operations
- **WARN level**: Warnings (e.g., when no buffers are found)
- **ERROR level**: Error conditions (e.g., root directory not found)

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
├── lua/
│   └── yank-file-path/
│       ├── init.lua            # Main module entry point
│       ├── config.lua          # Configuration management
│       ├── utils.lua           # Core utility functions
│       └── commands.lua        # User command definitions
├── plugin/
│   └── yank-file-path.lua      # Plugin loader
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
