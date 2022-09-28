require('user.editing.trevj')
require('user.editing.autopairs')
require('user.editing.comment')


require('trim').setup({
  -- if you want to ignore space of top
  patterns = {
    [[%s/\s\+$//e]],           -- remove unwanted spaces
    [[%s/\($\n\s*\)\+\%$//]],  -- trim last line
    [[%s/\%^\n\+//]],          -- trim first line
    -- [[%s/\(\n\n\)\n\+/\1/]],   -- replace multiple blank lines with a single line
  },
})
