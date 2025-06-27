-- Set test mode before requiring the plugin
vim.env.NVIM_TEST_MODE = "1"

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
        "YankFilePath"
      }

      for _, cmd in ipairs(commands) do
        local exists = vim.fn.exists(":" .. cmd) == 2
        assert.is_true(exists, "Command " .. cmd .. " should exist")
      end
    end)
  end)
end)
