
function! AckOld#CopyMotionForType(type)
    if a:type ==# 'v'
        silent execute "normal! `<" . a:type . "`>y"
    elseif a:type ==# 'char'
        silent execute "normal! `[v`]y"
    endif
endfunction

function! AckOld#DoAck(args)
    execute "normal! :Ack! " . a:args . "\<cr>"
endfunction

function! AckOld#ExecuteAckAndWait(searchString)
    if len(a:searchString) < 3
        echo "Ignoring ack since it's less than 3 characters"
        return
    endif

    let escapedStr = shellescape(a:searchString, 1)
    execute "normal! :AckSync! --literal " . escapedStr . " ". s:ackSearchDir . "\<cr>"
endfunction

function! AckOld#AckMotion(type) abort

    SaveDefaultReg

    call AckOld#CopyMotionForType(a:type)

    if len(@@) < 3
        echo "Ignoring ack since it's less than 3 characters"
        return
    endif

    let escapedStr = shellescape(@@)
    exec s:GetAckCommand(escapedStr, 0) . "\<cr>"

    RestoreDefaultReg
endfunction

function! s:GetAckCommand(searchPattern, isCaseSensitive)

    let ackCommand = "Ack! "

    if a:isCaseSensitive
        let ackCommand .= "-i "
    endif

    let ackCommand .= "--literal \"". a:searchPattern . "\""

    if !empty(s:filePattern)
        let ackCommand .= " -G " . s:filePattern
    endif

    let ackCommand .= " ". s:ackSearchDir

    return ackCommand
endfunction

function! AckOld#SetAckDirToProjectRoot()
    call AckOld#PreMotionConfig(projeny#GetCurrentRoot())
endfunction

function! AckOld#PreMotionConfig(dir, ...)
    let s:ackSearchDir = a:dir
    let s:filePattern = a:0 > 0 ? a:1 : ""
endfunction

function! AckOld#GetCurrentManualSearchString()
    return ':' . s:GetAckCommand('', 1) . "\<home>\<c-f>\<esc>f\"\<c-c>\<right>"
endfunction

function! AckOld#FindMatchesInProject(searchPattern)

    call AckOld#SetAckDirToProjectRoot()
    " Replace over the entire project tree!
    call AckOld#ExecuteAckAndWait(a:searchPattern)

    let bufNumMap = {}
    " put it in a dictionary to avoid duplicates
    for entry in getqflist()
        let bufNum = entry['bufnr']
        let bufNumMap[bufNum] = 1
    endfor

    return keys(bufNumMap)
endfunction

