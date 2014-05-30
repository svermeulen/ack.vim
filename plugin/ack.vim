
" NOTE: You must, of course, install the ack script
"       in your path.
" On Debian / Ubuntu:
"   sudo apt-get install ack-grep
" With MacPorts:
"   sudo port install p5-app-ack

" Location of the ack utility
if !exists("g:ackprg")
    let g:ackprg="ag --column"
endif

if !exists("g:ack_apply_qmappings")
    let g:ack_apply_qmappings = !exists("g:ack_qhandler")
endif

if !exists("g:ack_apply_lmappings")
    let g:ack_apply_lmappings = !exists("g:ack_lhandler")
endif

if !exists("g:ack_qhandler")
    let g:ack_qhandler="copen"
endif

if !exists("g:ack_lhandler")
    let g:ack_lhandler="lopen"
endif

function! s:AckSynchronous(cmd, args)
    call s:Ack(a:cmd, a:args, 0)
endfunction

function! s:AckAsynchronous(cmd, args)
    call s:Ack(a:cmd, a:args, 1)
endfunction

function! g:OnAckFinished(request)

    let qfcount = len(getqflist())
    echo 'Found '. qfcount . ' matches'
endfunction

function! s:Ack(cmd, args, async)
    try
        wa
    catch /\v.*/
        " Ignore 'buffer is not saved error'
    endtry

    redraw

    " If no pattern is provided, search for the word under the cursor
    if empty(a:args)
        let l:grepargs = expand("<cword>")
    else
        let l:grepargs = a:args . join(a:000, ' ')
    end

    echo "Searching..."

    " Format, used to manage column jump
    if a:cmd =~# '-g$'
        let g:ackformat="%f"
    else
        let g:ackformat="%f:%l:%c:%m"
    end

    if a:async
        setlocal errorformat=%f:%l:%c:%m
        let &l:makeprg=g:ackprg." ".grepargs
        silent call dispatch#compile_command(1, [], 0, 'g:OnAckFinished', [])

    else
        let &grepprg=g:ackprg
        let &grepformat=g:ackformat

        silent execute a:cmd . " " . grepargs

        " This does not populate the qflist
        "silent execute "!" . g:ackprg . " " . grepargs

        echo "Finished search"
    endif

    let searchStr = matchstr(a:args, '\"\zs[^\"]*\ze\"')

    " Note: this won't work all the time since vim's regex is not perl regex
    let @/=searchStr
endfunction

function! s:AckFromSearch(cmd, args)
    let search =  getreg('/')
    " translate vim regular expression to perl regular expression.
    let search = substitute(search,'\(\\<\|\\>\)','\\b','g')
    call s:Ack(a:cmd, '"' .  search .'" '. a:args, 1)
endfunction

function! s:GetDocLocations()
    let dp = ''
    for p in split(&rtp,',')
        let p = p.'/doc/'
        if isdirectory(p)
            let dp = p.'*.txt '.dp
        endif
    endfor
    return dp
endfunction

function! s:AckHelp(cmd,args)
    let args = a:args.' '.s:GetDocLocations()
    call s:Ack(a:cmd, args, 1)
endfunction

command! -bang -nargs=* Ack call s:AckAsynchronous('grep<bang>',<q-args>)
command! -bang -nargs=* AckSync call s:AckSynchronous('grep<bang>',<q-args>)
command! -bang -nargs=* AckAdd call s:Ack('grepadd<bang>', <q-args>)
command! -bang -nargs=* AckFromSearch call s:AckFromSearch('grep<bang>', <q-args>)
command! -bang -nargs=* LAck call s:Ack('lgrep<bang>', <q-args>)
command! -bang -nargs=* LAckAdd call s:Ack('lgrepadd<bang>', <q-args>)
command! -bang -nargs=* AckFile call s:Ack('grep<bang> -g', <q-args>)
command! -bang -nargs=* AckHelp call s:AckHelp('grep<bang>',<q-args>)
command! -bang -nargs=* LAckHelp call s:AckHelp('lgrep<bang>',<q-args>)
