import json
import sys
from eth_abi import encode
from eth_utils import keccak, to_bytes, to_hex
from web3 import Web3

def calculate_leaf_digest(entry):
    # Convert addresses to checksum format
    entry['DecoderAndSanitizerAddress'] = Web3.to_checksum_address(entry['DecoderAndSanitizerAddress'])
    entry['TargetAddress'] = Web3.to_checksum_address(entry['TargetAddress'])
    entry['PackedArgumentAddresses'] = Web3.to_checksum_address(entry['PackedArgumentAddresses'])

    raw_digest = Web3.solidity_keccak(
        ['address', 'address', 'bool', 'bytes4', 'address'],
        [
            entry['DecoderAndSanitizerAddress'],
            entry['TargetAddress'],
            entry['CanSendValue'],
            bytes.fromhex(entry['FunctionSelector'][2:]),
            entry['PackedArgumentAddresses']
        ]
    )
    return raw_digest.hex()

def main(json_file_path):
    with open(json_file_path, 'r') as file:
        data = json.load(file)
    
    if 'leafs' in data and isinstance(data['leafs'], list):
        for entry in data['leafs']:
            if isinstance(entry, dict):
                try:
                    calculated_digest = calculate_leaf_digest(entry)
                    print(f"Calculated digest: {calculated_digest}")
                except KeyError as e:
                    print(f"Error processing entry: {e}")
            else:
                print(f"Skipping invalid leaf entry: {entry}")
    else:
        print("Error: 'leafs' key not found or not a list in the JSON file")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python generateDigest.py <path_to_json_file>")
        sys.exit(1)
    
    json_file_path = sys.argv[1]
    main(json_file_path)
