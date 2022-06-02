-- Add the path to this plugin to the runtimepath
vim.cmd('set rtp+=' .. vim.fn.expand('<sfile>:p:h:h'))

-- Turn on termguicolors for feline
vim.opt.termguicolors = true

-- Download the packer
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
local packer_bootstrap
if fn.empty(fn.glob(install_path)) > 0 then
    packer_bootstrap = fn.system({
        'git',
        'clone',
        '--depth',
        '1',
        'https://github.com/wbthomason/packer.nvim',
        install_path,
    })
end

-- Turn on and setup packer
vim.cmd([[packadd packer.nvim]])
require('packer').startup(function(use)
    use('wbthomason/packer.nvim')
    use({
        'compline',
        requires = {
            'kyazdani42/nvim-web-devicons',
            'famiu/feline.nvim',
            'tpope/vim-fugitive',
        },
    })
end)

if packer_bootstrap then
    require('packer').sync()
    print('Please, restart nvim through try.sh to use installed plugins.')
else
    -- Configuration for test:
    if vim.env.COSMOSLINE then
        ---@diagnostic disable-next-line: unused-local
        local config = require('compline.cosmosline')
            :new('my_line', {
                active = { left = { a = { [1] = { provider = 'test' } } } },
            })
            :setup()
        -- vim.pretty_print(config)
    else
        require('compline.statusline')
            :new('test', {
                active_components = { { { provider = 'test' } } },
            })
            :setup()
    end
end
