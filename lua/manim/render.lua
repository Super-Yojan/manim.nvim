local M = {}

local function strip_ansi(s)
  return s:gsub("\27%[[%d;]*m", "")
end

function M.find_class_at_cursor()
  local bufnr = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  for i = row, 1, -1 do
    local line = vim.api.nvim_buf_get_lines(bufnr, i - 1, i, false)[1]
    local class_name = line:match("^class%s+(%w+)")
    if class_name then
      return class_name
    end
  end
  return nil
end

function M.render(config, callback)
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("manim: buffer has no file", vim.log.levels.ERROR)
    return
  end

  local class_name = M.find_class_at_cursor()
  if not class_name then
    vim.notify("manim: no class found above cursor", vim.log.levels.ERROR)
    return
  end

  local cmd = { config.manim_cmd, "render", config.quality, file, class_name }
  vim.notify("manim: rendering " .. class_name .. "...", vim.log.levels.INFO)

  local output = {}
  vim.fn.jobstart(cmd, {
    env = { TERM = "dumb", NO_COLOR = "1" },
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        vim.list_extend(output, data)
      end
    end,
    on_stderr = function(_, data)
      if data then
        vim.list_extend(output, data)
      end
    end,
    on_exit = function(_, code)
      vim.schedule(function()
        if code ~= 0 then
          vim.notify("manim: render failed (exit " .. code .. ")", vim.log.levels.ERROR)
          return
        end

        local full = strip_ansi(table.concat(output, "\n"))
        -- collapse the line-wrapped path back into one line
        local video_path = full:match("File ready at%s+'([^']+)'")
          or full:match("File ready at%s+\"([^\"]+)\"")
        if video_path then
          video_path = video_path:gsub("%s+", "")
        end

        if not video_path then
          vim.notify("manim: render succeeded but could not find output path", vim.log.levels.WARN)
          return
        end

        vim.notify("manim: render complete", vim.log.levels.INFO)
        if callback then
          callback(video_path, class_name)
        end
      end)
    end,
  })

  return class_name
end

return M
