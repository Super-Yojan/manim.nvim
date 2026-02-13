local M = {}

local job_id = nil
local current_path = nil

function M.play(video_path, config)
  if job_id and current_path == video_path then
    return
  end

  M.stop()

  local cmd = vim.list_extend({ "mpv" }, config.mpv_args)
  table.insert(cmd, video_path)

  job_id = vim.fn.jobstart(cmd, {
    detach = true,
    on_exit = function()
      job_id = nil
      current_path = nil
    end,
  })

  if job_id <= 0 then
    vim.notify("manim: failed to start mpv", vim.log.levels.ERROR)
    job_id = nil
    return
  end

  current_path = video_path
end

function M.stop()
  if job_id then
    vim.fn.jobstop(job_id)
    job_id = nil
    current_path = nil
  end
end

return M
