#lang racket/base

(require racket/port
		 racket/contract
		 racket/string
		 net/url
		 json)

(provide read-cache
		 write-cache
		 cache-exists?
		 cache-name)

(define/contract (cache-name url)
  (url? . -> . string?)

  (define (strip-url u)
	(string-replace (string-replace (url->string u)
									#px".*://"
									"")
					#rx"/" "_"))
  
  (format "cache/~a.cache"
		  (strip-url url)))

(define/contract (cache-exists? url)
  (url? . -> . boolean?)

  (file-exists? (cache-name url)))

(define/contract (read-cache url)
  (url? . -> . jsexpr?)
  
  (call-with-input-file (cache-name url)
						read))

(define/contract (write-cache url data)
  (url? jsexpr? . -> . void?)
  
  (call-with-output-file (cache-name url)
						 (lambda (out-port)
						   (write data out-port))
						 #:exists 'replace))
