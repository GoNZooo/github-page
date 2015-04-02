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

(define/contract (api/user [token (auth-token-value)])
  (() (string?) . ->* . (or/c jsexpr? eof-object?))
  
  (call/input-url (string->url github-user-url)
				  get-pure-port
				  read-json
				  `(,(format "Authorization: token ~a"
							 (auth-token-value)))))

(define/contract (api/repos [token (auth-token-value)])
  (() (string?) . ->* . (or/c jsexpr? eof-object?))
  
  (call/input-url (string->url github-repos-url)
				  get-pure-port
				  read-json
				  `(,(format "Authorization: token ~a"
							 (auth-token-value)))))

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
