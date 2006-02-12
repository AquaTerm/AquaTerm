;;;;
;;;; Wrapper for the aquaterm graphics terminal. Uses UFFI
;;;; to interface to the C sub-routines defined in aquaterm.h 
;;;;
;;;; hazen 1/05
;;;;

; loads uffi
(eval-when (:compile-toplevel :load-toplevel :execute)
  (require :uffi))

(defpackage :cl-aqt
  (:use :common-lisp
	:uffi)
  (:export :aqt-init
	   :aqt-terminate
	   :aqt-open-plot
	   :aqt-select-plot
	   :aqt-set-plot-size
	   :aqt-set-plot-title
	   :aqt-render-plot
	   :aqt-clear-plot
	   :aqt-close-plot
	   :aqt-set-accepting-events
	   :aqt-get-last-event
	   :aqt-wait-next-event
	   :aqt-set-clip-rect
	   :aqt-set-default-clip-rect
	   :aqt-colormap-size
	   :aqt-set-colormap-entry
	   :aqt-get-colormap-entry
	   :aqt-take-color-from-colormap-entry
	   :aqt-take-background-color-from-colormap-entry
	   :aqt-set-color
	   :aqt-set-background-color
	   :aqt-get-color
	   :aqt-get-background-color
	   :aqt-set-fontname
	   :aqt-set-fontsize
	   :aqt-add-label
	   :aqt-add-sheared-label
	   :aqt-set-linewidth
	   :aqt-set-linestyle-pattern
	   :aqt-set-linestyle-solid
	   :aqt-set-line-cap-style
	   :aqt-move-to
	   :aqt-add-line-to
	   :aqt-add-polyline
	   :aqt-move-to-vertex
	   :aqt-add-edge-to-vertex
	   :aqt-add-polygon
	   :aqt-add-filled-rect
	   :aqt-erase-rect
	   :aqt-set-image-transform
	   :aqt-reset-image-transform
	   :aqt-add-image-with-bitmap
	   :aqt-add-transformed-image-with-bitmap
	   :with-aqt-plot))

(in-package :cl-aqt)

;(load-foreign-library #p"libmysqlclient.so" :module "mysql" :supporting-libraries '("c")) 

;; this is called during compilation to load libaquaterm

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun load-aquaterm-lib ()
    "finds and loads libaquaterm"
    (let ((aqt-lib-name (find-foreign-library "libaquaterm" (list "/usr/local/lib/" "/sw/lib/"))))
      (load-foreign-library aqt-lib-name :module "cl-aqt")))
  (load-aquaterm-lib))


;;; aquaterm API

;; helper functions

(defun extract-rgb (func)
  "generic rgb extraction function"
  (let ((r 0.0)
	(g 0.0)
	(b 0.0))
    (with-foreign-object (red :float)
      (with-foreign-object (grn :float)
	(with-foreign-object (blue :float)
	  (funcall func red grn blue)
	  (setf r (deref-pointer red :float)
		g (deref-pointer grn :float)
		b (deref-pointer blue :float)))))
    (values r g b)))

(defun extract-event (func)
  "generic event abstraction"
  (let ((c-event (allocate-foreign-string 30))
	(event nil))
    (funcall func c-event)
    (setf event (convert-from-foreign-string c-event))
    (free-foreign-object c-event)
    event))

(defun make-c-float-array (vec)
  "converts a vector into an a c array, returns the array"
  (let* ((len (length vec))
	 (c-arr (allocate-foreign-object :float len)))
    (dotimes (i len)
      (setf (deref-array c-arr :float i) (float (aref vec i))))
    c-arr))

(defun generic-poly-line (func x y)
  "generic polyline / polygon drawing"
  (let ((xv (make-c-float-array x))
	(yv (make-c-float-array y)))
    (funcall func xv yv (length x))
    (free-foreign-object xv)
    (free-foreign-object yv)))

(defun make-c-bitmap (bitmap)
  "converts a n x m x 3 array into a void pointer to a c bitmap"
  (let* ((x-dim (array-dimension bitmap 0))
	 (y-dim (array-dimension bitmap 1))
	 (bmp-size (array-total-size bitmap))
	 (c-bmp (allocate-foreign-object :unsigned-byte bmp-size)))
    (dotimes (x x-dim)
      (dotimes (y y-dim)
	(dotimes (col 3)
	  (setf (deref-array c-bmp :unsigned-byte (+ (* 3 x-dim y) (* 3 x) col)) (aref bitmap x y col)))))
    c-bmp))

