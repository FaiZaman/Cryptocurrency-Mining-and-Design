import blockcypher

address_object = blockcypher.generate_new_address(\
            coin_symbol='btc-testnet', api_key='6e74ffe16f4a4e3fbd13acd5a3d01014')

print('Address:', address_object['address'])
print('Public key:', address_object['public'])
print('Private key:', address_object['private'])