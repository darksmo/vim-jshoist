" jshoist.vim - Move declaration of Javascript variables at the function scope
" Maintainer:   Savio Dimatteo <http://savio.dimatteo.it/>
" Version:      0.1

if exists("g:loaded_jshoist")
    finish
endif
let g:loaded_jshoist = 1

function! s:JsHoistGoToFunctionScope(declarationLineNumber) abort
    " go to the current function scope
    let l:jumpedToLineSoFar = line(".")
    while 1
        " go to the next function backwards
        let l:jumpedToLineNumber = search("function", "b")
        if l:jumpedToLineNumber >=# l:jumpedToLineSoFar

            " no more results put the cursor back where it was
            execute(l:jumpedToLineSoFar)
            return 0
        endif
        let l:jumpedToLineSoFar = l:jumpedToLineNumber

        call search("{")
        normal! %

        " check whether the declaration is in the body of the function
        if line(".") ># a:declarationLineNumber
            normal! %^
            return 1
        endif

        " back at the beginning of the function we just found
        normal! %
        call search("function", "b")
    endwhile

    return 1
endfunction

function! s:JsHoistEnsureBlankLineAfterSemicolon() abort
    let l:line = line(".")
    normal! ^
    call search(";")
    if getline(line(".") + 1) !~ "^\s*$"
        normal! o
    endif
    execute(l:line)
endfunction

function! s:JsHoistAppendDeclarationInScope(variableName, lineBelowFunction) abort
    """
    """ Insert the variable below in various ways
    """

    " function () {
    "    <line without 'var'>
    "
    if a:lineBelowFunction !~ "var"
        execute "normal! $ovar " . a:variableName . ";"
        normal! >>
        call s:JsHoistEnsureBlankLineAfterSemicolon()
        return 1
    endif

    " function () {           function () {
    "    var something;   ->     var hoisted,
    "                                something;
    if a:lineBelowFunction =~ "var.*;$"
        normal! j
        normal! ^/var<cr>
        execute "normal! wi" . a:variableName . ",\<cr>"
        normal! >>
        call s:JsHoistEnsureBlankLineAfterSemicolon()
        return 1
    endif

    " function () {           function () {
    "    var something,   ->     var hoisted,
    "                                something,
    if a:lineBelowFunction =~ "var.*,$"
        normal! j
        normal! ^/var<cr>
        execute "normal! wi" . a:variableName . ",\<cr>"
        normal! >>
        call s:JsHoistEnsureBlankLineAfterSemicolon()
        return 1
    endif

    return 0

endfunction

function! s:JsHoistMoveToFirstVarDeclation()
    let l:currentLineNumber = line(".")
    if search("var", "b") !=# l:currentLineNumber
        " no var declaration was found behind the cursor
        call search ("var")
    endif
endfunction

function! s:JsHoist() abort
    let l:originalLineContent = getline(".")
    let l:originalLineNumber = line(".")
    let l:varDeclarationPattern = "\s*var.*\=.*"

    " check precondition (only oneline statements for now)
    if l:originalLineContent !~ l:varDeclarationPattern
        echom "A var assignment was not found on this line"
        return
    endif

    " save current position before moving
    normal! mx 

    call s:JsHoistMoveToFirstVarDeclation()

    " take the name of the declared var
    normal! w
    let l:variableName = expand("<cWORD>")

    " delete variable name
    normal! bdw

    call s:JsHoistGoToFunctionScope(l:originalLineNumber)

    " make sure that on the line below there is no variable declaration...
    normal! j
    let l:lineBelowFunction = getline(".")
    normal! k

    if !s:JsHoistAppendDeclarationInScope(l:variableName, l:lineBelowFunction)
        echom "Variable cannot be inserted below the enclosing function signature"
    endif

    " go back where we were
    normal! `x

endfunction

command! JsHoist call <sid>JsHoist()
