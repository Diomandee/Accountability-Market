(define-data-var costPerToken uint u0)
(define-data-var totalEverMinted uint u0)
(define-data-var totalEverWithdrawn uint u0)
(define-data-var poolBalance uint u0)
;;  https://explorer.stacks.co/address/ST11ZRCRRZ1WZSNGAF8ZCJ1D0THZKXK8XD2FJPGVS?chain=testnet
(define-data-var auction-counter uint u0)
(define-data-var baseCost uint u100000)
(define-constant p 10)
(define-data-var last-id uint u0)


(define-map calculatePurchaseReturn 
    {purchase-id: uint}
    {
        total-supply: uint,
        pool-balance: uint,
        reserve-ratio: uint,
        amount: uint
    }
)

(define-read-only (get-purchase-info (purchase-id uint))
  (map-get? calculatePurchaseReturn { purchase-id: purchase-id })
)
(define-read-only (get-baseCost) 
  (var-get baseCost)
)

;; Compute the exponentiation of a fraction and an integer
(define-read-only (frac-exp (k int) (q int) (n int)) 
  (get s
    (fold step (list 0 1 2 3 4 5 6 7 8 9 10) 
      {k: k, q: q, n: n, s: 0, N: 1, B: 1})))


(define-private (step 
                  (i int) 
                  (acc {k: int, q: int, n: int, 
                        s: int, N: int, B: int})) 
  (let ((k (get k acc))
        (q (get q acc))
        (n (get n acc))
        (s (get s acc))
        (N (get N acc))
        (B (get B acc))) 
    (merge acc
      {s: (+ s (/ (+ s (* k n)) (* B (pow q i)))),
       N: (* N (- n i)),
       B: (* B (+ i 1))})))

;; (define-private (updateCostOfToken (supply uint)) 
;;   (body)
;; )


;; (define-read-only (token-price (auction-id uint))
;;   (let (
;;     (auction (unwrap-panic (get-auction-info auction-id)))
;;     (total-committed (get total-committed auction))
;;     (total-tokens (get total-tokens auction))
;;   )
;;     (/ (* total-committed u1000000) total-tokens)
;;   )
;; )


;; RANGE
;;
;; Generate a list of at most 1000 incrementally ascending integers
;; from a low to high boundary.
