# 🧬 COHR LAB Command Center
<img width="1531" height="684" alt="ChatGPT Image Apr 2, 2026, 05_52_12 AM" src="https://github.com/user-attachments/assets/5bd792f2-29e5-46b4-9f4a-7ab3d7702685" />

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

## 🔐 Execution Guarantees

COHR enforces strict invariants at the contract level:

- ✅ A batch can only move forward (no rollback)
- ✅ Only the owner can mutate state
- ✅ Each stage is executed exactly once
- ✅ Terminal states are irreversible
- ✅ Full lifecycle can be reconstructed from events alone

> This ensures deterministic, audit-safe execution under all conditions

---

## ⚠️ Failure Modes & Constraints

- ❌ Incorrect gas overrides will cause transaction failure (XRPL EVM limitation)
- ❌ Users must manually confirm every transaction (no relayer layer)
- ❌ No batching — each lifecycle step is a discrete transaction
- ❌ UI does not cache state — all reads come directly from chain
- ❌ Network instability directly impacts execution and UX
- ❌ Frontend dependency — no fallback execution path without UI

### Mitigations

- ✅ Explicit gas configuration enforced in all write calls
- ✅ Idempotent contract design (no duplicate state transitions)
- ✅ Event-driven UI reconstruction (stateless frontend)
- ✅ Clear lifecycle boundaries reduce invalid transitions

---

## 🔒 Security Considerations

- ✅ No external contract calls → eliminates reentrancy risk
- ✅ Strict ownership enforcement on all state mutations
- ✅ Bounded state machine → prevents invalid stage transitions
- ✅ No dynamic execution paths → predictable behavior
- ✅ Immutable deployment → no upgrade attack surface

### Known Limitations

- ❌ No pausable mechanism (cannot halt contract)
- ❌ No emergency admin override
- ❌ No upgrade proxy (logic cannot be modified post-deploy)

> Designed for deterministic execution over administrative control

---

## ⛽ Gas & Performance

### Execution Costs (Approximate)

- ✅ createBatch → ~120k gas
- ✅ advanceBatch → ~80k gas
- ✅ setStepNote → ~60k gas

### Optimization Characteristics

- ✅ Fixed-size arrays reduce dynamic storage overhead
- ✅ uint8 stage encoding minimizes storage footprint
- ✅ No external calls → consistent gas profile
- ✅ Linear lifecycle progression → predictable execution cost
- ✅ No complex loops → bounded computation

> Designed for predictable, stable execution per lifecycle step

---

## Lifecycle System

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

## 🧪 Local Execution

COHR LAB is a **stateless frontend** that interacts directly with a deployed smart contract — no backend required.

```bash
git clone https://github.com/zrt219/cohr-lab
cd cohr-lab
npx serve .
```

Open: http://localhost:3000

---

### 🦊 MetaMask (XRPL EVM Testnet)

| Field | Value |
|------|------|
| RPC | https://rpc.testnet.xrplevm.org |
| Chain ID | 1449000 |
| Symbol | XRP |

---

### ⚠️ Gas Override (Required)

```js
const overrides = {
  gasLimit: 300000,
  gasPrice: ethers.utils.parseUnits("100", "gwei"),
  type: 0
};
```

---

## 🚀 Deploy (Vercel)

- Import repo into Vercel  
- Framework: **Other**  
- Build: **none**  
- Output: `./`  

> Static deployment — UI connects directly to XRPL EVM


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

Core XRPL EVM systems plus related public product and AI repositories from the same portfolio.

