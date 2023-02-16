if exists('g:loaded_slime') || &cp || v:version < 700
  finish
endif
let g:loaded_slime = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Setup key bindings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

command -bar -nargs=0 ExamplePlug colorscheme blue
noremap <unique> <script> <silent> <Plug>(ChangeColor) :<c-u>ExamplePlug<cr>

command -bar -nargs=0 ExamplePlug2 colorscheme peachpuff
noremap <unique> <script> <silent> <Plug>(ChangeColor2) :<c-u>ExamplePlug2<cr>

nmap <leader>pp <Plug>(ChangeColor2)<Plug>(ChangeColor)

command -bar -nargs=0 SlimeConfig call slime#config()
command -range -bar -nargs=0 SlimeSend call slime#send_range(<line1>, <line2>)
command -nargs=+ SlimeSend1 call slime#send(<q-args> . "\r")
command -nargs=+ SlimeSend0 call slime#send(<args>)
command! SlimeSendCurrentLine call slime#send(getline(".") . "\r")

noremap <SID>Operator :<c-u>call slime#store_curpos()<cr>:set opfunc=slime#send_op<cr>g@

noremap <unique> <script> <silent> <Plug>SlimeRegionSend :<c-u>call slime#send_op(visualmode(), 1)<cr>
noremap <unique> <script> <silent> <Plug>SlimeLineSend :<c-u>call slime#send_lines(v:count1)<cr>
noremap <unique> <script> <silent> <Plug>SlimeMotionSend <SID>Operator
noremap <unique> <script> <silent> <Plug>SlimeParagraphSend <SID>Operatorip
noremap <unique> <script> <silent> <Plug>SlimeConfig :<c-u>SlimeConfig<cr>
noremap <unique> <script> <silent> <Plug>SlimeSendCell :<c-u>call slime#send_cell()<cr>

if !exists("g:slime_no_mappings") || !g:slime_no_mappings
  if !hasmapto('<Plug>SlimeRegionSend', 'x')
    xmap <c-c><c-c> <Plug>SlimeRegionSend
  endif

  if !hasmapto('<Plug>SlimeParagraphSend', 'n')
    nmap <c-c><c-c> <Plug>SlimeParagraphSend
  endif

  if !hasmapto('<Plug>SlimeConfig', 'n')
    nmap <c-c>v <Plug>SlimeConfig
  endif
endif

if has('nvim') && get(g:, "slime_target", "") == "neovim"

	function Change_bg()
		if g:colors_name ==? "gruvbox"
			colorscheme tokyonight
		elseif g:colors_name ==? "tokyonight"
			colorscheme gruvbox
		endif
	endfunction

	function SlimeAddChannel()
		if !exists("g:slime_last_channel")
			let g:slime_last_channel = [&channel]
			echo g:slime_last_channel
		else
			call add(g:slime_last_channel, &channel)
			echo g:slime_last_channel
		endif
		"call Change_bg()
	endfunction

	" values in is a list, dict in is a dictionary
	function HasTerminal(idx, val)
		let vars = a:val['variables']
		return has_key(vars, "terminal_job_id")
	endfunction

	let FilterFun = funcref("HasTerminal")

		"for k in vec_range "filtering down to just the info we wqant
		"	call filter(a[k], 'v:key ==? "bufnr"|| v:key ==? "lnum" || v:key ==? "loaded" || v:key ==? "hidden" || v:key ==? "name" || v:key ==? "variables"' )
		"	call filter(a[k]['variables'], 'v:key ==? "changedtick" || v:key ==? "terminal_job_pid" || v:key ==? "terminal_job_id" || v:key ==? "term_title"')
		"endfor
	function ClearExistingChannel(func_ref_in)
		let a = getbufinfo()
		let vec_range = range(len(a))

		call filter(a, a:func_ref_in)

		"call Change_bg()


	endfunction
	
	function SlimeClearChannel(func_ref_in)
		if !exists("g:slime_last_channel")
		elseif len(g:slime_last_channel) == 0
			unlet g:slime_last_channel
		else
			call ClearExistingChannel(a:func_ref_in)
		endif
	endfunction
	
	if get(g:, "slime_target", "") == "neovim"
		augroup nvim_slime
			autocmd!
	 	 	autocmd TermOpen * call SlimeAddChannel()
	 	 	autocmd TermClose * call SlimeClearChannel(FilterFun)
	 	augroup END
	endif
endif


nmap gz <Plug>SlimeMotionSend
nmap gzz <Plug>SlimeLineSend
xmap gz <Plug>SlimeRegionSend
