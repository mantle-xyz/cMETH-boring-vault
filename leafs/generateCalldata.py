import sys
import ast
from eth_abi import encode
from eth_utils import function_signature_to_4byte_selector

def main(manage_proofs, decoders_and_sanitizers, targets, target_data, values):
    # Check lengths
    if len(decoders_and_sanitizers) != len(targets) or len(targets) != len(target_data) or len(target_data) != len(values):
        print("Error: decoders_and_sanitizers, targets, target_data, and values must have the same length")
        sys.exit(1)

    # Function signature
    function_signature = "manageVaultWithMerkleVerification(bytes32[][],address[],address[],bytes[],uint256[])"
    function_selector = function_signature_to_4byte_selector(function_signature).hex()

    # Encode the parameters
    encoded_params = encode(
        ['bytes32[][]', 'address[]', 'address[]', 'bytes[]', 'uint256[]'],
        [manage_proofs, decoders_and_sanitizers, targets, target_data, values]
    )

    # Combine function selector and encoded parameters
    call_data = function_selector + encoded_params.hex()

    print(f"Call data for manageVaultWithMerkleVerification:")
    print(call_data)

# python generateCalldata.py "[[bytes.fromhex('1234' * 16), bytes.fromhex('5678' * 16)]]" "0x1234567890123456789012345678901234567890,0x0987654321098765432109876543210987654321" "0xabcdef0123456789abcdef0123456789abcdef01,0xfedcba9876543210fedcba9876543210fedcba98" "1a2b3c4d,5e6f7a8b" "100,200"
if __name__ == "__main__":
    if len(sys.argv) != 6:
        print("Usage: python generateCalldata.py <manage_proofs> <decoders_and_sanitizers> <targets> <target_data> <values>")
        sys.exit(1)

    # Parse command-line arguments
    try:
        manage_proofs_str = ast.literal_eval(sys.argv[1])
        manage_proofs = [[bytes.fromhex(proof[2:]) for proof in proofs] for proofs in manage_proofs_str]
    except (ValueError, SyntaxError) as e:
        print(f"Error parsing manage_proofs: {e}")
        sys.exit(1)
    
    decoders_and_sanitizers = sys.argv[2].split(',')  # Comma-separated list of addresses
    targets = sys.argv[3].split(',')  # Comma-separated list of addresses
    
    # Handle '0x' prefix in target_data
    target_data = [bytes.fromhex(data[2:] if data.startswith('0x') else data) for data in sys.argv[4].split(',')]
    
    values = [int(v) for v in sys.argv[5].split(',')]  # Comma-separated list of integers

    # Check if manage_proofs is a list of lists
    if not isinstance(manage_proofs, list) or not all(isinstance(proof, list) for proof in manage_proofs):
        print("Error: manage_proofs must be a list of lists")
        sys.exit(1)

    # Check if all other parameters have at least one element
    if not all([decoders_and_sanitizers, targets, target_data, values]):
        print("Error: All parameters must have at least one element")
        sys.exit(1)

    main(manage_proofs, decoders_and_sanitizers, targets, target_data, values)
