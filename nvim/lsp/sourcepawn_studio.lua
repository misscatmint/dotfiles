local sm = vim.env.SMDIR or ''
return {
  cmd = { 'sourcepawn-studio' },
  filetypes = { 'sourcepawn' },
  root_markers = { '.git' },
  settings = {
    SourcePawnLanguageServer = {
      compiler = { path = sm .. '/spcomp64' },
      includeDirectories = { sm .. '/include' },
    },
  },
}
