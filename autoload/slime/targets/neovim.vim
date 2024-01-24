
function! slime#targets#neovim#config() abort

  " unlet current config if its jobid doesn't exist
  if exists("b:slime_config")
    let bufinfo = s:get_filter_bufinfo()
    let current_jobid = get(b:slime_config, "jobid", "-1")
    if index(bufinfo, current_jobid) == -1
      unlet b:slime_config
    endif
  endif


  if !exists("b:slime_config")
    let last_pid = get(get(g:slime_last_channel, -1, {}), 'pid', '')
    let last_job = get(get(g:slime_last_channel, -1, {}), 'jobid', '')
    let b:slime_config =  {"jobid":  last_job, "pid": last_pid }
  endif

  "include option to input pid
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

function! slime#targets#neovim#SlimeClearChannel()
  let current_buffer_jobid = get(b:,"terminal_job_id",-1)

  if !exists("g:slime_last_channel")
    if exists("b:slime_config")
      unlet b:slime_config
    endif
    return
  elseif len(g:slime_last_channel) == 1
    unlet g:slime_last_channel
    if exists("b:slime_config")
      unlet b:slime_config
    endif
  else
    let bufinfo = s:get_filter_bufinfo()

    " tests if using a version of Neovim that
    " doesn't automatically close buffers when closed
    " or there is no autocommand that does that
    if len(bufinfo) == len(g:slime_last_channel)
      call filter(bufinfo, {_, val -> val != current_buffer_jobid})
    endif

    call filter(g:slime_last_channel, {_, val -> index(bufinfo, str2nr(val["jobid"])) >= 0})

  endif
endfunction

function! s:get_filter_bufinfo()
  let bufinfo = getbufinfo()
  "getting terminal buffers

  call filter(bufinfo, {_, val -> has_key(val['variables'], "terminal_job_id")
        \ && has_key(val['variables'], "terminal_job_pid")
        \    && get(val,"listed",0)})
  " only need the job id
  call map(bufinfo, {_, val -> val["variables"]["terminal_job_id"] })

  return bufinfo
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