<table>
  <thead>
    <tr>
      <th>Project</th>
      <th>Description</th>
      <th>Status</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><a href="https://github.com/zrt219/Zuc-Mine-Command-Center">ZUC Mine Command Center</a></td>
      <td>On-chain uranium mining operations dashboard with real-time reserve tracking, miner registry, and direct contract interaction through a frontend-only control surface.</td>
      <td><a href="https://zuc-mine-command-center.vercel.app/">Live</a></td>
    </tr>
    <tr>
      <td><a href="https://github.com/zrt219/-U235-Fuel-Cycle-">U235 Fuel Cycle</a></td>
      <td>Deterministic XRPL EVM fuel-cycle pipeline that tracks uranium batches from ore to enriched fuel rod with full on-chain traceability.</td>
      <td><a href="https://u235-fuel-cycle.vercel.app/">Live</a></td>
    </tr>
    <tr>
      <td><a href="https://github.com/zrt219/ISR-Network">ISR Network</a></td>
      <td>In-situ recovery control system with on-chain asset tracking, lifecycle state transitions, and operator-facing industrial simulation.</td>
      <td><a href="https://isr-network.vercel.app/">Live</a></td>
    </tr>
    <tr>
      <td><a href="https://github.com/zrt219/Dark-Matter-Farm">Dark Matter Farm</a></td>
      <td>XRPL EVM staking protocol with three orbit tiers, lock-period yield mechanics, and event-driven reward emissions.</td>
      <td><a href="https://dark-matter-farm.vercel.app/">Live</a></td>
    </tr>
    <tr>
      <td><a href="https://github.com/zrt219/Cohr-Lab">Cohr Lab</a></td>
      <td>Semiconductor laser fabrication lifecycle modeled as an immutable on-chain state machine from crystal growth to final pigtail.</td>
      <td><a href="https://cohr-lab.vercel.app">Live</a></td>
    </tr>
    <tr>
      <td><a href="https://github.com/zrt219/ForgeX">ForgeX</a></td>
      <td>Foundry-powered XRPL EVM deployment console that combines a natural-language UI, Node CLI orchestration, and realtime shader-based visuals.</td>
      <td><a href="https://forgex-theta.vercel.app">Live</a></td>
    </tr>
    <tr>
      <td><a href="https://github.com/zrt219/DatumX">DatumX</a></td>
      <td>Verification protocol for AI-transformed industrial data with deterministic lineage, validator review, and XRPL EVM finalization.</td>
      <td><a href="https://datumx.vercel.app">Live</a></td>
    </tr>
    <tr>
      <td><a href="https://github.com/zrt219/Ethex-Lottery-Game">Ethex Lottery Game</a></td>
      <td>Foundry plus Next.js betting workflow that modernizes the EthexLoto lifecycle for XRPL EVM reviewer-facing execution.</td>
      <td>Public Repo</td>
    </tr>
    <tr>
      <td><a href="https://github.com/zrt219/3DMoonX">3DMoonX</a></td>
      <td>Cinematic lunar industrial-base experience that combines Blender source assets with a React Three Fiber web runtime.</td>
      <td><a href="https://3dmoonx.vercel.app">Live</a></td>
    </tr>
    <tr>
      <td><a href="https://github.com/zrt219/Unknown002">Unknown002</a></td>
      <td>Browser-based 3D engineering viewer for a nuclear-electric propulsion spacecraft concept with staged prompt-pack support.</td>
      <td>Public Repo</td>
    </tr>
    <tr>
      <td><a href="https://github.com/zrt219/AI-Engineering-Evidence-Engine">AI Engineering Evidence Engine</a></td>
      <td>Interactive evidence dashboard that turns local engineering proof into a reviewer-facing systems narrative.</td>
      <td><a href="https://zhane-grey-evidence-dashboard.vercel.app/">Live</a></td>
    </tr>
    <tr>
      <td><a href="https://github.com/zrt219/Build-Doctor">Build Doctor</a></td>
      <td>Codex-style build diagnosis harness for failed Next.js and Vercel builds with deterministic failure analysis.</td>
      <td><a href="https://vercel-build-doctor-agent.vercel.app">Live</a></td>
    </tr>
    <tr>
      <td><a href="https://github.com/zrt219/ai-gateway-failover-playground">AI Gateway Failover Playground</a></td>
      <td>Public-facing sandbox for request routing, provider fallback, and resilient AI gateway behavior.</td>
      <td><a href="https://ai-gateway-failover-playground.vercel.app">Live</a></td>
    </tr>
    <tr>
      <td><a href="https://github.com/zrt219/enterprise-agent-workflow-studio">Enterprise Agent Workflow Studio</a></td>
      <td>Public-facing studio for approval-gated enterprise agent workflows, risk scoring, and audit-oriented design.</td>
      <td><a href="https://enterprise-agent-workflow-studio.vercel.app">Live</a></td>
    </tr>
    <tr>
      <td><a href="https://github.com/zrt219/resume-evidence-rag-auditor">Resume Evidence RAG Auditor</a></td>
      <td>Public-facing proof surface for claim verification, evidence retrieval, and grounded resume bullet generation.</td>
      <td><a href="https://resume-evidence-rag-auditor.vercel.app">Live</a></td>
    </tr>
    <tr>
      <td><a href="https://github.com/zrt219/AI-resume-tailor-service-">AI Resume Tailor Service</a></td>
      <td>Static Vercel-ready application for evidence-backed resume, cover-letter, and job-packet tailoring.</td>
      <td><a href="https://ai-resume-tailor-service.vercel.app">Live</a></td>
    </tr>
    <tr>
      <td><a href="https://github.com/zrt219/Fuji">Fuji</a></td>
      <td>Cinematic Next.js Fuji gallery atlas for portfolio storytelling and visual system design.</td>
      <td><a href="https://fuji-byzrt.vercel.app">Live</a></td>
    </tr>
    <tr>
      <td><a href="https://github.com/zrt219/ld-2-0-website">LD 2.0 Website</a></td>
      <td>Next.js speaker website for Lornette Daye.</td>
      <td>Public Repo</td>
    </tr>
    <tr>
      <td><a href="https://github.com/zrt219/ai-agents-for-beginners">AI Agents for Beginners</a></td>
      <td>Lesson repository for getting started building AI agents.</td>
      <td>Public Repo</td>
    </tr>
    <tr>
      <td><a href="https://github.com/zrt219/agentic-rag-memory-digital-twin-edge-system">Agentic RAG Memory Digital Twin Edge System</a></td>
      <td>Public-facing landing page for an agentic RAG, memory, and digital-twin edge-system portfolio project.</td>
      <td><a href="https://agentic-rag-memory-digital-twin-edg.vercel.app">Live</a></td>
    </tr>
  </tbody>
</table>


## License

MIT — see [LICENSE](LICENSE)
