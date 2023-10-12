
function! slime#targets#wezterm#config() abort
  if !exists("b:slime_config")
    let b:slime_config = {"pane_id": 1}
  elseif exists("b:slime_config.pane_direction")
    let pane_id = slime#common#system("wezterm cli get-pane-direction %s", [b:slime_config["pane_direction"]])
    let b:slime_config = {"pane_id": pane_id}
  endif
  let b:slime_config["pane_id"] = input("wezterm pane_id: ", b:slime_config["pane_id"])
endfunction

function! slime#targets#wezterm#send(config, text)
  let bracketed_paste = slime#config#resolve("bracketed_paste")

  let [text_to_paste, has_crlf] = [a:text, 0]
  if bracketed_paste
    if a:text[-2:] == "\r\n"
      let [text_to_paste, has_crlf] = [a:text[:-3], 1]
    elseif a:text[-1:] == "\r" || a:text[-1:] == "\n"
      let [text_to_paste, has_crlf] = [a:text[:-2], 1]
    endif
  endif

  if bracketed_paste
    call slime#common#system("wezterm cli send-text --pane-id=%s", [a:config["pane_id"]], text_to_paste)
  else
    call slime#common#system("wezterm cli send-text --no-paste --pane-id=%s", [a:config["pane_id"]], text_to_paste)
  endif

  " trailing newline
  if has_crlf
    call slime#common#system("wezterm cli send-text --no-paste --pane-id=%s", [a:config["pane_id"]], "\n")
  end
endfunction

