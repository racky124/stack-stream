;; -------------------------------------------
;; Contract: stack-stream
;; Trustless STX Salary Streamer
;; -------------------------------------------

(define-constant ERR_NOT_EMPLOYER (err u100))
(define-constant ERR_NOT_RECIPIENT (err u101))
(define-constant ERR_NO_STREAM (err u102))
(define-constant ERR_ZERO_AMOUNT (err u103))
(define-constant ERR_STX_TRANSFER_FAILED (err u104))

(define-data-var stream-id uint u0)

(define-map streams
  uint ;; stream-id
  {
    employer: principal,
    recipient: principal,
    total-amount: uint,
    start-block: uint,
    end-block: uint,
    withdrawn: uint,
    cancelled: bool
  }
)

;; === Create a stream ===
(define-public (create-stream (recipient principal) (duration uint) (amount uint))
  (let (
        (sid (var-get stream-id))
        (current-block stacks-block-height)
      )
    (begin
      (asserts! (> amount u0) ERR_ZERO_AMOUNT)
      (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
      (map-set streams
        sid
        {
          employer: tx-sender,
          recipient: recipient,
          total-amount: amount,
          start-block: current-block,
          end-block: (+ current-block duration),
          withdrawn: u0,
          cancelled: false
        }
      )
      (var-set stream-id (+ sid u1))
      (ok sid)
    )
  )
)

;; === Withdraw available balance ===
(define-public (withdraw (id uint))
  (let ((stream (unwrap! (map-get? streams id) ERR_NO_STREAM)))
    (begin
      (asserts! (is-eq (get recipient stream) tx-sender) ERR_NOT_RECIPIENT)
      (let (
            (now stacks-block-height)
            (start (get start-block stream))
            (end (get end-block stream))
            (total (get total-amount stream))
            (withdrawn (get withdrawn stream))
            (cancelled (get cancelled stream))
            (duration (- end start))
            (elapsed (if (> now end) duration (- now start)))
            (earned (/ (* total elapsed) duration))
            (available (- earned withdrawn))
          )
        (if (<= available u0)
            (ok u0)
            (begin
              (try! (stx-transfer? available (as-contract tx-sender) tx-sender))
              (map-set streams id (merge stream {withdrawn: (+ withdrawn available)}))
              (ok available)
            )
        )
      )
    )
  )
)

;; === Cancel stream (only employer) ===
(define-public (cancel-stream (id uint))
  (let ((stream (unwrap! (map-get? streams id) ERR_NO_STREAM)))
    (begin
      (asserts! (is-eq (get employer stream) tx-sender) ERR_NOT_EMPLOYER)
      (map-set streams id (merge stream {cancelled: true, end-block: stacks-block-height}))
      (ok true)
    )
  )
)

;; === View stream ===
(define-read-only (get-stream (id uint))
  (match (map-get? streams id)
    stream (ok stream)
    (err ERR_NO_STREAM)
  )
)