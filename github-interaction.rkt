#lang racket/base

(require racket/port
		 racket/string
		 racket/contract
		 racket/match
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

(struct user (name location html-url)
		#:transparent)

(define (json/user->user json-data)
  (define name (hash-ref json-data 'name))
  (define location (hash-ref json-data 'location))
  (define html-url (hash-ref json-data 'html_url))
  (user name location html-url))

(struct repo (name description html-url language)
		#:transparent)

(define (json/repo->repo json-data)
  (define name (hash-ref json-data 'name))
  (define description (hash-ref json-data 'description))
  (define html-url (hash-ref json-data 'html_url))
  (define language (hash-ref json-data 'language))
  (repo name description html-url language))

(define (json/repos->repos json-data)
  (map json/repo->repo json-data))

(module+ main
  (json/user->user (fetch/user))
  (json/repos->repos (fetch/repos)))
