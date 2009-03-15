(in-package :space-game)

(defvar *game* (make-instance 'game))

(defclass named ()
  ((name :accessor name
	 :initarg :name
	 :initform nil)))

(defclass game ()
  ((turn :accessor turn :initarg :turn
	 :initform 0)
   (pending-orders :accessor pending-orders
		   :initform nil)))

(defun do-turn ()
  "processes all orders and advances the game to the next turn."
  (setf (pending-orders *game*) nil)
  (incf (turn *game*)))

(defclass ship (named)
  ((capacity :accessor capacity
	     :initarg :capacity)
   (cargo :accessor cargo
	  :initform nil)))

(defclass small-freighter (ship)
  ()
  (:default-initargs
      :capacity 10))

(defclass trade-good (named)
  ())

(defmethod print-object ((tg named) stream)
  (print-unreadable-object (tg stream :type t :identity t)
    (format stream "~a" (name tg))))

(defvar *goods* (make-objects "Trade Good" 'trade-good 10))

(defclass trade-good-price ()
  ((good :accessor good
	 :initarg :good)
   (price :accessor price
	  :initform (iter (for p = (- (random 100) 50))
			  (while (zerop p))
			  (finally (return p))
			  ))))

(defmethod print-object ((tg trade-good-price) stream)
  (print-unreadable-object (tg stream :type t :identity t)
    (format stream "~a at ~a" (name (good tg)) (price tg))))

(defclass planet (named)
  ((market-goods :accessor market-goods
		 :initform nil)))

(defmethod market-goods :around ((p planet))
  (let ((mg (call-next-method))
	(goods (copy-list *goods*)))
    (if mg mg
	(setf (market-goods p)
	      (iterate (for g from 0 to (random 5))
		       (let ((good (alexandria:random-elt goods)))
			 (setf goods (remove good goods))
			 (collect (make-instance 'trade-good-price
						 :good good))))))))

(defclass system (named)
  ((planets :accessor planets
	    :initform nil)
   (systems :accessor systems
	    :initform nil)))

(defun make-objects (class name &optional (n (random 5)))
  (iterate (for i from 0 to n)
	   (collect
	       (apply #'make-instance
		      (if name
			  (list class :name
				(format nil "~a ~a"
					name
					(incf (get class :count 0))))
			  (list class))))))

(defmethod systems :around ((s system))
  (let ((p (call-next-method)))
    (if p p
	(setf (systems s) (make-objects 'system "System")))))

(defmethod planets :around ((s system))
  (let ((p (call-next-method)))
    (if p p
	(setf (planets s) (make-objects 'planet "Planet")))))

(defclass player ()
  ((money :accessor money
	  :initarg :money
	  :initform 0)
   (ships :accessor ships
	  :initform (list (make-instance 'small-freighter)))
   (system :accessor system
	   :initform (make-instance 'system :name "Home"))))

(defmethod print-object ((p player) stream)
  (print-unreadable-object (p stream :type t :identity t)
    (format stream "~a money, ~a ships, in ~a"
	    (money p)
	    (length (ships p))
	    (system p))))

(defvar *player* (make-instance 'player :money 100))


(defmethod market-goods ((s system))
  (iter (for p in (planets s))
	(collect (list p (market-goods p)))))

(defmethod market-goods ((p player))
  (market-goods (system p)))

