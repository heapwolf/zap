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

## The screen

```
 foss                       1 # Hosted Aela
   ae-v0                    2
     .notes                 3 Status: a proposal, ...
       HOSTED.md            ...
 NORMAL  HOSTED.md                   utf-8    markdown  6%  23:19
```

* The tree (of the start directory) is on the left, in a `tui::Split`.
  Resize it by dragging its edge, or with `<C-w>>` / `<C-w><`. `<C-t>`
  toggles it. In normal mode, `<Tab>` / `<S-Tab>` cycle focus between tree
  and editor (also `:focus next|prev|tree|editor`, `<C-w>h` / `<C-w>l`).
* The status line is lualine-like: mode, file, encoding, line endings, file
  type, scroll percent, line:column. Icons need a Nerd Font
  (`(set icons false)` for plain ones).
* Git signs: in a git repo, the column left of the line numbers marks
  changes since the last commit, live: `▎` added (green) or changed, `▁`
  lines deleted below. Colors are the theme's `git.add`, `git.change` and
  `git.delete` faces (fallback: its string, type and error colors). zap
  fetches the committed file from git once, in the background (on open,
  write, `:e!`), and diffs it itself. `(set gitsigns false)` turns them off.
  Not on AeOS (no git).
* Rows past the end show `~`, as in vim (`(set tildes false)`: blank).
* The command line takes no row (cmdheight 0) until you type `:` or `/`.
  Messages (`"x.ae" 12L written`, errors) show in the status line, in place
  of the file name, for a few seconds (`<Esc>` clears them), so the status
  line never moves. With `(set cmdheight 1)` they use the command line row.
* Started without a file, zap shows an intro, as nvim does (logo, version,
  hints). It goes away once you type or open something.

## Keys

| mode    | keys                                                                                                                       |
| ------- | -------------------------------------------------------------------------------------------------------------------------- |
| normal  | `h j k l w b e W B E 0 ^ $ gg G { } H M L f t F T ; , %`, counts, `<C-d> <C-u> <C-f> <C-b> <C-e> <C-y> zz zt zb`; held `h l` and arrows speed up a little (up to 3x; `(set keyaccel false)`: off) |
| edit    | `i a I A o O`, `x X s S r J ~ D C Y p P`, operators `d c y > <` with any motion (`dw`, `c$`, `3dd`, `>}`) or `iw aw iW aW` |
| insert  | completion as you type: buffer words, and in Aela files the declarations from `aec outline --deps` (icons, `pub fn` / `method Item` / `field Item`, `str::` module exports, `Size::` variants, `x.` members); shows the selection's signature and doc beside it and its remainder after the cursor; `<Tab> <C-n>` / `<S-Tab> <C-p>` cycle, `<CR> <C-y>` accept, `<C-e>` close; `(set autocomplete false)` |
| visual  | `v V <C-v>` (characters, lines, block), motions, `o`, `iw`, then `d x c s y > < ~ u U J r p`; block `I A`; `:` (`'<,'>`); `gv` |
| undo    | `u <C-r>`, `g- g+` (every state, branches too), `:earlier 10` / `5m` / `1f`, `:later`, `:undolist`; saved with the file on write |
| command | `<Tab>` opens a completion menu (`<Tab> <S-Tab>` cycle), `<Up> <Down>` history (saved); ranges `:1,3d`, `:.,+2y`, `:%s`, `:'<,'>>` |
| search  | `/` and `?` (`/` then Enter: repeat last), `n N * #`, `:noh`, `:s/a/b/g`, `:%s/a/b/g`; smartcase; `(set regex true)` |
| tree    | `j k gg G`, Enter / `o` / `l` open (toggles a directory), `h` close or go up, `R` reload, `H` hidden files, `-` parent directory, `C` set root here, `q` hide |
| buffers | `:e file`, `:ls`, `:b N` / `:b name` / `:b#`, `:bn` `:bp` (`<C-n>` `<C-p>`), `:bd[!]`, the palette (`<C-k>`)              |
| files   | `:w [file]` (`:w!`: even if changed on disk), `:wa`, `:q[!]`, `:qa[!]`, `:wq`, `:x`, `ZZ`, `ZQ`, `:e!`, `<C-g>`           |
| options | `:set number!` (`<leader>n`), `:set nonu`, `:set ts=8`, `:set nu?`, `:set`, `:theme ink`, `:reload`, `:config`, `:defaults` |
| mouse   | click the tree (open) or text (move cursor), drag text to select (double: word, triple: line), wheel scrolls the pane under it (sideways too: tilt, trackpad, or Shift+wheel), faster when spun faster (up to `(set scrollaccel 6)`x; 1: off), drag the split |
| sheet   | CSV or TSV: see below                                                                                                      |

Yanks also go to the system clipboard: via `pbcopy` (macOS), `wl-copy`,
`xclip` or `xsel` (Linux) when local, and via OSC 52, which works over ssh.
Not every terminal supports OSC 52 (Terminal.app and VTE don't; iTerm2 does
with "Applications in terminal may access clipboard" on).
`(set clipboard false)` turns this off.

The leader is `<Space>` (`(set leader "\\")` for Vim's).
