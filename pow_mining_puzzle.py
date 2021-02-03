import hashlib
import json
import time

# A block header - do not change any fields except nonce and coinbase_addr
block_header = {'height': 1478503,
                'prev_block': '0000000000000da6cff8a34298ddb42e80204669367b781c87c88cf00787fcf6',
                'total': 38982714093,
                'fees': 36351,
                'size': 484,
                'ver': 536870912,
                'time': 1550603039.882228,
                'bits': 437239872,
                'nonce': 0,  # change this - it should still be an int
                'coinbase_addr': 'psgg66', # change this field of the block to student ID
                'n_tx': 2,
                'mrkl_root': '69224771b7a2ed554b28857ed85a94b088dc3d89b53c2127bfc5c16ff49da229',
                'txids': [
                    '3f9dfc50198cf9c2b0328cd1452513e3953693708417440cd921ae18616f0bfc', 
                    '3352ead356030b335af000ed4e9030d487bf943089fc0912635f2bb020261e7f'
                    ],
                'depth': 0}

# 00000000FFFF = 65535 (decimal)
# 65535 * 1000 -> hex = new difficulty (0.001)
difficulty     = "00000000FFFF0000000000000000000000000000000000000000000000000000"
new_difficulty = hex(int(difficulty, 16) * 1000)
target = int(new_difficulty, 16)

# Simplified conversion of block header into bytes:
#block_serialised = json.dumps(block_header, sort_keys=True).encode()

# Double SHA256 hashing of the serialised block
#block_hash = hashlib.sha256(hashlib.sha256(block_serialised).digest()).hexdigest()
#print('Hash with nonce ' + str(block_header['nonce']) + ': ' + block_hash)

nonce = 0
start = time.time()

# loop and try hashing nonces in increasing order (1, 2, 3, ...)
while True:

    block_header['nonce'] = nonce

    block_serialised = json.dumps(block_header, sort_keys=True).encode()
    block_hash = hashlib.sha256(hashlib.sha256(block_serialised).digest()).hexdigest()

    # compute current value of hash
    current_value = int(block_hash, 16)
    if current_value < target:     # current target - break if hit
        print('Hash with nonce ' + str(block_header['nonce']) + ': ' + block_hash)
        break

    nonce += 1

# nonce: 2046895

end = time.time()
time_taken = end - start
print('Time taken: ' + str(time_taken) + ' seconds.')
