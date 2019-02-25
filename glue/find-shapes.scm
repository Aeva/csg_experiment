#lang racket

(require "math-stuff.scm")
(require "csg-common.scm")

(provide
 find-shapes
 shapes-by-type)

(define (handle-operator expr matrix mode)
  (let* ([operator (car expr)]
	 [operands (cdr expr)])
    (if (eq? operator 'minus)
	(append
	 (find-shapes-inner (car operands) matrix mode)
	 (find-shapes-inner* (cdr operands) matrix (* mode -1)))
	(find-shapes-inner* operands matrix mode))))

(define (transform-fn symbol)
  (cond [(eq? symbol 'translate) translate]
	[(eq? symbol 'rotate-x) rotate-x]
	[(eq? symbol 'rotate-y) rotate-y]
	[(eq? symbol 'rotate-z) rotate-z]
	[else (error "unkown transform")]))

(define (handle-transform expr lhs mode)
  (let* ([name (car expr)]
	 [params (if (eq? name 'translate) (cadr expr) (list (cadr expr)))]
	 [rhs (apply (transform-fn name) params)]
	 [matrix (mat4-mul lhs rhs)])
    (find-shapes-inner* (cddr expr) matrix mode)))

(define (find-shapes-inner expr matrix mode)
  (cond [(is-operator? expr) (handle-operator expr matrix mode)]
	[(is-transform? expr) (handle-transform expr matrix mode)]
	[(is-shape? expr) (list (list expr matrix mode))]
	[else (error "unreachable")]))

(define (find-shapes-inner* exprs matrix mode)
  (if (null? exprs)
      '()
      (append (find-shapes-inner (car exprs) matrix mode)
	      (find-shapes-inner* (cdr exprs) matrix mode))))

(define (find-shapes tree)
  (find-shapes-inner tree (translate 0 0 0) 1))

(define (shapes-by-type shape-list)
  (if (null? shape-list) (list '() '())
      (let* ([recurse (shapes-by-type (cdr shape-list))]
	     [spheres (car recurse)]
	     [boxes (cadr recurse)]
	     [shape (car shape-list)]
	     [type (caar shape)])
	(cond [(eq? type 'sphere) (list (cons shape spheres) boxes)]
	      [(eq? type 'box) (list spheres (cons shape boxes))]
	      [else (error "unreachable")]))))
