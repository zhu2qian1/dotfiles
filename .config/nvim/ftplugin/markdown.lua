if vim.fn.expand("%:t"):lower() ~= "todo.md" then
  return
end

require("todo").setup(0)
