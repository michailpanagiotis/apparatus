return {
  'ggandor/leap.nvim',
  config = function ()
    require('leap').setup({
      higlight_unlabeled = true,
      case_sensitive = true
    })

    require('leap').opts.safe_labels = {}
    vim.api.nvim_set_hl(0, 'LeapBackdrop', { link = 'Comment' })
    vim.keymap.set({'n', 'x', 'o'}, 's', function() require'leap'.leap({ target_windows = { vim.fn.win_getid() } }) end, {})
  end,
}
