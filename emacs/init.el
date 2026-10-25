;;; init.el --- Emacs user configuration -*- lexical-binding: t; -*-
;;; Emacs 27 introduced an additional configuration entrypoint in
;;; 'early-init.el' to hook before the builtin package management and
;;; UI execute.

(setq-default fill-column 80)
(dolist (hook-to-modify '(conf-mode-hook prog-mode-hook text-mode-hook))
  (dolist (fn-to-hook '(display-fill-column-indicator-mode display-line-numbers-mode))
    (add-hook hook-to-modify fn-to-hook)))


;; Keep backups, auto-saves and lock files out of the directories being
;; edited (and out of git status).
(let ((dir (expand-file-name "auto-save/" user-emacs-directory)))
  (make-directory dir t)
  (setq auto-save-file-name-transforms `((".*" ,dir t))
        lock-file-name-transforms `((".*" ,dir t))))
(setq backup-directory-alist
      `(("." . ,(expand-file-name "backups/" user-emacs-directory))))

;;; init.el ends here
