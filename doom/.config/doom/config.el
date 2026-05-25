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
          "~/Projects/org/uni-calendar.org"
          "~/Projects/org/references.org"))

  ;; Capture templates
  (setq org-capture-templates
        '(;; Quick inbox capture
          ("i" "Inbox" entry
           (file "~/Projects/org/inbox.org")
           "* %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n"
           :empty-lines 1)

          ;; Task with link to current buffer/file
          ("t" "Task (linked)" entry
           (file "~/Projects/org/inbox.org")
           "* TODO %?\n:PROPERTIES:\n:CREATED: %U\n:LINK: %a\n:END:\n"
           :empty-lines 1)

          ;; Calendar event / appointment
          ("c" "Calendar event" entry
           (file "~/Projects/org/calendar.org")
           "* %^{Event}\n%^{SCHEDULED}t\n:PROPERTIES:\n:CREATED: %U\n:END:\n%?"
           :empty-lines 1)

          ;; Reference / reading item
          ("r" "Reference to read" entry
           (file "~/Projects/org/references.org")
           "* TODO Read: %^{Title}\n:PROPERTIES:\n:CREATED: %U\n:URL: %^{URL (optional)}\n:END:\n%?"
           :empty-lines 1)

          ;; Uni assignment / problem
          ("u" "Uni task" entry
           (file+headline "~/Projects/org/projects.org" "University")
           "* TODO %^{Assignment}\n  DEADLINE: %^{Deadline}t\n:PROPERTIES:\n:COURSE: %^{Course}\n:CREATED: %U\n:END:\n%?"
           :empty-lines 1)

          ;; New project
          ("p" "Project" entry
           (file+headline "~/Projects/org/projects.org" "Active")
           "** %^{Project name} [/]\n:PROPERTIES:\n:GOAL: %^{Goal}\n:CREATED: %U\n:END:\n\n*** Tasks\n\n*** Notes\n%?"
           :empty-lines 1)

          ;; Email to follow up (works from mu4e!)
          ("e" "Email follow-up" entry
           (file "~/Projects/org/inbox.org")
           "* TODO Follow up: %a\n:PROPERTIES:\n:CREATED: %U\n:END:\n%?"
           :empty-lines 1)))

  ;; Refile targets
  (setq org-refile-targets
        '(("~/Projects/org/projects.org"   :maxlevel . 3)
          ("~/Projects/org/someday.org"    :maxlevel . 1)
          ("~/Projects/org/references.org" :maxlevel . 1)
          ("~/Projects/org/calendar.org"   :maxlevel . 1)
          (nil                             :maxlevel . 2))) ; current buffer

  (setq org-refile-use-outline-path 'file)
  (setq org-outline-path-complete-in-steps nil)
  (setq org-refile-allow-creating-parent-nodes 'confirm)

  ;; Agenda custom views
  (setq org-agenda-custom-commands
        '(("d" "Daily Dashboard"
           ((agenda "" ((org-agenda-span 1)
                        (org-agenda-start-with-log-mode t)))
            (todo "NEXT"
                  ((org-agenda-overriding-header "Next Actions")))
            (todo "WAITING"
                  ((org-agenda-overriding-header "Waiting For")))
            (tags-todo "+inbox"
                       ((org-agenda-overriding-header "Inbox (to refile)")))))

          ("w" "Weekly Review"
           ((agenda "" ((org-agenda-span 7)))
            (todo "TODO|NEXT"
                  ((org-agenda-overriding-header "All open tasks")))
            (todo "SOMEDAY"
                  ((org-agenda-overriding-header "Someday/Maybe")))))))

  ;; Logging & clocking
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  (setq org-clock-persist 'history)
  (org-clock-persistence-insinuate)

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

(after! org-gcal
  (setq org-gcal-file-alist
        ;; Map each calendar ID to an org file
        '(("mik.ziel7890@gmail.com" . "~/Projects/org/calendar.org")
          ("vr3ce5av1df5uj8et32gdoobuhrgv5eq@import.calendar.google.com" . "~/Projects/org/uni-calendar.org")
          ;; Add more calendars if you have them, e.g. uni calendar:
          ;; ("uni-calendar-id@group.calendar.google.com" . "~/Projects/org/calendar.org")
          ))

  ;; Auto-fetch when opening agenda
  (add-hook 'org-agenda-mode-hook #'org-gcal-fetch)

  ;; Auto-push when finishing a capture (new events go to Google Calendar)
  (add-hook 'org-capture-after-finalize-hook #'org-gcal-fetch)

  ;; Don't clutter the echo area with sync messages
  (setq org-gcal-notify-p nil))
