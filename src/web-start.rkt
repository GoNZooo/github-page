#lang racket/base

(require web-server/servlet
         web-server/servlet-env
         web-server/templates
         web-server/dispatch
         web-server/page

         "github-api/interface.rkt")

(define/page (main-page user-data repo-list)
  (response/full
    200 #"Okay"
    (current-seconds) TEXT/HTML-MIME-TYPE
    '()
    `(,(string->bytes/utf-8 (include-template "templates/main.html")))))

(define (request/github request)
  (main-page request
             (github/user "GoNZooo")
             (github/repos/enumerated "GoNZooo")))

(define/page (ping-page)
  (response/full
    200 #"Okay"
    (current-seconds) TEXT/HTML-MIME-TYPE
    '()
    `(,(string->bytes/utf-8 "Pong!"))))

(define (request/ping request)
  (ping-page request))

(define/page (ping-pong-page)
  (response/full
    200 #"Okay"
    (current-seconds) TEXT/HTML-MIME-TYPE
    '()
    `(,(string->bytes/utf-8 "Klurigt!"))))

(define (request/ping-pong request)
  (ping-pong-page request))

(define-values (github-page-dispatch github-page-url)
  (dispatch-rules
    [("ping") request/ping]
    [("github" "") request/github]))

(serve/servlet github-page-dispatch
               #:port 8080
               #:listen-ip #f
               #:servlet-regexp #rx""
               #:command-line? #t
               #:extra-files-paths `("static")
               #:servlet-current-directory "./"
               )
