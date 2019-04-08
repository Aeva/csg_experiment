#!/usr/bin/env racket
#lang racket

(require "glue/math-stuff.scm")
(require "glue/find-shapes.scm")
(require "glue/glsl-stuff.scm")

;; Some size constants that will be needed for:
(define vec4-size (* 4 4))
(define mat4-size (* vec4-size 4))
(define sphere-size vec4-size)
(define box-size (+ vec4-size (* mat4-size 2)))

;; Methods for writing numbers to disk so C++ can read them:
(define (write-uint32 x) (write-bytes (integer->integer-bytes x 4 #f)))
(define (write-uint32* x) (if (number? x) (write-uint32 x) (map write-uint32 x)))
(define (write-float x) (write-bytes (real->floating-point-bytes x 4)))
(define (write-float* x) (if (number? x) (write-float x) (map write-float x)))


;; CSG tree to be rendered:
(define csg-tree
  '(union
    (rotate-x -30
  	      (rotate-y 45
  			(minus
  			 (box 200 200 200)
  			 (box 150 150 400)
  			 (box 150 400 150)
  			 (box 400 150 150)
  			 )))
    (sphere 100)))

  ;; '(union
  ;;   (minus
  ;;    (sphere 200)
  ;;    (translate (-50 -50 -100) (sphere 150))
  ;;    (translate (100 100 -100) (sphere 80))
  ;;    (translate (-10 -10 100) (sphere 100))
  ;;    (translate (100 0 -55) (rotate-y 45 (box 60 400 60)))
  ;;    (translate (-100 -100 0) (rotate-z 45 (box 50 50 400))))

  ;;   (minus
  ;;    (inter
  ;;     (translate (310 125 0) (sphere 50))
  ;;     (translate (290 125 0) (sphere 50)))
  ;;    (translate (300 160 -10) (sphere 35))
  ;;    (translate (300 90 -15) (sphere 28))
  ;;    (translate (300 128 -50) (sphere 6)))
  ;;   (translate (300 160 -10) (sphere 20))
    
  ;;   (minus
  ;;    (inter
  ;;     (translate (300 0 0) (box 100 100 60))
  ;;     (translate (300 0 0) (sphere 50)))
  ;;    (translate (300 0 0) (sphere 40)))
  ;;   (translate (300 20 0) (sphere 20))
    
  ;;   (minus
  ;;    (translate (300 -125 0) (sphere 50))
  ;;    (minus
  ;;     (translate (300 -125 -45) (sphere 40))
  ;;     (translate (300 -125 -20) (sphere 30))))))


(define (munge-sphere sphere)
  (let* ([radius (cadar sphere)]
	 [origin (transform-origin (cadr sphere))]
	 [mode (caddr sphere)])
    (append origin (list (* radius mode)))))

(define (munge-box box)
  (let* ([extent (cdar box)]
	 [world-matrix (cadr box)]
	 [rotation-matrix (negate-rotation world-matrix)]
	 [mode (list (caddr box))])
    (append extent mode world-matrix rotation-matrix)))
   
(define (munge-spheres spheres) (apply append (map munge-sphere spheres)))
(define (munge-boxes boxes) (apply append (map munge-box boxes)))

;; Read shape data and dump it to disk:
(define (regen-blob)
  (let* ([shapes (shapes-by-type (find-shapes csg-tree))]
	 [spheres (car shapes)]
	 [boxes (cadr shapes)]
	 [shape-data (append (munge-spheres spheres)
			     (munge-boxes boxes))])
    (write-uint32*
     (list (length spheres)
	   (length boxes)
	   sphere-size
	   box-size))
    (write-float* shape-data))
  '())

(define (regen-glsl)
  (write-string (generate-glsl csg-tree)))

(with-output-to-file "shape.blob" regen-blob #:exists 'replace)
(with-output-to-file "shaders/generated.glsl" regen-glsl #:exists 'replace)
