;;; init.el --- Emacs user configuration -*- lexical-binding: t; -*-
;;; Commentary:
;; Emacs 27 introduced an additional configuration entrypoint in 'early-init.el'
;; to hook before the builtin package management and UI execute.

(setq-default fill-column 80)

;; Hooks for text editing modes
(dolist (hook-to-modify '(conf-mode-hook prog-mode-hook text-mode-hook))
  (dolist (fn-to-hook '(display-fill-column-indicator-mode display-line-numbers-mode))
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
(use-package magit)

;;; init.el ends here
