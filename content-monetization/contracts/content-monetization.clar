;; Define the contract owner
(define-constant contract-owner tx-sender)

;; Define error codes
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_INVALID_AMOUNT (err u101))
(define-constant ERR_SUBSCRIPTION_EXISTS (err u102))
(define-constant ERR_SUBSCRIPTION_NOT_FOUND (err u103))
(define-constant ERR_CONTENT_NOT_FOUND (err u104))

(define-constant ERR_INSUFFICIENT_BALANCE (err u105))
(define-constant ERR_TRANSFER_FAILED (err u106))
(define-constant ERR_INVALID_ROYALTY (err u107))


;; Data maps and variables
(define-map subscriptions { subscriber: principal } { creator: principal, expiry: uint })
(define-map content { content-id: uint } { creator: principal, price: uint, royalty-percentage: uint })
(define-map royalties { creator: principal } { balance: uint })

;; Helper function to check if the caller is the contract owner
(define-private (is-owner)
    (is-eq tx-sender contract-owner)
)

;; Create a new content item
(define-public (create-content (content-id uint) (price uint) (royalty-percentage uint))
    (begin
        ;; Ensure the caller is the contract owner
        (asserts! (is-owner) ERR_NOT_AUTHORIZED)

        ;; Ensure the content ID does not already exist
        (asserts! (is-none (map-get? content { content-id: content-id })) ERR_CONTENT_NOT_FOUND)

        ;; Add the content to the map
        (map-set content { content-id: content-id } { creator: tx-sender, price: price, royalty-percentage: royalty-percentage })
        (ok true)
    )
)

;; Check if a user has an active subscription
(define-read-only (has-active-subscription (subscriber principal) (creator principal))
    (let (
        (subscription (unwrap! (map-get? subscriptions { subscriber: subscriber }) ERR_SUBSCRIPTION_NOT_FOUND))
        (expiry (get expiry subscription))
    )
    (ok (> expiry stacks-block-height))
    )
)

;; Get the royalty balance for a creator
(define-read-only (get-royalty-balance (creator principal))
    (ok (default-to u0 (get balance (map-get? royalties { creator: creator }))))
)

;; Extend subscription
(define-public (extend-subscription (subscriber principal) (creator principal) (duration uint))
    (begin
        ;; Ensure the caller is the contract owner or the subscriber
        (asserts! (or (is-eq tx-sender contract-owner) (is-eq tx-sender subscriber)) ERR_NOT_AUTHORIZED)

        ;; Get the current subscription
        (let (
            (subscription (unwrap! (map-get? subscriptions { subscriber: subscriber }) ERR_SUBSCRIPTION_NOT_FOUND))
            (current-expiry (get expiry subscription))
        )
        ;; Update the subscription expiry
        (map-set subscriptions { subscriber: subscriber } { creator: creator, expiry: (+ current-expiry duration) })

        (ok true)
    )
)
)

;; Get content details
(define-read-only (get-content-details (content-id uint))
    (ok (map-get? content { content-id: content-id }))
)




