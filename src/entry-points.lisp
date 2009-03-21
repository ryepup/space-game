(in-package :space-game)

(hunchentoot:define-easy-handler (home :uri "/") (name)
  (home-page name)
  )

(defun home-page (name)
  (cl-who:with-html-output-to-string (*standard-output* nil
							:prologue t
							:indent t)
    (:html
     (:body
      (:p "here")
      
      )
     )
    )
  )