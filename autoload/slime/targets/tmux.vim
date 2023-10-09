
function! slime#targets#tmux#config() abort
  if !exists("b:slime_config")
    let b:slime_config = {"socket_name": "default", "target_pane": ""}
  end
  let b:slime_config["socket_name"] = input("tmux socket name or absolute path: ", b:slime_config["socket_name"])
  let b:slime_config["target_pane"] = input("tmux target pane: ", b:slime_config["target_pane"], "custom,slime#targets#tmux#pane_names")
  if b:slime_config["target_pane"] =~ '\s\+'
    let b:slime_config["target_pane"] = split(b:slime_config["target_pane"])[0]
  endif
endfunction

function! slime#targets#tmux#send(config, text)
  let bracketed_paste = slime#config#resolve("bracketed_paste")

  let [text_to_paste, has_crlf] = [a:text, 0]
  if bracketed_paste
    if a:text[-2:] == "\r\n"
      let [text_to_paste, has_crlf] = [a:text[:-3], 1]
    elseif a:text[-1:] == "\r" || a:text[-1:] == "\n"
      let [text_to_paste, has_crlf] = [a:text[:-2], 1]
    endif
  endif

  " reasonable hardcode, will become config if needed
  let chunk_size = 1000

  for i in range(0, len(text_to_paste) / chunk_size)
    let chunk = text_to_paste[i * chunk_size : (i + 1) * chunk_size - 1]
    call slime#common#write_paste_file(chunk)
    call s:TmuxCommand(a:config, "load-buffer %s", slime#config#resolve("paste_file"))
    call s:TmuxCommand(a:config, "send-keys -X -t %s cancel", a:config["target_pane"])
    if bracketed_paste
      call s:TmuxCommand(a:config, "paste-buffer -d -p -t %s", a:config["target_pane"])
    else
      call s:TmuxCommand(a:config, "paste-buffer -d -t %s", a:config["target_pane"])
    end
  endfor

  " trailing newline
  if has_crlf
    call s:TmuxCommand(a:config, "send-keys -t %s Enter", a:config["target_pane"])
  end
endfunction

" -------------------------------------------------

function! slime#targets#tmux#pane_names(A,L,P)
  let format = '#{pane_id} #{session_name}:#{window_index}.#{pane_index} #{window_name}#{?window_active, (active),}'
  return s:TmuxCommand(b:slime_config, "list-panes -a -F %s", format)
endfunction

function! s:TmuxCommand(config, cmd_template, ...)
  " socket with absolute path: use tmux -S
  " socket with relative path: use tmux -L
  if a:config["socket_name"] =~ "^/"
    let tmux_cmd = "tmux -S %s " . a:cmd_template
  else
    let tmux_cmd = "tmux -L %s " . a:cmd_template
  endif
  return slime#common#system(tmux_cmd, [a:config["socket_name"]] + a:000)
endfunction

