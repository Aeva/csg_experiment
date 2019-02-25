#lang racket

(provide
 is-operator?
 is-rotation?
 is-transform?
 is-shape?)

(define (is-operator? expr) (or (eq? (car expr) 'minus)
				(eq? (car expr) 'union)
				(eq? (car expr) 'inter)))

(define (is-rotation? expr) (or (eq? (car expr) 'rotate-x)
				(eq? (car expr) 'rotate-y)
				(eq? (car expr) 'rotate-z)))

(define (is-transform? expr) (or (eq? (car expr) 'translate)
				 (is-rotation? expr)))

(define (is-shape? expr) (or (eq? (car expr) 'sphere)
			     (eq? (car expr) 'box)))
