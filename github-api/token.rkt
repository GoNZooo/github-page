#lang racket/base

(require racket/port
         racket/string
         racket/contract)

(provide auth-token-value)

(define/contract (auth-token-loc)
  (-> string?)

  (bytes->string/utf-8
    (environment-variables-ref (current-environment-variables)
                               #"GITHUB_REPO_TOKEN_LOC")))

(define/contract (auth-token-value)
  (-> string?)

  (string-replace (call-with-input-file (auth-token-loc)
                                        port->string)
                  "\n" ""))

