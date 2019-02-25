#lang racket

(require "csg-common.scm")
(provide generate-glsl)

(define (emphasize word)
  (string-append "\n\t\t" word))

;; Translate symbols to GLSL function names:
(define (vocab symbol)
  (cond [(eq? symbol 'minus) (emphasize "Minus")]
	[(eq? symbol 'union) (emphasize "Union")]
	[(eq? symbol 'inter) (emphasize "Inter")]
	[(eq? symbol 'translate) "Translate"]
	[(eq? symbol 'rotate-x) "RotateX"]
	[(eq? symbol 'rotate-y) "RotateY"]
	[(eq? symbol 'rotate-z) "RotateZ"]
	[(eq? symbol 'scale) "Scale"]
	[(eq? symbol 'sphere) (emphasize "SphereSDF")]
	[(eq? symbol 'box) (emphasize "BoxSDF")]
	[(eq? symbol 'input-position) "Test"]
	[else (error symbol)]))

(define (handle-shape expr cursor)
  (let* ([name (car expr)]
	 [params (cdr expr)])
    (list name params cursor)))

(define (handle-transform expr cursor)
  (let* ([name (car expr)]
	 [params (if (is-rotation? expr)
		     (list (degrees->radians (cadr expr)))
		     (cadr expr))]
	 [new-cursor (list name params cursor)]
	 [tail (cddr expr)])
    (if (eq? (length tail) 1)
	(reflow-tree (car tail) new-cursor)
	(error "transforms can only have one child expression for now"))))

(define (explode-operator operator operands)
  (if (eq? (length operands) 2)
      (cons operator (reverse operands))
      (list operator (explode-operator operator (cdr operands)) (car operands))))

(define (handle-operator expr cursor)
  (let* ([operator (car expr)]
	 [operands (map (lambda (thing) (reflow-tree thing cursor)) (cdr expr))])
    (if (> (length operands) 1)
	(explode-operator operator (reverse operands))
	(error "too few operands"))))

(define (reflow-tree expr cursor)
  (cond [(is-shape? expr) (handle-shape expr cursor)]
	[(is-transform? expr) (handle-transform expr cursor)]
	[(is-operator? expr) (handle-operator expr cursor)]
	[else (error "unreachable")]))

(define (stringify-symbols sdf-tree)
  (map (lambda (thing)
	 (cond [(number? thing) thing]
	       [(list? thing) (stringify-symbols thing)]
	       [else (vocab thing)])) sdf-tree))

(define (all-numbers? expr)
  (cond [(eq? (length expr) 1) (number? (car expr))]
	[(eq? (length expr) 0) #f]
	[else (and (number? (car expr)) (all-numbers? (cdr expr)))]))

(define (replace-vectors expr)
  (cond [(not (list? expr)) expr]
	[(and (eq? (length expr) 1) (number? (car expr))) (car expr)]
	[(all-numbers? expr)
	 (cond [(eq? (length expr) 2) (cons "vec2" expr)]
	       [(eq? (length expr) 3) (cons "vec3" expr)]
	       [(eq? (length expr) 4) (cons "vec4" expr)]
	       [(eq? (length expr) 9) (cons "mat3" expr)]
	       [(eq? (length expr) 16) (cons "mat4" expr)]
	       [else expr])]
	[else (map replace-vectors expr)]))

(define (format-method name params)
  (string-append name "(" (string-join params ", ") ")"))

(define (ugly-print expr)
  (let* ([strings (map (lambda (thing)
			 (cond [(list? thing) (ugly-print thing)]
			       [(string? thing) thing]
			       [(number? thing) (number->string thing)]
			       [else (error thing)])) expr)]
	 [name (car strings)]
	 [params (cdr strings)])
    (format-method name params)))

(define (add-framing function-body)
  (string-append
   "--------------------------------------------------------------------------------"
   "\n\nfloat GeneratedSDF(vec3 Test)\n"
   "{\n"
   "\treturn "
   (string-trim function-body)
   ";\n"
   "}\n"))

(define (generate-glsl csg-tree)
  (if (list? (car csg-tree))
      (generate-glsl (list 'union csg-tree))
      (add-framing
       (ugly-print
	(replace-vectors
	 (stringify-symbols
	  (reflow-tree csg-tree 'input-position)))))))
