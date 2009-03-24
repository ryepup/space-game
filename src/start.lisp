(in-package :space-game)

(defcategory model)
(defcategory www)

(defvar *acceptor*
  (make-instance 'hunchentoot:acceptor :port 4242))

(defun start ()
;;  (elephant:open-store '(:BDB "/home/ryan/clbuild/source/space-game/db/"))
  (hunchentoot:stop *acceptor*)
  (start-stream-sender 'all *standard-output*
		     :category-spec '(dribble+)
		     :output-spec '(time category
				    context message))
  (hunchentoot:start *acceptor*)
  (log-for (www info) "acceptor started"))

