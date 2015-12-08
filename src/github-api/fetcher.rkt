#lang racket/base

(require racket/contract
         racket/string
         net/url
         json

         "etags.rkt"
         "cache.rkt")

(provide github/fetch)

(define/contract (github/fetch request-url
                               #:token [token ""])
  ((url?) (#:token string?) . ->* . jsexpr?)

  (define (request-header)
    (define/contract (add-token header)
      ((or/c (listof string?)) . -> . (or/c (listof string?)))

      (if (not (equal? token ""))
          (cons (format "Authorization: token ~a"
                        token)
                header)
          header))

    (define/contract (add-etag header)
      ((or/c (listof string?)) . -> . (or/c (listof string?)))

      (if (and (etag-exists? request-url)
               (cache-exists? request-url))
          (cons (format "If-None-Match: ~a"
                        (read-etag request-url))
                header)
          header))

    (define (chain funcs obj)
      (if (null? funcs)
          obj
          (chain (cdr funcs)
                 ((car funcs) obj))))

    (chain `(,add-etag ,add-token) '()))

  (define-values (api-port header-string)
    (get-pure-port/headers request-url
                           (request-header)))

  (define header (header-string->header-list header-string))

  (if (and (not-modified? header) (cache-exists? request-url))
      (read-cache request-url)

      (let ([js-data (read-json api-port)])
        (close-input-port api-port)
        (write-cache request-url js-data)
        (write-etag request-url (extract-etag header))
        js-data)))

(define/contract (not-modified? headers)
  ((listof (listof string?)) . -> . boolean?)

  (ormap (lambda (field)
           (begin
             (equal? field '("Status" "304 Not Modified"))))
         headers))

(define (header-string->header-list header-string)
  (map (lambda (field)
         (string-split field ": "))
       (string-split header-string "\r\n")))
