# source envs
source script/deploy/.env

# deploy sepolia
# deploy Layer1
ETHERSCAN_API_KEY=$ETHERSCAN_API_KEY forge script script/deploy.s.sol:Deploy \
-s "deployL1Contracts()" \
-vvvv \
--chain-id $CHAIN_ID \
--rpc-url $FOUNDRY_RPC_URL \
--sender $FOUNDRY_SENDER \
--private-key=$KEY \
--slow \
--broadcast \
--verify --verifier-url "https://api-sepolia.etherscan.io/api"

# deploy Layer2
forge script script/deploy.s.sol:Deploy \
-s "deployL2Contracts()" \
-vvvv \
--chain-id $CHAIN_ID \
--rpc-url $FOUNDRY_RPC_URL \
--sender $FOUNDRY_SENDER \
--private-key=$KEY \
--slow \
-g 4000000 \
--priority-gas-price 0 wei \
--broadcast \
--verify --verifier blockscout --verifier-url "https://explorer.sepolia.mantle.xyz/api?module=contract&action=verify"


# deploy mainnet
# deploy Layer1
ETHERSCAN_API_KEY=$ETHERSCAN_API_KEY forge script script/deploy.s.sol:Deploy \
-s "deployL1Contracts()" \
-vvvv \
--chain-id $CHAIN_ID \
--rpc-url $FOUNDRY_RPC_URL \
--sender $FOUNDRY_SENDER \
--private-key=$KEY \
--slow \
--broadcast \
--verify --verifier-url "https://api.etherscan.io/api"

# deploy Layer2
forge script script/deploy.s.sol:Deploy \
-s "deployL2Contracts()" \
-vvvv \
--chain-id $CHAIN_ID \
--rpc-url $FOUNDRY_RPC_URL \
--sender $FOUNDRY_SENDER \
--private-key=$KEY \
--slow \
-g 4000000 \
--priority-gas-price 0 wei \
--broadcast \
--verify --verifier blockscout --verifier-url "https://explorer.mantle.xyz/api?module=contract&action=verify"
