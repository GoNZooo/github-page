#lang racket/base

(require racket/contract
		 racket/string
		 net/url
		 json

		 "etags.rkt"
		 "cache.rkt")

(provide api/fetch
		 github-base-url)

(define github-base-url "https://api.github.com/")

(define/contract (api/fetch type
							auth-token
							#:cache? [cache? #t]
							#:url [request-url ""])
  ((string? string?) (#:cache? boolean? #:url string?) . ->* . jsexpr?)



  (define (api-url)
	(if (not (equal? request-url ""))
	  request-url
	  (case type
		[("user") (string-append github-base-url
								 "user")]
		[("repos") (string-append github-base-url
								  "user/repos")]
		[("email") (string-append github-base-url
								  "user/emails")])))

  (define-values (api-port header-string)
	(get-pure-port/headers (string->url (api-url))
						   (list (format "Authorization: token ~a"
										 auth-token)
								 (format "If-None-Match: ~a"
										 (read-etag type)))))

  (define header (header-string->header-list header-string))

  (if (and (not-modified? header) cache?)
	(read-cache type)
	(let ([js-data (read-json api-port)])
	  (close-input-port api-port)
	  (write-cache type js-data)
	  (write-etag type (extract-etag header))
	  js-data)))

(define/contract (not-modified? headers)
  ((listof (listof string?)) . -> . boolean?)

  (ormap (lambda (field)
		   (begin
			 (equal? field '("Status" "304 Not Modified"))))
		 headers))

(define (header-string->header-list header-string)
  (map (lambda (field)
		 (string-split field ": "))
	   (string-split header-string "\r\n")))
