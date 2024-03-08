
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



if slime#config#resolve("target") == "neovim"
  if has('nvim')
    " if true use a prompted menu config to 
    let g:slime_config_defaults["menu_config"] = 0

    " whether to populate the command line with an identifier when configuring
    let g:slime_config_defaults["suggest_default"] = 1

    "input PID rather than job ID on the command line when configuring
    let g:slime_config_defaults["input_pid"] = 0

    " can be set to a user-defined function to automatically get a job id. Set as zero here to evaluate to false.
    let g:slime_config_defaults["get_jobid"] = 0


    "order of menu if configuring that way
    let g:slime_config_defaults["neovim_menu_order"] = [{'pid': 'pid: '}, {'jobid': 'jobid: '}, {'term_title':''}, {'name': ''}]

    "delimiter of menu
    let g:slime_config_defaults["neovim_menu_delimiter"] = ','
  else
    call slime#targets#neovim#EchoWarningMsg("Trying to use Neovim target in standard Vim. This won't work.")
  endif
endif
