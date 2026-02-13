# manim.nvim

Neovim plugin for rendering [Manim Community Edition](https://www.manim.community/) scenes and playing them with mpv — right from your editor.

## Features

- Detects the Python class under your cursor and renders it asynchronously
- Auto-plays the result in mpv with `--loop`
- Hot reload on file save — edit, save, and see changes instantly
- Fully async — never blocks your editor

## Requirements

- Neovim >= 0.9
- [Manim Community Edition](https://docs.manim.community/en/stable/installation.html)
- [mpv](https://mpv.io/)

## Installation

### lazy.nvim

```lua
{
  "Super-Yojan/manim.nvim",
  opts = {},
}
```

### packer.nvim

```lua
use {
  "Super-Yojan/manim.nvim",
  config = function()
    require("manim").setup()
  end,
}
```

## Configuration

```lua
require("manim").setup({
  quality = "-qm",           -- manim quality flag (-ql, -qm, -qh, -qk)
  manim_cmd = "manim",       -- manim binary
  mpv_args = { "--loop" },   -- extra mpv arguments
  auto_play = true,          -- auto-launch mpv after render
})
```

## Keybindings

Set up automatically on `setup()`:

| Key | Action |
|---|---|
| `<leader>mv` | Render class under cursor and view in mpv |
| `<leader>mh` | Toggle hot reload for current file |
| `<leader>ms` | Stop mpv and disable hot reload |

## Commands

| Command | Description |
|---|---|
| `:ManimRender` | Render the Manim class under the cursor and play it |
| `:ManimHotReload` | Toggle hot reload on save for the current file |
| `:ManimStop` | Stop mpv and disable hot reload |

## Usage

1. Open a `.py` file containing a Manim `Scene` class
2. Place your cursor inside a class
3. Press `<leader>mv` or run `:ManimRender`
4. Toggle hot reload with `<leader>mh` — save the file to re-render automatically
5. Stop everything with `<leader>ms`
