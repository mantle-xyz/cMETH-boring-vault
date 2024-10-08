import json
import sys
from typing import List, Dict

def construct_merkle_proof(leaf_digest: str, tree_data: Dict) -> List[List[str]]:
    # Convert leaf_digest to lowercase for case-insensitive comparison
    leaf_digest = leaf_digest.lower()
    # Find the leaf index
    leaf_index = None
    leaf_depth = len(tree_data['MerkleTree']) - 1
    for i, digest in enumerate(tree_data['MerkleTree'][str(leaf_depth)]):
        if digest.lower() == leaf_digest:
            leaf_index = i
            break
    if leaf_index is None:
        raise ValueError("Leaf digest not found in the tree")
    # Initialize proof list
    proof = []
    current_index = leaf_index
    # Traverse up the tree
    for level in range(leaf_depth, 0, -1):
        is_right = current_index % 2 == 1
        sibling_index = current_index - 1 if is_right else current_index + 1
        if sibling_index < len(tree_data['MerkleTree'][str(level)]):
            sibling_digest = tree_data['MerkleTree'][str(level)][sibling_index]
            # Append the sibling digest directly (without quotes)
            proof.append(sibling_digest)
        current_index //= 2  # Move to the parent node
    # Return proof wrapped in a list to achieve [["digest1", "digest2", ...]]
    return [proof]

def main():
    # Check if both file name and leaf digest are provided as arguments
    if len(sys.argv) < 3:
        print("Usage: python generateSetupProof.py <tree_data_file.json> <leaf_digest>")
        sys.exit(1)
    # Use the first command-line argument as the JSON file name
    json_file = sys.argv[1]
    # Use the second command-line argument as the leaf digest
    leaf_digest = sys.argv[2]
    # Load the tree data from the specified JSON file
    try:
        with open(json_file, 'r') as f:
            tree_data = json.load(f)
    except FileNotFoundError:
        print(f"Error: File '{json_file}' not found.")
        sys.exit(1)
    except json.JSONDecodeError:
        print(f"Error: '{json_file}' is not a valid JSON file.")
        sys.exit(1)
    try:
        merkle_proof = construct_merkle_proof(leaf_digest, tree_data)
        print(f"Merkle Proof for leaf {leaf_digest}:")
        # Output the proof as a JSON-formatted string
        print(json.dumps(merkle_proof, separators=(',', ':')))
    except ValueError as e:
        print(f"Error: {e}")


if __name__ == "__main__":
    main()
