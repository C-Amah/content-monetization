;; Define the contract owner
(define-constant contract-owner tx-sender)

;; Define error codes
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_INVALID_AMOUNT (err u101))
(define-constant ERR_SUBSCRIPTION_EXISTS (err u102))
(define-constant ERR_SUBSCRIPTION_NOT_FOUND (err u103))
(define-constant ERR_CONTENT_NOT_FOUND (err u104))


;; Data maps and variables
(define-map subscriptions { subscriber: principal } { creator: principal, expiry: uint })
(define-map content { content-id: uint } { creator: principal, price: uint, royalty-percentage: uint })
(define-map royalties { creator: principal } { balance: uint })
