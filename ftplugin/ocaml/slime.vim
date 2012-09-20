function! _EscapeText_ocaml(text)
    " We only append ';;' to text if text 
    if match(text,';;\s*$') > -1
        return [a:text]
    else 
        return [a:text,";;\n"]
    endif
endfunction
