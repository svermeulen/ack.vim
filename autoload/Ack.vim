
function! Ack#DoAck(args)
    execute "normal! :Ack! " . a:args . "\<cr>"
endfunction

function! Ack#ExecuteAckAndWait(searchString, searchDir)

    if len(a:searchString) < 3
        echo "Ignoring ack since it's less than 3 characters"
        return
    endif

    let escapedStr = shellescape(a:searchString, 1)
    execute "normal! :AckSync! --literal " . escapedStr . " ". a:searchDir . "\<cr>"
endfunction

function! s:GetAckCommand(searchPattern, isCaseSensitive, filePattern, searchDir)

    let ackCommand = "Ack! "

    if a:isCaseSensitive
        let ackCommand .= "-i "
    endif

    let ackCommand .= "--literal ". a:searchPattern

    if !empty(a:filePattern)
        let ackCommand .= " -G \"" . a:filePattern . "\""
    endif

    let ackCommand .= " ". a:searchDir

    return ackCommand
endfunction

function! Ack#AckForSearchRegister()

    let searchText = Ave#Maps#GetCleanSearchRegister()

    echom "Searching for " . searchText

    let command = s:GetAckCommand(searchText, 0, '', Ave#ProjectRoot#GetDir()) . "\<cr>"
    "echom "Ack command = " . command
    exec command
endfunction

function! Ack#AckSelectedInDir(dir, ...)

    " Clear selection
    normal! 

    let filePattern = (a:0 > 0 ? a:1 : "")
    let searchText = Ave#Util#GetVisualSelection()

    "echom "Searching for " . searchText

    let escapedStr = shellescape(searchText)

    let command = s:GetAckCommand(escapedStr, 0, filePattern, a:dir) . "\<cr>"
    "echom "Ack command = " . command
    exec command
endfunction

function! Ack#GetAckManualCommand(dir, ...)
    let filePattern = (a:0 > 0 ? a:1 : "")
    return ':' . s:GetAckCommand('""', 1, filePattern, a:dir) . "\<home>\<c-f>\<esc>f\"\<c-c>\<right>"
endfunction

function! Ack#FindMatchesInProject(searchPattern)

    " Replace over the entire project tree!
    call Ack#ExecuteAckAndWait(a:searchPattern, Ave#ProjectRoot#GetDir())

    let bufNumMap = {}
    " put it in a dictionary to avoid duplicates
    for entry in getqflist()
        let bufNum = entry['bufnr']
        let bufNumMap[bufNum] = 1
    endfor

    return keys(bufNumMap)
endfunction
