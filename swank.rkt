#lang racket

(require racket/tcp)

(define listener (tcp-listen 4005 5 #t))
(displayln "Racket Swank server listening. Port: 4005")

(let mainloop []
  (let-values [[(i o) (tcp-accept listener)]] 
      (thread (λ []
               (displayln (read-line i 'any))
               (display "000016(:return (:ok nil) 1)\n" o)
               (close-output-port o))))
  (mainloop))
