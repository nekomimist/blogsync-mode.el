# blogsync-mode.el

## Example.

``` emacs-lisp
(use-package blogsync-mode
  :commands (blogsync-mode)
  :bind*
  (("C-c t" . helm-blogsync))
  :init
  (custom-set-variables
   '(blogsync-command "~/src/go/bin/blogsync.exe")
   '(blogsync-hatenablog-host "nekomimist.hatenablog.com"))
  :config
  (defun helm-blogsync ()
    (interactive)
    (helm-ag (expand-file-name blogsync-hatenablog-host
			       blogsync-rootdir))))
```
