;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
(setq doom-font (font-spec :family "JetBrainsMono Nerd Font Mono" :size 20)
      doom-variable-pitch-font (font-spec :family "JetBrainsMono Nerd Font Mono" :size 20)
      doom-big-font (font-spec :family "JetBrainsMono Nerd Font Mono" :size 24))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;; (setq doom-theme 'doom-one)

;; Theme
(setq doom-theme 'catppuccin)
(setq catppuccin-flavor 'macchiato)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")
(setq org-roam-directory "~/org/notes/")
(setq org-agenda-files '("~/org/inbox.org" "~/org/projects.org"))

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Force Emacs to start in maximized window
(add-to-list 'initial-frame-alist '(fullscreen . maximized))

(after! org
    ;; Org capture templates for inbox.org and projects.org
    (setq org-capture-templates
        '(("i" "Idea" entry
            (file "~/org/inbox.org")
            "* %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n"
            :empty-lines 1)

            ("t" "Task" entry
            (file "~/org/inbox.org")
            "* TODO %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n"
            :empty-lines 1)

            ("p" "Project" entry
            (file+headline "~/org/projects.org" "Active")
            "** %^{Project name} [%]\n:PROPERTIES:\n:GOAL: %^{Goal}\n:CREATED: %U\n:END:\n\n*** Notes\n%?"
            :empty-lines 1)))

    ;; Set max level for refiling headings
    (setq org-refile-targets
        '(("~/org/projects.org" :maxlevel . 2)
            ("~/org/inbox.org" :maxlevel . 1)))

    ;; Show the full path in refile prompt (file/heading/subheading)
    (setq org-refile-use-outline-path 'file)

    ;; Allow completing each path step separately (easier navigation)
    (setq org-outline-path-complete-in-steps nil))

;; Org Roam capture templates
(after! org-roam
  (setq org-roam-capture-templates
        '(("k" "Knowledge" plain
           "* %?\n\n* Links\n\n"
           :target (file+head "${slug}.org"
                              ":PROPERTIES:\n:ROAM_ALIASES: %^{Aliases (optional)}\n:END:\n#+title: ${title}\n#+filetags: :knowledge:\n#+date: %U\n\n")
           :unnarrowed t)

          ("b" "Book" plain
           "#+author: %^{Author}\n#+year: %^{Year}\n\n* Summary\n%?\n\n* Key Ideas\n\n* Quotes\n\n* Links\n\n"
           :target (file+head "${slug}.org"
                              ":PROPERTIES:\n:ROAM_ALIASES: %^{Aliases (optional)}\n:END:\n#+title: ${title}\n#+filetags: :knowledge:\n#+date: %U\n\n")
           :unnarrowed t)

          ("p" "Paper / Article" plain
           "#+author: %^{Author}\n#+url: %^{URL or DOI}\n\n* Summary\n%?\n\n* Key Points\n\n* My Thoughts\n\n* Links\n\n"
           :target (file+head "${slug}.org"
                              "#+title: ${title}\n#+filetags: :source: :paper:\n#+date: %U\n")
           :unnarrowed t)

          ("a" "Assignment / Exam" plain
           "#+course: %^{Course code}\n#+due: %^{Due date}\n\n* Requirements\n%?\n\n* Notes\n\n* Resources\n\n"
           :target (file+head "${slug}.org"
                              "#+title: ${title}\n#+filetags: :source: :uni:\n#+date: %U\n")
           :unnarrowed t))))
