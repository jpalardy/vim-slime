
function! slime#targets#tmux#config() abort
  if !exists("b:slime_config")
    let b:slime_config = {"socket_name": "default", "target_pane": ""}
  endif
  let b:slime_config["socket_name"] = input("tmux socket name or absolute path: ", b:slime_config["socket_name"])

  if slime#config#resolve("menu_config")
    let panes_list = split(slime#targets#tmux#pane_names("","",""), "\n")
    call insert(panes_list, ":")
    let menu_strings = copy(panes_list)
    for i in range(0, len(menu_strings) - 1)
      let menu_strings[i] = i . '. ' . menu_strings[i]
    endfor
    call insert(menu_strings, "Select a target tmux pane:")
    let selection = str2nr(inputlist(menu_strings))
    if selection < 0 || selection >= len(menu_strings)
      echohl WarningMsg
      echo "Selection out of bounds. Setting pane to \":\"."
      echohl None
      let b:slime_config["target_pane"] = ":"
      return
    endif
    let b:slime_config["target_pane"] = panes_list[selection]
  else
    let b:slime_config["target_pane"] = input("tmux target pane: ", b:slime_config["target_pane"], "custom,slime#targets#tmux#pane_names")
  endif

  " processing pane string
  if b:slime_config["target_pane"] =~ '\s\+'
    let b:slime_config["target_pane"] = split(b:slime_config["target_pane"])[0]
  endif
endfunction

function! slime#targets#tmux#send(config, text)
  let target_cmd = s:target_cmd(a:config["socket_name"])
  let [bracketed_paste, text_to_paste, has_crlf] = slime#common#bracketed_paste(a:text)

  " only need to do this once
  call slime#common#system(target_cmd . " send-keys -X -t %s cancel", [a:config["target_pane"]])

  " reasonable hardcode, will become config if needed
  let chunk_size = 1000

  for i in range(0, len(text_to_paste) / chunk_size)
    let chunk = text_to_paste[i * chunk_size : (i + 1) * chunk_size - 1]
    call slime#common#system(target_cmd . " load-buffer -", [], chunk)
    if bracketed_paste
      call slime#common#system(target_cmd . " paste-buffer -d -p -t %s", [a:config["target_pane"]])
    else
      call slime#common#system(target_cmd . " paste-buffer -d -t %s", [a:config["target_pane"]])
    endif
  endfor

  " trailing newline
  if has_crlf
    call slime#common#system(target_cmd . " send-keys -t %s Enter", [a:config["target_pane"]])
  endif
endfunction

" -------------------------------------------------

function! slime#targets#tmux#pane_names(A,L,P)
  let target_cmd = s:target_cmd(b:slime_config["socket_name"])
  let format = '#{pane_id} #{session_name}:#{window_index}.#{pane_index} #{window_name}#{?window_active, (active),}'
  return slime#common#system(target_cmd . " list-panes -a -F %s", [format])
endfunction

function! s:target_cmd(socket_name)
  " socket with absolute path: use tmux -S
  if a:socket_name =~ "^/"
    return "tmux -S " . shellescape(a:socket_name)
  endif
  " socket with relative path: use tmux -L
  return "tmux -L " . shellescape(a:socket_name)
endfunction
