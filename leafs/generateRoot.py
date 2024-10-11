import sys
import json
from eth_abi import encode
from eth_utils import keccak, to_bytes

def calculate_merkle_root(nodes):
    if len(nodes) == 0:
        return b'\x00' * 32
    
    layer = 0
    while len(nodes) > 1:
        print(f"Layer {layer}:")
        for node in nodes:
            print("0x" + node.hex())
        print()

        new_level = []
        for i in range(0, len(nodes), 2):
            if i + 1 < len(nodes):
                left = nodes[i]
                right = nodes[i+1]
                if left > right:
                    left, right = right, left
                new_level.append(keccak(left + right))
            else:
                new_level.append(nodes[i])
        nodes = new_level
        layer += 1
    
    print(f"Final Layer (Root):")
    print("0x" + nodes[0].hex())
    print()

    return nodes[0]

def process_digest(digest):
    if isinstance(digest, dict):
        # Assuming the digest is stored in a 'digest' key
        digest = digest.get('LeafDigest', '')
    return to_bytes(hexstr=digest[2:] if digest.startswith("0x") else digest)

# Check if a file path is provided as an argument
if len(sys.argv) < 2:
    print("Please provide the path to the JSON file as an argument.")
    sys.exit(1)

# Get the file path from command line argument
file_path = sys.argv[1]

# Read leaf digests from file
try:
    with open(file_path, 'r') as f:
        data = json.load(f)
except FileNotFoundError:
    print(f"Error: File '{file_path}' not found.")
    sys.exit(1)
except json.JSONDecodeError:
    print(f"Error: '{file_path}' is not a valid JSON file.")
    sys.exit(1)

# Assuming the leaf digests are in the "2" key
leaf_digests = data["leafs"]

# Process leaf digests
nodes = [process_digest(digest) for digest in leaf_digests]

# Calculate the root
root = calculate_merkle_root(nodes)

print("Merkle Root:", "0x" + root.hex())
