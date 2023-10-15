
function! slime#targets#kitty#config() abort
  if !exists("b:slime_config")
    let b:slime_config = {"window_id": 1, "listen_on": ""}
  end
  let b:slime_config["window_id"] = str2nr(slime#common#system("kitty @ select-window --self", []))
  if v:shell_error || b:slime_config["window_id"] == $KITTY_WINDOW_ID
    let b:slime_config["window_id"] = input("kitty window_id: ", b:slime_config["window_id"])
  endif
  let b:slime_config["listen_on"] = input("kitty listen on: ", b:slime_config["listen_on"])
endfunction

function! slime#targets#kitty#send(config, text)
  let [bracketed_paste, text_to_paste, has_crlf] = slime#common#bracketed_paste(a:text)

  if bracketed_paste
    let text_to_paste = "\e[200~" . text_to_paste . "\e[201~"
  endif

  let target_cmd = s:target_cmd(a:config["listen_on"])
  call slime#common#system(target_cmd . " send-text --match id:%s --stdin", [a:config["window_id"]], text_to_paste)

  " trailing newline
  if has_crlf
    call slime#common#system(target_cmd . " send-text --match id:%s --stdin", [a:config["window_id"]], "\n")
  endif
endfunction

" -------------------------------------------------

function! s:target_cmd(listen_on)
  if a:listen_on != ""
    return "kitty @ --to " . shellescape(a:listen_on)
  end
  return "kitty @"
endfunction

