(load "quicklisp.lisp")

(quicklisp-quickstart:install)

(print "Testing quicklisp")

(ql:quickload "vecto")

(ql:add-to-init-file)
