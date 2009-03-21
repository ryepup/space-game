(in-package :space-game)

(push
 (hunchentoot:create-folder-dispatcher-and-handler
  "/assets/" "/home/ryan/clbuild/source/space-game/www/" )
 hunchentoot:*dispatch-table*)

(hunchentoot:define-easy-handler (home :uri "/home") (name)
  (home-page name))

(hunchentoot:define-easy-handler (stop :uri "/stop") nil
  (hunchentoot:stop hunchentoot:*acceptor*))

(defmacro defhtmlfun (name (&rest args) &body body)
  `(defun ,name ,args
     (with-html-output (*standard-output* nil :indent t)
       ,@body)))

(defhtmlfun header ()
  (:head
   (:link :rel "stylesheet"
	  :href "/assets/css/smoothness/jquery-ui-1.7.1.custom.css")
   (:link :rel "stylesheet"
	  :href "/assets/css/jquery.jgrowl.css")
   (:link :rel "stylesheet"
	  :href "/assets/css/tablesorter.css")
   (:script :src "/assets/scripts/jquery-1.3.2.min.js")
   (:script :src "/assets/scripts/jquery.jgrowl_minimized.js")
   (:script :src "/assets/scripts/jquery.tablesorter.min.js")
   (:script :src "/assets/scripts/jquery-ui-1.7.1.custom.min.js")
   (:script :src "/assets/scripts/space-game.js")))

(defhtmlfun status-bar (&optional (player *player*))
  (:div :class "status-bar"
	(:span :class "money"
	       "Money:" (str (money player)))
	(:span :class "money"
	       "Ships:" (str (length (ships player))))
	(:span :class "money"
	       "Turn:" (str (turn *game*)))))

(defhtmlfun systems-tab ()
  (:div (fmt "info about ~a"
	     (name (system *player*))))
  (:h2 "Adjacent Systems")
  (:div :id "adjacent-systems"
	(iterate (for s in (systems *player*))
 
		 (htm
		  (:h3 (:a :href "#" (str (name s))))
		  (:div (:p (fmt "info about ~a" (name s))))
		  )))
  )

(defhtmlfun planets-tab ()
  (:table :id "trade-goods" :class "tablesorter"
	  (:thead
	   (:tr
	    (:th "Planet")
	    (:th "Good")
	    (:th "Produces")
	    (:th "Consumes")
	    (:th "Supply")
	    (:th "Price")))
	  (:tbody
	   (iterate (for (p goods) in (market-goods *player*))
		    (iterate (for g in goods)
			     (htm
			      (:tr
			       (:td (str (name p)))
			       (:td (str (name (good g))))
			       (:td (str (production g)))
			       (:td (str (consumption g)))
			       (:td (str (supply g)))
			       (:td (str (price g))))))))))
(defhtmlfun ships-tab ()
  (:table :id "ship-list" :class "tablesorter"
	  (:thead
	   (:tr
	    (:th "Class")
	    (:th "Name")
	    (:th "Capacity")
	    (:th "Cargo")))
	  (:tbody
	   (iterate
	     (for s in (ships *player*))
	     (htm
	      (:tr
	       (:td (str (class-name (class-of s))))
	       (:td (str (name s)))
	       (:td (str (capacity s)))
	       (:td (str (cargo-used s)))))))))

(defun home-page (name)
  (declare (ignore name))
  (with-html-output-to-string (*standard-output* nil
						 :prologue t
						 :indent t)
    (:html
     (header)
     (:body
      (:div :class "header"
	    (status-bar))
      (:div :id "tabs"
	    (:ul (:li (:a :href "#systems"		   
			  (fmt "System - ~a"
			       (name (system *player*)))))
		 (:li (:a :href "#planets"
			  (fmt "Planets - ~a"
			       (length (planets *player*)))))
		 (:li (:a :href "#ships"
			  (fmt "Ships - ~a"
			       (length (ships *player*)))))
		 (:li (:a :href "#orders"
			  "Pending orders -"
			  (:span :id "pending-order-count" "0"))))
	    (:div :id "systems"
		  (systems-tab))
	    (:div :id "planets"
		  (planets-tab))
	    (:div :id "ships"
		  (ships-tab))
	    (:div :id "orders"
		  "shows list of pending orders, with the 'turn' button."))))))
