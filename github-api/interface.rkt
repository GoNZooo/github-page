#lang racket/base

(require "repos.rkt"
         "user.rkt"
         "events.rkt")

(provide (all-from-out "repos.rkt"
                       "user.rkt"
                       "events.rkt"))

(module+ main
  (require racket/pretty)
  (pretty-print (github/user "GoNZooo"))
  (pretty-print (github/events "GoNZooo"))
  (pretty-print (github/repos "GoNZooo")))
