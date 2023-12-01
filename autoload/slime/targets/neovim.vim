
function! slime#targets#neovim#config() abort
  if !exists("b:slime_config")
    let last_pid = get(get(g:slime_last_channel, -1, {}), 'pid', '')
    let last_job = get(get(g:slime_last_channel, -1, {}), 'jobid', '')
    let b:slime_config =  {"jobid":  last_job, "pid": last_pid }
  endif

  if exists("g:slime_input_pid") && g:slime_input_pid
    let pid_in = input("pid: ", str2nr(jobpid(b:slime_config["jobid"])))
    let id_in = s:translate_pid_to_id(pid_in)
  else
    if exists("g:slime_get_jobid")
      let id_in = g:slime_get_jobid()
    else
      let id_in = input("jobid: ", str2nr(b:slime_config["jobid"]))
      let id_in = str2nr(id_in)
    endif
    let pid_in = s:translate_id_to_pid(id_in)
  endif

  let b:slime_config["jobid"] = id_in
  let b:slime_config["pid"] = pid_in
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

function! slime#targets#neovim#SlimeAddChannel()
  if !exists("g:slime_last_channel")
    let g:slime_last_channel = [{'jobid': &channel, 'pid': b:terminal_job_pid}]
  else
    call add(g:slime_last_channel, {'jobid': &channel, 'pid': b:terminal_job_pid})
  endif
endfunction

function slime#targets#neovim#SlimeClearChannel()
  if !exists("g:slime_last_channel")
    return
  elseif len(g:slime_last_channel) == 1
    unlet g:slime_last_channel
  else
    let bufinfo = getbufinfo()
    call filter(bufinfo, {_, val -> has_key(val['variables'], "terminal_job_id") && has_key(val['variables'], "terminal_job_pid") && !get(val['variables'],"terminal_closed",0)})
    call map(bufinfo, {_, val -> val["variables"]["terminal_job_id"] })
    call filter(g:slime_last_channel, {_, val -> index(bufinfo, val["jobid"]) >= 0})
  endif
endfunction

" Sets the status line if the appropriate flags are enabled.
function! slime#targets#neovim#SetStatusline()
  if exists("g:override_status") && g:override_status
    if exists("g:ruled_status") && g:ruled_status
      setlocal statusline=%{bufname()}%=%-14.(%l,%c%V%)\ %P\ \|\ id:\ %{b:terminal_job_id}\ pid:\ %{b:terminal_job_pid}
    else
      setlocal statusline=%{bufname()}%=id:\ %{b:terminal_job_id}\ pid:\ %{b:terminal_job_pid}
    endif
  endif
endfunction

function! s:translate_pid_to_id(pid)
  for ch in g:slime_last_channel
    if ch['pid'] == a:pid
      return ch['jobid']
    endif
  endfor
  return -1
endfunction

function! s:translate_id_to_pid(id)
  let pid_out = -1
  try
    let pid_out = jobpid(a:id)
  catch /E900: Invalid channel id/
    let pid_out = -1
  endtry
  return pid_out
endfunction
