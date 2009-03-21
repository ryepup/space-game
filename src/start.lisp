(in-package :space-game)

(defvar *acceptor*
  (make-instance 'hunchentoot:acceptor :port 4242))

(defun start ()
;;  (elephant:open-store '(:BDB "/home/ryan/clbuild/source/space-game/db/"))
  (hunchentoot:stop *acceptor*)
  (hunchentoot:start *acceptor*))