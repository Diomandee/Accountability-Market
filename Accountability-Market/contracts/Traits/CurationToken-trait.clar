(define-trait CurationToken-trait
  (
    ;; an optional URI that represents metadata of this token
    (get-token-topic () (response (optional (string-utf8 256)) uint))

    ;; an optional URI that represents metadata of this token
    (get-token-website () (response (optional (string-utf8 256)) uint))
    )
)
