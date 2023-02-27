# Keys of XRPL
## How to play
### Cookie of Power 💪
To claim the Cookie of power the block number must end in 420.

### Cookie of Wisdom 🧠
To claim the Cookie of wisdom, submit a number. If the hash of that number is greater than the hash of the previous number, you get the cookie. 

### Cookie of Time ⏳
Anyone can claim this cookie if it has been greater than 1 week since the last claim date 

### Cookie of War 😈
If the block number is a even number, anyone can claim this cookie.

### Cookie of Wealth 💸
Anyone can claim this cookie if they spend more than the previous claimer.

## Deployment Details
Deployer: `0xd8533cb6f083177c26222b97c0b90e52e9135aaa`

Deployed to: `0x392F814DA5c3C0B9e8ee2742C8c85839e9171989`

Transaction hash: `0x2de5cdc54712193d1e9200163a2ecdc4d02a78e1e63ead9ace8d8ab7f0c1892f`

rpc: `https://rpc-evm-sidechain.xrpl.org`

## Deploying the contract and verifying
Deploy the contract with the following command:
```
$ forge create --rpc-url https://rpc-evm-sidechain.xrpl.org \
    --private-key <private-key> \
    src/HazardsCookiesV5.sol:HazardsCookiesV5
```

Verify the contract with the following command:
```
forge verify-contract  --chain-id 1440001 --verifier=blockscout \
--verifier-url=https://evm-sidechain.peersyst.tech/api  <contract>   src/HazardsCookiesV5.sol:HazardsCookiesV5
```

Local blockchain:
```
forge script script/Deploy.s.sol:Deploy --fork-url http://localhost:8545 \
--private-key $PRIVATE_KEY --broadcast
```
