# Set Mantle Peer
forge script script/utils.s.sol:Utils \
-s "setPeers(address,uint32[],address[])" address eid1,eid2 oapp1,oapp2 \
-vvvv \
--chain-id $CHAIN_ID \
--rpc-url $FOUNDRY_RPC_URL \
--sender $FOUNDRY_SENDER \
--private-key=$KEY \
--slow \
-g 4000000 \
--priority-gas-price 0 wei \
--broadcast

# Set EVM Network Peer
forge script script/utils.s.sol:Utils \
-s "setPeers(address,uint32[],address[])" address, eid1,eid2 oapp1,oapp2 \
-vvvv \
--chain-id $CHAIN_ID \
--rpc-url $FOUNDRY_RPC_URL \
--sender $FOUNDRY_SENDER \
--private-key=$KEY \
--slow \
--broadcast

# Send L1
forge script script/utils.s.sol:Utils \
-s "sendL1cmETH(uint32,address,uint256)" 40246 $FOUNDRY_SENDER 1000000000000000000 \
-vvvv \
--chain-id $CHAIN_ID \
--rpc-url $FOUNDRY_RPC_URL \
--sender $FOUNDRY_SENDER \
--private-key=$KEY \
--slow \
--broadcast

# Send L2
forge script script/utils.s.sol:Utils \
-s "sendL2cmETH(uint32,address,uint256)" 40161 $FOUNDRY_SENDER 500000000000000000 \
-vvvv \
--chain-id $CHAIN_ID \
--rpc-url $FOUNDRY_RPC_URL \
--sender $FOUNDRY_SENDER \
--private-key=$KEY \
--slow \
-g 4000000 \
--priority-gas-price 0 wei \
--broadcast

# Send setIsTransferPausedFor L1
forge script script/utils.s.sol:Utils \
-s "setIsTransferPausedFor(address,uint32,bool)" targetOApp eId isPaused \
-vvvv \
--chain-id $CHAIN_ID \
--rpc-url $FOUNDRY_RPC_URL \
--sender $FOUNDRY_SENDER \
--private-key=$KEY \
--slow \
--broadcast

# Send setIsTransferPausedFor Mantle
forge script script/utils.s.sol:Utils \
-s "setIsTransferPausedFor(address,uint32,bool)" targetOApp eId isPaused \
-vvvv \
--chain-id $CHAIN_ID \
--rpc-url $FOUNDRY_RPC_URL \
--sender $FOUNDRY_SENDER \
--private-key=$KEY \
--slow \
-g 400000 \
--broadcast


forge script script/utils.s.sol:Utils \
-s "setExchangeRateFor(address,uint32,uint256)" targetOApp eId rate \
-vvvv \
--chain-id $CHAIN_ID \
--rpc-url $FOUNDRY_RPC_URL \
--sender $FOUNDRY_SENDER \
--private-key=$KEY \
--slow \
--broadcast


forge script script/utils.s.sol:Utils \
-s "setEnableFor(address,uint32,bool)" targetOApp eId isEnabled \
-vvvv \
--chain-id $CHAIN_ID \
--rpc-url $FOUNDRY_RPC_URL \
--sender $FOUNDRY_SENDER \
--private-key=$KEY \
--slow \
--broadcast


forge script script/utils.s.sol:Utils \
-s "setCapFor(address,uint32,uint256)" targetOApp eId cap \
-vvvv \
--chain-id $CHAIN_ID \
--rpc-url $FOUNDRY_RPC_URL \
--sender $FOUNDRY_SENDER \
--private-key=$KEY \
--slow \
--broadcast
