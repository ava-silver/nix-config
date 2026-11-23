-- Rex key bindings. See `rex config --help`.

-- The focused block of the active window, for key bindings whose ctx has no block.
local function focused_block()
  local view = rex.session.view({})
  for _, window in ipairs(view and view.windows or {}) do
    if window.window_id == view.active_window_id then return window.focused_block_id end
  end
end

-- A subagent block (label prefix from pi's background/src/backends/rex.ts) belongs to the pi that started it.
-- Closing its tab or pane detaches it, so it keeps running and reopens from pi's background manager.
local function send_back(ctx)
  local block_id = ctx.block_id or focused_block()
  local listed = rex.session.list_blocks({})
  for _, block in ipairs(listed and listed.blocks or {}) do
    if block.block_id == block_id and block.label:sub(1, 5) == "sub: " then
      rex.session.detach_block({ block_id = block_id })
      return true
    end
  end
  return false
end

rex.action({
  name = "send_back",
  title = "Send Subagent Back",
  run = function(ctx) return send_back(ctx) end,
})

rex.bind("cmd+w", function(ctx) return send_back(ctx) end)
rex.bind("alt+cmd+w", function(ctx) return send_back(ctx) end)
