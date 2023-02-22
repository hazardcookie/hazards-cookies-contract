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
Deployer: `0x67F141221bbDa7162373eC57aCbFa4E9564750e8`

Deployed to: `0xDA8969c0E047e12bfda6281283C7A7Bfdd0B70F5`

Transaction hash: `0x06dadc0fe29d695592000d507155a8f7c5d823aabbe564c2406c5e5d5509a3fe`

rpc: `https://rpc-evm-sidechain.xrpl.org`

## Deploying the contract and verifying
Deploy the contract with the following command:
```
$ forge create --rpc-url https://rpc-evm-sidechain.xrpl.org \
    --private-key <privateKey> \
    src/Cookies.sol:HazardsCookiesV4
```

Verify the contract with the following command:
```
forge verify-contract  --chain-id 1440001 --verifier=blockscout \
--verifier-url=https://evm-sidechain.peersyst.tech/api  <contract>   src/Cookies.sol:HazardsCookiesV3
```

Local blockchain:
```
forge script script/HazardsCookies.s.sol:CookiesScript --fork-url http://localhost:8545 \
--private-key $PRIVATE_KEY --broadcast
```
