return {
  "neovim/nvim-lspconfig",
  config = function()
    vim.lsp.config("pylsp", {})
    vim.lsp.config("lua_ls", {})
    vim.lsp.config("bashls", {
      filetypes = { "sh", "bash", "zsh", "fish", "bashrc", "zshrc" },
      settings = {
        bash = {
          enableIntegratedCmake = true,
          enableIntegratedShebang = true,
        },
      },
      root_markers = {},
      cmd = { "bash-language-server", "start" },
    })
    vim.lsp.enable({ "pylsp", "lua_ls", "bashls" })
  end,
}