(defun generic-bitmap (func bitmap)
  "generic bitmap display"
  (let ((pW (array-dimension bitmap 0))
	(pH (array-dimension bitmap 1))
	(c-bmp (make-c-bitmap bitmap)))
    (with-cast-pointer (voidptr c-bmp :pointer-void)
      (funcall func voidptr pW pH))
    (free-foreign-object c-bmp)))


;; API functions

(def-function ("aqtInit" aqt-init)
    nil
  :returning :int
  :module "cl-aqt")

(def-function ("aqtTerminate" aqt-terminate)
    nil
  :returning :void
  :module "cl-aqt")

(def-function ("aqtOpenPlot" aqt-open-plot)
    ((refNum :int))
  :returning :void
  :module "cl-aqt")

(def-function ("aqtSelectPlot" aqt-select-plot)
    ((refNum :int))
  :returning :int
  :module "cl-aqt")

(def-function ("aqtSetPlotSize" aqt-set-plot-size)
    ((width :float)
     (height :float))
  :returning :void
  :module "cl-aqt")

(def-function ("aqtSetPlotTitle" c-aqt-set-plot-title)
    ((title :cstring))
  :returning :void
  :module "cl-aqt")

(defun aqt-set-plot-title (title)
  "wrapper for aqtSetPlotTitle"
  (with-cstring (c-title title)
    (c-aqt-set-plot-title c-title)))

(def-function ("aqtRenderPlot" aqt-render-plot)
    nil
  :returning :void
  :module "cl-aqt")

(def-function ("aqtClearPlot" aqt-clear-plot)
    nil
  :returning :void
  :module "cl-aqt")

(def-function ("aqtClosePlot" aqt-close-plot)
    nil
  :returning :void
  :module "cl-aqt")

(def-function ("aqtSetAcceptingEvents" aqt-set-accepting-events)
    ((flag :int))
  :returning :void
  :module "cl-aqt")

(def-function ("aqtGetLastEvent" c-aqt-get-last-event)
    ((buffer :cstring))
  :returning :int
  :module "cl-aqt")

(defun aqt-get-last-event ()
  "wrapper for aqtGetLastEvent"
  (extract-event #'(lambda (event)
		     (c-aqt-wait-next-event event))))

(def-function ("aqtWaitNextEvent" c-aqt-wait-next-event)
    ((buffer (* :unsigned-char)))
  :returning :int
  :module "cl-aqt")

(defun aqt-wait-next-event ()
  "wrapper for aqtWaitNextEvent"
  (extract-event #'(lambda (event)
		     (c-aqt-wait-next-event event))))

(def-function ("aqtSetClipRect" aqt-set-clip-rect)
    ((originX :float)
     (originY :float)
     (width :float)
     (height :float))
  :returning :void
  :module "cl-aqt")

(def-function ("aqtSetDefaultClipRect" aqt-set-default-clip-rect)
    nil
  :returning :void
  :module "cl-aqt")

(def-function ("aqtColormapSize" aqt-colormap-size)
    nil
  :returning :int
  :module "cl-aqt")

(def-function ("aqtSetColormapEntry" aqt-set-colormap-entry)
    ((entryIndex :int)
     (r :float)
     (g :float)
     (b :float))
  :returning :void
  :module "cl-aqt")

(def-function ("aqtGetColormapEntry" c-aqt-get-colormap-entry)
    ((entryIndex :int)
     (r (* :float))
     (g (* :float))
     (b (* :float)))
  :returning :void
  :module "cl-aqt")

(defun aqt-get-colormap-entry (entry-index)
  "wrapper for aqtGetColormapEntry"
  (extract-rgb #'(lambda (r g b)
		   (c-aqt-get-colormap-entry entry-index r g b))))

(def-function ("aqtTakeColorFromColormapEntry" aqt-take-color-from-colormap-entry)
    ((index :int))
  :returning :void
  :module "cl-aqt")

(def-function ("aqtTakeBackgroundColorFromColormapEntry" aqt-take-background-color-from-colormap-entry)
    ((index :int))
  :returning :void
  :module "cl-aqt")

(def-function ("aqtSetColor" aqt-set-color)
    ((r :float)
     (g :float)
     (b :float))
  :returning :void
  :module "cl-aqt")

(def-function ("aqtSetBackgroundColor" aqt-set-background-color)
    ((r :float)
     (g :float)
     (b :float))
  :returning :void
  :module "cl-aqt")

(def-function ("aqtGetColor" c-aqt-get-color)
    ((r (* :float))
     (g (* :float))
     (b (* :float)))
  :returning :void
  :module "cl-aqt")

