;; @text          xxx guifg=#d4d4d4
;; @text.literal  xxx guifg=#d4d4d4
;; @text.reference xxx links to Identifier
;; Identifier     xxx guifg=#9cdcfe
;; @text.title    xxx cterm=bold gui=bold guifg=#569cd6
;; @text.uri      xxx guifg=#d4d4d4
;; @text.underline xxx guifg=#d7ba7d
;; @text.todo     xxx links to Todo
;; Todo           xxx cterm=bold gui=bold guifg=#d7ba7d guibg=#1e1e1e
;; @comment       xxx guifg=#6a9955
;; @punctuation   xxx links to Delimiter
;; Delimiter      xxx guifg=#d4d4d4
;; @constant      xxx guifg=#4fc1fe
;; @constant.builtin xxx guifg=#569cd6
;; @constant.macro xxx guifg=#4ec9b0
;; @define        xxx links to Define
;; @macro         xxx links to Macro
;; @string        xxx guifg=#ce9178
;; String         xxx guifg=#ce9178
;; @string.escape xxx links to SpecialChar
;; @string.special xxx links to SpecialChar
;; @character     xxx guifg=#ce9178
;; @character.special xxx links to SpecialChar
;; @number        xxx guifg=#b5cea8
;; @boolean       xxx guifg=#569cd6
;; @float         xxx guifg=#b5cea8
;; @function      xxx guifg=#dcdcaa
;; Function       xxx guifg=#dcdcaa
;; @function.builtin xxx guifg=#dcdcaa
;; @function.macro xxx guifg=#dcdcaa
;; @parameter     xxx guifg=#9cdcfe
;; @method        xxx guifg=#dcdcaa
;; @field         xxx guifg=#9cdcfe
;; @property      xxx guifg=#9cdcfe
;; @constructor   xxx guifg=#4ec9b0
;; @conditional   xxx guifg=#c586c0
;; @repeat        xxx guifg=#c586c0
;; @label         xxx guifg=#9cdcfe
;; @operator      xxx guifg=#d4d4d4
;; Operator       xxx guifg=#d4d4d4
;; @keyword       xxx guifg=#c586c0
;; @exception     xxx guifg=#c586c0
;; @variable      xxx guifg=#9cdcfe
;; @type          xxx guifg=#4ec9b0
;; @type.definition xxx links to Typedef
;; @storageclass  xxx guifg=#569cd6
;; @namespace     xxx guifg=#4ec9b0
;; @include       xxx guifg=#c586c0
;; @preproc       xxx links to PreProc
;; @debug         xxx links to Debug

(comment) @comment
(number) @number
(string) @string
(bool) @boolean
(builtin) @function.builtin
(keyword) @keyword
(klet) @keyword
(kdef) @keyword
(krec) @keyword
(kreturn) @keyword
(kmodule) @namespace
(kexport) @keyword
(terminals) @punctuation
(arg) @variable
(arg_list) @field
