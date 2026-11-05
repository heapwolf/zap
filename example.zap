;; A zap configuration: copy to ~/.config/zap/init.zap, or to init.zap in a
;; project (which replaces the global one there once you :trust it). Read
;; after the built-in defaults (:defaults shows them); :reload rereads it.

;; ---- options (:set lists them) ----------------------------------------------

(set number true)
(set tabstop 2)
(set tree-width 30)
(set scrolloff 4)
(set icons true)          ; false without a Nerd Font
(set regex false)         ; true: / and :s use regular expressions

;; ---- a custom theme: faces fall back by name (tree.dir, tree, normal) ------

(theme "sea" :inherit "paper"
  (normal :fg "#1f2933" :bg "#fbfcfd")
  (cursor :bg "#9fd3e0")
  (tree :bg "#eef3f6")
  (tree.cursor :bg "#dce8ee")
  (divider :bg "#eef3f6")
  (heading :fg "#0b7285")
  (list :fg "#0b7285")
  (url :fg "#0b7285")
  (search :fg "#ffffff" :bg "#0b7285")
  (status.mode.insert :fg "#ffffff" :bg "#0b7285")
  (tree.special :fg "#0b7285" :italic true))
;; (set theme "sea")

;; ---- keys: each runs an ex command ---------------------------------------------

(map normal "<leader>w" "w")
(map normal "<leader>q" "q")
(map normal "<leader>p" "commands")

;; ---- an add-in: commands that run programs, with keys and hooks -------------

(addin "aela-extra"
  (command "verify" :run ("aec" "%" "--check-only" "--verify-report" "--message-format" "short")
    :save true :errors true :doc "what the verifier cannot prove")
  (command "allocs" :run ("aec" "%" "--allocs") :show "buffer" :errors true
    :doc "every heap allocation the program can make")
  (map normal "<leader>v" "verify"))

;; the built-in aela add-in checks .ae files on save; to disable it:
;; (disable "aela")
