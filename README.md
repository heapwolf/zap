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

## The palette (`<C-k>`)

`<C-k>` opens it from normal, insert and visual mode and the tree (insert
mode is exited as by `<Esc>`; on the command line `<C-k>` deletes to the
end, as in readline). `<leader>p` opens it too (normal, visual, tree), for
terminals or tmux setups that grab Ctrl-K. It is a picker with categories:
`Tab` / `Shift+Tab` switch category, typing filters (fuzzy), `Up` / `Down`
select, `Enter` opens, `Esc` closes. It reopens on the last category.

| category | lists                                                                                       | also     |
| -------- | ------------------------------------------------------------------------------------------- | -------- |
| Files    | project files (the start directory; skips hidden directories and node_modules)              | `<leader>f` |
| Grep     | lines in those files matching the query (smartcase), in order; searches in the background as you type, 4 MB per step | `<leader>/` |
| Symbols  | project declarations, from the add-in command `symbols` (aela add-in: `aec outline <cwd>`)  | `<leader>s` |
| Buffers  | open buffers                                                                                | `<leader>b` |
| Commands | ex commands, and every add-in command with its `:doc`                                       |          |
| Themes   | themes; Enter applies one                                                                   | `:themes` |

`:palette NAME` opens it on a category.

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

### Add-ins and the Aela tools

Commands run programs in the background (the editor stays usable; the
status line shows a spinner; `:stop` kills it). Arguments may contain `%`
(the file), `%:h`, `%:r`, `%:t`, `<cword>`, `<cwd>`. With `:errors true`,
`file:line:col: message` output lines become diagnostics: line numbers turn
red, the status line counts them, `:cnext` / `:cprev` (`]d` / `[d`) step
through them, `:clist` lists them. `:show` sets where output goes:
`"panel"` (last lines, below the status line), `"buffer"`, `"jump"` (to the
first location printed) or `"quiet"`.

The built-in `aela` add-in uses `aec`:

| command    | runs                                        | keys        |
| ---------- | ------------------------------------------- | ----------- |
| `:check`   | `aec % --check-only` (also after each save) | `<leader>c` |
| `:build`   | `aec % -o %:r`                              |             |
| `:run`     | build, then run; output in a buffer         | `<leader>r` |
| `:test`    | `aec test %`                                | `<leader>t` |
| `:fmt`     | `aec fmt %`, then reload the file           |             |
| `:def`     | `aec query def % <cword>`: jump there       | `gd`        |
| `:refs`    | `aec query refs % <cword>`                  | `gr`        |
| `:explain` | `aec explain <cword>` (an error code)       | `K`         |
| `:docs`    | `aec docs <cword>`                          |             |
| `:outline` | `aec outline %`                             |             |
| `:symbols` | `aec outline <cwd>`: the palette's Symbols  | `<leader>s` |

`:addins` lists add-ins and their commands; the palette's Commands lists
all commands. A command with `:show "outline"` fills the palette's Symbols
with its output, in `aec outline` format (`== file`, then
`line declaration`).

`:! cmd` runs a shell command (output in the panel). `cd` and `pwd` are
built in (also `:cd dir`, `:cd -`, `:pwd`): they set and show zap's
directory, which is the tree root, where commands run, and what the palette
lists. On AeOS, which has no `sh` (programs can't start others), `:!` runs
zap's own `ls cat mkdir rm mv cp echo touch`, on `std/fs` (`@NAME/...`:
another program's space).

## How it works

* **The memline** (`src/memline.ae`). Opening a file scans it once, 64 KB
  at a time, to split it into chunks of about 8 KB of whole lines; no text
  is kept. A chunk is loaded (`fs::read_at`) on first access, and at most
  `resident` chunks (64) stay in memory, evicted least recently used first.
  An evicted changed chunk is appended to a swap file in
  `~/.local/state/zap/swap/` and reloaded from there; a chunk over 512
  lines is split. Writes go chunk by chunk to `file.zap-new` (or, if its
  directory is not writable, to `~/.local/state/zap/new/`), then copied
  over the file: it keeps its inode, permissions, owner, links and
  symlinks, and a failed write says where the new text is. A file changed
  on disk since it was read is not overwritten without `:w!`. If a chunk
  can't be reloaded (the file changed or was deleted), the buffer says so
  and refuses to write.
* **The undo tree** (`src/undo.ae`). Each change records the lines it
  replaced, inserted or deleted (old and new) and becomes a state, a child
  of the state it was made in. Undo goes to the parent; a change after an
  undo starts a branch, keeping the old one. `g-` `g+` and `:earlier`
  `:later` reach any state via their nearest common ancestor. Each write
  saves the tree to `~/.local/state/zap/undo/` with the file's size and
  mtime; reopening the unchanged file restores it. A 110 MB file opens in
  about 0.1 s and stays around 10 MB of memory through `G`, a search and an
  edit.
* **Only what is on screen.** Before each frame, `App.prepare` loads and
  highlights the visible lines and tree rows, and the frame paints only
  those (`std/tui` then writes only changed cells). Highlighting is one
  lexer per language, a line at a time; the state each line starts in
  (inside a comment, a code fence) is cached every 64 lines. When the view
  jumps past known states, the window is painted at once with a guess, the
  states are computed in the background (4096 lines per step between
  events), and it is repainted.
* **The loop is async** (`src/main.ae`): a `select` over terminal events,
  the running command's output (a pipe in the event loop, so the editor
  never waits on a tool) and background work.
