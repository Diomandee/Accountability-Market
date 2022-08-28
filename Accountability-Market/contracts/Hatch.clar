(use-trait ft-trait sip010-ft-trait.sip010-ft-trait)

;; GENERAL CONFIGURATION

(define-constant TokenManager tx-sender)
(define-constant PPM u1000000)
(define-data-var hatch-counter uint u0)


;; ERROR CODES

(define-constant ERR_UNAUTHORIZED u1000)
(define-constant ERR_USER_ALREADY_REGISTERED u1001)
(define-constant ERR_USER_NOT_FOUND u1002)
(define-constant ERR_USER_ID_NOT_FOUND u1003)
(define-constant ERR_ACTIVATION_THRESHOLD_REACHED u1004)
(define-constant ERR_CONTRACT_NOT_ACTIVATED u1005)
(define-constant ERR_USER_ALREADY_MINED u1006)
(define-constant ERR_INSUFFICIENT_COMMITMENT u1007)
(define-constant ERR_INSUFFICIENT_BALANCE u1008)
(define-constant ERR_USER_DID_NOT_MINE_IN_BLOCK u1009)
(define-constant ERR_CLAIMED_BEFORE_MATURITY u1010)
(define-constant ERR_NO_MINERS_AT_BLOCK u1011)
(define-constant ERR_REWARD_ALREADY_CLAIMED u1012)
(define-constant ERR_MINER_DID_NOT_WIN u1013)
(define-constant ERR_NO_VRF_SEED_FOUND u1014)
(define-constant ERR_STACKING_NOT_AVAILABLE u1015)
(define-constant ERR_CANNOT_STACK u1016)
(define-constant ERR_REWARD_CYCLE_NOT_COMPLETED u1017)
(define-constant ERR_NOTHING_TO_REDEEM u1018)
(define-constant ERR_UNABLE_TO_FIND_CITY_WALLET u1019)
(define-constant ERR_CLAIM_IN_WRONG_CONTRACT u1020)

(define-constant ERR_ADDRESS_NOT_FOUND u1001)
(define-constant ERR_ID_NOT_FOUND u1002)
(define-constant ERR_CANNOT_START_ON_PREVIOUS_BLOCK u1003)
(define-constant ERR_POOL_NOT_FOUND u1004)
(define-constant ERR_POOL_STILL_OPEN u1005)
(define-constant ERR_INSUFFICIENT_BALANCE u1006)
(define-constant ERR_CONTRIBUTION_BELOW_MINIMUM u1007)
(define-constant ERR_CONTRIBUTION_PERIOD_ENDED u1008)
(define-constant ERR_CONTRIBUTION_PERIOD_NOT_STARTED u1009)
(define-constant ERR_CONTRIBUTION_NOT_FOUND u1010)
(define-constant ERR_CALLER_NOT_AUTHORISED u1011)
(define-constant ERR_MINE_MANY_NOT_FOUND u1012)
(define-constant ERR_BLOCK_NOT_WON u1013)
(define-constant ERR_CLAIMING_UNAVAILABLE u1014)
(define-constant ERR_CLAIMING_ALREADY_ENABLED u1015)
(define-constant ERR_CLAIMING_NOT_ENABLED u1016)
(define-constant ERR_ALREADY_CLAIMED u1017)
(define-constant ERR_CLAIMS_NOT_FOUND u1018)
(define-constant ERR_CANNOT_REMOVE_FEE_ADDRESS u1019)
(define-constant POOL_CONTRACT_ADDRESS (as-contract tx-sender))

(define-data-var TokenManager principal tx-sender)

;; MANAGER WALLET MANAGEMENT
;; --------------------------------------------------------------------------
(define-constant TokenManager tx-sender)
(define-data-var Token-Manager principal TokenManager)

;; returns city wallet principal
(define-read-only (get-manager-wallet)
  (ok (var-get Token-Manager))
)

(define-private (is-authorized-auth-manager)
  (is-eq contract-caller (var-get Token-Manager))
)

