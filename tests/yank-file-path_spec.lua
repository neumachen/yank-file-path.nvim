-- Set test mode before requiring the plugin
vim.env.NVIM_TEST_MODE = "1"

-- Add project root to package path so we can require the plugin
local project_root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h")
package.path = project_root .. "/?.lua;" .. package.path

local plugin = require("plugin.yank-file-path")

describe("yank-file-path plugin", function()
  local original_notify
  local original_setreg
  local notifications = {}
  local clipboard_content = ""

  before_each(function()
    -- Mock vim.notify to capture notifications
    original_notify = vim.notify
    notifications = {}
    vim.notify = function(msg, level)
      table.insert(notifications, { msg = msg, level = level })
    end

    -- Mock vim.fn.setreg to capture clipboard content
    original_setreg = vim.fn.setreg
    vim.fn.setreg = function(reg, content)
      if reg == "+" then
        clipboard_content = content
      end
    end
  end)

  after_each(function()
    -- Restore original functions
    vim.notify = original_notify
    vim.fn.setreg = original_setreg
    notifications = {}
    clipboard_content = ""
  end)

  describe("format_path", function()
    it("should format path with relative modifier", function()
      -- Mock vim.fn.expand and vim.fn.fnamemodify
      local original_expand = vim.fn.expand
      local original_fnamemodify = vim.fn.fnamemodify
      
      vim.fn.expand = function(pattern)
        if pattern == "%" then
          return "/home/user/project/file.lua"
        end
        return pattern
      end
      
      vim.fn.fnamemodify = function(path, mods)
        if mods == ":." then
          return "project/file.lua"
        end
        return path
      end

      local result = plugin.format_path(":.")
      assert.equals("project/file.lua", result)

      -- Restore
      vim.fn.expand = original_expand
      vim.fn.fnamemodify = original_fnamemodify
    end)

    it("should use provided buf_path when given", function()
      local original_fnamemodify = vim.fn.fnamemodify
      
      vim.fn.fnamemodify = function(path, mods)
        if path == "/custom/path.lua" and mods == ":t" then
          return "path.lua"
        end
        return path
      end

      local result = plugin.format_path(":t", "/custom/path.lua")
      assert.equals("path.lua", result)

      vim.fn.fnamemodify = original_fnamemodify
    end)
  end)

  describe("parse_separator", function()
    it("should parse newline separator", function()
      local result = plugin.parse_separator("\\n")
      assert.equals("\n", result)
    end)

    it("should parse tab separator", function()
      local result = plugin.parse_separator("\\t")
      assert.equals("\t", result)
    end)

    it("should return other separators as-is", function()
      local result = plugin.parse_separator(",")
      assert.equals(",", result)
    end)
  end)

  describe("copy_to_clipboard", function()
    it("should copy path to clipboard and show notification", function()
      plugin.copy_to_clipboard("/test/path.lua")
      
      assert.equals("/test/path.lua", clipboard_content)
      assert.equals(1, #notifications)
      assert.equals("Copied: /test/path.lua", notifications[1].msg)
      assert.equals(vim.log.levels.INFO, notifications[1].level)
    end)
  end)

  describe("get_all_buffer_paths", function()
    it("should return paths for loaded buffers with names", function()
      -- Mock vim.api functions
      local original_list_bufs = vim.api.nvim_list_bufs
      local original_buf_is_loaded = vim.api.nvim_buf_is_loaded
      local original_buf_get_name = vim.api.nvim_buf_get_name
      local original_fnamemodify = vim.fn.fnamemodify

      vim.api.nvim_list_bufs = function()
        return { 1, 2, 3 }
      end

      vim.api.nvim_buf_is_loaded = function(buf)
        return buf <= 2 -- Only buffers 1 and 2 are loaded
      end

      vim.api.nvim_buf_get_name = function(buf)
        if buf == 1 then
          return "/path/file1.lua"
        elseif buf == 2 then
          return "/path/file2.lua"
        else
          return ""
        end
      end

      vim.fn.fnamemodify = function(path, mods)
        if mods == ":t" then
          return path:match("([^/]+)$")
        end
        return path
      end

      local result = plugin.get_all_buffer_paths(":t")
      assert.equals(2, #result)
      assert.equals("file1.lua", result[1])
      assert.equals("file2.lua", result[2])

      -- Restore
      vim.api.nvim_list_bufs = original_list_bufs
      vim.api.nvim_buf_is_loaded = original_buf_is_loaded
      vim.api.nvim_buf_get_name = original_buf_get_name
      vim.fn.fnamemodify = original_fnamemodify
    end)
  end)

  describe("copy_all_buffer_paths", function()
    it("should copy all buffer paths with default separator", function()
      -- Mock vim.api functions that get_all_buffer_paths uses
      local original_list_bufs = vim.api.nvim_list_bufs
      local original_buf_is_loaded = vim.api.nvim_buf_is_loaded
      local original_buf_get_name = vim.api.nvim_buf_get_name
      local original_fnamemodify = vim.fn.fnamemodify

      vim.api.nvim_list_bufs = function()
        return { 1, 2 }
      end

      vim.api.nvim_buf_is_loaded = function(buf)
        return true
      end

      vim.api.nvim_buf_get_name = function(buf)
        if buf == 1 then
          return "/path/file1.lua"
        elseif buf == 2 then
          return "/path/file2.lua"
        end
        return ""
      end

      vim.fn.fnamemodify = function(path, mods)
        if mods == ":t" then
          return path:match("([^/]+)$")
        end
        return path
      end

      plugin.copy_all_buffer_paths(":t", { args = "" })
      
      assert.equals("file1.lua file2.lua", clipboard_content)
      assert.equals(1, #notifications)
      assert.equals("Copied: file1.lua file2.lua", notifications[1].msg)

      -- Restore
      vim.api.nvim_list_bufs = original_list_bufs
      vim.api.nvim_buf_is_loaded = original_buf_is_loaded
      vim.api.nvim_buf_get_name = original_buf_get_name
      vim.fn.fnamemodify = original_fnamemodify
    end)

    it("should copy all buffer paths with custom separator", function()
      -- Mock vim.api functions that get_all_buffer_paths uses
      local original_list_bufs = vim.api.nvim_list_bufs
      local original_buf_is_loaded = vim.api.nvim_buf_is_loaded
      local original_buf_get_name = vim.api.nvim_buf_get_name
      local original_fnamemodify = vim.fn.fnamemodify

      vim.api.nvim_list_bufs = function()
        return { 1, 2 }
      end

      vim.api.nvim_buf_is_loaded = function(buf)
        return true
      end

      vim.api.nvim_buf_get_name = function(buf)
        if buf == 1 then
          return "/path/file1.lua"
        elseif buf == 2 then
          return "/path/file2.lua"
        end
        return ""
      end

      vim.fn.fnamemodify = function(path, mods)
        if mods == ":t" then
          return path:match("([^/]+)$")
        end
        return path
      end

      plugin.copy_all_buffer_paths(":t", { args = "\\n" })
      
      assert.equals("file1.lua\nfile2.lua", clipboard_content)

      -- Restore
      vim.api.nvim_list_bufs = original_list_bufs
      vim.api.nvim_buf_is_loaded = original_buf_is_loaded
      vim.api.nvim_buf_get_name = original_buf_get_name
      vim.fn.fnamemodify = original_fnamemodify
    end)

    it("should show warning when no buffers found", function()
      -- Mock vim.api functions to return no buffers
      local original_list_bufs = vim.api.nvim_list_bufs
      local original_buf_is_loaded = vim.api.nvim_buf_is_loaded
      local original_buf_get_name = vim.api.nvim_buf_get_name

      vim.api.nvim_list_bufs = function()
        return {}
      end

      vim.api.nvim_buf_is_loaded = function(buf)
        return false
      end

      vim.api.nvim_buf_get_name = function(buf)
        return ""
      end

      plugin.copy_all_buffer_paths(":t", { args = "" })
      
      assert.equals("", clipboard_content)
      assert.equals(1, #notifications)
      assert.equals("No buffers with file paths found", notifications[1].msg)
      assert.equals(vim.log.levels.WARN, notifications[1].level)

      -- Restore
      vim.api.nvim_list_bufs = original_list_bufs
      vim.api.nvim_buf_is_loaded = original_buf_is_loaded
      vim.api.nvim_buf_get_name = original_buf_get_name
    end)
  end)

  describe("find_root_dir", function()
    it("should find root directory with .git marker", function()
      -- Mock vim.fn functions
      local original_isdirectory = vim.fn.isdirectory
      local original_filereadable = vim.fn.filereadable
      local original_fnamemodify = vim.fn.fnamemodify

      vim.fn.isdirectory = function(path)
        if path == "/project/subdir/file.lua" then
          return 0 -- it's a file
        elseif path == "/project/.git" then
          return 1 -- .git directory exists
        else
          return 0
        end
      end

      vim.fn.filereadable = function(path)
        return 0 -- no files are readable in this test
      end

      vim.fn.fnamemodify = function(path, mods)
        if mods == ":h" then
          if path == "/project/subdir/file.lua" then
            return "/project/subdir"
          elseif path == "/project/subdir" then
            return "/project"
          elseif path == "/project" then
            return "/"
          end
        end
        return path
      end

      local result = plugin.find_root_dir("/project/subdir/file.lua")
      assert.equals("/project", result)

      -- Restore
      vim.fn.isdirectory = original_isdirectory
      vim.fn.filereadable = original_filereadable
      vim.fn.fnamemodify = original_fnamemodify
    end)

    it("should return nil when no root marker found", function()
      -- Mock vim.fn functions
      local original_isdirectory = vim.fn.isdirectory
      local original_filereadable = vim.fn.filereadable
      local original_fnamemodify = vim.fn.fnamemodify

      vim.fn.isdirectory = function(path)
        if path == "/some/file.lua" then
          return 0 -- it's a file
        else
          return 0 -- no directories match
        end
      end

      vim.fn.filereadable = function(path)
        return 0 -- no files are readable
      end

      vim.fn.fnamemodify = function(path, mods)
        if mods == ":h" then
          if path == "/some/file.lua" then
            return "/some"
          elseif path == "/some" then
            return "/"
          end
        end
        return path
      end

      local result = plugin.find_root_dir("/some/file.lua")
      assert.is_nil(result)

      -- Restore
      vim.fn.isdirectory = original_isdirectory
      vim.fn.filereadable = original_filereadable
      vim.fn.fnamemodify = original_fnamemodify
    end)
  end)

  describe("format_path with root modifier", function()
    it("should format path relative to root directory", function()
      -- Mock vim.fn functions
      local original_expand = vim.fn.expand
      local original_isdirectory = vim.fn.isdirectory
      local original_filereadable = vim.fn.filereadable
      local original_fnamemodify = vim.fn.fnamemodify
      local original_substitute = vim.fn.substitute
      local original_resolve = vim.fn.resolve
      local original_escape = vim.fn.escape

      vim.fn.expand = function(pattern)
        if pattern == "%" then
          return "/project/src/file.lua"
        end
        return pattern
      end

      vim.fn.isdirectory = function(path)
        if path == "/project/src/file.lua" then
          return 0 -- it's a file
        elseif path == "/project/.git" then
          return 1 -- .git directory exists
        else
          return 0
        end
      end

      vim.fn.filereadable = function(path)
        return 0
      end

      vim.fn.fnamemodify = function(path, mods)
        if mods == ":h" then
          if path == "/project/src/file.lua" then
            return "/project/src"
          elseif path == "/project/src" then
            return "/project"
          elseif path == "/project" then
            return "/"
          end
        elseif mods == ":." then
          return "src/file.lua"
        end
        return path
      end

      vim.fn.resolve = function(path)
        return path
      end

      vim.fn.escape = function(str, chars)
        return str:gsub("([" .. chars .. "])", "\\%1")
      end

      vim.fn.substitute = function(str, pattern, replacement, flags)
        if pattern == "^/project/" then
          return str:gsub("^/project/", "")
        end
        return str
      end

      local result = plugin.format_path(":root")
      assert.equals("src/file.lua", result)

      -- Restore
      vim.fn.expand = original_expand
      vim.fn.isdirectory = original_isdirectory
      vim.fn.filereadable = original_filereadable
      vim.fn.fnamemodify = original_fnamemodify
      vim.fn.substitute = original_substitute
      vim.fn.resolve = original_resolve
      vim.fn.escape = original_escape
    end)

    it("should fallback to relative path when no root found", function()
      -- Mock vim.fn functions
      local original_expand = vim.fn.expand
      local original_isdirectory = vim.fn.isdirectory
      local original_filereadable = vim.fn.filereadable
      local original_fnamemodify = vim.fn.fnamemodify

      vim.fn.expand = function(pattern)
        if pattern == "%" then
          return "/some/file.lua"
        end
        return pattern
      end

      vim.fn.isdirectory = function(path)
        return 0 -- no directories
      end

      vim.fn.filereadable = function(path)
        return 0 -- no files
      end

      vim.fn.fnamemodify = function(path, mods)
        if mods == ":h" then
          if path == "/some/file.lua" then
            return "/some"
          elseif path == "/some" then
            return "/"
          end
        elseif mods == ":." then
          return "file.lua"
        end
        return path
      end

      local result = plugin.format_path(":root")
      assert.equals("file.lua", result)

      -- Restore
      vim.fn.expand = original_expand
      vim.fn.isdirectory = original_isdirectory
      vim.fn.filereadable = original_filereadable
      vim.fn.fnamemodify = original_fnamemodify
    end)
  end)

  describe("set_root_markers", function()
    it("should update root markers configuration", function()
      local original_markers = plugin.config.root_markers
      
      plugin.set_root_markers({ ".git", "package.json" })
      assert.same({ ".git", "package.json" }, plugin.config.root_markers)
      
      -- Restore original markers
      plugin.config.root_markers = original_markers
    end)
  end)

  describe("user commands", function()
    it("should create all expected commands", function()
      -- Check that commands exist (this is a basic integration test)
      local commands = {
        "YankRelativeFilePath",
        "YankAbsoluteFilePath", 
        "YankRelativeFilePathFromHome",
        "YankFileName",
        "YankAllRelativeFilePaths",
        "YankAllAbsoluteFilePaths",
        "YankAllRelativeFilePathsFromHome",
        "YankAllFileNames",
        "YankRootRelativeFilePath",
        "YankAllRootRelativeFilePaths",
        "YankFilePath"
      }

      for _, cmd in ipairs(commands) do
        local exists = vim.fn.exists(":" .. cmd) == 2
        assert.is_true(exists, "Command " .. cmd .. " should exist")
      end
    end)
  end)
end)
