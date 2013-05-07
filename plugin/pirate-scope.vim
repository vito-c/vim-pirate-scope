"--------------------------------------------------------------------------------
" Information {
"--------------------------------------------------------------------------------
" vim: set sw=4 ts=4 sts=4 et tw=78 foldmarker={,} foldmethod=marker :
" 
" By: Vito C.
"                       .ed'''' '''$$$$be.                     
"                     -'           ^''**$$$e.                  
"                   .'                   '$$$c                 
"                  /                      '4$$b                
"                 d  3                     $$$$                
"                 $  *                   .$$$$$$               
"                .$  ^c           $$$$$e$$$$$$$$.              
"                d$L  4.         4$$$$$$$$$$$$$$b              
"                $$$$b ^ceeeee.  4$$ECL.F*$$$$$$$              
"    e$''=.      $$$$P d$$$$F $ $$$$$$$$$- $$$$$$              
"   z$$b. ^c     3$$$F '$$$$b   $'$$$$$$$  $$$$*'      .=''$c  
"  4$$$$L   \     $$P'  '$$b   .$ $$$$$...e$$        .=  e$$$. 
"  ^*$$$$$c  %..   *c    ..    $$ 3$$$$$$$$$$eF     zP  d$$$$$ 
"    '**$$$ec   '\   %ce''    $$$  $$$$$$$$$$*    .r' =$$$$P'' 
"          '*$b.  'c  *$e.    *** d$$$$$'L$$    .d'  e$$***'   
"            ^*$$c ^$c $$$      4J$$$$$% $$$ .e*'.eeP'         
"               '$$$$$$''$=e....$*$$**$cz$$' '..d$*'           
"                 '*$$$  *=%4.$ L L$ P3$$$F $$$P'              
"                    '$   '%*ebJLzb$e$$$$$b $P'                
"                      %..      4$$$$$$$$$$ '                  
"                       $$$e   z$$$$$$$$$$%                    
"                        '*$c  '$$$$$$$P'                      
"                         .'''*$$$$$$$$bc                      
"                      .-'    .$***$$$'''*e.                   
"                   .-'    .e$'     '*$c  ^*b.                 
"            .=*''''    .e$*'          '*bc  '*$e..            
"          .$'        .z*'               ^*$e.   '*****e.      
"          $$ee$c   .d'                     '*$.        3.     
"          ^*$E')$..$'                         *   .ee==d%     
"             $.d$$$*                           *  J$$$e*      
"              '''''                             '$$$'   
" }
"--------------------------------------------------------------------------------
"--------------------------------------------------------------------------------
" Suggested Mappings {
"--------------------------------------------------------------------------------
	nmap <silent> <leader>o :call ToggleList("Quickfix List", 'c')<CR>
	"nnoremap <leader>ff :vimgrep <C-R>=expand("<cword>")<CR> % <Bar> copen <Bar> wincmd J <Bar> exec "norm /<C-R>=expand("<cword>")<CR>\<CR>" <CR>
	nnoremap <leader>ff :call FindInFile()<CR>
	"noremap <leader>fg :Ack <C-R>=expand("<cword>")<CR><CR>
	noremap <leader>fc :call FindInPath()<CR>
	"noremap <leader><leader>t :echo "<C-R>=expand("<cword>")<CR>"<CR>
" }
"--------------------------------------------------------------------------------
" Functions {
"--------------------------------------------------------------------------------
    " Headers {
        command! -nargs=1 -complete=command -bang Cdo call ArgPopAndRestore( ListFileNames( 'quickfix' ), <f-args> )
        command! -nargs=1 -complete=command -bang Ldo call ArgPopAndRestore( ListFileNames( 'loclist' ), <f-args> )
    " }
    " CScope {
        if has("cscope")
            " add any cscope database in current directory
