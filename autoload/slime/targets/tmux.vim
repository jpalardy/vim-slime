
function! s:TmuxCommand(config, args)
  let l:socket = a:config["socket_name"]
  " For an absolute path to the socket, use tmux -S.
  " For a relative path to the socket in tmux's temporary directory, use tmux -L.
  " Case sensitivity does not matter here, but let's follow good practice.
  " TODO: Make this cross-platform. Windows supports tmux as of mid-2016.
  let l:socket_option = l:socket[0] ==? "/" ? "-S" : "-L"
  return system("tmux " . l:socket_option . " " . shellescape(l:socket) . " " . a:args)
endfunction

function! s:TmuxSend(config, text)
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
    call s:WritePasteFile(chunk)
    call s:TmuxCommand(a:config, "load-buffer " . slime#config#resolve("paste_file"))
    call s:TmuxCommand(a:config, "send-keys -X -t " . shellescape(a:config["target_pane"]) . " cancel")
    if bracketed_paste
      call s:TmuxCommand(a:config, "paste-buffer -d -p -t " . shellescape(a:config["target_pane"]))
    else
      call s:TmuxCommand(a:config, "paste-buffer -d -t " . shellescape(a:config["target_pane"]))
    end
  endfor

  " trailing newline
  if has_crlf
    call s:TmuxCommand(a:config, "send-keys -t " . shellescape(a:config["target_pane"]) . " Enter")
  end
endfunction

function! s:TmuxPaneNames(A,L,P)
  let format = '#{pane_id} #{session_name}:#{window_index}.#{pane_index} #{window_name}#{?window_active, (active),}'
  return s:TmuxCommand(b:slime_config, "list-panes -a -F " . shellescape(format))
endfunction

function! s:TmuxConfig() abort
  if !exists("b:slime_config")
    let b:slime_config = {"socket_name": "default", "target_pane": ":"}
  end
  let b:slime_config["socket_name"] = input("tmux socket name or absolute path: ", b:slime_config["socket_name"])
  let b:slime_config["target_pane"] = input("tmux target pane: ", b:slime_config["target_pane"], "custom,<SNR>" . s:SID() . "_TmuxPaneNames")
  if b:slime_config["target_pane"] =~ '\s\+'
    let b:slime_config["target_pane"] = split(b:slime_config["target_pane"])[0]
  endif
endfunction

