
function! slime#targets#neovim#config() abort

  if exists("g:slime_menu_config") && g:slime_menu_config
    call s:config_with_menu()
  else
    " unlet current config if its jobid doesn't exist
    let last_channels = get(g:, 'slime_last_channel', [])
    let most_recent_channel = get(last_channels, -1, {})

    let last_pid = get(most_recent_channel, 'pid', '')
    let last_job = get(most_recent_channel, 'jobid', '')

    let b:slime_config =  {"jobid":  last_job, "pid": last_pid }

    " include option to input pid
    if exists("g:slime_input_pid") && g:slime_input_pid

      let default_pid = jobpid(b:slime_config["jobid"])
      "if everything does right this validation should be redundant
      "validation of the environment with ValidEnv should prevent the empty string
      if !empty(default_pid)
        let default_pid = str2nr(default_pid)
      endif
      let pid_in = input("Configuring vim-slime. Input pid: ", default_pid , 'customlist,Last_channel_to_pid')

      let jobid_in = str2nr(s:translate_pid_to_id(pid_in))
    else
      if exists("g:slime_get_jobid")
        let jobid_in = g:slime_get_jobid()
      else
        let default_jobid = b:slime_config["jobid"]
        if !empty(default_jobid)
          let default_jobid = str2nr(default_jobid)
        endif
        let jobid_in = input("Configuring vim-slime. Input jobid: ", default_jobid, 'customlist,Last_channel_to_jobid')
        let jobid_in = str2nr(jobid_in)
      endif
      let pid_in = s:translate_id_to_pid(jobid_in)
    endif

    let b:slime_config["jobid"] = jobid_in
    let b:slime_config["pid"] = pid_in
  endif
endfunction

function! slime#targets#neovim#send(config, text)
  " Neovim jobsend is fully asynchronous, it causes some problems with
  " iPython %cpaste (input buffering: not all lines sent over)
  " So this `write_paste_file` can help as a small lock & delay
  call slime#common#write_paste_file(a:text)
  call chansend(str2nr(a:config["jobid"]), split(a:text, "\n", 1))
endfunction

function! slime#targets#neovim#SlimeAddChannel(buf_in)
  let buf_in = str2nr(a:buf_in)
  let jobid = getbufvar(buf_in, "&channel")
  let jobpid = jobpid(jobid)

  if !exists("g:slime_last_channel")
    let g:slime_last_channel = [{'jobid': jobid, 'pid': jobpid}]
  else
    call add(g:slime_last_channel, {'jobid': jobid, 'pid': jobpid})
  endif
endfunction

function! slime#targets#neovim#SlimeClearChannel(buf_in)

  let bufinfo = getbufinfo()

  if !exists("g:slime_last_channel")
    echom "slime last channel not found"
    call s:clear_all_buffs()
    return
  elseif len(g:slime_last_channel) <= 1
    echom "len slime last chanel is one or less"
    call s:clear_all_buffs()
    let g:slime_last_channel = []
  else
    echom "len slime last greater than one"
    let buf_in = str2nr(a:buf_in)
    "filtering for the buffer info with the terminal job
    let target_buffer =  filter(copy(bufinfo), {_, val -> val['bufnr'] == buf_in})

    if len(target_buffer) == 1
      " getbufinfo was able to detect the terminal buffer
      let jobid = getbufvar(buf_in, "&channel")
      if jobid == ""
        " the buffer somehow go wiped out
        let jobid = s:job_id_when_buffer_cleared()
      endif
    else
      let jobid = s:job_id_when_buffer_cleared()
    endif
    call s:clear_related_bufs(jobid)
    call filter(g:slime_last_channel, {_, val -> str2nr(val['jobid']) != jobid})
  endif
endfunction

function! s:job_id_when_buffer_cleared()
  let listed_term_jobs = s:get_terminal_jobids()
  let last_term_jobs =  map(copy(g:slime_last_channel),{_, val -> val['jobid']})
  call filter(last_term_jobs, {_, val -> index(listed_term_jobs, val) == -1})
  let jobid = last_term_jobs[0]
  return jobid
endfunction


"evaluates whether ther is a terminal running; if there isn't then no config can be valid
function! slime#targets#neovim#ValidEnv() abort
  if s:NotExistsLastChannel()
    echon "Terminal not found."
    return 0
  endif
  return 1
endfunction

" "checks that a configuration is valid
" returns boolean of whether the supplied config is valid
function! slime#targets#neovim#ValidConfig(config) abort
  if !exists(a:config)
    echo "\nNo config found."
    return 0
  else
    let config_in = eval(a:config)

    if s:NotExistsLastChannel()
      echo "Terminal not found."
      return 0
    endif

    if !exists("config_in") ||  config_in is v:null
      echo "Config does not exist."
      return 0
    endif

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

    if !(index( s:last_channel_to_jobid_array(g:slime_last_channel), config_in['jobid']) >= 0)
      echo "Job ID not found."
      return 0
    endif

    if !(index(s:get_terminal_jobids(), config_in['jobid']) >= 0)
      echo "Job ID not found."
      return 0
    endif

    if empty(jobpid(config_in['jobid']))
      echo "Job ID not linked to a PID."
      return 0
    endif

  endif

  return 1
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
  endtry
  return pid_out