;; protected function to update city wallet variable
(define-public (set-manager-wallet (newTokenManager principal))
     ;; #[allow(unchecked_data)]
  (begin
    (asserts! (is-authorized-auth-manager) (err ERR_UNAUTHORIZED))
         ;; #[allow(unchecked_data)]
    (ok (var-set Token-Manager newTokenManager))
  )
)
;; RESERVE WALLET MANAGEMENT
;; --------------------------------------------------------------------------
(define-constant ReserveWallet 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5)
(define-data-var Reserve-Wallet principal ReserveWallet)

;; returns city wallet principal
(define-read-only (get-reserve-wallet)
  (ok (var-get Reserve-Wallet))
)

(define-private (is-authorized-auth-reserve)
  (is-eq contract-caller (var-get Reserve-Wallet))
)

;; protected function to update city wallet variable
(define-public (set-reserve-wallet (newReserveWallet principal))
     ;; #[allow(unchecked_data)]
  (begin
    (asserts! (is-authorized-auth-reserve) (err ERR_UNAUTHORIZED))
         ;; #[allow(unchecked_data)]
    (ok (var-set Reserve-Wallet newReserveWallet))
  )
)


;; FUNDIND WALLET MANAGEMENT

;; initial value for city wallet, set to this contract until initialized
(define-constant NFTWallet 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG)
(define-data-var NFT-Wallet principal NFTWallet)

;; returns city wallet principal
(define-read-only (get-nft-wallet)
  (ok (var-get NFT-Wallet))
)

(define-private (is-authorized-auth-nft)
  (is-eq contract-caller (var-get NFT-Wallet))
)

;; protected function to update city wallet variable
(define-public (set-nft-wallet (newNFTWallet principal))
     ;; #[allow(unchecked_data)]
  (begin
       ;; #[allow(unchecked_data)]
    (asserts! (is-authorized-auth-nft) (err ERR_UNAUTHORIZED))
    (ok (var-set NFT-Wallet newNFTWallet))
  )
)

(define-map HatchInfo 
    { hatchId: uint }
    {   
        payment-token: principal,
        total-tokens: uint,
        start-price: uint,
        min-price: uint,
        feePercentage: uint,
        fundingForNftree: uint,
        contributionsStartBlock: uint,
        contributionsEndBlock: uint,
        totalContributed: uint,
    }
)
(define-map vestingInfo 
    { hatchId: uint }
    {   
        vestingCliffPeriod: uint,
        vestingCompletePeriod: uint,
        vestingCliffDate: uint,
        vestingCompleteDate: uint,
    }
)

;; (define-map Contributions
;;     { 
;;       hatchId: uint, 
;;       address: principal 
;;     }
;;     { 
;;       amountUstx: uint
;;     }
;; )

(define-map commitments
  { 
    user: principal,
    hatchId: uint 
  }
  {
    committed: uint,
    claimed: uint,
  }
)

(define-read-only (get-hatch-info (HatchInfo uint))
  (map-get? auction-info { hatchId: hatchId })
)

(define-read-only (get-commitments (user principal) (hatch-id uint))
  (default-to
    {
      committed: u0,
      claimed: u0,
    }
    (map-get? commitments { user: user, hatchId: hatchId })
  )
)



;; HATCHING STATE
;; --------------------------------------------------------------------------
;; (define-map stateInfo 
;;     { stateId: uint }
;;     { 
;;         Pending: bool,  
;;         Funding: bool,
;;         Closed: bool
;;     }
;; )

;; (define-constant OPEN_ROLE u0) 
;; (define-constant CONTRIBUTE_ROLE u1)
;; (define-constant CLOSE_ROLE u2)


;; REGISTRATION
;; --------------------------------------------------------------------------

;; HATCHING CONFIGURATION
;; --------------------------------------------------------------------------

;; define split to reserve and funding wallet address for economy
;; (define-constant WALLET_SPLIT_PCT u30)

;; how long a miner must wait before block winner can claim their minted tokens
;; (define-data-var tokenRewardMaturity uint u33600)

;; At a given Stacks block height:
;; - how many miners were there
;; - what was the total amount submitted
;; - what was the total amount submitted to the city
;; - what was the total amount submitted to Stackers
;; - was the block reward claimed
;; (define-map HaychStatsAtBlock
;;   uint
;;   {
;;     minersCount: uint,
;;     amount: uint,
;;     amountToReserve: uint,
;;     amountToNFTREE: uint,
;;     rewardClaimed: bool
;;   }
;; )

