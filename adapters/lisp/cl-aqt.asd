;;;
;;; cl-aqt installer
;;;

(in-package #:cl-user)

(defpackage #:cl-aqt-system
  (:use #:cl
        #:asdf))

(in-package #:cl-aqt-system)

(defsystem #:cl-aqt
  :name "cl-aqt"
  :author "Hazen Babcock <hbabcockos1@mac.com>"
  :version "0.0.1"
  :description "Interface to the OS-X AquaTerm Graphics Terminal"
  :components ((:file "cl-aqt"))
  :depends-on (:uffi))