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
(setq org-directory "~/Projects/org/")
(setq org-roam-directory "~/Projects/org/notes/")

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

;; Search path for Projectile
(setq projectile-project-search-path '("~/Projects"))

(after! org
  ;; TODO states
  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "WAITING(w@/!)" "SOMEDAY(s)"
           "|" "DONE(d!)" "CANCELLED(c@)")))

  (setq org-todo-keyword-faces
        '(("TODO"      . (:foreground "#ed8796" :weight bold))
          ("NEXT"      . (:foreground "#8aadf4" :weight bold))
          ("WAITING"   . (:foreground "#f5a97f" :weight bold))
          ("SOMEDAY"   . (:foreground "#a5adcb"))
          ("DONE"      . (:foreground "#a6da95"))
          ("CANCELLED" . (:foreground "#6e738d" :strike-through t))))

  ;; Agenda files
  (setq org-agenda-files
        '("~/Projects/org/inbox.org"
          "~/Projects/org/projects.org"
          "~/Projects/org/calendar.org"
          "~/Projects/org/uni.org"
          "~/Projects/org/tasks.org"))

  ;; Capture templates
  (setq org-capture-templates
        '(;; Quick inbox capture
          ("i" "Inbox" entry
           (file "~/Projects/org/inbox.org")
           "* %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n"
           :empty-lines 1)

          ;; Task with link to current buffer/file
          ("t" "Task (linked" entry
           (file "~/Projects/org/inbox.org")
           "* TODO %?\n:PROPERTIES:\n:CREATED: %U\n:LINK: %a\n:END:\n"
           :empty-lines 1)

          ;; Calendar event / appointment
          ("c" "Calendar event" entry
           (file "~/Projects/org/calendar.org")
           "* %?\n:PROPERTIES:\n:calendar-id:\tmik.ziel7890@gmail.com\n:END:\n:org-gcal:\n%^T--%^T\n:END:\n\n"
           :empty-lines 1
           :jump-to-captured t)

          ;; New project
          ("p" "Project" entry
           (file "~/Projects/org/projects.org")
           "** %^{Project name}\n:PROPERTIES:\n:GOAL: %^{Goal}\n:CREATED: %U\n:END:\n\n*** Tasks [/]\n\n*** Notes\n%?"
           :empty-lines 1)))

  ;; Refile targets
  (setq org-refile-targets
        '(("~/Projects/org/projects.org"   :maxlevel . 3)
          ("~/Projects/org/calendar.org"   :maxlevel . 1)
          ("~/Projects/org/tasks.org"      :maxlevel . 2)
          ("~/Projects/org/uni.org"        :maxlevel . 3)
          (nil                             :maxlevel . 2))) ; current buffer

  (setq org-refile-use-outline-path 'file)
  (setq org-outline-path-complete-in-steps nil)
  (setq org-refile-allow-creating-parent-nodes 'confirm)

  ;; Agenda custom views
  (setq org-agenda-custom-commands
        '(("a" "Main Dashboard"
           ((agenda "" ((org-agenda-span 3)
                        (org-deadline-warning-days 7)
                        (org-agenda-start-with-log-mode t)
                        (org-agenda-start-day "+0d")))
            (todo "NEXT"
                  ((org-agenda-overriding-header "Next Tasks")))
            (todo "WAITING"
                  ((org-agenda-overriding-header "Waiting")))))))

  ;; Visual tweaks
  (setq org-startup-indented t)
  (setq org-hide-leading-stars t)
  (setq org-startup-folded 'overview))

;; Org Roam capture templates
(after! org-roam
  (setq org-roam-capture-templates
        '(("k" "Knowledge" plain
           "* %?\n\n* Links\n\n"
           :target (file+head "${slug}.org"
                              ":PROPERTIES:\n:ROAM_ALIASES: %^{Aliases (optional)}\n:END:\n#+title: ${title}\n#+filetags: :knowledge:\n#+date: %U\n\n")
           :unnarrowed t))))

;; Email integration
(after! mu4e
  (setq mu4e-maildir "~/.mail"
        mu4e-get-mail-command "mbsync -a"   ; or offlineimap
        mu4e-update-interval 300            ; fetch every 5 min
        mu4e-compose-reply-to-address "your@email.com"
        user-mail-address "your@email.com"
        user-full-name "Your Name"

        ;; Gmail-style folder mapping (adjust for your provider)
        mu4e-sent-folder   "/gmail/[Gmail]/Sent Mail"
        mu4e-drafts-folder "/gmail/[Gmail]/Drafts"
        mu4e-trash-folder  "/gmail/[Gmail]/Trash"
        mu4e-refile-folder "/gmail/[Gmail]/All Mail"

        ;; Show related messages in a thread
        mu4e-headers-include-related t
        mu4e-headers-skip-duplicates t

        ;; When reading a message, capture a follow-up with 'C'
        ;; The "e" capture template above handles this
        mu4e-org-link-query-in-headers-mode t)

  ;; Quick actions from mu4e headers/view with 'C'
  (add-to-list 'mu4e-headers-actions
               '("capture as task" . mu4e-action-capture-message) t)
  (add-to-list 'mu4e-view-actions
               '("capture as task" . mu4e-action-capture-message) t))

;; Google calendar integration
(load! "private/org-gcal-credentials" doom-user-dir t)

;; (setq epg-pinentry-mode 'loopback)

(require 'plstore)

(defconst my/org-gcal-gpg-key "1240EFCC8C3F4169FD2C5FD06552193223994A93")

(add-to-list 'plstore-encrypt-to my/org-gcal-gpg-key)

(after! org-gcal
  (setq org-gcal-file-alist
        ;; Map each calendar ID to an org file
        '(("mik.ziel7890@gmail.com" . "~/Projects/org/calendar.org")
          ("vr3ce5av1df5uj8et32gdoobuhrgv5eq@import.calendar.google.com" . "~/Projects/org/uni.org")
          ("73b7c6e8f32a5f4515186d17e7cf8a0ef1585896599b86b229e0b81ca6dca24d@group.calendar.google.com" . "~/Projects/org/projects.org")
          ("a3cba964df8556d8fb9626f91b0ebeb32fd76d1376c298d164626c55dd8d92bb@group.calendar.google.com" . "~/Projects/org/uni.org")
          ("31078d7ee71b401e10fd9253b1f62e3b52fdb6af587e4d4eb5e16c0cf8af8bfd@group.calendar.google.com" . "~/Projects/org/tasks.org")
          ;; Add more calendars if you have them, e.g. uni calendar:
          ;; ("uni-calendar-id@group.calendar.google.com" . "~/Projects/org/calendar.org")
          )))

(map! :leader
      :desc "Org-gcal sync"       "G s" #'org-gcal-sync
      :desc "Org-gcal fetch"      "G f" #'org-gcal-fetch)

(map! :map org-mode-map
      :localleader
      :desc "Org-gcal post point" "G p" #'org-gcal-post-at-point)
