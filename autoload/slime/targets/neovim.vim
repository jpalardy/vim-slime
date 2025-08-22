
function! slime#targets#neovim#config() abort
  let config_set = 0

    if !config_set && slime#config#resolve("menu_config")
      let temp_config =  s:config_with_menu()
      let config_set = 1
    endif


  " unlet current config if its job ID doesn't exist
  if !config_set
    let slime_suggest_default = slime#config#resolve("suggest_default")
    let last_channels = get(g:, 'slime_last_channel', [])
    let most_recent_channel = get(last_channels, -1, {})

    let last_pid = get(most_recent_channel, 'pid', '')
    let last_job = get(most_recent_channel, 'jobid', '')

    let temp_config =  {"jobid":  last_job, "pid": last_pid }
  endif

  " include option to input pid
  if !config_set && slime#config#resolve("input_pid")
    let default_pid = slime_suggest_default ? s:translate_id_to_pid(temp_config["jobid"]) : ""
    if default_pid == -1
      let default_pid = ""
    endif
    let pid_in = input("Configuring vim-slime. Input pid: ", default_pid , 'customlist,Last_channel_to_pid')
    redraw
    let jobid_in = str2nr(s:translate_pid_to_id(pid_in))
    let temp_config["jobid"] = jobid_in
    let temp_config["pid"] = pid_in
    let config_set = 1
  endif

  if !config_set && exists('g:slime_get_jobid') && type(g:slime_get_jobid) == v:t_func
    let jobid_in = luaeval('vim.g.slime_get_jobid()')
    let pid_in = s:translate_id_to_pid(jobid_in)
    let temp_config["jobid"] = jobid_in
    let temp_config["pid"] = pid_in
    let config_set = 1
  endif

  " passed all guard cases, inputting jobid
  if !config_set
    let default_jobid = slime_suggest_default ? temp_config["jobid"] : ""
    if !empty(default_jobid)
      let default_jobid = str2nr(default_jobid)
    endif
    let jobid_in = input("Configuring vim-slime. Input jobid: ", default_jobid, 'customlist,Last_channel_to_jobid')
    redraw
    let jobid_in = str2nr(jobid_in)
    let pid_in = s:translate_id_to_pid(jobid_in)

    let temp_config["jobid"] = jobid_in
    let temp_config["pid"] = pid_in
  endif

  let b:slime_config = temp_config
endfunction

function! slime#targets#neovim#send(config, text) abort
  let [bracketed_paste, text_to_paste, has_crlf] = slime#common#bracketed_paste(a:text)
  let job_id = str2nr(a:config["jobid"])
  if bracketed_paste
    call chansend(job_id, "\e[200~")
    call chansend(job_id, text_to_paste)
    call chansend(job_id, "\e[201~")
    if has_crlf
      call chansend(job_id, "\n")
    end
  else
    call chansend(job_id, split(a:text, "\n", 1))
  end
endfunction

function! slime#targets#neovim#SlimeAddChannel(buf_in) abort
  let buf_in = str2nr(a:buf_in)

  if slime#config#resolve("neovim_ignore_unlisted") && !buflisted(buf_in)
    return
  endif

  " only interactive terminals havve the &channel option, it is one of their defining properties
  " this is poorly documented
  " getbufvar returns "" when the option/variable lit looks for isn't found
  let jobid = getbufvar(buf_in, "&channel")
  if jobid == ""
    return
  endif

  let job_pid = jobpid(jobid)

  if !exists("g:slime_last_channel")
    let g:slime_last_channel = [{'jobid': jobid, 'pid': job_pid, 'bufnr': buf_in}]
  else
    call add(g:slime_last_channel, {'jobid': jobid, 'pid': job_pid, 'bufnr': buf_in})
  endif
endfunction

