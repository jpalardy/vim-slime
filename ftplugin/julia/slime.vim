function! _EscapeText_julia(text)
	if len(split(a:text,"\n")) > 1
		return ["begin\n", a:text, "end\n"]
	else
		return a:text
	endif
endfunction

