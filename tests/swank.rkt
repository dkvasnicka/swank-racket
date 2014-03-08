#lang racket

(require rackunit
         "../swank.rkt")

(test-equal? "test message stringification"                
             (serialize-result-message '(:return (:ok nil) 1))
             "000016(:return (:ok nil) 1)\n")

(test-equal? "Dropping string from right"                
             (tolerant-string-drop-right "abc" 2)
             "a")

(test-equal? "Dropping string from right, n > length of the string"                
             (tolerant-string-drop-right "abc" 10)
             "")
