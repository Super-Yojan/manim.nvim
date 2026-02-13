local render = require("manim.render")
local player = require("manim.player")

local M = {}

local config = {
  quality = "-qm",
  manim_cmd = "manim",
  mpv_args = { "--loop" },
  auto_play = true,
  hot_reload = false,
}

local hot_reload_augroup = nil
local last_class_name = nil

function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})

  vim.keymap.set("n", "<leader>mv", M.render, { desc = "Manim: render and view" })
  vim.keymap.set("n", "<leader>mh", M.toggle_hot_reload, { desc = "Manim: toggle hot reload" })
  vim.keymap.set("n", "<leader>ms", M.stop, { desc = "Manim: stop" })
end

function M.render()
  local class_name = render.render(config, function(video_path, name)
    last_class_name = name
    if config.auto_play then
      player.play(video_path, config)
    end
  end)
  if class_name then
    last_class_name = class_name
  end
end

function M.toggle_hot_reload()
  if hot_reload_augroup then
    vim.api.nvim_del_augroup_by_id(hot_reload_augroup)
    hot_reload_augroup = nil
    vim.notify("manim: hot reload disabled", vim.log.levels.INFO)
    return
  end

  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("manim: buffer has no file", vim.log.levels.ERROR)
    return
  end

  hot_reload_augroup = vim.api.nvim_create_augroup("ManimHotReload", { clear = true })
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = hot_reload_augroup,
    pattern = file,
    callback = function()
      if last_class_name then
        render.render(config, function(video_path)
          if config.auto_play then
            player.play(video_path, config)
          end
        end)
      else
        vim.notify("manim: no class rendered yet, run :ManimRender first", vim.log.levels.WARN)
      end
    end,
  })
  vim.notify("manim: hot reload enabled for " .. vim.fn.fnamemodify(file, ":t"), vim.log.levels.INFO)
end

function M.stop()
  player.stop()
  if hot_reload_augroup then
    vim.api.nvim_del_augroup_by_id(hot_reload_augroup)
    hot_reload_augroup = nil
  end
  last_class_name = nil
  vim.notify("manim: stopped", vim.log.levels.INFO)
end

return M
