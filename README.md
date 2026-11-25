# Allowlist Ballot

A two-option vote with a fixed electorate and a precise closing timestamp.

## How it works

1. Deploy with a nonempty list of distinct voters and a voting duration in seconds.
2. Each voter can call `vote(true)` for yes or `vote(false)` for no once before `closesAt`.
3. Call `passed()` after closing. A proposal passes when yes votes outnumber no votes.

Votes are public. A tie or an empty ballot fails. There is no quorum and the electorate cannot change.

## Build and test

Install [Foundry](https://getfoundry.sh/) and run these commands from this directory. Forge selects Solidity 0.8.36 from `foundry.toml`. The project has no third-party Solidity dependencies.

```bash
forge build
forge test -vv
forge coverage --exclude-tests
```

## Local deployment

Start a fresh `anvil` node in a separate terminal. Deploy with the first unlocked account on that local node.

```bash
export RPC_URL=http://127.0.0.1:8545
export ANVIL_ACCOUNT=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
forge create src/AllowlistBallot.sol:AllowlistBallot --rpc-url "$RPC_URL" --from "$ANVIL_ACCOUNT" --unlocked --broadcast --constructor-args "[$ANVIL_ACCOUNT]" 3600
```

## Local example

Set `CONTRACT` to the address printed by `forge create` and keep using the same terminal.

```bash
export ETH_RPC_URL="$RPC_URL"
CONTRACT=0x... # Replace with your deployed address.
cast send "$CONTRACT" 'vote(bool)' true --from "$ANVIL_ACCOUNT" --unlocked
cast call "$CONTRACT" 'yesVotes()(uint256)'
cast rpc evm_increaseTime 3600
cast rpc evm_mine
cast call "$CONTRACT" 'passed()(bool)'
```

## Test cases

Foundry reports 7 passing tests and 100% coverage on contract lines, statements, branches and functions.

- Electorate validation, duplicate and unauthorized vote rejection.
- Both vote options, ties, and the exact closing timestamp.
