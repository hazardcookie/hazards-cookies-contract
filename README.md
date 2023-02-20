# Keys of XRPL
## How to play
### Key of Power 💪
To claim the key of power the block number must end in 420.

### Key of Wisdom 🧠
To claim the key of wisdom, submit a number. If the hash of that number is greater than the hash of the previous number, you get the key. 

### Key of Time ⏳
Anyone can claim this key if it has been greater than 1 week since the last claim date 

### Key of War 😈
If the block number is a even number, anyone can claim this key.

### Key of Wealth 💸
Anyone can claim this key if they spend more than the previous claimer.

## Deployment Details
Deployer: `0x67F141221bbDa7162373eC57aCbFa4E9564750e8` \n
Deployed to: `0xDA8969c0E047e12bfda6281283C7A7Bfdd0B70F5` \n 
Transaction hash: `0x06dadc0fe29d695592000d507155a8f7c5d823aabbe564c2406c5e5d5509a3fe` \n
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
forge script script/Cookies.s.sol:CookiesScript --fork-url http://localhost:8545 \
--private-key $PRIVATE_KEY --broadcast
```
