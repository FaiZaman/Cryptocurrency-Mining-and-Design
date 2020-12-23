import blockcypher
import json

# Specify the inputs and outputs below
# For convenince you can specify an address, 
#  and the backend will work out what transaction output that address has available to spend
# You do not need to list a change address, by default the transaction will be created with all change 
#  (minus the fees) going to the first input address

public_key = '03f2fb06f61d8dfe3451ee55a1e86578665f4d1548465d207f301865fa1be2d5df'
private_key = '6cd46f66cc9b262adc2aa6d60666aed8271bbcd1e2b4393dbadab3fd50c18ec9'

# sends 'val' satoshis to address
def value_transaction(val):

    inputs = [{'address': 'mhihAtVZhNT13zzWA2AUyQFYtUyaunDKSp'}]
    outputs = [{'address': 'mpamtqLA66JFVSQNDaPHZ5xMiCz6T2MeNn', 'value': val}]

    # The next line creates the transaction shell, which is as yet unsigned
    unsigned_tx = blockcypher.create_unsigned_tx(inputs=inputs, outputs=outputs, 
                        coin_symbol='btc-testnet', api_key='6e74ffe16f4a4e3fbd13acd5a3d01014')

    # You can edit the transaction fields at this stage, before signing it.
    #print(json.dumps(unsigned_tx, sort_keys=True, indent=4))

    # Now list the private and public keys corresponding to the inputs
    public_keys = [public_key]
    private_keys = [private_key]

    # Next create the signatures
    tx_signatures = blockcypher.make_tx_signatures(txs_to_sign=unsigned_tx['tosign'],\
        privkey_list=private_keys, pubkey_list=public_keys)

    # Finally push the transaction and signatures onto the network
    blockcypher.broadcast_signed_transaction(unsigned_tx=unsigned_tx, signatures=tx_signatures,\
        pubkeys=public_keys, coin_symbol='btc-testnet', api_key='6e74ffe16f4a4e3fbd13acd5a3d01014')

    # Transaction ID: 8fbfaf8213746c3beb5e2592250389649500e19e325f6603f02f515d8655e5eb
    # https://sochain.com/tx/BTCTEST/8fbfaf8213746c3beb5e2592250389649500e19e325f6603f02f515d8655e5eb


# writes a user ID to the blockchain
def write_ID_transaction(ID):

    inputs = [{'address': 'mhihAtVZhNT13zzWA2AUyQFYtUyaunDKSp'}]

    # hex encoding of a suitable script to create a proof of burn transaction with ID on it
    hex_ID = str.encode(ID).hex()    # hex version of student ID

    # 6a - opcode for OP_RETURN
    # 06 - length of metadata (user ID) in bytes
    script = "6a06" + hex_ID

    # assigning script to output
    outputs = [{'value': 0, 'script_type': "null-data", 'script': script}]

    # create transaction as in previous task
    unsigned_tx = blockcypher.create_unsigned_tx(inputs=inputs, outputs=outputs, 
                        coin_symbol='btc-testnet', api_key='6e74ffe16f4a4e3fbd13acd5a3d01014')

    print(json.dumps(unsigned_tx, sort_keys=True, indent=4))

    public_keys = [public_key]
    private_keys = [private_key]

    tx_signatures = blockcypher.make_tx_signatures(txs_to_sign=unsigned_tx['tosign'],\
        privkey_list=private_keys, pubkey_list=public_keys)

    blockcypher.broadcast_signed_transaction(unsigned_tx=unsigned_tx, signatures=tx_signatures,\
        pubkeys=public_keys, coin_symbol='btc-testnet', api_key='6e74ffe16f4a4e3fbd13acd5a3d01014')

    # Transaction ID: cb19c2dc3e0eb274c825d082fff4d09f1d4c8c66709f2dd0f74fd157c1757562
    # https://sochain.com/tx/BTCTEST/8fbfaf8213746c3beb5e2592250389649500e19e325f6603f02f515d8655e5eb

# value_transaction(100) - runs 100 satoshis transaction
write_ID_transaction('psgg66')  # - writes user ID to blockchain
