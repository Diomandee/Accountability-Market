(define-constant ERR_NOT_AUTHORIZED u4104)

(define-map contracts
  (string-ascii 256)
  {
    address: principal, 
    qualified-name: principal 
  }
)


;; (begin
  
;;   (map-set contracts
;;     "governance"
;;     {
;;       address: 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE,
;;       qualified-name: 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE.stackswap-governance-v1
;;     }
;;   )
;; )

(define-data-var dao-owner principal tx-sender)
(define-data-var payout-address principal (var-get dao-owner)) 



(define-read-only (get-dao-owner)
  (var-get dao-owner)
)

(define-read-only (get-payout-address)
  (var-get payout-address)
)

(define-public (set-dao-owner (address principal))
  (begin
    (asserts! (is-eq contract-caller (var-get dao-owner)) (err ERR_NOT_AUTHORIZED))
     ;; #[allow(unchecked_data)]
    (ok (var-set dao-owner address))
  )
)

(define-public (set-payout-address (address principal))
  (begin
    (asserts! (is-eq contract-caller (var-get dao-owner)) (err ERR_NOT_AUTHORIZED))
     ;; #[allow(unchecked_data)]
    (ok (var-set payout-address address))
  )
)

(define-read-only (get-contract-address-by-name (name (string-ascii 256)))
  (get address (map-get? contracts name))
)

(define-read-only (get-qualified-name-by-name (name (string-ascii 256)))
  (get qualified-name (map-get? contracts name))
)

;; (define-public (set-contract-address (name (string-ascii 256)) (address principal) (qualified-name principal))
;;   (let (
;;     (current-contract (map-get? contracts name))
;;   )
;;     (asserts! 
;;       (or 
;;         (is-eq (unwrap-panic (get-qualified-name-by-name "governance")) contract-caller)
;;         (is-eq (as-contract tx-sender) contract-caller)
;;       )
;;       (err ERR_NOT_AUTHORIZED))
;;                      ;; #[allow(unchecked_data)]
;;     (map-set contracts name { address: address, qualified-name: qualified-name })
;;     (ok true)

;;   )
;; )

