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

;; Gets the document size for a registered estate
(define-private (fetch-document-size (estate-id uint))
  (default-to u0
    (get document-size
      (map-get? estate-registry { estate-id: estate-id })
    )
  )
)

;; Validates individual category tag format
(define-private (is-valid-tag (tag (string-ascii 32)))
  (and
    (> (len tag) u0)
    (< (len tag) u33)
  )
)

;; Ensures the complete tag collection meets requirements
(define-private (validate-tags (tags (list 10 (string-ascii 32))))
  (and
    (> (len tags) u0)
    (<= (len tags) u10)
    (is-eq (len (filter is-valid-tag tags)) (len tags))
  )
)

;; ===== Public Registry Functions =====

;; Registers a new estate in the system
(define-public (register-estate
  (title (string-ascii 64))
  (document-size uint)
  (description (string-ascii 128))
  (tags (list 10 (string-ascii 32)))
)
  (let
    (
      (next-id (+ (var-get registry-count) u1))
    )
    ;; Validate all inputs
    (asserts! (> (len title) u0) ERR-INVALID-NAME)
    (asserts! (< (len title) u65) ERR-INVALID-NAME)
    (asserts! (> document-size u0) ERR-INVALID-SIZE)
    (asserts! (< document-size u1000000000) ERR-INVALID-SIZE)
    (asserts! (> (len description) u0) ERR-INVALID-NAME)
    (asserts! (< (len description) u129) ERR-INVALID-NAME)
    (asserts! (validate-tags tags) ERR-INVALID-TAGS)

    ;; Create estate record
    (map-insert estate-registry
      { estate-id: next-id }
      {
        estate-title: title,
        owner-address: tx-sender,
        document-size: document-size,
        registration-block: block-height,
        property-description: description,
        category-tags: tags
      }
    )

    ;; Give access permission to creator
    (map-insert viewing-permissions
      { estate-id: next-id, viewer: tx-sender }
      { access-allowed: true }
    )

    ;; Update registry counter
    (var-set registry-count next-id)
    (ok next-id)
  )
)

;; Updates an existing estate's information
(define-public (update-estate
  (estate-id uint)
  (new-title (string-ascii 64))
  (new-document-size uint)
  (new-description (string-ascii 128))
  (new-tags (list 10 (string-ascii 32)))
)
  (let
    (
      (registry-entry (unwrap! (map-get? estate-registry { estate-id: estate-id })
      ERR-NOT-FOUND))
    )
    ;; Verify ownership and validate inputs
    (asserts! (estate-registered estate-id) ERR-NOT-FOUND)
    (asserts! (is-eq (get owner-address registry-entry) tx-sender) ERR-OWNERSHIP-REQUIRED)
    (asserts! (> (len new-title) u0) ERR-INVALID-NAME)
    (asserts! (< (len new-title) u65) ERR-INVALID-NAME)
    (asserts! (> new-document-size u0) ERR-INVALID-SIZE)
    (asserts! (< new-document-size u1000000000) ERR-INVALID-SIZE)
    (asserts! (> (len new-description) u0) ERR-INVALID-NAME)
    (asserts! (< (len new-description) u129) ERR-INVALID-NAME)
    (asserts! (validate-tags new-tags) ERR-INVALID-TAGS)

    ;; Update estate with new information
    (map-set estate-registry
      { estate-id: estate-id }
      (merge registry-entry {
        estate-title: new-title,
        document-size: new-document-size,
        property-description: new-description,
        category-tags: new-tags
      })
    )
    (ok true)
  )
)

;; Removes an estate from the registry
(define-public (deregister-estate (estate-id uint))
  (let
    (
      (registry-entry (unwrap! (map-get? estate-registry { estate-id: estate-id })
      ERR-NOT-FOUND))
    )
    ;; Verify estate exists and caller has ownership
    (asserts! (estate-registered estate-id) ERR-NOT-FOUND)
    (asserts! (is-eq (get owner-address registry-entry) tx-sender) ERR-OWNERSHIP-REQUIRED)

    ;; Remove the estate
    (map-delete estate-registry { estate-id: estate-id })
    (ok true)
  )
)

;; Transfers estate ownership to another address
(define-public (transfer-estate (estate-id uint) (new-owner principal))
  (let
    (
      (registry-entry (unwrap! (map-get? estate-registry { estate-id: estate-id })
      ERR-NOT-FOUND))
    )
    ;; Ensure caller is current owner
    (asserts! (estate-registered estate-id) ERR-NOT-FOUND)
    (asserts! (is-eq (get owner-address registry-entry) tx-sender) ERR-OWNERSHIP-REQUIRED)

    ;; Update ownership record
    (map-set estate-registry
      { estate-id: estate-id }
      (merge registry-entry { owner-address: new-owner })
    )
    (ok true)
  )
)

