(in-package :space-game)

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

(defclass named ()
  ((name :accessor name
	 :initarg :name
	 :initform nil)))

(defclass game ()
  ((turn :accessor turn :initarg :turn
	 :initform 0)
   (pending-orders :accessor pending-orders
		   :initform nil)))

(defvar *game* (make-instance 'game))

(defun do-turn ()
  "processes all orders and advances the game to the next turn."
  (setf (pending-orders *game*) nil)
  (incf (turn *game*)))

(defclass ship (named)
  ((capacity :accessor capacity
	     :initarg :capacity)
   (cargo :accessor cargo
	  :initform nil)))

(defmethod print-object ((obj ship) stream)
  (print-unreadable-object (obj stream :type t :identity t)
    (format stream "cargo ~a / ~a"
	    (iter (for (q g p) in (cargo obj))
		  (summing q))
	    (capacity obj))))

(defclass small-freighter (ship)
  ()
  (:default-initargs
      :capacity 10))

(defclass trade-good (named)
  ())

(defmethod print-object ((tg named) stream)
  (print-unreadable-object (tg stream :type t :identity t)
    (format stream "~a" (name tg))))

(defvar *goods* (make-objects 'trade-good "Trade Good" 10))

(defclass trade-good-usage ()
  ((good :accessor good
	 :initarg :good)
   (consumption :accessor consumption
		:initarg :consumption
		:initform (random 10))
   (production :accessor production
	       :initarg :production
	       :initform (random 10))
   (supply :accessor supply
	   :initform (+ 50 (random 100)))))

(defmethod (setf supply) :before (new (obj trade-good-usage))
  (when (minusp new)
    (error "can't go into debt")))

(defmethod price ((obj trade-good-usage))
  (let ((usage-rate (- (production obj) (consumption obj))))
    (if (zerop usage-rate)
	(* 10.0 (/ (production obj) (supply obj)))
	(* 10.0 (/ usage-rate (supply obj))))))

(defmethod print-object ((tg trade-good-usage) stream)
  (print-unreadable-object (tg stream :type t :identity t)
    (format stream "~a (~a,+~a -~a) at ~a" (name (good tg))
	    (supply tg)
	    (production tg)
	    (consumption tg)
	    (price tg))))

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
			 (collect (make-instance 'trade-good-usage
						 :good good))))))))

(defclass system (named)
  ((planets :accessor planets
	    :initform nil)
   (systems :accessor systems
	    :initform nil)))

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

(defmethod (setf money) :before (new (obj player))
  (when (minusp new)
    (error "can't go into debt")))

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

(defmethod planets ((p player))
  (planets (system p)))

(defmethod systems ((p player))
  (systems (system p)))

(defmethod travel ((p player) (s system))
  (when (member s (systems p))
    (setf (system p) s)))

(defmethod cargo ((p player))
  (iterate (for s in (ships p))
	   (nconcing (cargo s))))

(defmethod buy-trade-good ((pl player) (tgu trade-good-usage) (s ship) quantity)
  (let ((price (* quantity (price tgu))))
    (decf (money pl) price)
    (decf (supply tgu) quantity)
    (push (list quantity (good tgu) (price tgu))
	  (cargo s))))

(defmethod sell-trade-good ((pl player) (tgu trade-good-usage) (s ship) quantity)
  (let ((price (* quantity (price tgu)))
	(cargo (find-if #'(lambda (cargo)
			    (eq (good tgu) (second cargo)))
			(cargo s))))
    (decf (money pl) price)
    (incf (supply tgu) quantity)
    (decf (first cargo) quantity)))
