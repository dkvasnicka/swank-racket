#lang racket

(require rackunit
         "../swank.rkt")

(test-equal? "test message stringification"                
             (serialize-result-message '(:return (:ok nil) 1))
             "000016(:return (:ok nil) 1)\n")
