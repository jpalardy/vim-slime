" look for `config_name` in unusal places
" fallback to default_Value
function! slime#config#resolve(config_name, default_value)
  if exists("b:slime_" . a:config_name)
    echom 'using b: value of ' . a:config_name
    return eval("b:slime_" . a:config_name)
  endif
  if exists("g:slime_" . a:config_name)
    echom 'using g: value of ' . a:config_name
    return eval("g:slime_" . a:config_name)
  endif
  echom 'using default value of ' . a:config_name
  return a:default_value
endfunction
