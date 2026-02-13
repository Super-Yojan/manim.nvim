vim.api.nvim_create_user_command("ManimRender", function()
  require("manim").render()
end, { desc = "Render the Manim class under the cursor and play it" })

vim.api.nvim_create_user_command("ManimHotReload", function()
  require("manim").toggle_hot_reload()
end, { desc = "Toggle hot reload on save for the current file" })

vim.api.nvim_create_user_command("ManimStop", function()
  require("manim").stop()
end, { desc = "Stop mpv and disable hot reload" })
