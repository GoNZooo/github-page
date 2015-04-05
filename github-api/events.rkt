#lang racket/base

(require racket/contract
		 "fetcher.rkt")

(define/contract (api/events [token (auth-token-value)] [cache? #t])
  (() (string? boolean?) . ->* . (or/c jsexpr? eof-object?))

  (api/fetch "events" cache?))

(define/contract (api/event->event json-data)
  (jsexpr? . -> . event?)
  
  (define actor (hash-ref (hash-ref json-data 'actor)
						  'login))

  (define type (hash-ref json-data 'type))

  (define repo-name (hash-ref (hash-ref json-data 'repo)
							  'name))

  (define repo-url (hash-ref (hash-ref json-data 'repo)
							 'url))

  (event actor type repo-name repo-url))