(defun aqt-get-color ()
  "wrapper for aqtGetColor"
  (extract-rgb #'(lambda (r g b)
		   (c-aqt-get-color r g b))))

(def-function ("aqtGetBackgroundColor" c-aqt-get-background-color)
    ((r (* :float))
     (g (* :float))
     (b (* :float)))
  :returning :void
  :module "cl-aqt")

(defun aqt-get-background-color ()
  "wrapper for aqtGetColor"
  (extract-rgb #'(lambda (r g b)
		   (c-aqt-get-background-color r g b))))

(def-function ("aqtSetFontname" aqt-set-fontname)
    ((newFontname :cstring))
  :returning :void
  :module "cl-aqt")

(def-function ("aqtSetFontsize" aqt-set-fontsize)
    ((newFontsize :float))
  :returning :void
  :module "cl-aqt")

(def-function ("aqtAddLabel" c-aqt-add-label)
    ((text :cstring)
     (x :float)
     (y :float)
     (angle :float)
     (align :int))
  :returning :void
  :module "cl-aqt")

(defun aqt-add-label (title x y angle align)
  "wrapper for aqtAddLabel"
  (with-cstring (c-title title)
    (c-aqt-add-label c-title x y angle align)))

(def-function ("aqtAddShearedLabel" c-aqt-add-sheared-label)
    ((text :cstring)
     (x :float)
     (y :float)
     (angle :float)
     (shearAngle :float)
     (align :int))
  :returning :void
  :module "cl-aqt")

(defun aqt-add-sheared-label (title x y angle shearAngle align)
  "wrapper for aqtAddShearedLabel"
  (with-cstring (c-title title)
    (c-aqt-add-sheared-label c-title x y angle shearAngle align)))

(def-function ("aqtSetLinewidth" aqt-set-linewidth)
    ((newLinewidth :float))
  :returning :void
  :module "cl-aqt")

(def-function ("aqtSetLinestylePattern" c-aqt-set-linestyle-pattern)
    ((newPattern (* :float))
     (newCount :int)
     (newPhase :float))
  :returning :void
  :module "cl-aqt")

(defun aqt-set-linestyle-pattern (pat phase)
  "wrapper for aqtSetLinestylePattern, pat should be an array of floats"
  (let ((c-pat (make-c-float-array pat)))
    (c-aqt-set-linestyle-pattern c-pat (length pat) (float phase))
    (free-foreign-object c-pat)))

(def-function ("aqtSetLinestyleSolid" aqt-set-linestyle-solid)
    nil
  :returning :void
  :module "cl-aqt")

(def-function ("aqtSetLineCapStyle" aqt-set-line-cap-style)
    ((capStyle :int))
  :returning :void
  :module "cl-aqt")

(def-function ("aqtMoveTo" aqt-move-to)
    ((x :float)
     (y :float))
  :returning :void
  :module "cl-aqt")

(def-function ("aqtAddLineTo" aqt-add-line-to)
    ((x :float)
     (y :float))
  :returning :void
  :module "cl-aqt")

(def-function ("aqtAddPolyline" c-aqt-add-polyline)
    ((x (* :float))
     (y (* :float))
     (pointCount :int))
  :returning :void
  :module "cl-aqt")

(defun aqt-add-polyline (x y)
  "wrapper for aqtAddPolyLine"
  (generic-poly-line #'(lambda (xv yv l)
			 (c-aqt-add-polyline xv yv l))
		     x y))

(def-function ("aqtMoveToVertex" aqt-move-to-vertex)
    ((x :float)
     (y :float))
  :returning :void
  :module "cl-aqt")

(def-function ("aqtAddEdgeToVertex" aqt-add-edge-to-vertex)
    ((x :float)
     (y :float))
  :returning :void
  :module "cl-aqt")

(def-function ("aqtAddPolygon" c-aqt-add-polygon)
    ((x (* :float))
     (y (* :float))
     (pointCount :int))
  :returning :void
  :module "cl-aqt")

(defun aqt-add-polygon (x y)
  "wrapper for aqtAddPolygon"
  (generic-poly-line #'(lambda (xv yv l)
			 (c-aqt-add-polygon xv yv l))
		     x y))

(def-function ("aqtAddFilledRect" aqt-add-filled-rect)
    ((originX :float)
     (originY :float)
     (width :float)
     (height :float))
  :returning :void
  :module "cl-aqt")

(def-function ("aqtEraseRect" aqt-erase-rect)
    ((originX :float)
     (originY :float)
     (width :float)
     (height :float))
  :returning :void
  :module "cl-aqt")

