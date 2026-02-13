local M = {}

local pid = nil
local current_path = nil

function M.play(video_path, config)
  -- Same file: mpv is still running, nothing to do
  if pid and current_path == video_path then
    -- check if mpv is actually still alive
    local ok = pcall(vim.uv.kill, pid, 0)
    if ok then
      return
    end
    -- mpv died, clean up and relaunch below
    pid = nil
    current_path = nil
  end

  M.stop()

  local cmd = vim.list_extend({ "mpv" }, config.mpv_args)
  table.insert(cmd, video_path)

  local job_id = vim.fn.jobstart(cmd, {
    detach = true,
    on_exit = function()
      pid = nil
      current_path = nil
    end,
  })

  if job_id <= 0 then
    vim.notify("manim: failed to start mpv", vim.log.levels.ERROR)
    return
  end

  pid = vim.fn.jobpid(job_id)
  current_path = video_path
end

function M.stop()
  if pid then
    pcall(vim.uv.kill, pid, 15) -- SIGTERM
    pid = nil
    current_path = nil
  end
end

return M
