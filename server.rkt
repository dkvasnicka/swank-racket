#lang racket

(require racket/tcp
         "swank.rkt")

(define listener (tcp-listen 4005 5 #t))
(displayln "Racket Swank server listening. Port: 4005")

(let mainloop []
  (let-values [[(i o) (tcp-accept listener)]] 
      (thread (λ []               
               (let [[msg-result (handle-message 
                                   (extract-message 
                                     (read-line i 'any)))]]
                   (display (serialize-result-message msg-result) o))
               (close-output-port o))))
  (mainloop))
