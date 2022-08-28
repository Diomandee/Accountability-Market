(define-trait ContinuousToken-sip010-token-trait
  (
    (initialize ((string-ascii 32) (string-ascii 32) uint (string-utf8 256) (string-utf8 256) principal uint) (response uint uint))
    (set-token-uri ((string-utf8 256)) (response bool uint))
    (approve (bool) (response bool uint))
  )
)


(define-trait ContinuousToken-poxl-token-trait
  (
    (initialize ((string-ascii 32) (string-ascii 32) uint (string-utf8 256) (string-utf8 256) uint uint uint uint uint ) (response uint uint))
    (set-token-uri ((string-utf8 256)) (response bool uint))
    (approve (bool) (response bool uint))
  )
)


(define-trait ContinuousToken-liquidity-token-trait
  (
    ;; (set-token-uri ((string-utf8 256)) (response bool uint))
    (initialize ((string-ascii 32) (string-ascii 32) uint (string-utf8 256)) (response uint uint))
  )
)