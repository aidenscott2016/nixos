(require 'package)
(defvar package-list (list 'flycheck 'evil 'ledger-mode 'treemacs
		       'evil-leader 'treemacs 'treemacs-evil
		       'projectile 'undo-tree 'terraform-mode
		       'ido 'rainbow-delimiters 'evil-collection
		       'magit 'treemacs-projectile 'which-key
		       'format-all 'geiser-mit 'hydra 'paredit
		       'org-autolist 'ox-jira 'restclient 'tide
		       'ace-window 'company 'ag 'typescript-mode 'nix-mode))

;; (USEu-package ace-window
;;   :ensure t
;;   :init (setq
;; 	      aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)
;;               aw-char-position 'left
;;               aw-ignore-current nil
;;               aw-leading-char-style 'char
;; 	      aw-dispatch-always 't)
;;   :bind (("M-o" . ace-window)
;;          ("M-O" . ace-swap-window)))

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
  '(ansi-color-faces-vector
     [default default default italic underline success warning error])
  '(ansi-color-names-vector
     ["#242424" "#e5786d" "#95e454" "#cae682" "#8ac6f2" "#333366" "#ccaa8f" "#f6f3e8"])
  '(custom-enabled-themes '(tsdh-dark))
  '(evil-goto-definition-functions
     '(evil-goto-definition-imenu evil-goto-definition-semantic evil-goto-definition-xref evil-goto-definition-search tide-jump-to-definition))
  '(evil-undo-system 'undo-tree)
  '(format-all-default-formatters
     '(("Assembly" asmfmt)
	("ATS" atsfmt)
	("Bazel" buildifier)
	("BibTeX" emacs-bibtex)
	("C" clang-format)
	("C#" clang-format)
	("C++" clang-format)
	("Cabal Config" cabal-fmt)
	("Clojure" cljfmt)
	("CMake" cmake-format)
	("Crystal" crystal)
	("CSS" prettier)
	("Cuda" clang-format)
	("D" dfmt)
	("Dart" dart-format)
	("Dhall" dhall)
	("Dockerfile" dockfmt)
	("Elixir" mix-format)
	("Elm" elm-format)
	("Emacs Lisp" emacs-lisp)
	("F#" fantomas)
	("Fish" fish-indent)
	("Fortran Free Form" fprettify)
	("GLSL" clang-format)
	("Go" gofmt)
	("GraphQL" prettier)
	("Haskell" brittany)
	("HTML" html-tidy)
	("Java" clang-format)
	("JavaScript" prettier)
	("JSON" prettier)
	("Jsonnet" jsonnetfmt)
	("JSX" prettier)
	("Kotlin" ktlint)
	("LaTeX" latexindent)
	("Less" prettier)
	("Literate Haskell" brittany)
	("Lua" lua-fmt)
	("Markdown" prettier)
	("Nix" nixpkgs-fmt)
	("Objective-C" clang-format)
	("OCaml" ocp-indent)
	("Perl" perltidy)
	("PHP" prettier)
	("Protocol Buffer" clang-format)
	("PureScript" purty)
	("Python" black)
	("R" styler)
	("Reason" bsrefmt)
	("ReScript" rescript)
	("Ruby" rufo)
	("Rust" rustfmt)
	("Scala" scalafmt)
	("SCSS" prettier)
	("Shell" shfmt)
	("Solidity" prettier)
	("SQL" sqlformat)
	("Svelte" prettier)
	("Swift" swiftformat)
	("Terraform" terraform-fmt)
	("TOML" prettier)
	("TSX" prettier)
	("TypeScript" prettier)
	("V" v-fmt)
	("Verilog" istyle-verilog)
	("Vue" prettier)
	("XML" html-tidy)
	("YAML" prettier)
	("_Angular" prettier)
	("_Flow" prettier)
	("_Gleam" gleam)
	("_Ledger" ledger-mode)
	("_Nginx" nginxfmt)
	("_Snakemake" snakefmt)
	("Scheme" emacs-lisp)))
  '(format-all-show-errors 'never)
  '(ledger-reports
     '(("bal" "%(binary) -f %(ledger-file) -c bal Assets Liabilities")
	("reg" "%(binary) -f %(ledger-file) reg")
	("payee" "%(binary) -f %(ledger-file) reg @%(payee)")
	("account" "%(binary) -f %(ledger-file) reg %(account)")))
  '(package-selected-packages
     '(ag nix-mode yasnippet lsp-ui lsp-metals lsp-mode sbt-mode scala-mode htmlize restclient ox-jira flycheck ledger-mode evil))
  '(projectile-project-search-path '("~/src" "~/crap" "~/ledger"))
  '(warning-suppress-log-types
     '((comp)
	((package reinitialization))
	((package reinitialization))))
  '(warning-suppress-types
     '(((package reinitialization))
	((package reinitialization))
	((package reinitialization)))))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
  '(ledger-font-xact-highlight-face ((t (:weight ultra-bold))))
  '(terraform--resource-name-face ((t (:foreground "dark orange" :weight semi-bold)))))


