-- Rex key bindings. See `rex config --help`.

local SUBAGENT_PREFIX = "sub: "

local function is_subagent(block)
  return block ~= nil and type(block.label) == "string" and block.label:sub(1, #SUBAGENT_PREFIX) == SUBAGENT_PREFIX
end

local function list_blocks()
  local listed = rex.session.list_blocks({})
  return listed and listed.blocks or {}
end

-- The focused block of the active window, for calls whose ctx has no block.
local function focused_block()
  local view = rex.session.view({})
  for _, window in ipairs(view and view.windows or {}) do
    if window.window_id == view.active_window_id then return window.focused_block_id end
  end
end

local function find_block(blocks, block_id)
  if not block_id then return nil end
  for _, block in ipairs(blocks) do
    if block.block_id == block_id then return block end
  end
end

-- A subagent block (label prefix from pi's background/src/backends/rex.ts) belongs to the pi that started it.
-- Closing its pane or tab detaches it, so it keeps running and reopens from pi's background manager.
local function send_back(ctx)
  if not ctx.session_id then return false end
  local block = find_block(list_blocks(), ctx.block_id or focused_block())
  if not is_subagent(block) then return false end
  rex.session.detach_block({ block_id = block.block_id })
  return true
end

-- Detaches every subagent in the target window. Returns true when detaching them closed the window.
local function send_back_tab(ctx)
  if not ctx.session_id then return false end
  local blocks = list_blocks()
  local current = find_block(blocks, ctx.block_id or focused_block())
  local window_id = current and current.window_id
  if not window_id then
    local view = rex.session.view({})
    window_id = view and view.active_window_id
  end
  if not window_id then return false end

  local detached = 0
  local remaining = 0
  for _, block in ipairs(blocks) do
    if block.window_id == window_id then
      if is_subagent(block) then
        rex.session.detach_block({ block_id = block.block_id })
        detached = detached + 1
      else
        remaining = remaining + 1
      end
    end
  end
  return detached > 0 and remaining == 0
end

rex.action({
  name = "send_back",
  title = "Send Subagent Back",
  run = function(ctx) send_back(ctx) end,
})

-- Function keybindings swallow the client's default binding even when they return false,
-- so close shortcuts run as actions and queue the default close action for non-subagent panes/tabs.
rex.action({
  name = "close_pane_or_send_back",
  title = "Close Pane or Send Subagent Back",
  run = function(ctx)
    if not send_back(ctx) then rex.client.queue("client.close") end
  end,
})

rex.action({
  name = "close_tab_or_send_back",
  title = "Close Tab or Send Subagent Back",
  run = function(ctx)
    if not send_back_tab(ctx) then rex.client.queue("client.tab.close") end
  end,
})

rex.bind("cmd+w", "close_pane_or_send_back")
rex.bind("alt+cmd+w", "close_tab_or_send_back")
