#lang racket/base

(require racket/port
		 racket/string
		 racket/contract
		 json
		 net/url)

(define github-base-url "https://api.github.com/")
(define github-user-url (string-append github-base-url
									   "user"))
(define github-repos-url (string-append github-user-url
										"/repos"))

(define (auth-token-loc)
  (bytes->string/utf-8
	(environment-variables-ref (current-environment-variables)
							   #"GITHUB_REPO_TOKEN_LOC")))

(define (auth-token-value)
  (string-replace (call-with-input-file (auth-token-loc)
										port->string)
				  "\n" ""))

(define/contract (fetch/user [token (auth-token-value)])
  (() (string?) . ->* . (or/c jsexpr? eof-object?))
  
  (call/input-url (string->url github-user-url)
				  get-pure-port
				  read-json
				  `(,(format "Authorization: token ~a"
							 (auth-token-value)))))

(define/contract (fetch/repos [token (auth-token-value)])
  (() (string?) . ->* . (or/c jsexpr? eof-object?))
  
  (call/input-url (string->url github-repos-url)
				  get-pure-port
				  read-json
				  `(,(format "Authorization: token ~a"
							 (auth-token-value)))))
(module+ main
  (fetch/user)
  (length (fetch/repos)))
