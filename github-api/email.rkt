#lang racket/base

(require racket/contract
		 json
		 "token.rkt"
		 "fetcher.rkt")

(provide api/email->email
		 (struct-out email))

(define/contract (api/email [token (auth-token-value)] [cache? #t])
  (() (string? boolean?) . ->* . (or/c jsexpr? eof-object?))
  
  (api/fetch "email" cache?))

(struct email (adress)
		#:transparent)

(define/contract (api/email->email [json-data (api/email)])
  (() ((listof jsexpr?)) . ->* . (or/c email? boolean?))
  
  (match json-data
	[(list a ... (hash-table ('primary #t) ('email adress) ('verified #t)) b ...)
	 (email adress)]
	[else #f]))

