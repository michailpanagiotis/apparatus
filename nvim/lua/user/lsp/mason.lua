local lspParams = require('user.lsp.config')
require('mason').setup(lspParams.installer.setup)
require('mason-lspconfig').setup(lspParams.installer.setup)
