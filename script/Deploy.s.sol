// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";
import {CohrLab} from "../src/CohrLab.sol";

/**
 * @title  Deploy
 * @notice Deployment script for CohrLab on XRPL EVM Sidechain.
 *
 * @dev    Usage (XRPL EVM requires --legacy flag — no EIP-1559):
 *
 *         export PRIVATE_KEY=0x...
 *         export RPC_URL=https://rpc.evm.xrpl.org
 *
 *         forge create src/CohrLab.sol:CohrLab \
 *           --rpc-url $RPC_URL \
 *           --private-key $PRIVATE_KEY \
 *           --legacy \
 *           --gas-price 100000000000
 *
 *         NOTE: forge script is intentionally NOT used here.
 *               XRPL EVM does not support eth_estimateGas reliably.
 *               Use forge create with --legacy and explicit --gas-price.
 */
contract Deploy is Script {
    function run() external returns (CohrLab lab) {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(pk);
        lab = new CohrLab();
        vm.stopBroadcast();
    }
}
