
let g:slime_config_defaults = {}
let g:slime_config_defaults["target"] = "screen"
let g:slime_config_defaults["preserve_curpos"] = 1
let g:slime_config_defaults["paste_file"] = expand("$HOME/.slime_paste")
let g:slime_config_defaults["bracketed_paste"] = 0
let g:slime_config_defaults["debug"] = 0

" -------------------------------------------------

" look for `config_name` in unusal places
" fallback to default_Value
function! slime#config#resolve(config_name)
  if exists("b:slime_" . a:config_name)
    return get(b:, "slime_" . a:config_name)
  endif
  if exists("g:slime_" . a:config_name)
    return get(g:, "slime_" . a:config_name)
  endif
  if has_key(g:slime_config_defaults, a:config_name)
    return get(g:slime_config_defaults, a:config_name)
  endif
  echoerr "missing config value for: slime_" . a:config_name
  return v:null
endfunction
