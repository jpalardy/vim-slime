
function! slime#targets#neovim#config() abort
  if !exists("b:slime_config")
    let b:slime_config = {"jobid": get(g:, "slime_last_channel", "")}
  end
  if exists("g:slime_get_jobid")
    let b:slime_config["jobid"] = g:slime_get_jobid()
  else
    let b:slime_config["jobid"] = input("jobid: ", b:slime_config["jobid"])
  end
endfunction

function! slime#targets#neovim#send(config, text)
  " Neovim jobsend is fully asynchronous, it causes some problems with
  " iPython %cpaste (input buffering: not all lines sent over)
  " So this `write_paste_file` can help as a small lock & delay
  call slime#common#write_paste_file(a:text)
  call chansend(str2nr(a:config["jobid"]), split(a:text, "\n", 1))
  " if b:slime_config is {"jobid": ""} and not configured
  " then unset it for automatic configuration next time
  if b:slime_config["jobid"]  == ""
      unlet b:slime_config
  endif
endfunction

