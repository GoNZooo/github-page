#lang racket/base

(require racket/port
		 racket/string
		 racket/contract
		 racket/match
		 racket/list
		 json
		 net/url)

(provide (struct-out user)
		 (struct-out repo)
		 (struct-out email)
		 api/user->user
		 api/repos->repos
		 api/email->email)

(define/contract (auth-token-loc)
  (-> string?)
  
  (bytes->string/utf-8
	(environment-variables-ref (current-environment-variables)
							   #"GITHUB_REPO_TOKEN_LOC")))

(define/contract (auth-token-value)
  (-> string?)

  (string-replace (call-with-input-file (auth-token-loc)
										port->string)
				  "\n" ""))

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

(define/contract (extract-etag headers)
  ((listof (listof string?)) . -> . string?)

  (match headers
	[(list a ... (list "ETag" etag-value) b ...) etag-value]
	[else ""]))


(define/contract (not-modified? headers)
  ((listof (listof string?)) . -> . boolean?)

  (ormap (lambda (field)
		   (begin
			 (equal? field '("Status" "304 Not Modified"))))
		 headers))

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

(define (header-string->header-list header-string)
  (map (lambda (field)
		 (string-split field ": "))
	   (string-split header-string "\r\n")))

(define/contract (api/fetch type [cache? #t])
  ((string?) (boolean?) . ->* . jsexpr?)

  (define (api-url)
	(define github-base-url "https://api.github.com/")
	(case type
	  [("user") (string-append github-base-url
							   "user")]
	  [("repos") (string-append github-base-url
								"user/repos")]
	  [("email") (string-append github-base-url
								"user/emails")]))

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

(define/contract (api/user [token (auth-token-value)] [cache? #t])
  (() (string? boolean?) . ->* . (or/c jsexpr? eof-object?))

  (api/fetch "user" cache?))

(define/contract (api/repos [token (auth-token-value)] [cache? #t])
  (() (string? boolean?) . ->* . (or/c jsexpr? eof-object?))

  (api/fetch "repos" cache?))

(define/contract (api/email [token (auth-token-value)] [cache? #t])
  (() (string? boolean?) . ->* . (or/c jsexpr? eof-object?))
  
  (api/fetch "email" cache?))

(struct user (name location html-url)
		#:transparent)

(define/contract (api/user->user [json-data (api/user)])
  (() (jsexpr?) . ->* . user?)

  (define name (hash-ref json-data 'name))
  (define location (hash-ref json-data 'location))
  (define html-url (hash-ref json-data 'html_url))
  (user name location html-url))

(struct repo (name description html-url language)
		#:transparent)

(define/contract (api/repo->repo json-data)
  (() (jsexpr?) . ->* . repo?)
  
  (define name (hash-ref json-data 'name))
  (define description (hash-ref json-data 'description))
  (define html-url (hash-ref json-data 'html_url))
  (define language (hash-ref json-data 'language))

  (repo name description html-url language))

(define/contract (api/repos->repos [json-data (api/repos)])
  (() ((listof jsexpr?)) . ->* . (listof (cons/c integer? repo?)))

  (map (lambda (repo num)
		 (cons num (api/repo->repo repo)))
	   json-data
	   (range (length json-data))))

(struct email (adress)
		#:transparent)

(define/contract (api/email->email [json-data (api/email)])
  (() ((listof jsexpr?)) . ->* . (or/c email? boolean?))
  
  (match json-data
	[(list a ... (hash-table ('primary #t) ('email adress) ('verified #t)) b ...)
	 (email adress)]
	[else #f]))

(module+ main
  (require racket/pretty)
  (api/user->user)
  (pretty-print (api/repos->repos))
  (api/email->email))
