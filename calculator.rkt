#lang racket

;; CS4337 Project 1 - final version
;; everything should work now: unary -, $n history (correct order), div by zero, leftover text check

(define interactive?
  (let [(args (current-command-line-arguments))]
    (cond
      [(= (vector-length args) 0) #t]
      [(string=? (vector-ref args 0) "-b") #f]
      [(string=? (vector-ref args 0) "--batch") #f]
      [else #t])))

;; skip whitespace from front of char list
(define (skip-ws chars)
  (cond
    [(null? chars) '()]
    [(char-whitespace? (car chars)) (skip-ws (cdr chars))]
    [else chars]))

;; read consecutive digits, returns (digits-string . remaining-chars)
(define (read-digits chars)
  (cond
    [(null? chars) (cons "" '())]
    [(char-numeric? (car chars))
     (let ([rest (read-digits (cdr chars))])
       (cons (string-append (string (car chars)) (car rest)) (cdr rest)))]
    [else (cons "" chars)]))

;; parse one expression from a char list
;; history is a list with most recent value first (cons'd in)
;; returns (value . remaining-chars) on success, #f on any error
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

      ;; binary / with divide-by-zero check
      [(char=? (car chars) #\/)
       (let ([r1 (parse-expr (cdr chars) history)])
         (if (not r1)
             #f
             (let ([r2 (parse-expr (cdr r1) history)])
               (cond
                 [(not r2) #f]
                 [(= (car r2) 0) #f]    ; divide by zero -> error
                 [else (cons (quotient (car r1) (car r2)) (cdr r2))]))))]

      ;; unary - (negation, not subtraction)
      [(char=? (car chars) #\-)
       (let ([r1 (parse-expr (cdr chars) history)])
         (if (not r1)
             #f
             (cons (- (car r1)) (cdr r1))))]

      ;; $n: look up history value at id n
      ;; history is stored newest-first (via cons), so reverse it before indexing
      [(char=? (car chars) #\$)
       (let ([digits (read-digits (cdr chars))])
         (if (string=? (car digits) "")
             #f
             (let ([id (string->number (car digits))])
               (if (not id)
                   #f
                   (let ([hist-ordered (reverse history)])
                     (if (or (< id 1) (> id (length hist-ordered)))
                         #f
                         (cons (list-ref hist-ordered (- id 1)) (cdr digits))))))))]

      ;; plain number (non-negative integer)
      [(char-numeric? (car chars))
       (let ([digits (read-digits chars)])
         (if (string=? (car digits) "")
             #f
             (cons (string->number (car digits)) (cdr digits))))]

      ;; anything else is invalid
      [else #f])))

;; check if remaining chars are all whitespace (used to detect leftover text)
(define (all-whitespace? chars)
  (cond
    [(null? chars) #t]
    [(char-whitespace? (car chars)) (all-whitespace? (cdr chars))]
    [else #f]))

;; main eval loop, history starts empty and grows via cons
(define (eval-loop history)
  (when interactive? (display "> "))
  (let* ([raw (read-line)]
       [line (if (eof-object? raw) raw (string-trim raw))])
    (when (not (eof-object? line))
      (cond
        [(string=? line "quit") (void)]
        [else
         (let ([result (parse-expr (string->list line) history)])
           (cond
             ;; parse failed or there were leftover characters
             [(not result)
              (displayln "Error: Invalid Expression")
              (eval-loop history)]
             [(not (all-whitespace? (cdr result)))
              (displayln "Error: Invalid Expression")
              (eval-loop history)]
             [else
              ;; cons new value onto history, id = new length of history list
              (let* ([new-history (cons (car result) history)]
                     [id (length new-history)])
                (display id)
                (display ": ")
                (display (real->double-flonum (car result)))
                (newline)
                (eval-loop new-history))]))]))))

(eval-loop '())