;; utility-verification.clar
;; This contract validates and manages energy providers

(define-data-var admin principal tx-sender)

;; Map to store verified utilities
(define-map verified-utilities principal
  {
    name: (string-utf8 100),
    status: bool,
    registration-time: uint,
    region: (string-utf8 50)
  }
)

;; Public function to register a new utility (only admin)
(define-public (register-utility (utility-address principal) (name (string-utf8 100)) (region (string-utf8 50)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1)) ;; Only admin can register
    (asserts! (is-none (map-get? verified-utilities utility-address)) (err u2)) ;; Cannot register twice

    (map-set verified-utilities utility-address
      {
        name: name,
        status: true,
        registration-time: block-height,
        region: region
      }
    )
    (ok true)
  )
)

;; Public function to update utility status (only admin)
(define-public (update-utility-status (utility-address principal) (new-status bool))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1)) ;; Only admin can update
    (asserts! (is-some (map-get? verified-utilities utility-address)) (err u3)) ;; Utility must exist

    (let ((utility (unwrap-panic (map-get? verified-utilities utility-address))))
      (map-set verified-utilities utility-address
        (merge utility { status: new-status })
      )
    )
    (ok true)
  )
)

;; Read-only function to check if a utility is verified
(define-read-only (is-verified-utility (utility-address principal))
  (match (map-get? verified-utilities utility-address)
    utility (is-eq (get status utility) true)
    false
  )
)

;; Read-only function to get utility details
(define-read-only (get-utility-details (utility-address principal))
  (map-get? verified-utilities utility-address)
)

;; Function to transfer admin rights (only current admin)
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (var-set admin new-admin)
    (ok true)
  )
)
