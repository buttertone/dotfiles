;;; init.el --- Emacs user configuration -*- lexical-binding: t; -*-
;;; Commentary:
;; Emacs 27 introduced an additional configuration entrypoint in 'early-init.el'
;; to hook before the builtin package management and UI execute.

(setq-default fill-column 80)

;; Hooks for text editing modes
(dolist (hook-to-modify '(conf-mode-hook prog-mode-hook text-mode-hook))
  (dolist (fn-to-hook '(display-fill-column-indicator-mode display-line-numbers-mode hl-line-mode))
    (add-hook hook-to-modify fn-to-hook)))

;; Keep backups, auto-saves and lock files out of the directories being
;; edited (and out of git status).
(let ((auto-save-dir (expand-file-name "auto-save/" user-emacs-directory))
      (backup-dir (expand-file-name "backups/" user-emacs-directory))
      (lock-dir (expand-file-name "locks/" user-emacs-directory)))
  (make-directory auto-save-dir t)
  (make-directory backup-dir t)  
  (make-directory lock-dir t)
  (setq auto-save-file-name-transforms `((".*" ,auto-save-dir t))
	backup-directory-alist `(("." . ,backup-dir))
        lock-file-name-transforms `((".*" ,lock-dir t))))

;;; Packages

;; Git UI
(use-package magit
  :custom
  ;; magit-status takes over the whole frame; q puts the old layout back.
  (magit-display-buffer-function #'magit-display-buffer-fullframe-status-v1)
  (magit-bury-buffer-function #'magit-restore-window-configuration))

(use-package doom-themes
  :config
  (load-theme 'doom-nord-aurora t))

(use-package doom-modeline
  :init
  (doom-modeline-mode 1))

;; Vertical candidate list in the minibuffer (M-x, find-file, buffers).
(use-package vertico
  :init
  (vertico-mode 1))

;; Match space-separated pieces in any order ("file find" finds find-file).
;; Settings from its README: file names keep partial-completion so paths
;; like ~/d/dot expand; basic is the fallback.
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-pcm-leading-wildcard t))

;; Notes beside each candidate: key bindings, docstrings, file details.
(use-package marginalia
  :init
  (marginalia-mode 1))

;;; Org

;;   C-c c t  quick capture (TRIAGE)    C-c a r  everything still in TRIAGE
;;   C-c c w  detailed capture (TODO)   C-c a d  today's agenda, no TRIAGE
(use-package org
  ;; Built in; without this straight would fetch org from source.
  :straight (:type built-in)
  :bind (("C-c c" . org-capture)
         ("C-c a" . org-agenda))
  :custom
  (org-directory "~/org")
  (org-agenda-files '("~/org"))
  (org-todo-keywords
   '((sequence "TRIAGE(r)" "TODO(t)" "RELEASE(l)" "|" "DONE(d)")))
  ;; Relative file names resolve against `org-directory'.
  (org-capture-templates
   '(("t" "Triage (quick)" entry (file "inbox.org")
      "* TRIAGE %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n")
     ("w" "Work (detailed, scheduled)" entry (file "todo.org")
      "* TODO %^{Title}\nSCHEDULED: %^t\n:PROPERTIES:\n:CREATED: %U\n:END:\n%?")))
  (org-agenda-custom-commands
   '(("r" "Triage" todo "TRIAGE")
     ("d" "Today (no triage)" agenda ""
      ((org-agenda-span 'day)
       (org-agenda-skip-function
        '(org-agenda-skip-entry-if 'todo '("TRIAGE")))))))
  :config
  ;; Capture fails if the directory is missing.
  (make-directory org-directory t))

;;; UI mods

;; Window dividers as a continuous line (│ instead of |), without the
;; theme's background block. Runs after the theme so it isn't overridden.
(unless standard-display-table
  (setq standard-display-table (make-display-table)))
(set-display-table-slot standard-display-table 'vertical-border
                        (make-glyph-code ?│))
(set-face-attribute 'vertical-border nil :background 'unspecified)

;;; init.el ends here