(def-function ("aqtSetImageTransform" aqt-set-image-transform)
    ((m11 :float)
     (m12 :float)
     (m21 :float)
     (m22 :float)
     (tX :float)
     (tY :float))
  :returning :void
  :module "cl-aqt")

(def-function ("aqtResetImageTransform" aqt-reset-image-transform)
    nil
  :returning :void
  :module "cl-aqt")

(def-function ("aqtAddImageWithBitmap" c-aqt-add-image-with-bitmap)
    ((bitmap :pointer-void)
     (pixWide :int)
     (pixHigh :int)
     (destX :float)
     (destY :float)
     (destWidth :float)
     (destHeight :float))
  :returning :void
  :module "cl-aqt")

(defun aqt-add-image-with-bitmap (bitmap destX destY destWidth destHeight)
  "wrapper for aqtAddImageWithBitmap"
  (generic-bitmap #'(lambda (voidp pW pH)
		      (c-aqt-add-image-with-bitmap voidp pW pH destX destY destWidth destHeight))
		  bitmap))
      
(def-function ("aqtAddTransformedImageWithBitmap" c-aqt-add-transformed-image-with-bitmap)
    ((bitmap :pointer-void)
     (pixWide :int)
     (pixHigh :int)
     (clipX :float)
     (clipY :float)
     (clipWidth :float)
     (clipHeight :float))
  :returning :void
  :module "cl-aqt")

(defun aqt-add-transformed-image-with-bitmap (bitmap clipX clipY clipWidth clipHeight)
  "wrapper for aqtAddTransformedImageWithBitmap"
  (generic-bitmap #'(lambda (voidp pW pH)
		      (c-aqt-add-transformed-image-with-bitmap voidp pW pH clipX clipY clipWidth clipHeight))
		  bitmap))

(defmacro with-aqt-plot ((title width height &optional (ref-num 1)) &rest body)
  "wraps user plotting commands inside plot creation, rendering & closing"
  `(progn
     (aqt-init)
     (aqt-open-plot (round ,ref-num))
     (aqt-set-plot-size (float ,width) (float ,height))
     (aqt-set-plot-title ,title)
     ,@body
     (aqt-render-plot)
     (aqt-close-plot)))

;;; testing

(defun test-aqt ()
  (with-cstring (c-title "test")
    (aqt-init)
    (aqt-open-plot 1)
    (aqt-set-plot-size 100.0 100.0)
    (aqt-set-plot-title c-title)
    (aqt-move-to 10.0 10.0)
    (aqt-add-line-to 90.0 90.0)
    (aqt-render-plot)
    (aqt-close-plot)
    (aqt-terminate)))

(defun start-aqt ()
  (with-cstring (c-title "test2")
    (aqt-init)
    (aqt-open-plot 2)
    (aqt-set-plot-size 100.0 100.0)
    (aqt-set-plot-title c-title)
    (aqt-render-plot)))

(defun test-get ()
  (let ((r 0.2)
	(g 0.2)
	(b 0.2))
    (aqt-get-color)
    (format t "~A ~A ~A~%" r g b)))

(defun test-pat ()
  (let ((pat (vector 0.1 0.01 0.2)))
    (aqt-clear-plot)
    (aqt-set-linestyle-pattern pat 0.5)
    (aqt-move-to 10.0 10.0)
    (aqt-add-line-to 90.0 90.0)
    (aqt-render-plot)))

(defun test-poly-line ()
  (let ((x (vector 5.0 3.0 53.0 50.0 5.0))
	(y (vector 5.0 50.0 50.0 5.0 5.0)))
    (aqt-clear-plot)
    (aqt-add-polygon x y)
    (aqt-render-plot)))

(defun test-bmp ()
  (let ((bmp (make-array '(80 80 3) :element-type '(unsigned-byte 8))))
    (dotimes (i 80)
      (dotimes (j 80)
	(setf (aref bmp i j 0) (* 3 j))
	(setf (aref bmp i j 1) (* 3 j))
	(setf (aref bmp i j 2) (* 3 j))))
    (with-aqt-plot ("test" 100 100)
      
;    (format t "~A~%" (type-of bmp))))
;    (aqt-clear-plot)
;    (aqt-set-image-transform 0.9 0.1 -0.1 0.9 0.0 0.0)
      (aqt-add-image-with-bitmap bmp 10.0 10.0 90.0 90.0))))
;    (aqt-add-transformed-image-with-bitmap bmp 10.0 10.0 90.0 90.0)
;    (aqt-reset-image-transform)
;    (aqt-render-plot)))