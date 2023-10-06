
function! slime#targets#zellij#config() abort
  if !exists("b:slime_config")
    let b:slime_config = {"session_id": "current", "relative_pane": "current"}
  end
  let b:slime_config["session_id"] = input("zellij session: ", b:slime_config["session_id"])
  let b:slime_config["relative_pane"] = input("target pane relative position: ", b:slime_config["relative_pane"])
  if b:slime_config["relative_pane"] == "current"
    let b:slime_config["relative_move_back"] = "current"
  elseif b:slime_config["relative_pane"] == "right"
    let b:slime_config["relative_move_back"] = "left"
  elseif b:slime_config["relative_pane"] == "left"
    let b:slime_config["relative_move_back"] = "right"
  elseif b:slime_config["relative_pane"] == "up"
    let b:slime_config["relative_move_back"] = "down"
  elseif b:slime_config["relative_pane"] == "down"
    let b:slime_config["relative_move_back"] = "up"
  else
    echoerr "Error: Allowed values are (current, right, left, up, down)"
  endif
endfunction

function! slime#targets#zellij#send(config, text)
  let target_session = ""
  if a:config["session_id"] != "current"
    let target_session = "-s " . shellescape(a:config["session_id"])
  end
  if a:config["relative_pane"] != "current"
    call system("zellij " . target_session . " action move-focus " . shellescape(a:config["relative_pane"]))
  end
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
    call system("zellij " . target_session . " action write 27 91 50 48 48 126")
    call system("zellij " . target_session . " action write-chars " . shellescape(text_to_paste))
    call system("zellij " . target_session . " action write 27 91 50 48 49 126")
    if has_crlf
      call system("zellij " . target_session . " action write 10")
    endif
  else
    call system("zellij " . target_session . " action write-chars " . shellescape(text_to_paste))
  endif

  if a:config["relative_pane"] != "current"
    call system("zellij " . target_session . " action move-focus " . shellescape(a:config["relative_move_back"]))
  end
endfunction

