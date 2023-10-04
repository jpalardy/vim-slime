" look for `config_name` in unusal places
" fallback to default_Value
function! slime#config#resolve(config_name, default_value)
  if exists("b:slime_" . a:config_name)
    return get(b:, "slime_" . a:config_name)
  endif
  if exists("g:slime_" . a:config_name)
    return get(g:, "slime_" . a:config_name)
  endif
  return a:default_value
endfunction
