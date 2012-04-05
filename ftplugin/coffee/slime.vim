

function! _PreTmux_coffee(socket_name, target_pane)
  call system("tmux -L " . a:socket_name . " send-keys C-v -t " . a:target_pane)
endfunction

function! _PostTmux_coffee(socket_name, target_pane)
  call system("tmux -L " . a:socket_name . " send-keys C-d -t " . a:target_pane)
endfunction

