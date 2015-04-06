#lang racket/base

(require racket/contract
		 json

		 "token.rkt"
		 "user.rkt"
		 "fetcher.rkt")

(provide api/events->events
		 (struct-out event))

(struct event (actor type repo-name repo-url)
		#:transparent)

(define (get-public-events-url)
  (format "~ausers/~a/events/public"
		  github-base-url
		  (user-login (api/user->user))))

(define/contract (api/events [token (auth-token-value)] [cache? #t])
  (() (string? boolean?) . ->* . (or/c jsexpr? eof-object?))

  (api/fetch "events"
			 token
			 #:cache? cache?
			 #:url (get-public-events-url)))

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

(define/contract (api/events->events [json-data (api/events)]
									 #:cache? [cache? #t])
  (() ((listof jsexpr?) #:cache? boolean?) . ->* . (listof event?))
  
  (map api/event->event json-data))
