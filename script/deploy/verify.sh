# forge verify mantle
# verify AllocateUnits
forge verify-contract --verifier blockscout --watch \
--verifier-url $VERIFIER_URL \
--compiler-version "0.8.18" \
--num-of-optimizations 1000000 \
--constructor-args $(cast abi-encode "constructor()") \
--chain $CHAIN_ID \
0xdf32c92B47CAE6D5A6Add3ecCa2f074513c86c28 ./src/AllocateUnits.sol:AllocateUnits

# verify L1BlockInfo
forge verify-contract \
--verifier blockscout --watch \
--verifier-url $VERIFIER_URL \
--compiler-version "0.8.18" \
--num-of-optimizations 1000000 \
--constructor-args $(cast abi-encode "constructor()") \
--chain $CHAIN_ID \
0x62d042b908d1dac508424882a681192ca73774de ./src/L1BlockInfo.sol:L1BlockInfo

# verify Staking
forge verify-contract \
--verifier blockscout --watch \
--verifier-url $VERIFIER_URL \
--compiler-version "0.8.18" \
--num-of-optimizations 1000000 \
--constructor-args $(cast abi-encode "constructor()") \
--chain $CHAIN_ID \
0x259cec4902ee9f358d0c6f14dad9a5513f286e82 ./src/MNTStaking.sol:Staking

# verify Pauser
forge verify-contract \
--verifier blockscout --watch \
--verifier-url $VERIFIER_URL \
--compiler-version "0.8.18" \
--num-of-optimizations 1000000 \
--constructor-args $(cast abi-encode "constructor()") \
--chain $CHAIN_ID \
0x53d2134c137e92c29e36872e1a2571eab597187d ./src/Pauser.sol:Pauser

# verify TrancheManager
forge verify-contract \
--verifier blockscout --watch \
--verifier-url $VERIFIER_URL \
--compiler-version "0.8.18" \
--num-of-optimizations 1000000 \
--constructor-args $(cast abi-encode "constructor()") \
--chain $CHAIN_ID \
0x733e7c5bee511b1bf19df8c701a4d6908b004ce4 ./src/TrancheManager.sol:TrancheManager

# verify Tranche
#forge verify-contract \
#--verifier blockscout --watch \
#--verifier-url $VERIFIER_URL \
#--compiler-version "0.8.18+commit.87f61d96" \
#--num-of-optimizations 1000000 \
#--constructor-args $(cast abi-encode "constructor()") \
#--chain $CHAIN_ID \
#0x1CB17c979Ad598F6081864601F4192CddD8f5689 ./src/L1BlockInfo.sol:L1BlockInfo
