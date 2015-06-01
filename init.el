;;
;; Emacs kronos edition
;;
;; installation: brew install emacs --HEAD --use-git-head --with-cocoa --with-gnutls --with-rsvg --with-imagemagick

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

;; window size
(setq initial-frame-alist '((top . 0) (left . 0) (width . 235) (height . 68)))

;; disable audio bell
(setq ring-bell-function 'ignore)

;; fonts
(set-face-attribute 'default nil
                    :family "menlo"
                    :height 120
                    :weight 'normal
                    :width 'normal)
(when (functionp 'set-fontset-font)
  (set-fontset-font "fontset-default"
                    'unicode
                    (font-spec :family "menlo"
                               :width 'normal
                               :size 12
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

;; tell emacs to use system buffer
(setq x-select-enable-clipboard t)

;; sorry, no tabs
(setq-default indent-tabs-mode nil)

;; always referesh buffers from disk
(global-auto-revert-mode 1)

;; Не создавать фреймы при внешних вызовах ???
(setq ns-pop-up-frames nil)

;; ido
(ido-mode t)
(setq ido-auto-merge-work-directories-length -1)
(setq ido-case-fold t)
(ido-everywhere t)

;; notifications
(defun my/notification (text &optional title)
    (do-applescript
     (format "display notification \"%s\" with title \"%s\" sound name \"Ping\""
             text (if title title "Emacs"))))

;; el-get
(add-to-list 'load-path "~/.emacs.d/el-get/el-get")
(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.github.com/dimitri/el-get/master/el-get-install.el")
    (let (el-get-master-branch)
      (goto-char (point-max))
      (eval-print-last-sexp))))
(add-to-list 'el-get-recipe-path "~/.emacs.d/el-get-user/recipes")

;; packages
(setq el-get-sources
      '((:name elisp-slime-nav
               :type github
               :pkgname "purcell/elisp-slime-nav"
               :features elisp-slime-nav
               :after (progn
                        (add-hook 'emacs-lisp-mode-hook
                                  (lambda () (elisp-slime-nav-mode t)))))
        (:name cider
               :checkout "master")
        (:name clojure-mode
               :checkout "master")
        (:name smart-mode-line
               :type github
               :pkgname "Bruce-Connor/smart-mode-line"
               :features smart-mode-line)))
        ;; с официальным не совместим clj-refactor.el там куда то делся paredit-move-forward
        ;;(:name paredit
        ;;       :type github
        ;;       :pkgname "emacsmirror/paredit")

;; more packages
;; smex - command autocomlete
;; exec-path-from-shell - to make work nrepl
(setq dim-packages
      (append
       '(yasnippet smartparens flx smex rich-minority org-mode auto-complete undo-tree auto-complete ac-nrepl cl-lib multiple-cursors clj-refactor
                    rainbow-delimiters exec-path-from-shell)
       (mapcar 'el-get-as-symbol (mapcar 'el-get-source-name el-get-sources))))

(el-get 'sync dim-packages)

; flx-ido
(require 'flx)
(require 'flx-ido)
(flx-ido-mode 1)
;; disable ido faces to see flx highlights.
(setq ido-enable-flex-matching t)
(setq ido-use-faces nil)

;; smex
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)
(setq smex-save-file "~/.emacs.d/tmp/smex-items")

;; exec-path-from-shell
(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))

(require 'ob-clojure)
(setq org-babel-clojure-backend 'cider)

(org-babel-do-load-languages
 'org-babel-load-languages
 '(
   (clojure . t)
   ))

(setq org-src-fontify-natively t)
(setq org-confirm-babel-evaluate nil)

(add-hook 'cider-repl-mode-hook 'ac-nrepl-setup)
(add-hook 'cider-mode-hook 'ac-nrepl-setup)
(eval-after-load "auto-complete"
  '(add-to-list 'ac-modes 'cider-repl-mode))
(eval-after-load "cider"
  '(progn
     (define-key cider-repl-mode-map (kbd "C-c C-d") 'ac-nrepl-popup-doc)
     (define-key cider-mode-map (kbd "C-c C-d") 'ac-nrepl-popup-doc)))

(require 'auto-complete)

(ac-flyspell-workaround)

(global-auto-complete-mode t)
(setq ac-auto-show-menu t)
(setq ac-dwim t)
(setq ac-use-menu-map t)
(setq ac-quick-help-delay 1)
(setq ac-quick-help-height 60)
(setq ac-disable-inline t)
(setq ac-show-menu-immediately-on-auto-complete t)
(setq ac-auto-start nil)
(setq ac-candidate-menu-min 0)

(ac-set-trigger-key "TAB")

(dolist (mode '(magit-log-edit-mode log-edit-mode org-mode clojure-mode))
  (add-to-list 'ac-modes mode))

(defun my/nrepl-refresh ()
  (interactive)
  (set-buffer "*nrepl*")
  (goto-char (point-max))
  (insert "(clojure.tools.namespace.repl/refresh)")
  (nrepl-return))

(defun my/nrepl-reset ()
  (interactive)
  (save-some-buffers nil (lambda () (equal major-mode 'clojure-mode)))
  (cider-tooling-eval "((ns-resolve 'user.my 'reset))"
                      (cider-repl-handler (cider-current-repl-buffer))))

(defun my/nrepl-refresh ()
  (interactive)
  (save-some-buffers nil (lambda () (equal major-mode 'clojure-mode)))
  (cider-tooling-eval "(clojure.tools.namespace.repl/refresh)"
                      (cider-repl-handler (cider-current-repl-buffer))))

(defun my/cider-repl-mode-hooks ()
  (rainbow-delimiters-mode +1)
  (setq cider-repl-popup-stacktraces t)
  (define-key cider-mode-map (kbd "C-c C-n") 'my/nrepl-reset))

(defun my/cider-mode-hooks ()
  "Clojure specific setup code that should only be run when we
  have a CIDER REPL connection"
  (cider-turn-on-eldoc-mode)
  (define-key cider-repl-mode-map (kbd "C-c C-n") 'my/nrepl-reset)
  (define-key cider-repl-mode-map (kbd "C-c C-r") 'my/nrepl-refresh)
  (define-key cider-mode-map (kbd "C-c C-r") 'my/nrepl-refresh))

(add-hook 'cider-mode-hook
          'my/cider-mode-hooks)

(add-hook 'cider-repl-mode-hook
          'my/cider-repl-mode-hooks)

(add-hook 'clojure-mode-hook (lambda ()
                               (clj-refactor-mode 1)
(cljr-add-keybindings-with-prefix "C-c C-]")))

(require 'clojure-mode)
(define-clojure-indent

  ;;compojure
  (defroutes 'defun)
  (GET 2)
  (POST 2)
  (PUT 2)
  (DELETE 2)
  (HEAD 2)
  (ANY 2)
  (context 2)

  ;; http-kit
  (schedule-task 1)

  (go-loop 1)
  (thread-loop 1))

;; cider-repl
(add-to-list 'exec-path "/usr/local/bin")

;; Changes all yes/no questions to y/n type
(fset 'yes-or-no-p 'y-or-n-p)

;; No need for ~ files when editing
(setq create-lockfiles nil)

;; key bindings
(global-set-key (kbd "M-s") 'save-buffer)
(global-set-key (kbd "M-q") 'save-buffers-kill-terminal)

;; osx buttons
(setq mac-command-modifier 'meta)
(setq mac-option-modifier 'hyper)
(setq mac-right-option-modifier 'alt)

;; paredit
(require 'clojure-mode)
(require 'smartparens-config)
;(enable-paredit-mode)
;(add-hook 'clojure-mode-hook #'paredit-mode)
(add-hook 'clojure-mode-hook #'smartparens-strict-mode)
(smartparens-global-mode t)
(show-smartparens-global-mode t)
;; |foobar
;; hit C-(
;; becomes (|foobar)
(sp-pair "(" ")" :wrap "C-(")

;; projectile
(projectile-global-mode)


;; Show line numbers
(global-linum-mode)

;; scroll
(setq redisplay-dont-pause t
  scroll-margin 1
  scroll-step 1
  scroll-conservatively 10000
  scroll-preserve-screen-position 1)

;; save open buffers
;; Automatically save and restore sessions
(setq desktop-dirname             "~/.emacs.d/tmp/desktop/"
      desktop-base-file-name      "emacs.desktop"
      desktop-base-lock-name      "lock"
      desktop-path                (list desktop-dirname)
      desktop-save                t
      desktop-files-not-to-save   "^$" ;reload tramp paths
      desktop-load-locked-desktop nil)
(desktop-save-mode 1)

;; http://stackoverflow.com/questions/2706527/make-emacs-stop-asking-active-processes-exist-kill-them-and-exit-anyway
(defadvice save-buffers-kill-emacs (around no-query-kill-emacs activate)
  "Prevent annoying \"Active processes exist\" query when you quit Emacs."
  (flet ((process-list ())) ad-do-it))

;; no backup files
(setq make-backup-files nil)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages (quote (nil queue))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
