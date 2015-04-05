#lang racket/base

(require racket/contract
		 json
		 "token.rkt"
		 "fetcher.rkt")

(provide api/user->user
		 (struct-out user))

(struct user (name location html-url)
		#:transparent)

(define/contract (api/user [token (auth-token-value)] [cache? #t])
  (() (string? boolean?) . ->* . (or/c jsexpr? eof-object?))

  (api/fetch "user" cache?))

(define/contract (api/user->user [json-data (api/user)])
  (() (jsexpr?) . ->* . user?)

  (define name (hash-ref json-data 'name))
  (define location (hash-ref json-data 'location))
  (define html-url (hash-ref json-data 'html_url))
  (user name location html-url))