endfunction


" Checks if a previous channel does not exist or is empty.
function! s:NotExistsLastChannel() abort
  return (!exists("g:slime_last_channel") || (len(g:slime_last_channel)) < 1)
endfunction

function! s:get_terminal_jobids()
  "transforming it so calling it by its final form
  let job_ids = getbufinfo()
  call filter(job_ids, {_, val -> get(val, "listed", 0)})
  call map(job_ids, {_, val -> val['bufnr']})
  call map(job_ids, {_, val -> getbufvar(val, '&channel')})
  call filter(job_ids, {_, val -> val > 0})
  return job_ids
endfunction

function! s:get_terminal_bufinfo()
  "get full bufinfo only of terminal buffers
  let buf_info = getbufinfo()
  call filter(buf_info, {_, val -> get(val, "listed", 0)})
  let buf_nrs =  map(copy( buf_info ), {_, val -> val['bufnr']})
  let job_ids =  map(copy(buf_nrs), {_, val -> getbufvar(val, '&channel')})
  for i in range(len(job_ids) - 1)
    if job_ids[i] == 0
      let buf_info[i] = 0
    endif
  endfor

  call filter(buf_info, {_, val -> type(val) == v:t_dict})
  return buf_info
endfunction


" Transforms a channel dictionary with job id and pid into an newline separated string  of job IDs.
" for the purposes of input completion
function! Last_channel_to_jobid(ArgLead, CmdLine, CursorPos)
  let jobids = s:last_channel_to_jobid_array(g:slime_last_channel)
  call map(jobids, {_, val -> string(val)})
  return jobids
endfunction

" Transforms a channel dictionary with job ida and pid into an newline separated string  of job PIDs.
" for the purposes of input completion
function! Last_channel_to_pid(ArgLead, CmdLine, CursorPos)
  "they will be transformed into pids so naming them by their final identity
  let jobpids = map(copy(g:slime_last_channel), {_, val -> val["jobid"]})
  call map(jobpids, {_, val -> s:translate_id_to_pid(val)})
  call filter(jobpids, {_,val -> val != -1})
  call map(jobpids, {_, val -> string(val)})
  return jobpids
endfunction



function! s:last_channel_to_jobid_array(channel_dict)
  return map(copy(a:channel_dict), {_, val -> val["jobid"]})
endfunction


" clears all buffers with a certain invalid configuration
function! s:clear_related_bufs(id_in)
  let related_bufs = filter(getbufinfo(), {_, val -> has_key(val['variables'], "slime_config")
        \ && get(val['variables']['slime_config'], 'jobid', -2) == a:id_in})

  for buf in related_bufs
    call setbufvar(buf['bufnr'], 'slime_config', {})
  endfor
endfunction

" clears all buffers with a certain invalid configuration
function! s:clear_all_buffs()
  let target_bufs = filter(getbufinfo(), {_, val -> has_key(val['variables'], "slime_config") })

  for buf in target_bufs
    call setbufvar(buf['bufnr'], 'slime_config', {})
  endfor
endfunction

function! s:extract_buffer_details(buffer)
  let bufnr = get(a:buffer, 'bufnr', -3)
  let details = {}
  let details['name'] = get(a:buffer, 'name', 'N/A')
  let vars = get(a:buffer, 'variables', {})
  let details['term_title'] = get(vars, 'term_title', 'N/A')

  if bufnr != -3
    let details['jobid'] = getbufvar(bufnr, '&channel', 0)
  endif
  return details
endfunction


function! s:buffer_dictionary_to_string(dict_in)
  if exists('g:slime_neovim_menu_order')
    let menu_order = g:slime_neovim_menu_order
  else
    let menu_order = [{'pid': 'pid: '},{'jobid':'jobid: '},{'term_title':''},{'name':''}]
  endif

  if exists('g:slime_neovim_menu_delimiter')
    let delimiter = g:slime_neovim_menu_delimiter
  else
    let delimiter = ', '
  endif

  let menu_string = ''

  for i in range(len(menu_order))
    let menu_item = menu_order[i]
    let key = keys(menu_order[i])[0]
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

function! s:config_with_menu()
  let bufinfo = s:get_terminal_bufinfo()
  call map(bufinfo, { _, val -> s:extract_buffer_details(val)})
  let valid_job_ids = s:last_channel_to_jobid_array(g:slime_last_channel)
  call filter(bufinfo, {_, val -> index( valid_job_ids, val['jobid']) >= 0})
  call map(bufinfo, {_, val -> extend(val, {'pid': s:translate_id_to_pid(val['jobid'])})})
  call filter(bufinfo, {_, val ->  val['pid'] != -1})
  let valid_configs =  map(copy(bufinfo), {_, val ->  {'jobid': val['jobid'], 'pid': val['pid']}})
  call map(bufinfo, {_, val -> s:buffer_dictionary_to_string(val)})
  for i in range(1, len(bufinfo))
    let bufinfo[i - 1] = i . '. ' . bufinfo[i - 1]
  endfor
  call insert(bufinfo, "Select a terminal:")
  let selection = str2nr(inputlist(bufinfo))

  if selection <= 0 || selection >= len(bufinfo)
    return
  endif

  let b:slime_config = valid_configs[selection - 1]
endfunction





