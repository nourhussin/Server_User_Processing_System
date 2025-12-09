# Multi-Clock Processing System

## User Domain (Slow Clock)

The User side is implemented as a **RAM block** containing 16-bit packets in the following format:

[ processed_flag | ID(7 bits) | data(8 bits) ]


- **processed_flag (1 bit):**  
  Indicates whether this RAM entry has already been processed.

- **ID (7 bits):**  
  Used for authentication and operation selection.  
  - The **upper 3 bits must be `101`** for the ID to be authenticated.  
  - The remaining **4 bits represent hot-dot encoding** for the desired operation.  If more than one bit is HIGH, the ID is invalid.

- **data (8 bits):**  
  Payload sent to the Operation Unit for processing.


## Server Domain (Medium Clock)

The Server domain is the main controller of the entire system. It performs:

- **Authenticates** user ID.  
- Decodes the **1-bit or 2-bit operation code** from the hot-dot encoding.  
- Sends both **operation code** and **data** to the Operation Unit across a clock boundary.  



## Operation Unit Domain (Fast Clock)

The Operation Unit executes the actual computation at the fastest clock in the system.

### Inputs
- **op_code (1–2 bits)** from the Server  
- **data (8 bits)** from the Server  

### Dummy Operations 
- Shift left by 2  
- Rotate left  
- (Optional) Add a constant  
- (Optional) Bitwise transform  


