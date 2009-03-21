(in-package :space-game)

(defun start ()
;;  (elephant:open-store '(:BDB "/home/ryan/clbuild/source/space-game/db/"))
  (hunchentoot:start (make-instance 'hunchentoot:acceptor :port 4242)))