
function! slime#targets#conemu#config() abort
  " set destination for send commands, as specified in http://conemu.github.io/en/GuiMacro.html#Command_line
  if !exists("b:slime_config")
    " defaults to the active tab/split of the first found ConEmu window
    let b:slime_config = {"HWND": "0"}
  end
  let b:slime_config["HWND"] = input("Console server HWND: ", b:slime_config["HWND"])
endfunction

function! slime#targets#conemu#send(config, text)
  " use the selection register to send text to ConEmu using the windows clipboard (see help gui-clipboard)
  " save the current selection to restore it after send
  let tmp = @*
  let @* = a:text
  call slime#common#system("conemuc -guimacro:%s print", [a:config["HWND"]])
  let @* = tmp
endfunction

