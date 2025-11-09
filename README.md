# zap

A terminal editor in Aela, built on `std/tui`: nvim-like modes and keys, a
command line, search, a resizable file tree, buffers, themes, and add-ins
(s-expressions) that run the Aela compiler's tools.

```sh
aec build                    # -> build/zap (index.json)
build/zap [file...] [+line]  # a directory argument sets the tree's root
```

`:help` opens read-only Markdown help (`:help undo` jumps to the undo
section; `q` closes it). `aec test src` runs the tests (memline, undo, sexp,
syntax, tree, config, buffer, and the whole editor, headless).
