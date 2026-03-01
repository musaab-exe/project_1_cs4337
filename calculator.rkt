#lang racket

;; CS4337 Project 1

(define interactive?
  (let [(args (current-command-line-arguments))]
    (cond
      [(= (vector-length args) 0) #t]
      [(string=? (vector-ref args 0) "-b") #f]
      [(string=? (vector-ref args 0) "--batch") #f]
      [else #t])))

(define (skip-ws chars)
  (cond
    [(null? chars) '()]
    [(char-whitespace? (car chars)) (skip-ws (cdr chars))]
    [else chars]))

(define (read-digits chars)
  (cond
    [(null? chars) (cons "" '())]
    [(char-numeric? (car chars))
     (let ([rest (read-digits (cdr chars))])
       (cons (string-append (string (car chars)) (car rest)) (cdr rest)))]
    [else (cons "" chars)]))

;; parse one expression, return (value . remaining-chars) or #f on error
(define (parse-expr chars history)
  (let ([chars (skip-ws chars)])
    (cond
      [(null? chars) #f]

      ;; binary +
      [(char=? (car chars) #\+)
       (let ([r1 (parse-expr (cdr chars) history)])
         (if (not r1)
             #f
             (let ([r2 (parse-expr (cdr r1) history)])
               (if (not r2)
                   #f
                   (cons (+ (car r1) (car r2)) (cdr r2))))))]

      ;; binary *
      [(char=? (car chars) #\*)
       (let ([r1 (parse-expr (cdr chars) history)])
         (if (not r1)
             #f
             (let ([r2 (parse-expr (cdr r1) history)])
               (if (not r2)
                   #f
                   (cons (* (car r1) (car r2)) (cdr r2))))))]

      ;; binary / -- BUG: still not checking divide by zero
      [(char=? (car chars) #\/)
       (let ([r1 (parse-expr (cdr chars) history)])
         (if (not r1)
             #f
             (let ([r2 (parse-expr (cdr r1) history)])
               (if (not r2)
                   #f
                   (cons (quotient (car r1) (car r2)) (cdr r2))))))]

      ;; unary - (fixed from last time)
      [(char=? (car chars) #\-)
       (let ([r1 (parse-expr (cdr chars) history)])
         (if (not r1)
             #f
             (cons (- (car r1)) (cdr r1))))]

      ;; $n history reference
      ;; BUG: off by one -- using (length history) as max but history is reversed
      ;; so if history is '(30 10) that means id=1 -> 10 and id=2 -> 30
      ;; but I'm just doing list-ref without reversing, so it's backwards
      [(char=? (car chars) #\$)
       (let ([digits (read-digits (cdr chars))])
         (if (string=? (car digits) "")
             #f
             (let ([id (string->number (car digits))])
               (if (not id)
                   #f
                   (if (or (< id 1) (> id (length history)))
                       #f
                       ;; BUG: should be (reverse history) before list-ref
                       ;; this gives values in wrong order
                       (cons (list-ref history (- id 1)) (cdr digits)))))))]

      ;; number
      [(char-numeric? (car chars))
       (let ([digits (read-digits chars)])
         (if (string=? (car digits) "")
             #f
             (cons (string->number (car digits)) (cdr digits))))]

      [else #f])))

(define (all-whitespace? chars)
  (cond
    [(null? chars) #t]
    [(char-whitespace? (car chars)) (all-whitespace? (cdr chars))]
    [else #f]))

(define (eval-loop history)
  (when interactive? (display "> "))
  (let ([line (read-line)])
    (when (not (eof-object? line))
      (cond
        [(string=? line "quit") (void)]
        [else
         (let ([result (parse-expr (string->list line) history)])
           (cond
             [(not result)
              (displayln "Error: Invalid Expression")
              (eval-loop history)]
             ;; now checking for leftover text
             [(not (all-whitespace? (cdr result)))
              (displayln "Error: Invalid Expression")
              (eval-loop history)]
             [else
              (let* ([new-history (cons (car result) history)]
                     [id (length new-history)])
                (display id)
                (display ": ")
                (display (real->double-flonum (car result)))
                (newline)
                (eval-loop new-history))]))]))))

(eval-loop '())