return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false, -- Never set this value to "*"! Never!
  opts = {
    provider = "lmstudio",
    providers = {
      lmstudio = {
        __inherited_from = "openai",
        endpoint = "http://localhost:1234/v1/",
        model = "qwen3-0.6b",
        api_key_name = "FAKE_LMSTUDIO_KEY",
      },
      lmstudiobig = {
        __inherited_from = "openai",
        endpoint = "http://localhost:1234/v1/",
        model = "qwen3-4b",
        api_key_name = "FAKE_LMSTUDIO_KEY",
      },
    }
  },
  ---@module 'avante'
  ---@type avante.Config
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "echasnovski/mini.pick", -- for file_selector provider mini.pick
    "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
    "folke/snacks.nvim", -- for input provider snacks
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}
