 Stack Stream

**A Clarity Smart Contract for Real-Time STX and SIP-010 Token Streaming on the Stacks Blockchain**

---

 Overview

Stack Stream enables **continuous, real-time payment streams** between users using either STX or SIP-010 compatible tokens. Designed for subscriptions, payroll, grants, and vesting schedules, it allows users to initiate, receive, and manage token streams transparently and securely.

---

 Features

-  **Stream Creation**: Define token flow rate, duration, and recipient.
-  **Real-Time Withdrawals**: Recipients can withdraw the accrued balance at any time.
-  **Stream Cancellation**: Streamers can cancel unspent balances.
-  **Modular Design**: Easily extendable for vesting, NFT-gated access, or DAO payroll.
-  **Clarity-Based Security**: Fully on-chain and auditable.

---

 Smart Contract Details

- **Language**: Clarity
- **Contract Name**: `stack-stream`
- **Compatibility**: STX & SIP-010 tokens
- **Tested With**: Clarinet

---

 Functions

| Function | Description |
|---------|-------------|
| `create-stream` | Initializes a new payment stream. |
| `withdraw-from-stream` | Recipient pulls available tokens based on elapsed time. |
| `cancel-stream` | Terminates the stream and refunds remaining balance to the sender. |
| `get-stream-info` | Returns details about an active stream. |

---

Testing

```bash
clarinet test
