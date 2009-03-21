(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package :space-game.system)
    (defpackage :space-game.system
      (:use :common-lisp :asdf))))

(in-package :space-game.system)

(defsystem :space-game
  :description "space game"
  :author "Ryan Davis <ryan@acceleration.net>"
  :licence "LGPL (or talk to me)"
  :version "0.2"
  :depends-on (#:cl-who #:hunchentoot #:iterate #:alexandria)
  :components ((:module
		:src
		:components ((:file "packages")
			     (:file "model" :depends-on ("packages" "start"))
			     (:file "start" :depends-on ("packages"))
			     (:file "entry-points" :depends-on ("packages"))))))