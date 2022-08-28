(define-constant fee-ratio u997)
(define-constant curator-ratio u3)
(define-constant total-ratio u1000)


(define-read-only (get-owner-amount (init-amount uint))
  ( / (* init-amount fee-ratio)  total-ratio)
)

(define-read-only (get-curator-amount (init-amount uint))
  ( / (* init-amount curator-ratio)  total-ratio)
)

(define-data-var appchain-config
    {
        ;; 32-bit unique chain identifier (goes into the chain's transactions)
        chain-id: uint,
        ;; height on the host chain at which the appchain's blocks start
        start-height: uint,
        ;; list of boot nodes' public keys, p2p addresses, and rpc addresses
        boot-nodes: (list 16 { public-key: (buff 33), host: (buff 16), port: (buff 2), data-host: (buff 16), data-port: (buff 2) }),
        ;; PoX config for the appchain
        pox: {
            reward-cycle-length: uint,
            prepare-length: uint,
            anchor-threshold: uint,
            pox-rejection-fraction: uint,
            pox-participation-threshold-pct: uint,
            sunset-start: uint,
            sunset-end: uint
        },
        ;; Block limit for the app chain
        block-limit: {
            write-length: uint,
            write-count: uint,
            read-length: uint,
            read-count: uint,
            runtime: uint
        },
        ;; List of contract names that will execute as part of the appchain boot code.
        boot-code: (list 128 (string-ascii 128)),
        ;; List of initial balances to be allocated in the appchain genesis block
        initial-balances: (list 128 { recipient: principal, amount: uint })
    }
    {
        ;; chain ID: 0x80000002
        chain-id: u2147483650,
        ;; mining starts now -- as soon as the transaction containing this contract is mined
        start-height: block-height,
        ;; one initial boot node.
        ;; In practice, this contract would have a function for updating this list.
        boot-nodes: (list
            {
                public-key: 0x025f2a3e20527805a5bc57539b4a127764738510480bc5545458d4a3d1375ba135, 
                ;; 44.199.104.134:14300
                host: 0x00000000000000000000ffff2cc76886,
                port: 0x37dc,
                ;; 44.199.104.134:14301
                data-host: 0x00000000000000000000ffff2cc76886,
                data-port: 0x37dd
            }
        ),
        
       pox: {
            ;; 100-block reward cycle
            reward-cycle-length: u100,
            ;; 20-block prepare phase
            prepare-length: u20,
            ;; 16 out of 20 prepare phase blocks must confirm an anchor block
            anchor-threshold: u16,
            ;; at least 25% of all liquid appchain tokens must vote to turn off PoX per reward cycle
            pox-rejection-fraction: u25,
            ;; at least 5% of all liquid appchain tokens must stack in order for PoX to activate in a reward cycle
            pox-participation-threshold-pct: u5,
            ;; basically never sunset -- use the largest allowed values by the node
            sunset-start: u18446744073709551615,
            sunset-end: u18446744073709551615
        },
        ;; Block size -- 2x what Stacks mainnet is
        block-limit: {
            write-length: u30000000,
            write-count: u15500,
            read-length: u200000000,
            read-count: u15500,
            runtime: u10000000000
        },
        ;; One custom boot code contract that prints "hello appchains!" (just to prove that this feature works)
        boot-code: (list
            "hello-world"
        ),
        ;; Initial appchain tokens -- allocate a faucet
        initial-balances: (list
            {
                recipient: 'ST310DN3W42RNTYDQBVFYPA1ZBE40ENNG49ZM58X1,
                amount: u1000000000000
            }
        )
    }
)