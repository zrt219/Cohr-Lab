# 🧬 COHR LAB Command Center
<img width="1773" height="886" alt="ChatGPT Image Apr 2, 2026, 05_00_15 AM" src="https://github.com/user-attachments/assets/9cb5100c-b6cf-4cbd-ad03-40f469eba24b" />

>Deterministic on-chain lifecycle engine modeling semiconductor fabrication — executed entirely through direct contract interaction (no backend layer) built on the **XRPL EVM Sidechain Testnet**.
> A fully deployed Solidity contract powering a live Web3 state machine — no backend, no server, one frontend execution layer.

![XRPL EVM](https://img.shields.io/badge/XRPL%20EVM-Testnet%201449000-00FFB8?style=flat-square)
![Solidity](https://img.shields.io/badge/Solidity-0.8.x-A855F7?style=flat-square)
![Contract](https://img.shields.io/badge/Contract-Deployed-00D4FF?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-FFB830?style=flat-square)

---

## 🔴 Live Demo

**[View Dashboard →](https://cohr-lab.vercel.app/)**

**Contract on Explorer →** https://explorer.testnet.xrplevm.org/address/0x870201041262975C5b40941e1fE85792Fb2dfF3D

https://github.com/user-attachments/assets/409ba288-34fd-4486-89ae-a679c88cd821


>COHR Lab Simulator — a system-level interface for modeling event-driven workflows that trigger programmable on-chain value routing (USDC/XRP) across coordinated execution stages.
---

## What This Is

COHR LAB is the **operational control layer** for a deterministic semiconductor fabrication pipeline deployed on the XRPL EVM Sidechain.

It is not a static dashboard — it is a **direct execution interface over a production Solidity state machine**.

Through a single frontend surface, operators can:

- create fabrication batches
- advance batches through real manufacturing stages
- attach per-stage process notes
- track full lifecycle timestamps
- audit complete production history on-chain

The system enforces a strict constraint:

> **No backend. No API. No middleware.**

## Why This Matters

Most Web3 applications rely on off-chain orchestration layers, APIs, and backend services to coordinate execution.

COHR removes that entirely.

This system demonstrates:

- fully deterministic execution without backend infrastructure
- direct UI → contract interaction as the sole control surface
- on-chain lifecycle systems that mirror real-world industrial processes
- verifiable, replayable state transitions without reliance on external systems

> This is not a dashboard — it is a **control system for programmable reality**

### Data Flow

UI  
→ ethers.js (provider + signer)  
→ XRPL EVM Sidechain  
→ CohrLab.sol (state machine + lifecycle logic)

### Guarantees

- every state transition is immutable  
- every lifecycle step is timestamped  
- every batch is independently owned  
- every history is replayable from events  

---

## Features

### Blockchain
- ✅ Live contract deployed on XRPL EVM Testnet
- ✅ Deterministic 6-stage fabrication lifecycle
- ✅ Immutable state transitions (no rollback)
- ✅ Per-batch ownership enforcement
- ✅ Indexed event log for full lifecycle replay
- ✅ Terminal states (Complete / Abandoned)

---

### Lifecycle System

- ✅ Crystal → Wafer → Epitaxy → Lithography → Testing → Pigtail
- ✅ Per-stage timestamps stored on-chain
- ✅ Operator notes per stage
- ✅ Batch-level ownership model
- ✅ Event-driven audit reconstruction

---

## ⚡ Live Execution

![ScreenRecorderProject62](https://github.com/user-attachments/assets/369076ea-4544-4315-8327-6793dc0d39e3)

![ScreenRecorderProject61](https://github.com/user-attachments/assets/027d8081-89a3-4a83-8bc1-eb57e0dc7f1a)

![ScreenRecorderProject63](https://github.com/user-attachments/assets/4afc0ee7-6450-47d8-bd6c-3e3b97078716)

https://github.com/user-attachments/assets/51be3cc9-0983-4e9b-bd69-d853ed7afe50



## On-Chain Command Execution

This interface exposes direct interaction with the contract lifecycle system, allowing users to create and advance fabrication batches through signed transactions.

---

## Contract — `CohrLab.sol`

**Deployed:** `0x870201041262975C5b40941e1fE85792Fb2dfF3D`  
**Network:** XRPL EVM Sidechain Testnet (Chain ID: `1449000`)  
**Compiler:** Solidity `0.8.x`

---

### Write Functions
```solidity
createBatch(string name)
advanceBatch(uint256 id)
abandonBatch(uint256 id)
setStepNote(uint256 id, uint8 step, string note)
```

---

### Read Functions
```solidity
getBatch(uint256 id)
getBatchSteps(uint256 id)
getBatchCount()
getBatchesByOwner()
```

---

### Solidity Patterns Used

| Pattern | Implementation |
|---------|---------------|
| Explicit state machine | `uint8 stage (0–5)` |
| Terminal states | Complete / Abandoned |
| Per-record ownership | batch.owner |
| Fixed arrays | timestamps + notes |
| Indexed events | lifecycle tracking |
| No dependencies | single-file contract |

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Blockchain | XRPL EVM Sidechain Testnet |
| Smart Contract | Solidity 0.8.x |
| Web3 Provider | Ethers.js v5 |
| Frontend | Vanilla HTML/CSS/JS |
| Hosting | Vercel |

---

## Project Structure

```
cohr-lab/
├── index.html
├── CohrLab.sol
├── script/
├── README.md
└── LICENSE
```

---

## Running Locally

```bash
git clone https://github.com/zrt219/cohr-lab
cd cohr-lab
open index.html
```

---

## Connecting MetaMask

| Field | Value |
|-------|-------|
| Network Name | XRPL EVM Testnet |
| RPC URL | https://rpc.testnet.xrplevm.org |
| Chain ID | 1449000 |
| Symbol | XRP |
| Explorer | https://explorer.testnet.xrplevm.org |

---

## XRPL EVM Constraints

- ❌ No `eth_estimateGas`
- ❌ No `eth_gasPrice`

### Required Override

```js
const overrides = {
  gasLimit: 300000,
  gasPrice: ethers.utils.parseUnits("100", "gwei"),
  type: 0
};
```

---

## Redeploying the Contract (Foundry)

```bash
forge script script/Deploy.s.sol:DeployCohrLab --rpc-url https://rpc.testnet.xrplevm.org --broadcast --legacy -vvvv
```

---

<img width="1773" height="886" alt="ChatGPT Image Apr 2, 2026, 05_04_18 AM" src="https://github.com/user-attachments/assets/41add8a4-7e9e-4013-88db-f842e3b62087" />

## On-Chain Systems Portfolio

| Project | Description | Status |
|---------|-------------|--------|
| **[ZUC Mine Command Center](https://github.com/zrt219/Zuc-Mine-Command-Center)** | On-chain uranium mining operations dashboard — real-time reserve tracking, miner registry, and contract interaction via a fully frontend-driven command interface | ✅ Live |
| **[U235 Fuel Cycle](https://github.com/zrt219/-U235-Fuel-Cycle-)** | Nuclear fuel cycle pipeline — uranium ore to enriched fuel rod, deterministic multi-stage processing with full on-chain traceability | ✅ Live |
| **[ISR Network](https://github.com/zrt219/ISR-Network)** | Intelligence surveillance reconnaissance system — on-chain asset tracking, mission lifecycle state machine, and role-based operator control | ✅ Live |
| **[Dark Matter Farm](https://github.com/zrt219/Dark-Matter-Farm)** | DeFi yield protocol — experimental high-convexity farming system with custom reward mechanics and on-chain state-driven emissions | ✅ Live |
| **[COHR LAB](https://github.com/zrt219/cohr-lab)** | Semiconductor fabrication lifecycle system — deterministic on-chain state machine tracking irreversible production stages from crystal growth to final pigtail with full auditability | ✅ Live |
---

---

## License

MIT — see [LICENSE](LICENSE)
