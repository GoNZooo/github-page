#lang racket/base

(require racket/port
		 racket/string
		 racket/contract
		 racket/match
		 json
		 net/url)

(provide (struct-out user)
		 (struct-out repo)
		 api/user->user
		 api/repos->repos)

(define github-base-url "https://api.github.com/")
(define github-user-url (string-append github-base-url
									   "user"))
(define github-repos-url (string-append github-user-url
										"/repos"))

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

(define/contract (api/user [token (auth-token-value)])
  (() (string?) . ->* . (or/c jsexpr? eof-object?))

  (define request-fields (list (format "Authorization: token ~a"
									   (auth-token-value))
							   (format "If-None-Match: ~a"
									   (read-etag "user"))))

  (define-values (api-port header-string)
	(get-pure-port/headers (string->url github-user-url)
						   request-fields))

  (define headers (map (lambda (field)
						 (string-split field ": "))
					   (string-split header-string "\r\n")))

  (define etag (extract-etag headers))

  (if (not-modified? headers)
	(read-cache "user")
	(let ([js-data (read-json api-port)])
	  (close-input-port api-port)
	  (write-cache "user" js-data)
	  (write-etag "user" etag)
	  js-data)))

(define/contract (not-modified? headers)
  ((listof (listof string?)) . -> . boolean?)

  (ormap (lambda (field)
		   (begin
			 (equal? field '("Status" "304 Not Modified"))))
		 headers))

(define/contract (api/repos [token (auth-token-value)])
  (() (string?) . ->* . (or/c jsexpr? eof-object?))


  (define request-fields (list (format "Authorization: token ~a"
									   (auth-token-value))
							   (format "If-None-Match: ~a"
									   (read-etag "repos"))))

  (define-values (api-port header-string)
	(get-pure-port/headers (string->url github-repos-url)
						   request-fields))

  (define headers (map (lambda (field)
						 (string-split field ": "))
					   (string-split header-string "\r\n")))

  (define etag (extract-etag headers))

  (if (not-modified? headers)
	(read-cache "repos")
	(let ([js-data (read-json api-port)])
	  (write-cache "repos" js-data)
	  (write-etag "repos" etag)
	  js-data)))

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
  (() ((listof jsexpr?)) . ->* . (listof repo?))
  
  (map api/repo->repo json-data))

(module+ main
  (require racket/pretty)
  (api/user->user)
  (pretty-print (api/repos->repos)))
