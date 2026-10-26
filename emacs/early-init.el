;;; early-init.el --- runs before package.el and the UI -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

;; Disable the default package manager 'package.el'. Setup 'straight.el' in its
;; place.
(setq package-enable-at-startup nil)
;; Bootstrap code taken from the documentation:
;; https://github.com/radian-software/straight.el#getting-started
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; use-package is built in from Emacs 29; older versions need to install.
(when (< emacs-major-version 29)
  (straight-use-package 'use-package))

;; Configure 'use-package' to install packages through 'straight.el'
(setq straight-use-package-by-default t)

;;; early-init.el ends here
