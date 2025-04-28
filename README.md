# Real Estate Registry Management System - Smart Contract

## Overview
The Real Estate Registry Management System is a blockchain-based solution designed for transparent property record management. It provides a decentralized platform for the registration, tracking, and transfer of ownership of real estate assets. This contract is built to ensure secure, verifiable, and efficient management of property documentation.

## Key Features
- **Estate Registration**: Register new estates, including property titles, descriptions, document sizes, and category tags.
- **Ownership Validation**: Ensure only rightful owners can modify or transfer estate details.
- **Estate Updates**: Update details of existing estates, such as title, description, size, and tags.
- **Ownership Transfer**: Transfer ownership of an estate to another user.
- **Estate Deregistration**: Remove estates from the registry, ensuring only owners can deregister their properties.
- **Viewing Permissions**: Manage who can view estate information, ensuring that access is controlled and restricted.

## Contract Structure

### Configuration Constants
- **Controller Address**: The address of the contract deployer or administrator.
- **Error Constants**: A set of predefined error messages, including `ERR-NOT-FOUND`, `ERR-ALREADY-EXISTS`, `ERR-INVALID-NAME`, etc., to handle various edge cases.
  
### State Variables
- **`registry-count`**: A global counter used to assign unique identifiers to new estates.
- **`estate-registry`**: A mapping of estate IDs to their respective property records.
- **`viewing-permissions`**: A mapping that tracks which addresses have permission to view specific estates.

### Data Structures
1. **Estate Record**:
   - `estate-title`: The title/name of the estate.
   - `owner-address`: The principal address of the estate's owner.
   - `document-size`: The size of the document associated with the estate.
   - `registration-block`: The block height at which the estate was registered.
   - `property-description`: A detailed description of the property.
   - `category-tags`: A list of tags categorizing the estate.

2. **Viewing Permissions**:
   - `estate-id`: The unique identifier of the estate.
   - `viewer`: The address of the person requesting to view the estate.
   - `access-allowed`: A boolean indicating whether the viewer is allowed access.

### Public Functions

#### 1. `register-estate`
- Registers a new estate in the system with necessary details (title, document size, description, tags).
- **Parameters**:
  - `title`: The title of the estate.
  - `document-size`: Size of the estate's documentation.
  - `description`: A brief description of the estate.
  - `tags`: Tags categorizing the estate (maximum of 10 tags, each up to 32 characters).
- **Returns**: The ID of the newly registered estate.
- **Access**: Only the deployer (controller address) or authorized users can register estates.

#### 2. `update-estate`
- Allows the owner of an estate to update its title, document size, description, and tags.
- **Parameters**:
  - `estate-id`: The unique identifier of the estate to update.
  - `new-title`: The updated title.
  - `new-document-size`: The updated document size.
  - `new-description`: The updated description.
  - `new-tags`: The updated tags list.
- **Returns**: `true` if the update was successful.
- **Access**: Only the current owner can update the estate details.

#### 3. `deregister-estate`
- Deregisters an estate, removing it from the registry.
- **Parameters**:
  - `estate-id`: The unique identifier of the estate to deregister.
- **Returns**: `true` if the deregistration was successful.
- **Access**: Only the estate owner can deregister the property.

#### 4. `transfer-estate`
- Transfers ownership of an estate to another user.
- **Parameters**:
  - `estate-id`: The unique identifier of the estate to transfer.
  - `new-owner`: The address of the new owner.
- **Returns**: `true` if the transfer was successful.
- **Access**: Only the current owner can transfer the estate.

### Private Helper Functions
- **`estate-registered`**: Checks whether an estate exists in the registry.
- **`verify-ownership`**: Verifies that the given address is the rightful owner of the estate.
- **`fetch-document-size`**: Fetches the document size for a registered estate.
- **`is-valid-tag`**: Validates that a tag follows the correct format.
- **`validate-tags`**: Validates the collection of tags to ensure they are within the allowed constraints.

### Authorization and Permissions
- **Estate Owner**: The address that originally registered the estate has control over it, including the ability to update, transfer, or deregister the estate.
- **View Permissions**: Access to view estate details can be controlled using the `viewing-permissions` mapping.

## Error Handling
- **ERR-NOT-FOUND**: Thrown when an estate is not found in the registry.
- **ERR-ALREADY-EXISTS**: Thrown when trying to register an estate that already exists.
- **ERR-INVALID-NAME**: Thrown when an invalid name or title is provided.
- **ERR-INVALID-SIZE**: Thrown when an invalid document size is specified.
- **ERR-ACCESS-DENIED**: Thrown when unauthorized access is attempted.
- **ERR-OWNERSHIP-REQUIRED**: Thrown when an operation is attempted by someone who does not own the estate.
- **ERR-ADMIN-ONLY**: Thrown when an operation is restricted to admins only.
- **ERR-VIEW-RESTRICTED**: Thrown when access to view an estate is restricted.
- **ERR-INVALID-TAGS**: Thrown when the provided tags do not meet the validation criteria.

## Conclusion
This smart contract facilitates transparent and secure management of real estate documentation on the blockchain, ensuring that ownership, registration, and modification of property records are tamper-proof and accessible to the rightful parties. By leveraging decentralized technology, the Real Estate Registry Management System offers an innovative solution for modern property tracking.