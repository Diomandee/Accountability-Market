

(define-constant ERR_PERMISSION_DENIED u4251)
(define-constant ERR_UNAUTHORIZED u4252)
(define-constant ERR_ALREADY_INITIALIZED u4253)

(define-data-var costPerToken uint u0)
(define-data-var totalEverMinted uint u0)
(define-data-var totalEverWithdrawn uint u0)
(define-data-var poolBalance uint u0)

(define-data-var token-name (string-ascii 32) "")
(define-data-var token-symbol (string-ascii 32) "")
(define-data-var token-decimals uint u0)

(define-data-var deployer-principal principal tx-sender)
(define-data-var is-initialized bool false)

(define-fungible-token CurationToken)

(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance CurationToken owner)))

(define-read-only (get-name)
  (ok (var-get token-name)))

(define-read-only (get-symbol)
  (ok (var-get token-symbol)))

(define-read-only (get-decimals)
  (ok (var-get token-decimals)))

(define-read-only (get-total-supply)
  (ok (ft-get-supply CurationToken)))


(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq from tx-sender) (err ERR_PERMISSION_DENIED))
    ;; #[allow(unchecked_data)]
    (try! (ft-transfer? CurationToken amount from to))
	(match memo to-print (print to-print) 0x)
	(ok true)
  )
)

(define-constant OWNER_ROLE u0) 
(define-constant MINTER_ROLE u1)
(define-constant BURNER_ROLE u2)
(define-constant REVOKER_ROLE u3) 
(define-constant BLACKLISTER_ROLE u4) 


(define-map roles 
  {
    role: uint,
    account: principal
  }
  {
    allowed: bool
  }
)

(define-read-only (has-role (role-to-check uint) (principal-to-check principal)) 
  (default-to false
    (get allowed (map-get? roles {role: role-to-check, account: principal-to-check }))
  )
)

(define-public (add-principal-to-role (role-to-add uint) (principal-to-add principal))
   (begin
    (asserts! (has-role OWNER_ROLE contract-caller) (err ERR_PERMISSION_DENIED))
    (print { action: "add-principal-to-role", role-to-add: role-to-add, principal-to-add: principal-to-add })
        ;; #[allow(unchecked_data)]
    (ok (map-set roles { role: role-to-add, account: principal-to-add } { allowed: true }))))

(define-public (remove-principal-from-role (role-to-remove uint) (principal-to-remove principal))
   (begin
    (asserts! (has-role OWNER_ROLE contract-caller) (err ERR_PERMISSION_DENIED))
    (print { action: "remove-principal-from-role", role-to-remove: role-to-remove, principal-to-remove: principal-to-remove })
       ;; #[allow(unchecked_data)]
    (ok (map-set roles { role: role-to-remove, account: principal-to-remove } { allowed: false }))))

;; Token URI
;; --------------------------------------------------------------------------

;; Variable for URI storage
(define-data-var uri (string-utf8 256) u"")

;; Public getter for the URI
(define-read-only (get-token-uri)
  (ok (some (var-get uri))))

;; Setter for the URI - only the owner can set it
(define-public (set-token-uri (updated-uri (string-utf8 256)))
  (begin
    (asserts! (has-role OWNER_ROLE contract-caller) (err ERR_PERMISSION_DENIED))
    ;; Print the action for any off chain watchers
    (print { action: "set-token-uri", updated-uri: updated-uri })
           ;; #[allow(unchecked_data)]
    (ok (var-set uri updated-uri))))


;; Token Website
;; --------------------------------------------------------------------------

;; Variable for website storage
(define-data-var website (string-utf8 256) u"")

;; Public getter for the website
(define-read-only (get-token-website)
  (ok (some (var-get website))))

;; Setter for the website - only the owner can set it
(define-public (set-token-website (updated-website (string-utf8 256)))
  (begin
    (asserts! (has-role OWNER_ROLE contract-caller) (err ERR_PERMISSION_DENIED))
    ;; Print the action for any off chain watchers
    (print { action: "set-token-website", updated-website: updated-website })
           ;; #[allow(unchecked_data)]
    (ok (var-set website updated-website))))


;; Token Website
;; --------------------------------------------------------------------------

;; Variable for topic storage
(define-data-var topic (string-utf8 256) u"")

;; Public getter for the website
(define-read-only (get-token-topic)
  (ok (some (var-get topic))))

;; Setter for the website - only the owner can set it
(define-public (set-token-topic (updated-topic (string-utf8 256)))
  (begin
    (asserts! (has-role OWNER_ROLE contract-caller) (err ERR_PERMISSION_DENIED))
    ;; Print the action for any off chain watchers
    (print { action: "set-token-topic", updated-website: updated-topic })
           ;; #[allow(unchecked_data)]
    (ok (var-set topic updated-topic))))


;; Minting and Burning
;; --------------------------------------------------------------------------

;; Mint tokens to the target address
;; Only existing principals with the MINTER_ROLE can mint tokens
(define-public (mint-tokens (mint-amount uint) (mint-to principal) )
  (begin
    (asserts! (has-role MINTER_ROLE contract-caller) (err ERR_PERMISSION_DENIED))
    ;; Print the action for any off chain watchers
    (print { action: "mint-tokens", mint-amount: mint-amount, mint-to: mint-to  })
               ;; #[allow(unchecked_data)]
    (ft-mint? CurationToken mint-amount mint-to)))

;; Burn tokens from the target address
;; Only existing principals with the BURNER_ROLE can mint tokens
(define-public (burn-tokens (burn-amount uint) (burn-from principal) )
  (begin
    (asserts! (has-role BURNER_ROLE contract-caller) (err ERR_PERMISSION_DENIED))
    ;; Print the action for any off chain watchers
    (print { action: "burn-tokens", burn-amount: burn-amount, burn-from : burn-from  })
               ;; #[allow(unchecked_data)]
    (ft-burn? CurationToken burn-amount burn-from)))




(define-public (initialize (name-to-set (string-ascii 32)) (symbol-to-set (string-ascii 32)) (decimals-to-set uint) 
    (uri-to-set (string-utf8 256)) (website-to-set (string-utf8 256)) (topic-to-set (string-utf8 256)) (initial-owner principal) (initial-amount uint))
  (begin
    (asserts! (not (var-get is-initialized)) (err ERR_ALREADY_INITIALIZED))
    (var-set is-initialized true) ;; Set to true so that this can't be called again
    (var-set token-name name-to-set)
    (var-set token-symbol symbol-to-set)
    (var-set token-decimals decimals-to-set)
    (var-set uri uri-to-set)
    (var-set website website-to-set)
    (var-set topic topic-to-set)
    (map-set roles { role: OWNER_ROLE, account: initial-owner } { allowed: true })
    (map-set roles { role: MINTER_ROLE, account: initial-owner } { allowed: true })
  
    (ok u0)
))



