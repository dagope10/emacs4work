;; ------------------------------------------------------------
;; UI básica
;; ------------------------------------------------------------
(global-display-line-numbers-mode 1)
(setq-default indent-tabs-mode nil)

(defun kill-hidden-buffers ()
  "Mata todos los buffers que no estén visibles en el frame actual."
  (interactive)
  (let ((visible-buffers
         (mapcar #'window-buffer (window-list))))
    (dolist (buf (buffer-list))
      (unless (memq buf visible-buffers)
        (kill-buffer buf)))))

(global-set-key (kbd "C-c b k") #'kill-hidden-buffers)
(setq dired-dwim-target t
      inhibit-startup-screen t
      initial-scratch-message nil
      use-short-answers t)



(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))

(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))

(when (fboundp 'menu-bar-mode)
  (menu-bar-mode -1))

(line-number-mode 1)
(column-number-mode 1)

;; No crear .#file lockfiles.
(setq create-lockfiles nil)

;; Fuente.

(set-face-attribute 'default nil
                    :family "Iosevka"
                    :height 200
                    :weight 'normal)

;; ------------------------------------------------------------
;; Backups / autosaves
;; ------------------------------------------------------------

;; Mantener backups y autosaves, pero fuera de los proyectos
;; y fuera del repo de configuración de Emacs.

(let* ((cache-home
        (file-name-as-directory
         (or (getenv "XDG_CACHE_HOME")
             (expand-file-name "~/.cache"))))
       (backup-dir
        (expand-file-name "emacs/backups/" cache-home))
       (autosave-dir
        (expand-file-name "emacs/autosave/" cache-home)))

  (make-directory backup-dir t)
  (make-directory autosave-dir t)

  (setq backup-directory-alist
        `(("." . ,backup-dir)))

  (setq auto-save-file-name-transforms
        `((".*" ,autosave-dir t)))

  (setq auto-save-list-file-prefix
        (expand-file-name ".saves-" autosave-dir)))


;; ------------------------------------------------------------
;; Custom
;; ------------------------------------------------------------

;; No dejar custom.el dentro del repo de configuración.

(let ((state-dir
       (expand-file-name
        "emacs/"
        (or (getenv "XDG_STATE_HOME")
            (expand-file-name "~/.local/state")))))

  (make-directory state-dir t)

  (setq custom-file
        (expand-file-name "custom.el" state-dir))

  (load custom-file 'noerror))

;; ------------------------------------------------------------
;; Paquetes
;; ------------------------------------------------------------

(require 'package)

(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")))
(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://melpa.org/packages/")))

(require 'use-package)

;; Todo paquete externo declarado con use-package se instala
;; automáticamente. Los built-in/locales llevan :ensure nil.
(setq use-package-always-ensure t)

;; ------------------------------------------------------------
;; Ace Window
;; ------------------------------------------------------------

(use-package ace-window
  :ensure t
  :bind ("M-o" . ace-window))


;; ------------------------------------------------------------
;; Tema
;; ------------------------------------------------------------

(add-to-list 'custom-theme-load-path
             (expand-file-name "themes" user-emacs-directory))

(load-theme 'mariana t)


;; ------------------------------------------------------------
;; Minibuffer / completion
;; ------------------------------------------------------------

(fido-vertical-mode 1)

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides
   '((file (styles partial-completion)))))

(use-package marginalia
  :init
  (marginalia-mode 1))

(which-key-mode 1)

(use-package consult
  :bind
  (("M-s l" . consult-line)
   ("M-s r" . consult-ripgrep)
   ("M-s f" . consult-find)
   ("M-g i" . consult-imenu)
   ("C-x b" . consult-buffer)))

(use-package avy
  :bind
  ("C-'" . avy-goto-char-timer))


;; ------------------------------------------------------------
;; Web Mode
;; ------------------------------------------------------------
(use-package web-mode
  :ensure t
  :mode ("\\.php\\'" . web-mode))

(setq web-mode-enable-auto-closing t
      web-mode-auto-close-style 2)



;; ------------------------------------------------------------
;; Compile
;; ------------------------------------------------------------

(setq compilation-scroll-output t)
(setq compilation-ask-about-save nil)

(global-set-key
 (kbd "C-c c")
 #'compile)

(global-set-key
 (kbd "C-c r")
 #'recompile)

(require 'ansi-color)

(add-hook
 'compilation-filter-hook
 #'ansi-color-compilation-filter)


;; ------------------------------------------------------------
;; Markdown
;; ------------------------------------------------------------

(use-package markdown-mode)


;; ------------------------------------------------------------
;; PDF
;; ------------------------------------------------------------

(use-package pdf-tools
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :magic ("%PDF" . pdf-view-mode)

  :config
  (pdf-tools-install :no-query)

  (setq-default pdf-view-display-size 'fit-page)
  (setq pdf-annot-activate-created-annotations t)

  :hook
  (pdf-view-mode . (lambda ()
                     (display-line-numbers-mode -1)
                     (blink-cursor-mode -1))))


(use-package pdf-view-restore
  :after pdf-tools
  :hook
  (pdf-view-mode . pdf-view-restore-mode))


;; ------------------------------------------------------------
;; Git
;; ------------------------------------------------------------

(use-package magit
  :bind
  ("C-x g" . magit-status))


;; ------------------------------------------------------------
;; Duplicate line
;; ------------------------------------------------------------

(global-set-key
 (kbd "C-,")
 #'duplicate-line)


;; ------------------------------------------------------------
;; Multiple cursors
;; ------------------------------------------------------------

(use-package multiple-cursors
  :bind
  (("C-c l"     . mc/edit-lines)
   ("C->"        . mc/mark-next-like-this)
   ("C-<"        . mc/mark-previous-like-this)
   ("C-c C-<"    . mc/mark-all-like-this)
   ("C-c C-SPC"  . mc/skip-to-next-like-this)
   ("C-S-<mouse-1>" . mc/add-cursor-on-click)))

;; ------------------------------------------------------------
;; Mover líneas
;; ------------------------------------------------------------

(defun my/move-line-up ()
  "Mueve la línea actual una posición hacia arriba."
  (interactive)
  (transpose-lines 1)
  (forward-line -2))

(defun my/move-line-down ()
  "Mueve la línea actual una posición hacia abajo."
  (interactive)
  (forward-line 1)
  (transpose-lines 1)
  (forward-line -1))

(global-set-key
 (kbd "C-S-p")
 #'my/move-line-up)

(global-set-key
 (kbd "C-S-n")
 #'my/move-line-down)


;; ------------------------------------------------------------
;; Projectile
;; ------------------------------------------------------------

(use-package projectile
  :init
  (projectile-mode 1)

  :bind-keymap
  ("C-c p" . projectile-command-map))

;; ------------------------------------------------------------
;; Surround
;; ------------------------------------------------------------
(use-package surround
  :ensure t
  :bind-keymap ("M-'" . surround-keymap))


;; ------------------------------------------------------------
;; Move to whitespaces
;; ------------------------------------------------------------

(defun previous-blank-line ()
  "Move to the previous blank line."
  (interactive)
  (forward-line -1)
  (when (re-search-backward "^[ \t]*$" nil t)
    (beginning-of-line)))

(defun next-blank-line ()
  "Move to the next blank line."
  (interactive)
  (forward-line 1)
  (when (re-search-forward "^[ \t]*$" nil t)
    (beginning-of-line)))

(global-set-key (kbd "M-n") #'next-blank-line)
(global-set-key (kbd "M-<down>") #'next-blank-line)
(global-set-key (kbd "M-p") #'previous-blank-line)
(global-set-key (kbd "M-<up>") #'previous-blank-line)

(split-window-right)


(global-set-key (kbd "M-o") #'ace-window)

