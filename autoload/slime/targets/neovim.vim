
function! slime#targets#neovim#config() abort

  if exists("g:slime_menu_config") && g:slime_menu_config
    call s:config_with_menu()
    return
  endif

  if exists("g:slime_suggest_default") && g:slime_suggest_default
    let slime_suggest_default = 1
  else
    let slime_suggest_default = 0
  endif

  " unlet current config if its jobid doesn't exist
  let last_channels = get(g:, 'slime_last_channel', [])
  let most_recent_channel = get(last_channels, -1, {})

  let last_pid = get(most_recent_channel, 'pid', '')
  let last_job = get(most_recent_channel, 'jobid', '')

  let b:slime_config =  {"jobid":  last_job, "pid": last_pid }

  " include option to input pid
  if exists("g:slime_input_pid") && g:slime_input_pid
    let default_pid = slime_suggest_default ? s:translate_id_to_pid(b:slime_config["jobid"]) : ""
    if default_pid == -1
      let default_pid = ""
    endif
    let pid_in = input("Configuring vim-slime. Input pid: ", default_pid , 'customlist,Last_channel_to_pid')
    let jobid_in = str2nr(s:translate_pid_to_id(pid_in))
    let b:slime_config["jobid"] = jobid_in
    let b:slime_config["pid"] = pid_in
    return
  endif


  if exists("g:slime_get_jobid")
    let jobid_in = g:slime_get_jobid()
    let pid_in = s:translate_id_to_pid(jobid_in)
    let b:slime_config["jobid"] = jobid_in
    let b:slime_config["pid"] = pid_in
    return
  endif

  "inputing jobid
  let default_jobid = slime_suggest_default ? b:slime_config["jobid"] : ""
  if !empty(default_jobid)
    let default_jobid = str2nr(default_jobid)
  endif
  let jobid_in = input("Configuring vim-slime. Input jobid: ", default_jobid, 'customlist,Last_channel_to_jobid')
  let jobid_in = str2nr(jobid_in)
  let pid_in = s:translate_id_to_pid(jobid_in)

  let b:slime_config["jobid"] = jobid_in
  let b:slime_config["pid"] = pid_in
endfunction

function! slime#targets#neovim#send(config, text) abort
  " Neovim jobsend is fully asynchronous, it causes some problems with
  " iPython %cpaste (input buffering: not all lines sent over)
  " So this `write_paste_file` can help as a small lock & delay
  call slime#common#write_paste_file(a:text)
  call chansend(str2nr(a:config["jobid"]), split(a:text, "\n", 1))
endfunction

function! slime#targets#neovim#SlimeAddChannel(buf_in) abort
  let buf_in = str2nr(a:buf_in)
  let jobid = getbufvar(buf_in, "&channel")
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
  elseif len(g:slime_last_channel) <= 1
    call s:clear_all_buffs()
    unlet g:slime_last_channel
  else
    let jobid_to_clear = filter(copy(g:slime_last_channel), {_, val -> val['bufnr'] == a:buf_in})[0]['jobid']
    call s:clear_related_bufs(jobid_to_clear)
    call filter(g:slime_last_channel, {_, val -> val['bufnr'] != a:buf_in})
  endif
endfunction

"evaluates whether ther is a terminal running; if there isn't then no config can be valid
function! slime#targets#neovim#ValidEnv() abort
  if (!exists("g:slime_last_channel") || (len(g:slime_last_channel)) < 1) || empty(g:slime_last_channel)
    echo "Terminal not found."
    return 0
  endif
  return 1
endfunction

" "checks that a configuration is valid
" returns boolean of whether the supplied config is valid
function! slime#targets#neovim#ValidConfig(config) abort
  "config is passed as a string, the name of the config variable

  if !slime#targets#neovim#ValidEnv()
    return 0
  endif

  if !exists(a:config)
    echo "No config found."
    return 0
  else

    let config_in = eval(a:config)

    " Ensure the config is a dictionary and a previous channel exists
    if type(config_in) != v:t_dict
      echo "Config type not valid."
      return 0
    endif

    if empty(config_in)
      echo "Config is empty."
      return 0
    endif

    " Ensure the correct keys exist within the configuration
    if !(has_key(config_in, 'jobid'))
      echo "Configration object lacks 'jobid'."
      return 0
    endif

    if config_in["jobid"] == -1  "the id wasn't found translate_pid_to_id
      echo "No matching job id for the provided pid."
      return 0
    endif

    if !(index(
          \map(copy(g:slime_last_channel), {_, val -> val["jobid"]}),
          \config_in['jobid']) >= 0
          \)
      echo "Invalid Job ID."
      return 0
    endif

    if s:translate_id_to_pid(config_in['jobid']) == -1
      echo "Job ID not linked to a PID."
      return 0
    endif

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

" Transforms a channel dictionary with job id and pid into an newline separated string  of job IDs.
" for the purposes of input completion
function! Last_channel_to_jobid(ArgLead, CmdLine, CursorPos) abort
  let jobids = map(copy(g:slime_last_channel), {_, val -> val["jobid"]})
  call map(jobids, {_, val -> string(val)})
  return reverse(jobids) " making correct order in menu
endfunction

" Transforms a channel dictionary with job ida and pid into an newline separated string  of job PIDs.
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

" clears all buffers with a certain invalid configuration
function! s:clear_all_buffs() abort
  let target_bufs = filter(getbufinfo(), {_, val -> has_key(val['variables'], "slime_config") })

  for buf in target_bufs
    call setbufvar(buf['bufnr'], 'slime_config', {})
  endfor
endfunction

function! s:extend_term_buffer_titles(specific_term_info, all_bufinfo) abort
  " add buffer name and terminal title to a dictionary that already has jobid, pid, buffer number
  "specific term info is a dictionary that contains jobid, pid, and bufnr
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

  "menu order is an array of dictionaries
  "menu entries will follow the order of menu order
  " the labels of each field of the menu entry will be the values of each dictionary in the array
  if exists('g:slime_neovim_menu_order')
    let menu_order = g:slime_neovim_menu_order
  else
    let menu_order = [{'pid': 'pid: '}, {'jobid': 'jobid: '}, {'term_title':''}, {'name': ''}]
  endif

  if exists('g:slime_neovim_menu_delimiter')
    let delimiter = g:slime_neovim_menu_delimiter
  else
    let delimiter = ', '
  endif

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
    return
  endif

  let used_config = term_bufinfo[selection - 1]

  let b:slime_config = {"jobid": used_config["jobid"], "pid": used_config["pid"] }
endfunction
