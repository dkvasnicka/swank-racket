#lang racket

(require racket/tcp
         "swank.rkt")

(define listener (tcp-listen 4005 5 #t))
(displayln "Running Racket Swank server on port 4005")

(define [start-server]
  (displayln "Waiting for the client to connect.")  
  (define-values (i o) (tcp-accept listener)) 
  (displayln "Client connection accepted!")

  (let mainloop []  
       (define msg-bytes (make-bytes 1024)) 
       (read-bytes-avail! msg-bytes i)
       (let [[msg-result (handle-message 
                           (extract-message 
                             (bytes->string/utf-8 msg-bytes)))]]
           (display (serialize-result-message msg-result) o)
           (flush-output o)) 
       (mainloop)))

(start-server)
