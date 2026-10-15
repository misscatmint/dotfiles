if vim.env.SMDIR then
  vim.bo.makeprg = vim.env.SMDIR .. '/spcomp64 %'
  vim.bo.errorformat = '%f(%l) : %trror %n: %m,%f(%l) : %tarning %n: %m'
end
