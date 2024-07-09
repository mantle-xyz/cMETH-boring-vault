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

forge script script/utils.s.sol:Utils \
-s "updateCooldown(uint256)" 60 \
-vvv \
--chain-id $CHAIN_ID \
--rpc-url $FOUNDRY_RPC_URL \
--sender $FOUNDRY_SENDER \
--private-key=$KEY \
--slow \
-g 400000 \
--broadcast

#forge script script/utils.s.sol:Utils \
#-s "defundAndClose(uint256)" 5 \
#-vvv \
#--chain-id $CHAIN_ID \
#--rpc-url $FOUNDRY_RPC_URL \
#--sender $FOUNDRY_SENDER \
#--private-key=$KEY \
#--slow \
#-g 400000 \
#--broadcast
#
#
## create LSP
#forge script script/utils.s.sol:Utils \
#-s "createStandardTranche(string,string,string)" LSP https://www.mantle.xyz/meth ipfs://QmUjh11Zhu4wuboZxwf66TF9Gjbevesoxe2TPpCjGdBELc \
#-vvv \
#--chain-id $CHAIN_ID \
#--rpc-url $FOUNDRY_RPC_URL \
#--sender $FOUNDRY_SENDER \
#--private-key=$KEY \
#--slow \
#-g 400000 \
#--priority-gas-price 0 wei \
#--broadcast
#
#cast send 0x9268fD680cB2B8F0a701E79Aa66Bc611B8Cb69F0 "mint(address,uint256)" 0x427deF1c9d4a067cf7A2e0a1bd3b6280a6bC2bE5 1000000000000000000000000 --private-key=$KEY --rpc-url=$FOUNDRY_RPC_URL
#
#forge script script/utils.s.sol:Utils \
#-s "finaliseTranche(uint256)" 3 \
#-vvv \
#--chain-id $CHAIN_ID \
#--rpc-url $FOUNDRY_RPC_URL \
#--sender $FOUNDRY_SENDER \
#--private-key=$KEY \
#--slow \
#-g 400000 \
#--priority-gas-price 0 wei \
#--broadcast
#
## create ALT
#forge script script/utils.s.sol:Utils \
#-s "createStandardTranche(string,string,string)" Altlayer https://altlayer.io/ ipfs://QmQXc7Tsy1U61SeGgLuKqbL1hXn9NZawSDGXSjLwagN7dR \
#-vvv \
#--chain-id $CHAIN_ID \
#--rpc-url $FOUNDRY_RPC_URL \
#--sender $FOUNDRY_SENDER \
#--private-key=$KEY \
#--slow \
#-g 800000 \
#--priority-gas-price 0 wei \
#--broadcast
#
#cast send 0x168949f34d98277aB26D288F79095EBa79E178f6 "mint(address,uint256)" 0x427deF1c9d4a067cf7A2e0a1bd3b6280a6bC2bE5 1000000000000000000000000 --private-key=$KEY --rpc-url=$FOUNDRY_RPC_URL
#
#forge script script/utils.s.sol:Utils \
#-s "finaliseTranche(uint256)" 4 \
#-vvv \
#--chain-id $CHAIN_ID \
#--rpc-url $FOUNDRY_RPC_URL \
#--sender $FOUNDRY_SENDER \
#--private-key=$KEY \
#--slow \
#-g 400000 \
#--priority-gas-price 0 wei \
#--broadcast
#
## create INIT Capital
#forge script script/utils.s.sol:Utils \
#-s "createStandardTranche(string,string,string)" INIT https://init.capital/ ipfs://QmcKWCgRuAM3m1YHzosFGAdXui8TVyTMPxRs19HfJNqtHu \
#-vvv \
#--chain-id $CHAIN_ID \
#--rpc-url $FOUNDRY_RPC_URL \
#--sender $FOUNDRY_SENDER \
#--private-key=$KEY \
#--slow \
#-g 800000 \
#--priority-gas-price 0 wei \
#--broadcast
#
#cast send 0x9E6E5569ac8d4311009A09F0ee1e4436BD85E380 "mint(address,uint256)" 0x427deF1c9d4a067cf7A2e0a1bd3b6280a6bC2bE5 1000000000000000000000000 --private-key=$KEY --rpc-url=$FOUNDRY_RPC_URL
#
#forge script script/utils.s.sol:Utils \
#-s "finaliseTranche(uint256)" 6 \
#-vvv \
#--chain-id $CHAIN_ID \
#--rpc-url $FOUNDRY_RPC_URL \
#--sender $FOUNDRY_SENDER \
#--private-key=$KEY \
#--slow \
#-g 800000 \
#--priority-gas-price 0 wei \
#--broadcast
