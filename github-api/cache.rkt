#lang racket/base

(require racket/port
		 racket/contract)

(define/contract (read-cache type)
  (string? . -> . jsexpr?)
  
  (call-with-input-file (format "cache/~a.cache"
								type)
						read))

(define/contract (write-cache type data)
  (string? jsexpr? . -> . void?)
  
  (call-with-output-file (format "cache/~a.cache"
								 type)
						 (lambda (out-port)
						   (write data out-port))
						 #:exists 'replace))

