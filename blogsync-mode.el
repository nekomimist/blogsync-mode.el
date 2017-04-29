;;; blogsync-mode-mode.el --- mode for editing hatenablog & blogsync
;; Copyright 2017 Hiroyuki Ishikura. All rights reserved.
;; Use of this source code is governed by a BSD-style
;; license that can be found in the LICENSE file.

;;; Code:

;;;###autoload
(define-minor-mode blogsync-mode
 "handle hatenablog and blogsync" ;; DOC
 nil 				  ;; init-value
 " BS"				  ;; mode-line
 ;; keymap
 '(("\C-cn" . blogsync-post)
   ("\C-c\C-s" . blogsync-pull)
   ("\C-c\C-c" . blogsync-push)))
   
(defconst blogsync-mode-version "0.0" "the version of blogsync-mode")
(defgroup blogsync-mode nil "Top of blogsync-mode customization group."
  :group 'hypermedia)
(defcustom blogsync-command "~/src/go/bin/blogsync.exe"
  "The full-path name of Blogsync executable"
  :type 'filename
  :group 'blogsync-mode)
(defcustom blogsync-rootdir "~/blog/"
  "The root directory of blog."
  :type 'directory
  :group 'blogsync-mode)
(defcustom blogsync-hatenablog-host "nekomimist.hatenablog.com"
  "The hostname of your hatena blog"
  :type 'hostname
  :group 'blogsync-mode)

(defun blogsync--setup-exec ()
  (if (not (exec-installed-p (expand-file-name blogsync-command)))
      (error "blogsync-command is not properly set"))
  (if (get-process "blogsync")
      (delete-process "blogsync"))
  (with-current-buffer (get-buffer-create "*blogsync*")
    (erase-buffer))
  (display-buffer "*blogsync*"))

(defun blogsync-pull ()
  (interactive)
  "Execute blogsync push"
  (blogsync--setup-exec)
  (message "Blogsync pull")
  (save-excursion
    (cd (expand-file-name blogsync-rootdir))
    (apply (function call-process)
	   (expand-file-name blogsync-command)
	   nil "*blogsync*" t
	   (list "pull" blogsync-hatenablog-host)))
  (message "Blogsync pull ... done"))

(defun blogsync-post ()
  (interactive)
  "Execute blogsync post"
  (if (not (y-or-n-p "Create new hatenablog entry?"))
      (user-error "Abort"))
  (blogsync--setup-exec)
  (message "Blogsync push")
  (save-excursion
    (cd (expand-file-name blogsync-rootdir))
    (apply (function call-process)
	   (expand-file-name blogsync-command)
	   nil "*blogsync*" t
	   (list "post" blogsync-hatenablog-host "--draft"))
    (message "Blogsync post ... done"))
    (set-buffer "*blogsync*")
    (goto-char (point-max))
    (re-search-backward "store \\(.*\\)")
    (setq file (buffer-substring-no-properties
		(match-beginning 1) (match-end 1)))
    (find-file (expand-file-name file))
    (blogsync-mode))

(defun blogsync-push ()
  (interactive)
  "Execute blogsync push with current buffer"
  (blogsync--setup-exec)
  (save-current-buffer)
  (message "Blogsync push")
  (save-excursion
    (cd (expand-file-name blogsync-rootdir))
    (apply (function call-process-region)
	   (point-min) (point-max) ;; whole buffer
	   (expand-file-name blogsync-command)
	   nil "*blogsync*" t
	   (list "push" (buffer-file-name))))
  (message "Blogsync push ... done"))

(provide 'blogsync-mode)
