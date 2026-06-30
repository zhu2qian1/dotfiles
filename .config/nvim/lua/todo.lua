local M = {}

local function get_task_prefix()
  local line = vim.api.nvim_get_current_line()
  local indent = line:match("^(%s*)%- %[[ x%-]%] ")

  if indent then
    return indent .. "- [ ] "
  end

  return ""
end

local function insert_task_below()
  local prefix = get_task_prefix()

  if prefix == "" then
    vim.cmd("normal! o")
    return
  end

  local row = vim.api.nvim_win_get_cursor(0)[1]

  vim.api.nvim_buf_set_lines(
    0,
    row,
    row,
    false,
    { prefix }
  )

  vim.api.nvim_win_set_cursor(0, { row + 1, #prefix })
  vim.cmd("startinsert!")
end

local function insert_task_above()
  local prefix = get_task_prefix()

  if prefix == "" then
    vim.cmd("normal! O")
    return
  end

  local row = vim.api.nvim_win_get_cursor(0)[1]

  vim.api.nvim_buf_set_lines(
    0,
    row - 1,
    row - 1,
    false,
    { prefix }
  )

  vim.api.nvim_win_set_cursor(0, { row, #prefix })
  vim.cmd("startinsert!")
end

local function toggle_task()
  local line = vim.api.nvim_get_current_line()

  if line:match("^%s*%- %[ %]") then
    vim.api.nvim_set_current_line(
      line:gsub("%[ %]", "[x]", 1)
    )

  elseif line:match("^%s*%- %[x%]") then
    vim.api.nvim_set_current_line(
      line:gsub("%[x%]", "[ ]", 1)
    )

  else
    vim.cmd("normal! <CR>")
  end
end

function M.setup(bufnr)
  local opts = {
    buffer = bufnr,
    silent = true,
    noremap = true,
  }

  vim.keymap.set("n", "<CR>", toggle_task, opts)
  vim.keymap.set("n", "o", insert_task_below, opts)
  vim.keymap.set("n", "O", insert_task_above, opts)
end

return M
