#lang racket/base

(require racket/contract
		 racket/match
		 json

		 "urls.rkt"
		 "fetcher.rkt")

(provide github/events
		 (struct-out actor)
		 (struct-out event/repo)
		 (struct-out event))

(struct actor (avatar-url
				gravatar-id
				id
				login
				url)
		#:transparent)

(struct event/repo (id
					name
					url)
		#:transparent)

(struct event (created-at
				id
				payload
				public
				repo
				type)
		#:transparent)


(define/contract (github/events login
								#:token [token ""])
  ((string?) (#:token string?) . ->* . (listof event?))

  (define/contract (js-event->event js-event)
	(jsexpr? . -> . event?)

	(match js-event
	  [(hash-table
		 ('actor
		  (hash-table
			('avatar_url avatar-url)
			('gravatar_id gravatar-id)
			('id actor-id)
			('login login)
			('url actor-url)))
		 ('created_at created-at)
		 ('id id)
		 ('payload payload)
		 ('public public)
		 ('repo
		  (hash-table
			('id repo-id)
			('name name)
			('url repo-url)))
		 ('type type))
	   (event
		 (actor avatar-url
				gravatar-id
				actor-id
				login
				actor-url)
		 id
		 payload
		 public
		 (event/repo
		   repo-id
		   name
		   repo-url)
		 type)]))

  (map js-event->event
	   (github/fetch (compose-events-url login)
					 #:token token))) 

(module+ main
  (require racket/pretty
		   "token.rkt")
  
  (pretty-print (github/events "GoNZooo")))
