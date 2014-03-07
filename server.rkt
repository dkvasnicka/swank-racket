#lang racket

(require racket/tcp
         "swank.rkt")

(define listener (tcp-listen 4005 5 #t))
(displayln "Running Racket Swank server on port 4005")

(define [start-server]
    (displayln "Waiting for the client to connect.")  
    (define-values [i o] (tcp-accept listener)) 
    (displayln "Client connection accepted!")

    (let*-values [[[repl-tap local-sink] (make-pipe)]
                [[local-tap repl-sink] (make-pipe)]]
               
        (thread (λ []
                 (parameterize [[current-namespace (make-base-namespace)]
                                (current-input-port repl-tap)
                                (current-output-port repl-sink)
                                (current-error-port repl-sink)]
                            (read-eval-print-loop))))

        ; read away the first prompt "> " - workaround?
        (read-bytes 2 local-tap)  

        (let mainloop []  
           (read i) ; We don't care about the size info ATM
           (let [[msg-result (handle-message (read i) local-sink local-tap)]]
               (display (serialize-result-message msg-result) o)
               (flush-output o)) 
           (mainloop))))

(start-server)
