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

## Spreadsheets

`.csv` and `.tsv` files open as a spreadsheet, as in sc: a formula bar (cell
name, text, and a formula's value), column letters, row numbers, a header row
(bold, pinned on scroll) when the first row looks like one, and
right-aligned numbers.

```
 D4  =SUM(C2:C3)*2  → 7
      A    B    C       D
   1 item qty price
   2 pen    2   1.5
   3 ink    3     2
   4              7
```

The buffer text is still the file: editing a cell rewrites its record's
lines (quoting as needed), so `u`, `:w`, swap and undo files work on the
text, and `:sheet` toggles the same buffer to text and back. Records may
span lines (quoted line breaks). The separator is `,`, `;` or tab (detected
from the first line; `.tsv`: tab). `(set sheets false)` opens them as text.

| keys | |
| ---- | - |
| move | `h j k l`, arrows, `w b`, `0 $`, `gg G` (`5G`), `<C-d> <C-u> <C-f> <C-b>`, wheel, click; the grid spans at least Z and row 256 |
| edit | `<CR>` / `e` / `a` / double click / click the bar: edit the cell in the bar (`B3 = ...`); `=` formula, `c` from empty, `x` clear |
| select | `v` cells, `V` rows, `<C-v>` columns, or click a row number or column letter, or drag; the bar shows sum, average and count; `y` yank (as TSV), `x` clear, `d` delete rows or columns, `p` paste a yanked block |
| rows, columns | `o O`, `ir ic` (insert before), `ar ac` (after), `dd` / `3dd`, `dc`; `y` cell, `Y` rows, `p P` |
| widths | `> <` (`5>`), or drag a column letter's right edge; `f` fit to contents, `F` fit all |
| other | `/ ? n N` search cell text and values; `:sheet` toggle text/grid, `:sheet header`, `:sheet fit` |

Formulas: numbers, `"text"`, cells (`B3`, `$B$3`), `+ - * / ^`, `&`, `= <> <
> <= >=` (1 or 0), and `SUM AVERAGE MIN MAX COUNT COUNTA ABS ROUND INT SQRT
MOD POW IF AND OR NOT LEN UPPER LOWER CONCAT` (ranges as arguments:
`SUM(B2:B9)`; sc's `@sum(B2:B9)` too). Errors: `#REF! #DIV/0! #VALUE! #NAME?
#CYCLE! #ERR!`. Colors come from the theme (cursor cell: `search`,
selection: `visual`, bar: the grid's background, letters and numbers:
`status`). Themes can override them with `sheet.head`,
`sheet.head.current`, `sheet.cursor`, `sheet.selection`, `sheet.header` and
`sheet.bar`.

## Diagrams

Mermaid diagrams (a Markdown ` ```mermaid ` block or a `.mmd` file) are
drawn in place of the text with box-drawing characters. `<leader>m`
(`:mermaid`) toggles drawing and text; clicking a Markdown block draws it
(`(set mermaid false)`: not on click). `h j k l` (or drag, or wheel) pan,
`+` `-` zoom (space for boxes and gaps; below 0, labels are truncated with
an ellipsis, down to 3 cells, so big diagrams fit), `0` resets, `q` returns
to text. Round nodes get rounded corners, decisions `◇` on the border,
circles `●`, hexagons `⬡`, subroutines double sides. It redraws as the
source changes, in the theme's syntax colors.

```
      ┌───────┐
      │ Start │
      └───────┘
          │
          ▼
     ╭────◇───╮
     │ Is it? │
     ╰────◇───╯
       │  │ ▲
    ┌──┘  │ │
    │     └─┤
    │       ├─┐
    │ Yes   │ No
    ▼       ▼ │
 ┌────┐   ┌─────┐
 │ OK │   │ Fix │
 └────┘   └─────┘
```

* **Flowcharts** (`graph` / `flowchart`, `TD` `TB` `BT` `LR` `RL`): node
  shapes, links (`-->` `---` `-.->` `==>` `--x` `--o` `<-->` `~~~`), labels
  (`-->|yes|`, `-- yes -->`), chains and `&`. Layered layout
  (`src/mermaid.ae`): cycles broken, each node ranked by its longest path,
  a waypoint in each rank a long link crosses, rank order by neighbors (to
  reduce crossings), links spread along node sides, one gap row per bend.
* **State diagrams**: like flowcharts; `[*]` is a start (●) or end (◉).
* **Sequence diagrams**: participants and actors, messages (`->>` `-->>`
  `->` `-->` `-x` `-)`, self-messages too), notes, blocks (`loop` `alt`
  `else` `opt` `par` ... `end`), `autonumber`.
* Not yet: subgraph frames (their nodes are drawn), class, ER, Gantt, pie
  and other kinds (the viewer says so).

## Configuration

`~/.config/zap/init.zap` (or `$XDG_CONFIG_HOME/zap/init.zap`), read after
the built-in defaults (`:defaults` shows them; `:config` opens yours, with a
starter if new; `:reload` rereads it).

A **local** `init.zap` (the nearest one in the start directory or above)
replaces it (`(load "~/.config/zap/init.zap")` inside it loads yours too).
Config runs programs (hooks), so a local one is read only once trusted:
`:trust` records its path and text hash in `~/.local/state/zap/trust`; any
change needs `:trust` again (like nvim's `exrc`). Until then zap says it was
skipped and uses yours.

One form per declaration:

```lisp
(set number true)              ; options: :set lists them
(set tree-width 30)
(set theme "ink")              ; themes below

(theme "mine" :inherit "paper" ; a theme: faces fall back by name
  (normal :fg "#202020" :bg "#fbfbf8")      ; tree.dir -> tree -> normal
  (heading :fg "#0b7285")
  (search :fg "#ffffff" :bg "#0b7285"))

(map normal "<leader>w" "w")   ; keys run ex commands
(filetype "jsonc" :ext (".jsonc") :syntax "json" :comment "//") ; :names ("Dockerfile") too
(special "README.md" "Makefile")
(load "more.zap")              ; relative to this file

(addin "mine"                  ; an add-in: commands, keys, hooks together
  (command "lint" :run ("aec" "%" "--check-only" "--message-format" "short")
    :save true :errors true :show "quiet" :doc "check this file")
  (on "save" "*.ae" "lint")
  (map normal "<leader>l" "lint"))
(disable "aela")               ; turn off an add-in
```

Themes live in `src/themes/`: **paper** (light, default) and **ink**
(dark), which the others inherit (`base.ae`); soft **dune**, **mist**
(light) and **moss** (dark); high-contrast **noon** (light), **coal** and
**volt** (dark); monochrome **chalk** (light, gray) and **amber** (dark, one
hue) (`more.ae`). The
[zenbones](https://github.com/zenbones-theme/zenbones.nvim) family
(`zenbones.ae`), light and dark: **zenbones**, **zenwritten**,
**neobones**, **rosebones**, **forestbones**, **tokyobones** and
**seoulbones** (`-light` / `-dark`, e.g. `zenbones-dark`), **vimbones**
(light), **nordbones**, **duckbones**, **zenburned** and **kanagawabones**
(dark). Bram de Haan's
[Atelier](https://atelierbram.github.io/syntax-highlighting/atelier-schemes/)
schemes (`atelier.ae`, one template over their base16 palettes), dark and
light: **atelier-cave**, **-dune**, **-estuary**, **-forest**, **-heath**,
**-lakeside**, **-plateau**, **-savanna**, **-seaside** and
**-sulphurpool** (`atelier-cave-light` etc.). `:theme <Tab>` and the
palette's Themes tab list them. A theme's `visual` face is the selection
(background only, over the text colors); `menu` and `menu.selected` style
command line completions.

A filetype's `:syntax` is one of zap's lexers (`aela markdown sexp shell c
cpp swift js css html python mermaid asm json`), `csv` or `tsv`
(spreadsheet), or `""` (plain text). Any other name is a config error (the
files open as plain text). Later `filetype`s win, so init.zap can take over
a built-in extension.

See `example.zap` for an example. The forms are documented at the top of
`src/config.ae`; faces in `src/themes/theme.ae`.

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
