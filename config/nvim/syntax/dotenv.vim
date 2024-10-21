" Vim syntax file
" Language:        env files (NOT shell code)
" Maintainer:      Gernot Schulz <gernot.schulz@overleaf.com>

" quit when a syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

" Syntax matching for comments
syn match dotenvComment '^#.*'

" Match for unassigned variables (e.g., VAR_NAME without a value)
syn match dotenvVariableUnassigned "^\h\w*$"

" Match for variables followed by an assignment
syn match dotenvVariable "^\h\w*\ze=" nextgroup=dotenvVarAssign

" Match for the equal sign used in assignment
syn match dotenvVarAssign contained "=" nextgroup=dotenvQuotedValue,dotenvUnquotedValue

" Match for variable names (contained in a dotenv assignment)
syn match dotenvVar contained "\h\w*"

" Match for spaces between variable names and values
syn match dotenvSpace contained "\s\+"

" Match for quoted values (handles both ' and ")
syn region dotenvQuotedValue start=+["']+ skip=+\\["']+ end=+["']+ contains=dotenvEscape

" Match for unquoted values (anything after '=' without quotes)
syn match dotenvUnquotedValue "^\h\w*\s*=\s*\zs[^#\"'\s]\S*" nextgroup=NONE contained

" Match for escape sequences inside quotes (e.g., \n, \", etc.)
syn match dotenvEscape contained "\\."

" Set the current syntax to dotenv
let b:current_syntax = "dotenv"

" Highlighting rules
hi def link dotenvComment Comment
hi def link dotenvVariableUnassigned Error
hi def link dotenvVariable Identifier
hi def link dotenvVarAssign Operator
hi def link dotenvSpace Error
hi def link dotenvQuotedValue String
hi def link dotenvUnquotedValue Constant
hi def link dotenvEscape SpecialChar