;; HATCHING ACTIONS
;; --------------------------------------------------------------------------


;; HATCH START PRICE
;; --------------------------------------------------------------------------

(define-constant p 10)
(define-data-var baseCost uint u1000000)
(define-data-var costPerToken uint u0)
(define-data-var totalEverMinted uint u0)
(define-data-var totalEverWithdrawn uint u0)
(define-data-var poolBalance uint u0)


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
       B: (* B (+ i 1))}))
)


(define-map calculatePurchaseReturn 
    {purchase-id: uint}
    {
        total-supply: uint,
        pool-balance: uint,
        reserve-ratio: uint,
        deposit-amount: uint
    }
)


(define-read-only (get-purchase-info (purchase-id uint))
  (map-get? calculatePurchaseReturn { purchase-id: purchase-id })
)
(define-read-only (get-baseCost) 
  (var-get baseCost)
)

(define-map calculateSaleReturn 
    {purchase-id: uint}
    {
        total-supply: int,
        pool-balance: int,
        reserve-ratio: int,
        deposit-amount: int
    }
)

;; HATCH PRICE ACTION
;; --------------------------------------------------------------------------

(define-read-only (token-price (HatchId uint))
  (let (
    (hatch (unwrap-panic (get-hatch-info HatchId)))
    (totalContributed (get totalContributed hatch))
    (total-tokens (get total-tokens hatch))
  )
    (/ (* totalContributed u1000000) total-tokens)
  )
)


(define-read-only (price-function (HatchId uint))
  (let (
    (hatch (unwrap-panic (get-hatch-info HatchId)))
  )
    (if (<= block-height (get contributionsStartBlock hatch))
      (get start-price hatch)
      (if (>= block-height (get contributionsEndBlock hatch))
        (get min-price hatch)
        (current-price HatchId)
      )
    )
  )
)
;; HATCHING OPENS
;; --------------------------------------------------------------------------

(define-public (commit-tokens (HatchId uint) (amount uint))
  (let (
    (hatch (unwrap-panic (get-hatch-info HatchId)))
    (contributionsEndBlock (get contributionsEndBlock hatch))
    (contributionsStartBlock (get contributionsStartBlock hatch))
    (callerAddress tx-sender)
    (tokens-to-transfer (calculate-commitment HatchId amount))
  )
    (asserts! (< block-height contributionsEndBlock) (err ERR_CONTRIBUTION_PERIOD_ENDED))
    (asserts! (>= block-height contributionsStartBlock) (err ERR_CONTRIBUTION_PERIOD_NOT_STARTED))
    (asserts! (>= (stx-get-balance callerAddress) amountUstx) (err ERR_INSUFFICIENT_BALANCE))

    (if (> tokens-to-transfer u0)
      (begin
        ;; Transfer from user
        (try! (stx-transfer? tokens-to-transfer callerAddress POOL_CONTRACT_ADDRESS))
        ;; Add commitment
        (add-commitment HatchId tx-sender tokens-to-transfer)
      )
      (ok u0)
    )
  )
)

(define-private (add-commitment (HatchId uint) (user principal) (commitment uint))
  (let (
    (hatch (unwrap-panic (get-auction-info HatchId)))
    (current-total (get totalContributed hatch))

    (user-committed (get-commitments user HatchId))
    (current-committed (get committed user-committed))
  )
    ;; Update auction
    (map-set HatchInfo
      { HatchId: HatchId }
      (merge auction { totalContributed: (+ current-total commitment) })
    )

    ;; Update user
    (map-set commitments
      { user: user, HatchId: HatchId }
      (merge user-committed { committed: (+ current-committed commitment) })
    )
  
    (ok commitment)
  )
)

(define-read-only (calculate-commitment (HatchId uint) (commitment uint))
  (let (
    (hatch (unwrap-panic (get-hatch-info hatch-id)))
    (max-commitment (/ (* (get total-tokens hatch) (clearing-price HatchId)) u1000000))
    (new-commitment (+ commitment (get totalContributed hatch)))
  )
    (if (> new-commitment max-commitment)
      (- max-commitment (get totalContributed hatch))
      commitment
    )
  )
)

;; HATCHING ENDS
;; --------------------------------------------------------------------------

