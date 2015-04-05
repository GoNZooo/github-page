#lang racket/base

(require racket/port)

(provide read-etag
		 write-etag)

(define/contract (read-etag type)
  (string? . -> . string?)
  
  (call-with-input-file (format "etags/~a.etag"
								type)
						port->string))

(define/contract (write-etag type etag)
  (string? string? . -> . integer?)
  
  (call-with-output-file (format "etags/~a.etag"
								 type)
						 (lambda (out-port)
						   (write-string etag out-port))
						 #:exists 'replace))