function! slime#targets#neovim#SlimeClearChannel(buf_in) abort
  if !exists("g:slime_last_channel")
    call s:clear_all_buffs()
    return
  elseif len(g:slime_last_channel) == 0
    call s:clear_all_buffs()
    unlet g:slime_last_channel
  else
    let last_channel_copy =  copy(g:slime_last_channel)
    let filtered_last_channels = filter(last_channel_copy, {_, val -> val['bufnr'] == a:buf_in})

    if len(filtered_last_channels) > 0
      let jobid_to_clear = filtered_last_channels[0]['jobid']
      call s:clear_related_bufs(jobid_to_clear)
      call filter(g:slime_last_channel, {_, val -> val['bufnr'] != a:buf_in})
    endif

  endif
endfunction

" evaluates whether there is a terminal running; if there isn't then no config can be valid
function! slime#targets#neovim#ValidEnv() abort
  if (!exists("g:slime_last_channel") || (len(g:slime_last_channel)) < 1) || empty(g:slime_last_channel)
    call slime#targets#neovim#EchoWarningMsg("Terminal not found.")
    return 0
  endif
  return 1
endfunction

" "checks that a configuration is valid
" returns boolean of whether the supplied config is valid
function! slime#targets#neovim#ValidConfig(config, silent) abort

  if !exists("g:slime_last_channel") 
    if !a:silent
      call slime#targets#neovim#EchoWarningMsg("Terminal not found.")
    endif
    return 0
  endif

  " Ensure the config is a dictionary and a previous channel exists
  if type(a:config) != v:t_dict
    if !a:silent
      call slime#targets#neovim#EchoWarningMsg("Config type not valid.")
    endif
    return 0
  endif

  if empty(a:config)
    if !a:silent
      call slime#targets#neovim#EchoWarningMsg("Config is empty.")
    endif
    return 0
  endif

  " Ensure the correct keys exist within the configuration
  if !(has_key(a:config, 'jobid'))
    if !a:silent
      call slime#targets#neovim#EchoWarningMsg("Config object lacks 'jobid'.")
    endif
    return 0
  endif

  if a:config["jobid"] == -1  "the id wasn't found translate_pid_to_id
    if !a:silent
      call slime#targets#neovim#EchoWarningMsg("No matching job ID for the provided pid.")
    endif
    return 0
  endif

  if !(index(
        \map(copy(g:slime_last_channel), {_, val -> val["jobid"]}),
        \a:config['jobid']) >= 0
        \)
    if !a:silent
      call slime#targets#neovim#EchoWarningMsg("Invalid job ID.")
    endif
    return 0
  endif

  if s:translate_id_to_pid(a:config['jobid']) == -1
    if !a:silent
      call slime#targets#neovim#EchoWarningMsg("job ID not linked to a PID.")
    endif
    return 0
  endif

  return 1
endfunction

function! s:translate_pid_to_id(pid) abort
  for ch in g:slime_last_channel
    if ch['pid'] == a:pid
      return ch['jobid']
    endif
  endfor
  return -1
endfunction

function! s:translate_id_to_pid(id) abort
  let pid_out = -1
  try
    let pid_out = jobpid(a:id)
  catch
  endtry
  return pid_out
endfunction

" Transforms a channel dictionary with job ID and pid into a newline separated string  of job IDs.
" for the purposes of input completion
function! Last_channel_to_jobid(ArgLead, CmdLine, CursorPos) abort
  let jobids = map(copy(g:slime_last_channel), {_, val -> val["jobid"]})
  call map(jobids, {_, val -> string(val)})
  return reverse(jobids) " making correct order in menu
endfunction

" Transforms a channel dictionary with job ID and pid into an newline separated string  of job PIDs.
" for the purposes of input completion
function! Last_channel_to_pid(ArgLead, CmdLine, CursorPos) abort
  "they will be transformed into pids so naming them by their final identity
  let jobpids = map(copy(g:slime_last_channel), {_, val -> val["jobid"]})
  call map(jobpids, {_, val -> s:translate_id_to_pid(val)})
  call filter(jobpids, {_,val -> val != -1})
  call map(jobpids, {_, val -> string(val)})
  return reverse(jobpids) "making most recent the first selected
endfunction


