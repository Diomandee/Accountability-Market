;; (define-trait AugmentedBondingCurve-trait 
;;     (
;;         (get-collateral-type-by-name ((string-ascii 12)) (response (tuple 
;;         (_reserve principal) 
;;         (_beneficiary principal) 
;;         (_contributionToken principal) 
;;         (_reserve (string-ascii 256)) 
;;         (url (string-ascii 256))
;;         (_minGoal uint) 
;;         (_maxGoal uint) 
;;         ( _period uint) 
;;         (_exchangeRate uint) 
;;         (_vestingCliffPeriod uint) 
;;         (_vestingCompletePeriod uint) 
;;         (_supplyOfferedPct uint) 
;;         (_fundingForBeneficiaryPct uint) 
;;         (_openDate uint)) bool))

;;         (mint-for-dao (uint principal) (response uint uint))
;;         (mint-for-dao (uint principal) (response uint uint))
;;         (mint-for-dao (uint principal) (response uint uint))
;;         (mint-for-dao (uint principal) (response uint uint))

;;         (fetch-price ((string-ascii 12)) (response (tuple 
;;         (last-price-in-cents uint) 
;;         (last-block uint)) uint))

;;         (SetOpenDate (uint) (response uint bool))
;;         (Contribute () (response uint bool))
;;         (initiate-stacking ((tuple (version (buff 1)) (hashbytes (buff 20))) uint uint)     (response uint uint))
;;         (request-stx-for-withdrawal (uint) (response bool uint))
;;         (payout (uint) (response bool uint))
;;         (get-stx-balance () (response uint uint))

;;         (initialize ((string-ascii 32) (string-ascii 32) uint (string-utf8 256) (string-utf8 256) principal uint) (response uint uint))


;;     )
;; )
;; ;; AugmentedBondingCurve-trait
;; ;; <add a description here>

;; ;; constants
;; ;;

;; ;; data maps and vars
;; ;;

;; ;; private functions
;; ;;

;; ;; public functions
;; ;;
;;     (get-collateral-type-by-name ((string-ascii 12)) (response (tuple (name (string-ascii 256)) (token (string-ascii 12)) (token-type (string-ascii 12)) (token-address principal) (url (string-ascii 256)) (total-debt uint) (liquidation-ratio uint) (collateral-to-debt-ratio uint) (maximum-debt uint) (liquidation-penalty uint) (stability-fee uint) (stability-fee-decimals uint) (stability-fee-apy uint)) bool))



;; (define-data-var tokenManager principal bool)
;; (define-data-var reserve principal bool)
;; (define-data-var beneficiary principal bool)
;; (define-data-var contributionToken principal bool)
;; (define-data-var minGoal principal bool)
;; (define-data-var maxGoal principal bool)
;; (define-data-var period principal bool)
;; (define-data-var exchangeRate principal bool)
;; (define-data-var vestingCliffPeriod principal bool)
;; (define-data-var vestingCompletePeriod principal bool)
;; (define-data-var supplyOfferedPct principal bool)
;; (define-data-var fundingForBeneficiaryPct principal bool)
;; (define-data-var openDate principal bool)


(define-data-var Hatch-Params
    {
      Module-1: {
        Token-Freeze-Cycle: uint,
        Token-Thaw-Cycle: uint,
        Opening-Price: uint
      },
      Module-2: {
        Nftree-Tribute: uint,
        Entry-Tribute: uint,
        Exit-Tribute: uint
      },
      Module-3: {
        Support-Required: uint,
        Minimum-Quorum: uint,
        Delegated-Voting-Period: uint,
        Vote-Duration: uint,
        Quiet-Ending-Period: uint,
        Quiet-Ending-Extension: uint,
        Execution-Delay: uint,
      },
      Module-4: {
        Conviction-Growth: uint,
        Minimum-Conviction: uint,
        Spending-Limit: uint
      }
    }
    {
       Module-1: {
        Token-Freeze-Cycle: u32,
        Token-Thaw-Cycle: u32,
        Opening-Price: u1
      },
      Module-2: {
        Nftree-Tribute: u30,
        Entry-Tribute: u3,
        Exit-Tribute: u3
      },
      Module-3: {
        Support-Required: u75,
        Minimum-Quorum: u15,
        Delegated-Voting-Period: u7,
        Vote-Duration: u4,
        Quiet-Ending-Period: u1,
        Quiet-Ending-Extension: u2,
        Execution-Delay: u1,
      },
      Module-4: {
        Conviction-Growth: u15,
        Minimum-Conviction: u3,
        Spending-Limit: u12
      }
    }
)
(define-read-only (get-hatch-params)
  (ok (var-get Hatch-Params))
)



(define-public (contribute (HatchId uint) (amountUstx uint)) 
    (let
      (
        (hatch (unwrap-panic (get-auction-info HatchId)))
        (contributionsEndBlock (get contributionsEndBlock hatch))
        (contributionsStartBlock (get contributionsStartBlock hatch))
        (callerAddress tx-sender)
        (currentContribution (get amountUstx (map-get? Contributions {HatchId: HatchId, address: callerAddress})))
      )

      (asserts! (< block-height contributionsEndBlock) (err ERR_CONTRIBUTION_PERIOD_ENDED))
      (asserts! (>= block-height contributionsStartBlock) (err ERR_CONTRIBUTION_PERIOD_NOT_STARTED))
      (asserts! (>= (stx-get-balance callerAddress) amountUstx) (err ERR_INSUFFICIENT_BALANCE))

      (try! (stx-transfer? amountUstx callerAddress POOL_CONTRACT_ADDRESS))

      (if (is-none currentContribution)
          (begin
            (asserts! (map-insert Contributions {HatchId: HatchId, address: callerAddress} 
            {amountUstx: amountUstx}) (err u0))
            (asserts! (map-insert Claims {HatchId: HatchId, address: callerAddress} 
            {mineManysClaimed: (list)}) (err u0))
          )
          (asserts! (map-set Contributions {HatchId: HatchId, address: callerAddress} {amountUstx: (+ (unwrap-panic currentContribution) amountUstx)}) (err u0))
      )

      (asserts! (map-set HatchInfo {HatchId: HatchId}
        {
          contributionsStartBlock: (get contributionsStartBlock hatch),
          contributionsEndBlock: contributionsEndBlock,
          totalContributed: (+ (get totalContributed hatch) amountUstx),
          feePercentage: (get feePercentage hatch),
        }
      ) (err u0))

      (ok true)
    )
)

(define-public (commit-tokens (token <ft-trait>) (HatchId uint) (amount uint))
  (let (
    (auction (unwrap-panic (get-auction-info HatchId)))
    (tokens-to-transfer (calculate-commitment HatchId amount))
  )
    (asserts! (hatch-open HatchId) (err ERR_CONTRIBUTION_PERIOD_NOT_STARTED))
    (asserts! (is-eq (contract-of token) (get payment-token hatch)) (err ERR-WRONG-TOKEN))

    (if (> tokens-to-transfer u0)
      (begin
        ;; Transfer from user
        (try! (stx-transfer? amountUstx callerAddress POOL_CONTRACT_ADDRESS))
        (try! (contract-call? token transfer tokens-to-transfer tx-sender (as-contract tx-sender) none))

        ;; Add commitment
        (add-commitment HatchId tx-sender tokens-to-transfer)
      )
      (ok u0)
    )
  )
)