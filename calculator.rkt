#lang racket

;; CS4337 Project 1

(define interactive?
  (let [(args (current-command-line-arguments))]
    (cond
      [(= (vector-length args) 0) #t]
      [(string=? (vector-ref args 0) "-b") #f]
      [(string=? (vector-ref args 0) "--batch") #f]
      [else #t])))

;; skip whitespace off the front of a char list
(define (skip-ws chars)
  (cond
    [(null? chars) '()]
    [(char-whitespace? (car chars)) (skip-ws (cdr chars))]
    [else chars]))

;; read consecutive digits, returns (digits-string . remaining)
(define (read-digits chars)
  (cond
    [(null? chars) (cons "" '())]
    [(char-numeric? (car chars))
     (let ([rest (read-digits (cdr chars))])
       (cons (string-append (string (car chars)) (car rest)) (cdr rest)))]
    [else (cons "" chars)]))

;; parse one expression, return (value . remaining-chars) or #f on error
;; BUG: doesnt handle $n history references yet
;; BUG: - operator broken, treats it like binary subtraction
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

      ;; binary / -- forgot to check divide by zero lol
      [(char=? (car chars) #\/)
       (let ([r1 (parse-expr (cdr chars) history)])
         (if (not r1)
             #f
             (let ([r2 (parse-expr (cdr r1) history)])
               (if (not r2)
                   #f
                   (cons (quotient (car r1) (car r2)) (cdr r2))))))]

      ;; BUG: treating - as binary subtraction, supposed to be unary negate
      [(char=? (car chars) #\-)
       (let ([r1 (parse-expr (cdr chars) history)])
         (if (not r1)
             #f
             (let ([r2 (parse-expr (cdr r1) history)])
               (if (not r2)
                   #f
                   (cons (- (car r1) (car r2)) (cdr r2))))))]

      ;; number
      [(char-numeric? (car chars))
       (let ([digits (read-digits chars)])
         (if (string=? (car digits) "")
             #f
             (cons (string->number (car digits)) (cdr digits))))]

      ;; TODO: $n history -- not implemented yet
      [else #f])))

;; BUG: not checking if there are leftover chars after parsing
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
             [else
              ;; BUG: history id is wrong, using length before cons
              (let* ([id (+ 1 (length history))]
                     [new-history (cons (car result) history)])
                (display id)
                (display ": ")
                (display (real->double-flonum (car result)))
                (newline)
                (eval-loop new-history))]))]))))

(eval-loop '())