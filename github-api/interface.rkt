#lang racket/base

(require "email.rkt"
         "repos.rkt"
         "user.rkt"
         "events.rkt")

(provide (all-from-out "repos.rkt"
                       "user.rkt"
                       "events.rkt"))

(module+ main
  (require racket/pretty)
  (api/user->user)
  (api/email->email)
  (pretty-print (api/repos->repos))
  (pretty-print (api/events->events)))
