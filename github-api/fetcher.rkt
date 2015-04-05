#lang racket/base

(require racket/contract
		 net/url
		 json)

(provide api/fetch)

(define/contract (api/fetch type [cache? #t])
  ((string?) (boolean?) . ->* . jsexpr?)

  (define github-base-url "https://api.github.com/")

  (define (get-public-events-url)
	(format "~ausers/~a/events/public"
			github-base-url
			(hash-ref (api/user) 'login)))

  (define (api-url)
	(case type
	  [("user") (string-append github-base-url
							   "user")]
	  [("repos") (string-append github-base-url
								"user/repos")]
	  [("email") (string-append github-base-url
								"user/emails")]
	  [("events") (get-public-events-url)]))

  (define-values (api-port header-string)
	(get-pure-port/headers (string->url (api-url))
						   (list (format "Authorization: token ~a"
										 (auth-token-value))
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
