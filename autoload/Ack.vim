
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
    if len(a:searchString) < 3
        echo "Ignoring ack since it's less than 3 characters"
        return
    endif

    let escapedStr = shellescape(a:searchString, 1)
    execute "normal! :AckSync! --literal " . escapedStr . " ". s:ackSearchDir . "\<cr>"
endfunction

function! Ack#AckMotion(type) abort

    SaveDefaultReg

    call Ack#CopyMotionForType(a:type)

    if len(@@) < 3
        echo "Ignoring ack since it's less than 3 characters"
        return
    endif

    let escapedStr = shellescape(@@)
    exec "Ack! ". "--literal ". escapedStr . " ". s:ackSearchDir . "\<cr>"

    RestoreDefaultReg
endfunction

function! Ack#SetAckDirToProjectRoot()
    call Ack#PreMotionConfig(Ave#Util#GetProjectRootDir())
endfunction

function! Ack#PreMotionConfig(dir, ...)
    let s:ackSearchDir = a:dir
    let s:filePattern = a:0 > 0 ? a:1 : ""
endfunction

function! Ack#FindMatchesInProject(searchPattern)

    call Ack#SetAckDirToProjectRoot()
    " Replace over the entire project tree!
    call Ack#ExecuteAckAndWait(a:searchPattern)

    let bufNumMap = {}
    " put it in a dictionary to avoid duplicates
    for entry in getqflist()
        let bufNum = entry['bufnr']
        let bufNumMap[bufNum] = 1
    endfor

    return keys(bufNumMap)
endfunction

