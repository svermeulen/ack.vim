
function! Ack#CopyMotionForType(type)
    if a:type ==# 'v'
        silent execute "normal! `<" . a:type . "`>y"
    elseif a:type ==# 'char'
        silent execute "normal! `[v`]y"
    endif
endfunction

function! Ack#DoAck(args)
    execute "normal! :Ack! " . a:args . "\<cr>"
endfunction

function! Ack#ExecuteAckAndWait(searchString)
    let escapedStr = shellescape(a:searchString)
    execute "normal! :AckSync! --literal " . escapedStr . " ". s:ackSearchDir . "\<cr>"
endfunction

function! Ack#AckMotion(type) abort
    let reg_save = @@

    call Ack#CopyMotionForType(a:type)
    let escapedStr = shellescape(@@)
    exec "Ack! ". "--literal ". escapedStr . " ". s:ackSearchDir . "\<cr>"

    let @@ = reg_save
endfunction

function! Ack#SetAckDirToProjectRoot()
    let s:ackSearchDir = Ave#Util#GetProjectRootDir()
endfunction

function! Ack#SetAckDirToCurrentDir()
    let s:ackSearchDir = expand("%:p:h")
endfunction

function! Ack#SetAckDir(dir)
    let s:ackSearchDir = a:dir
endfunction

function! Ack#FindMatchesInProject(searchPattern)

    call Ack#SetAckDirToProjectRoot()
    " Replace over the entire project tree!
    call Ack#ExecuteAckAndWait(a:searchPattern)

    let bufNumMap = {}
    " put it in a dictionary to avoid duplicates
    for entry in getqflist()
        let bufNumMap[entry['bufnr']] = 1
    endfor

    return keys(bufNumMap)
endfunction

