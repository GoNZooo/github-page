#lang racket/base

(require racket/contract
		 json
		 "token.rkt"
		 "fetcher.rkt")

(provide api/repos->repos
		 (struct-out repo))

(struct repo (name description html-url language)
		#:transparent)

(define/contract (api/repos [token (auth-token-value)] [cache? #t])
  (() (string? boolean?) . ->* . (or/c jsexpr? eof-object?))

  (api/fetch "repos" cache?))

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

