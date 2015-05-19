#lang racket/base

(require racket/contract
         net/url)

(provide compose-user-url
         compose-repos-url
         compose-events-url)

(define urls
  '#hash((user . "https://api.github.com/users/~a")
         (repos . "https://api.github.com/users/~a/repos")
         (events . "https://api.github.com/users/~a/events")))

(define/contract (compose-user-url login)
  (string? . -> . url?)

  (string->url (format (hash-ref urls 'user)
                       login)))

(define/contract (compose-repos-url login)
  (string? . -> . url?)

  (string->url (format (hash-ref urls 'repos)
                       login)))

(define/contract (compose-events-url login)
  (string? . -> . url?)

  (string->url (format (hash-ref urls 'events)
                       login)))

(module+ main
  (url->string (compose-user-url "GoNZooo")))
