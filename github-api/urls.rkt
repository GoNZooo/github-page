#lang racket/base

(require racket/contract
		 net/url)

(provide compose-user-url
		 compose-repos-url)

(define urls
  '#hash((user . "https://api.github.com/users/~a")
		 (repos . "https://api.github.com/users/~a/repos")))

(define/contract (compose-user-url login)
  (string? . -> . url?)
  
  (string->url (format (hash-ref urls 'user)
					   login)))

(define/contract (compose-repos-url login)
  (string? . -> . url?)
  
  (string->url (format (hash-ref urls 'repos)
					   login)))
(module+ main
  (url->string (compose-user-url "GoNZooo")))
