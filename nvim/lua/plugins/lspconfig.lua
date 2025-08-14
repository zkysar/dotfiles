return {
  "neovim/nvim-lspconfig",
  config = function()
    require("lspconfig").pylsp.setup{}
    require("lspconfig").lua_ls.setup{}
    require("lspconfig").bashls.setup {
      filetypes = { "sh", "bash", "zsh", "fish", "bashrc", "zshrc" },
      settings = {
        bash = {
          enableIntegratedCmake = true,
          enableIntegratedShebang = true,
        },
      },
      root_dir = function(client, bufnr)
        return nil -- or a custom logic to find the root directory
      end,
      cmd = { "bash-language-server", "start" },
    }
  end,
}