" clears all buffers with a certain invalid configuration
function! s:clear_related_bufs(id_in) abort
  let related_bufs = filter(getbufinfo(), {_, val -> has_key(val['variables'], "slime_config")
        \ && get(val['variables']['slime_config'], 'jobid', -2) == a:id_in})

  for buf in related_bufs
    call setbufvar(buf['bufnr'], 'slime_config', {})
  endfor
endfunction

" clears all buffers of all configurations
function! s:clear_all_buffs() abort
  let target_bufs = filter(getbufinfo(), {_, val -> has_key(val['variables'], "slime_config") })

  for buf in target_bufs
    call setbufvar(buf['bufnr'], 'slime_config', {})
  endfor
endfunction

function! s:extend_term_buffer_titles(specific_term_info, all_bufinfo) abort
  " add buffer name and terminal title to a dictionary that already has jobid, pid, buffer number
  " specific term info is a dictionary that contains jobid, pid, and bufnr
  " all_bufinfo is the output of getbufinfo()

  " important to use copy here to avoid filtering in calling environment
  let all_bufinfo_in = copy(a:all_bufinfo)
  let specific_term_info_in = copy(a:specific_term_info)

  " get the term info
  let wanted_term = filter(all_bufinfo_in, {_, val -> val['bufnr'] == specific_term_info_in['bufnr']})[0]
  return extend(specific_term_info_in, {'name': wanted_term['name'], 'term_title': wanted_term['variables']['term_title']})
endfunction


function! s:buffer_dictionary_to_string(dict_in) abort
  " dict in is an array of dictionaries that has the values of the menu items

  " menu order is an array of dictionaries
  " menu entries will follow the order of menu order
  " the labels of each field of the menu entry will be the values of each dictionary in the array
  let menu_order = slime#config#resolve('neovim_menu_order')

  let delimiter = slime#config#resolve('neovim_menu_delimiter')

  let menu_string = ''

  for i in range(len(menu_order))
    let menu_item = menu_order[i]
    let key = keys(menu_item)[0]
    let label = get(menu_item, key, "")
    let value = get(a:dict_in, key, "")
    if i != len(menu_order) - 1
      let menu_string = menu_string . label . value . delimiter
    else
      let menu_string = menu_string . label . value
    endif
  endfor

  return menu_string
endfunction


"get full bufinfo only of terminal buffers
function! s:get_terminal_bufinfo() abort
  if !exists("g:slime_last_channel") || len(g:slime_last_channel) == 0 || empty(g:slime_last_channel)
    "there are no valid terminal buffers
    return []
  endif

  let buf_info = getbufinfo()
  return map(copy(g:slime_last_channel), { _, val -> s:extend_term_buffer_titles(val, buf_info)})
endfunction


function! s:config_with_menu() abort
  " get info of running terminals, array of dictionaries
  " reversing to make it appear in the right order in the menu
  let term_bufinfo =  s:get_terminal_bufinfo()

  " turn each item into a string for the menu
  let menu_strings =  map(copy(term_bufinfo), {_, val -> s:buffer_dictionary_to_string(val)})

  for i in range(1, len(menu_strings))
    let menu_strings[i - 1] = i . '. ' . menu_strings[i - 1]
  endfor
  call insert(menu_strings, "Select a terminal:")

  let selection = str2nr(inputlist(menu_strings))

  if selection <= 0 || selection >= len(menu_strings)
    return {}
  endif

  let used_config = term_bufinfo[selection - 1]

  return {"jobid": used_config["jobid"], "pid": used_config["pid"] }
endfunction


"really make sure the config is cleared from the current buffer, and from all buffers with the same config
function! s:sure_clear_buf_config()
  if exists('b:slime_config')  && type(b:slime_config) == v:t_dict && !empty(b:slime_config) && has_key(b:slime_config, 'jobid') && type(b:slime_config['jobid']) == v:t_number
    call s:clear_related_bufs(b:slime_config['jobid'])
  endif
endfunction



function! slime#targets#neovim#EchoWarningMsg(msg)
  echohl WarningMsg
  echo a:msg
  echohl None
endfunction
