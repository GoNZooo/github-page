#lang racket/base

(require racket/port
         racket/match
         racket/contract
         racket/string
         net/url)

(provide read-etag
         write-etag
         etag-name
         etag-exists?
         extract-etag)

(define/contract (etag-name url)
  (url? . -> . string?)

  (define (strip-url u)
    (string-replace (string-replace (url->string u)
                                    #px".*://"
                                    "")
                    #rx"/" "_"))

  (format "etags/~a.etag"
          (strip-url url)))

(define/contract (etag-exists? url)
  (url? . -> . boolean?)

  (file-exists? (etag-name url)))

(define/contract (read-etag url)
  (url? . -> . string?)

  (call-with-input-file (etag-name url) port->string))

(define/contract (write-etag url etag)
  (url? string? . -> . integer?)

  (call-with-output-file (etag-name url)
    (lambda (out-port)
      (write-string etag out-port))
    #:exists 'replace))

(define/contract (extract-etag headers)
  ((listof (listof string?)) . -> . string?)

  (match headers
    [(list a ... (list "ETag" etag-value) b ...) etag-value]
    [else ""]))