(define-public (set-end-block (HatchId uint) (contributionsEndBlock uint)) 
  (let
      (
        (hatch (unwrap! (map-get? HatchInfo { HatchId: HatchId }) (err ERR_POOL_NOT_FOUND)))
      )
      (asserts! (is-authorized-auth-manager) (err ERR_CALLER_NOT_AUTHORISED))
      (asserts! (map-set HatchInfo {HatchId: HatchId}
        {
          contributionsStartBlock: (get contributionsStartBlock pool),
          contributionsEndBlock: contributionsEndBlock,
          totalContributed: (get totalContributed pool),
          feePercentage: (get feePercentage pool),
        }
      ) (err u0))
      (ok true)
  )
)

(define-read-only (hatch-successful (HatchId uint))
  (let (
    (clearing (clearing-price HatchId))
    (token (token-price HatchId))
  )
    (if (>= token clearing)
      true
      false
    )
  )
)

(define-read-only (hatch-ended (HatchId uint))
  (let (
    (hatch (unwrap-panic (get-hatch-info HatchId)))
  )
    (if (> block-height (get contributionsEndBlock hatch))
      true
      false
    )
  )
)

;; HATCHING CLAIM 
;; --------------------------------------------------------------------------

(define-public (withdraw-tokens (HatchId uint))
  (let (
    (user tx-sender)
    (claimable (tokens-claimable HatchId user))

    (user-committed (get-commitments user HatchId))
    (current-claimed (get claimed user-committed))
  )
    (asserts! (> claimable u0) (err ERR-NO-CLAIMABLE-TOKENS))

    (map-set commitments
      { user: user, HatchId: HatchId }
      (merge user-committed { claimed: claimable })
    )
  
    (try! (as-contract (contract-call? .MeaningFullToken transfer claimable (as-contract tx-sender) user none)))

    (ok claimable)
  )
)

(define-read-only (tokens-claimable (HatchId uint) (user principal))
  (let (
    (hatch (unwrap-panic (get-hatch-info HatchId)))
    (user-committed (get committed (get-commitments user HatchId)))
    (user-claimed (get claimed (get-commitments user HatchId)))

    (totalContributed (get totalContributed hatch))
  )
    (if (is-eq totalContributed u0)
      u0
      (let (
        (total-claimable (/ (* user-committed (get total-tokens hatch)) totalContributed))
        (claimable (- total-claimable user-claimed))
      )
        (if (and (hatch-ended HatchId) (hatch-successful HatchId))
          claimable
          u0
        )  
      )
    )
  )
)

(define-public (withdraw-committed (token <ft-trait>) (HatchId uint))
  (let (
    (user tx-sender)
    (hatch (unwrap-panic (get-hatch-info HatchId)))

    (user-committed (get-commitments user HatchId))
    (current-committed (get committed user-committed))
    (current-claimed (get claimed user-committed))
    (claimable (- current-committed current-claimed))
  )
    (asserts! (is-eq (contract-of token) (get payment-token hatch)) (err ERR-WRONG-TOKEN))
    (asserts! (hatch-ended HatchId) (err ERR-AUCTION-NOT-ENDED))
    (asserts! (not (hatch-successful HatchId)) (err ERR-AUCTION-SUCCESSFUL))
    (asserts! (> claimable u0) (err ERR-NO-CLAIMABLE-TOKENS))

    (map-set commitments
      { user: user, HatchId: HatchId }
      (merge user-committed { claimed: claimable })
    )
  
    (try! (as-contract (contract-call? token transfer claimable (as-contract tx-sender) user none)))

    (ok claimable)
  )
)
;; HATCHING REWARD CLAIM ACTIONS
;; --------------------------------------------------------------------------

;; TOKEN CONFIGURATION
;; --------------------------------------------------------------------------

;; UTILITIES
;; --------------------------------------------------------------------------

;; TOKEN FREZZE & TOKEN THAW
;; --------------------------------------------------------------------------

;; AUGMENTED BONDING CURVE
;; --------------------------------------------------------------------------

;; TOA VOTING
;; --------------------------------------------------------------------------

;; CONVICTION VOTING
;; --------------------------------------------------------------------------

;; DOA
;; --------------------------------------------------------------------------