(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)
;;(package-refresh-contents)

(global-set-key (kbd "C-c i")
  (lambda ()
    (interactive)
    (find-file "~/.emacs.d/init.el")))

(defun as/install-package (package)
  (unless (package-installed-p package)
    (package-install package))
  )

(defun as/install-packages (package-list)
  (dolist (p package-list)
    (as/install-package p)))

(as/install-packages package-list)


(defvar as/indent-width 2)
(setq ring-bell-function 'ignore
  default-directory "~/"
  help-window-select t
  backup-directory-alist `((".*" . ,temporary-file-directory))
  auto-save-file-name-transforms `((".*" ,temporary-file-directory t))
  evil-want-C-u-scroll t
  evil-shift-width as/indent-width
  evil-collection-setup-minibuffer t
  evil-want-keybinding nil
  lisp-indent-offset 2
  help-window-select t
  display-line-numbers 'relative
  display-line-numbers-type 'relative
  geiser-active-implementations '(mit)
  )


(require 'evil)
(when (require 'evil-collection nil t)
  (evil-collection-init))

(require 'treemacs)
(require 'treemacs-evil)
(require 'undo-tree)
(require 'terraform-mode)
(require 'display-line-numbers)
(require 'treemacs-projectile)
(require 'ox-jira)
(require 'typescript-mode)
(require 'tide)
(which-key-mode)
(global-undo-tree-mode)
(global-evil-leader-mode)
(global-display-line-numbers-mode)
(evil-mode 1)
(tool-bar-mode -1)
(menu-bar-mode -1)
(show-paren-mode 1)
(scroll-bar-mode -1)
(projectile-mode +1)
(global-company-mode +1)
(global-visual-line-mode +1)

					;(load-theme 'wombat)
(ido-mode +1)
(add-to-list 'auto-mode-alist '("\\.tf\\'" . terraform-mode))
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)
(add-hook 'prog-mode-hook 'format-all-mode)
(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(add-hook 'format-all-mode-hook 'format-all-ensure-formatter)

(evil-set-leader 'normal (kbd "SPC"))
(evil-define-key 'normal 'global (kbd "<leader>SPC") 'projectile-find-file-dwim)
(evil-define-key 'normal 'global (kbd "<leader>sp") 'projectile-ag)
(evil-define-key 'normal 'global (kbd "<leader>ir") 'indent-region)
(evil-define-key 'nil 'global (kbd "C-SPC") 'company-complete)
;;(evil-define-key 'normal 'global (kbd "q") 'delete-window)
(evil-define-key 'normal 'global (kbd "<leader>b") 'projectile-ibuffer)
(evil-define-key 'normal 'global (kbd "<leader>ib") 'ibuffer)
(evil-define-key 'normal 'global (kbd "<leader>p") 'treemacs)
(evil-define-key 'normal 'global (kbd "<leader>gg") 'magit)
(evil-define-key 'normal 'global (kbd "<leader>f") 'format-all-buffer)
(evil-define-key 'normal 'global (kbd "<leader>xb") 'eval-buffer)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
(evil-define-key 'normal 'global (kbd "<leader>w") 'ace-window)
(evil-define-key 'normal 'global (kbd "<leader>q") 'ace-delete-window)
(define-key projectile-mode-map (kbd "C-x d") 'dired-at-point)


;; linum
;; ace-windowq
;; kill window hotkey
;; treemacs-icons-dired

(add-hook 'ledger-mode-hook
  (lambda ()
    (defun bal-report ()
      (interactive)
      (ledger-report "bal" nil))

    (evil-define-key 'normal 'global (kbd "<leader>rb") 'bal-report)))
(evil-define-key 'normal 'global (kbd "<leader>cc") 'projectile-compile-project)

(ignore-errors
  (require 'ansi-color)
  (defun my-colorize-compilation-buffer ()
    (when (eq major-mode 'compilation-mode)
      (ansi-color-apply-on-region compilation-filter-start (point-max))))
  (add-hook 'compilation-filter-hook 'my-colorize-compilation-buffer))


(load "/home/aiden/.emacs.d/metals.el")

(add-hook 'org-mode-hook (lambda () (org-autolist-mode)))


(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1)
  ;; company is an optional dependency. You have to
  ;; install it separately via package-install
  ;; `M-x package-install [ret] company`
  (company-mode +1))

;; aligns annotation to the right hand side
(setq company-tooltip-align-annotations t)

;; formats the buffer before saving
(add-hook 'before-save-hook 'tide-format-before-save)

(add-hook 'typescript-mode-hook #'setup-tide-mode)
(setq-default ediff-forward-word-function 'forward-char)

(use-package nix-mode
  :mode "\\.nix\\'")


(require 'package)

;; Add melpa to your packages repositories
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

(package-initialize)

;; Install use-package if not already installed
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)

;; Enable defer and ensure by default for use-package
;; Keep auto-save/backup files separate from source code:  https://github.com/scalameta/metals/issues/1027
(setq use-package-always-defer t
  use-package-always-ensure t
  backup-directory-alist `((".*" . ,temporary-file-directory))
  auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))

;; Enable scala-mode for highlighting, indentation and motion commands
(use-package scala-mode
  :interpreter
  ("scala" . scala-mode))

;; Enable sbt mode for executing sbt commands
(use-package sbt-mode
  :commands sbt-start sbt-command
  :config
  ;; WORKAROUND: https://github.com/ensime/emacs-sbt-mode/issues/31
  ;; allows using SPACE when in the minibuffer
  (substitute-key-definition
    'minibuffer-complete-word
    'self-insert-command
    minibuffer-local-completion-map)
  ;; sbt-supershell kills sbt-mode:  https://github.com/hvesalai/emacs-sbt-mode/issues/152
  (setq sbt:program-options '("-Dsbt.supershell=false"))
  )

;; Enable nice rendering of diagnostics like compile errors.
(use-package flycheck
  :init (global-flycheck-mode))

(use-package lsp-mode
  ;; Optional - enable lsp-mode automatically in scala files
  :hook  (scala-mode . lsp)
  (lsp-mode . lsp-lens-mode)
  :config
  ;; Uncomment following section if you would like to tune lsp-mode performance according to
  ;; https://emacs-lsp.github.io/lsp-mode/page/performance/
  ;;       (setq gc-cons-threshold 100000000) ;; 100mb
  ;;       (setq read-process-output-max (* 1024 1024)) ;; 1mb
  ;;       (setq lsp-idle-delay 0.500)
  ;;       (setq lsp-log-io nil)
  ;;       (setq lsp-completion-provider :capf)
  (setq lsp-prefer-flymake nil))

;; Add metals backend for lsp-mode
(use-package lsp-metals)

;; Enable nice rendering of documentation on hover
;;   Warning: on some systems this package can reduce your emacs responsiveness significally.
;;   (See: https://emacs-lsp.github.io/lsp-mode/page/performance/)
;;   In that case you have to not only disable this but also remove from the packages since
;;   lsp-mode can activate it automatically.
(use-package lsp-ui)

;; lsp-mode supports snippets, but in order for them to work you need to use yasnippet
;; If you don't want to use snippets set lsp-enable-snippet to nil in your lsp-mode settings
;;   to avoid odd behavior with snippets and indentation
(use-package yasnippet)

;; Use company-capf as a completion provider.
;;
;; To Company-lsp users:
;;   Company-lsp is no longer maintained and has been removed from MELPA.
;;   Please migrate to company-capf.
(use-package company
  :hook (scala-mode . company-mode)
  :config
  (setq lsp-completion-provider :capf))

;; Use the Debug Adapter Protocol for running tests and debugging
(use-package posframe
  ;; Posframe is a pop-up tool that must be manually installed for dap-mode
  )
(use-package dap-mode
  :hook
  (lsp-mode . dap-mode)
  (lsp-mode . dap-ui-mode)
  )


(setq-default mode-line-buffer-identification
  (list 'buffer-file-name
    (propertized-buffer-identification "%12f")
    (propertized-buffer-identification "%12b")))

(global-set-key (kbd "C-c ") #'org-store-link)

(require 'nix-mode)
(add-to-list 'auto-mode-alist '("\\.nix\\'" . nix-mode))