"            if filereadable("cscope.out")
"                cs add cscope.out  
"            " else add the database pointed to by environment variable 
"            elseif $CSCOPE_DB != ""
"                cs add $CSCOPE_DB
"            else
"                cs add ~/workrepos/farm-mobile/cscope.out
"            endif
			if !exists("cscope_test_loaded")
				let cscope_test_loaded = 1
				cs add /Users/$USER/workrepos/farm-mobile/.git/cscope.out
			endif
            " show msg when any other cscope db added
            set cscopeverbose  
            set cscopequickfix=s-,c-,d-,i-,t-,e-,g-
            " search tag files first
            set csto=1
            nmap <leader>fs :execute 'cs find s <C-R>=expand("<cword>")<CR>' <Bar> copen <Bar> wincmd J <CR>
        endif
    " }
    " ArgPopAndRestore {
    " @param exelist: The list of files you want to execute some commands
    " @param execommand: The commands you want to execute
        " TODO: consider buffdo instead of argdo then restor the buffer list
        function! ArgPopAndRestore( exelist, execommand )
            let current_arglist = argv()
            exe 'args ' . a:exelist . '| argdo! ' . a:execommand
            exe 'args ' . join(current_arglist)
        endfunc
    "}
    " ListFileNames {
    " @param listName: name of the list you want (loclist or quickfix)
    " @returns a map of buffer numbers to file names
        function! ListFileNames( listName )
          " Building a hash ensures we get each buffer only once
          let buffer_numbers = {}
          if a:listName == 'quickfix' 
              for quickfix_item in getqflist()
                let buffer_numbers[quickfix_item['bufnr']] = bufname(quickfix_item['bufnr'])
              endfor
          elseif a:listName == 'loclist'
              for loclist_item in getloclist()
                let buffer_numbers[loclist_item['bufnr']] = bufname(loclist_item['bufnr'])
              endfor
          endif
          return join(map(values(buffer_numbers), 'fnameescape(v:val)'))
        endfunction
    "}
    " GetBufferList {
    " @returns: buffer list
        function! GetBufferList()
            redir =>buflist
            silent! ls
            redir END
            return buflist
        endfunction
    "}
    " ToggleBuffer {
    " @param bufname: buffer list
    " @param pfx: buffer prefix
        function! ToggleBuffer(bufname, pfx)
            let buflist = GetBufferList()
            "let pat = '"'.a:bufname.'"' | echo filter(split('abc keep also def'), 'pat =~ v:val' )
            for bufnum in map(filter(split(buflist, '\n'), 'v:val =~ a:bufname'), 'str2nr(matchstr(v:val, "\\d\\+"))')
                if bufwinnr(bufnum) != -1
                    exec('bd '.bufnum)
                    return
                endif
            endfor
            " Test Prefix and open your buffer here
            if a:pfx == 'g'
                :Gstatus
                return
            endif
        endfunction
    "}
    " ToggleList {
    " @param bufname: buffer list
    " @param pfx: open/close
        function! ToggleList(bufname, pfx)
            let buflist = GetBufferList()
            for bufnum in map(filter(split(buflist, '\n'), 'v:val =~ "'.a:bufname.'"'), 'str2nr(matchstr(v:val, "\\d\\+"))')
                if bufwinnr(bufnum) != -1
                    exec(a:pfx.'close')
                    return
                endif
            endfor
            if a:pfx == 'l' && len(getloclist(0)) == 0
                echohl ErrorMsg
                echo "Location List is Empty."
                return
            endif
            let winnr = winnr()
            exec(a:pfx.'open')
            wincmd J
            if winnr() != winnr
                wincmd J
            endif
        endfunction
    "}
    " FindInFile {
    " searchs current file for the word under the cursor and populates 
    " the quickfix list with that word
        function! FindInFile()
            let needle = expand("<cword>")
            let start = line(".")	
            let results = search( needle )
            exec "vimgrep " . needle . " % "
            let @/ = needle
            let counter = 0
            for qf_item in getqflist()
                let counter += 1
                if qf_item[ 'lnum' ] == start
                    exe 'cc ' . counter 
                endif
            endfor
            copen | wincmd J
        endfunction
    "}
    " FindInPath {
    " searchs current path for the word under the cursor and populates 
    " the quickfix list with that word
        function! FindInPath()
            let cFileType = &ft
            let needle = expand("<cword>")
            let start = line(".")	
            exec "grep " . needle . " ./**/*." . cFileType	
            let @/ = needle
            let counter = 0
            for qf_item in getqflist()
                let counter += 1
                if qf_item[ 'lnum' ] == start
                    exe 'cc ' . counter 
                endif
            endfor
            copen | wincmd J
        endfunction
    " }
" }
"--------------------------------------------------------------------------------
