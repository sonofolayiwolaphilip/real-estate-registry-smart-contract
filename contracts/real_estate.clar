;; Real Estate Registry Management System
;; Blockchain-based solution for real estate documentation and ownership tracking
;; Developed for transparent property record management

;; System-wide configuration constants
(define-constant controller-address tx-sender)
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-ALREADY-EXISTS (err u409))
(define-constant ERR-INVALID-NAME (err u422))
(define-constant ERR-INVALID-SIZE (err u423))
(define-constant ERR-ACCESS-DENIED (err u403))
(define-constant ERR-OWNERSHIP-REQUIRED (err u401))
(define-constant ERR-ADMIN-ONLY (err u405))
(define-constant ERR-VIEW-RESTRICTED (err u406))
(define-constant ERR-INVALID-TAGS (err u407))

;; Global state counter
(define-data-var registry-count uint u0)

;; Primary data structures for estate tracking
(define-map estate-registry
  { estate-id: uint }
  {
    estate-title: (string-ascii 64),
    owner-address: principal,
    document-size: uint,
    registration-block: uint,
    property-description: (string-ascii 128),
    category-tags: (list 10 (string-ascii 32))
  }
)

;; Authorization management for viewing properties
(define-map viewing-permissions
  { estate-id: uint, viewer: principal }
  { access-allowed: bool }
)

;; ===== Helper Functions =====

;; Checks if an estate exists in the registry
(define-private (estate-registered (estate-id uint))
  (is-some (map-get? estate-registry { estate-id: estate-id }))
)

;; Validates if a user is the rightful owner
(define-private (verify-ownership (estate-id uint) (user principal))
  (match (map-get? estate-registry { estate-id: estate-id })
    registry-entry (is-eq (get owner-address registry-entry) user)
    false
  )
)