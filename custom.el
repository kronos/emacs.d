;;
;; Emacs kronos edition
;;
;; installation: brew install emacs --HEAD --use-git-head --with-cocoa --with-gnutls --with-rsvg --with-imagemagick

;; window size
(setq initial-frame-alist '((top . 0) (left . 0) (width . 235) (height . 68)))

;; disable audio bell
(setq ring-bell-function 'ignore)

;; fonts
(set-face-attribute 'default nil
                    :family "menlo"
                    :height 140
                    :weight 'normal
                    :width 'normal)
(when (functionp 'set-fontset-font)
  (set-fontset-font "fontset-default"
                    'unicode
                    (font-spec :family "menlo"
                               :width 'normal
                               :size 14
                               :weight 'normal)))

;; theme
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
(load-theme 'leuven t)

;; show position in footer
(setq column-number-mode t)

;; line-spacing
(setq-default line-spacing 2)

;; disable start screen
(setq inhibit-startup-screen +1)

;; backups
(setq backup-directory-alist `(("." . ,(concat user-emacs-directory "backups"))))
(setq auto-save-default nil)
