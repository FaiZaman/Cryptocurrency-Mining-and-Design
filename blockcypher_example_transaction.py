import blockcypher
import json

# Specify the inputs and outputs below
# For convenince you can specify an address, 
#  and the backend will work out what transaction output that address has available to spend
# You do not need to list a change address, by default the transaction will be created with all change 
#  (minus the fees) going to the first input address

inputs = [{'address': 'n3A4ktBMc9oY3krtauDikqW8Ec2dhf6uSb'}]
outputs = [{'address': 'mkHS9ne12qx9pS9VojpwU5xtRd4T7X7ZUt', 'value': 100}]

# The next line creates the transaction shell, which is as yet unsigned
unsigned_tx = blockcypher.create_unsigned_tx(inputs=inputs, outputs=outputs, 
                    coin_symbol='btc-testnet', api_key='6e74ffe16f4a4e3fbd13acd5a3d01014')

# You can edit the transaction fields at this stage, before signing it.
print(json.dumps(unsigned_tx, sort_keys=True, indent=4))


# Now list the private and public keys corresponding to the inputs
private_keys = ['03c5792b9fc16319f6da2503916168d21de8a63f8ea7c8a0155a1b079742f7a11b']
public_keys = ['49e9455c8687ad5fc74d33a419a59db554559f6796546d6f2b1a24643f146fc8']

# Next create the signatures
tx_signatures = blockcypher.make_tx_signatures(txs_to_sign=unsigned_tx['tosign'],\
    privkey_list=private_keys, pubkey_list=public_keys)

# Finally push the transaction and signatures onto the network
blockcypher.broadcast_signed_transaction(unsigned_tx=unsigned_tx, signatures=tx_signatures,\
    pubkeys=public_keys, coin_symbol='btc-testnet', api_key='6e74ffe16f4a4e3fbd13acd5a3d01014')
