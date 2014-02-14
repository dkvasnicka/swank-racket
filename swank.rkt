#lang racket

(provide serialize-result-message
         extract-message
         handle-message)

(define-namespace-anchor a)
(define ns (namespace-anchor->namespace a))

(define [extract-message line]
  (eval 
    (read 
      (open-input-string 
        (string-append "'" (substring line 6)))) ns))

(define [handle-message msg]
  '(:return (:ok nil) 1))

(define [serialize-result-message msg]
  (let [[stringified (~s msg)]]
    (string-append (~r (+ (string-length stringified) 1) 
                     #:base 16 #:min-width 6 #:pad-string "0") 
                   stringified "\n")))
