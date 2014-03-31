#lang racket

(require racket/match
         mzlib/os
         scribble/decode
         srfi/13)

(provide serialize-result-message
         handle-message
         tolerant-string-drop-right)

(define racket-base-symbols
    (let-values [[[procs1 procs2] (module->exports 'racket)]]
        (map symbol->string (filter symbol? (flatten (append procs1 procs2))))))

(define [tolerant-string-drop-right str n]
    (string-drop-right str (min n (string-length str))))

(define [do-send-to-repl to-repl from-repl code]
    (display code to-repl)
    (flush-output to-repl)
    
    (let readlines [[bytes (make-bytes 1 (read-byte from-repl))]]
        (if (byte-ready? from-repl)
          (readlines (bytes-append bytes 
                                   (make-bytes 1 
                                               (read-byte from-repl))))
          (tolerant-string-drop-right 
            (bytes->string/utf-8 bytes) 3))))

(define [strip-lang-directive code]
    (string-join 
      (filter (curry (compose1 not string-prefix-ci?) "#lang") 
              (string-split code "\n")) 
      "\n"))

(define [evaluate to-repl from-repl code]
    (if (whitespace? code)
        ""
        (do-send-to-repl to-repl from-repl 
                         (strip-lang-directive code))))

(define [code-complete pattern]
    (let [[candidates (filter (curry string-prefix-ci? pattern) racket-base-symbols)]]
         (if (empty? candidates) 'nil candidates)))

(define [handle-message msg to-repl from-repl]
    (let* [[cmd (cadr msg)]
           [continuation (last msg)]]
        (match cmd
               [(list 'swank:connection-info) 
                `(:return (:ok (:pid ,(getpid)
                              :package (:name Racket :prompt Racket) 
                              :encoding (:coding-systems ("utf-8-unix")) 
                              :lisp-implementation 
                                (:type "Racket" :version ,(version)))) ,continuation)]

               [(list 'swank:swank-require swank-repl) 
                `(:return (:ok nil) ,continuation)]
               
               [(list 'swank:create-repl nil) 
                `(:return (:ok "Racket" "Racket") ,continuation)]
               
               [(list 'swank:operator-arglist fn _) 
                `(:return (:ok "([x])") ,continuation)]
               
               [(list 'swank:listener-eval code) 
                `(:return (:ok (:values ,(evaluate to-repl from-repl code))) ,continuation)]
               
               [(list 'swank:simple-completions pattern _) 
                `(:return (:ok ,(list (code-complete pattern) pattern)) ,continuation)]
               
               [_ `(:return (:ok nil) ,continuation)])))

(define [serialize-result-message msg]
    (let [[stringified (~s msg)]]
        (string-append (~r (+ (string-length stringified) 1) 
                     #:base 16 #:min-width 6 #:pad-string "0") 
                   stringified "\n")))
