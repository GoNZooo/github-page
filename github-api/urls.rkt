#lang racket/base

(require racket/contract
		 net/url)

(provide compose-user-url)

(define urls
  '#hash((user . "https://api.github.com/users/~a")))

(define/contract (compose-user-url login)
  (string? . -> . url?)
  
  (string->url (format (hash-ref urls 'user)
					   login)))

(module+ main
  (url->string (compose-user-url "GoNZooo")))
