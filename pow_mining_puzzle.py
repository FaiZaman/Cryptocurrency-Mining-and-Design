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
                'coinbase_addr': 'psgg66', #change this field of the block to student ID
                'n_tx': 2,
                'mrkl_root': '69224771b7a2ed554b28857ed85a94b088dc3d89b53c2127bfc5c16ff49da229',
                'txids': [
                    '3f9dfc50198cf9c2b0328cd1452513e3953693708417440cd921ae18616f0bfc', 
                    '3352ead356030b335af000ed4e9030d487bf943089fc0912635f2bb020261e7f'
                    ],
                'depth': 0}

# (65535 * 100) -> hex = new difficulty (0.001)
difficulty = "00000000FFFF0000000000000000000000000000000000000000000000000000"
new_diffic = "000003E7FC180000000000000000000000000000000000000000000000000000"     # 22 leading
target_zeroes = 22

# Simplified conversion of block header into bytes:
#block_serialised = json.dumps(block_header, sort_keys=True).encode()

# Double SHA256 hashing of the serialised block
#block_hash = hashlib.sha256(hashlib.sha256(block_serialised).digest()).hexdigest()
#print('Hash with nonce ' + str(block_header['nonce']) + ': ' + block_hash)


# calculates the number of leading zeroes in a given hexadecimal string
def get_leading_zeros(hex):

    zeroes = 0
    scale = 16

    for i in hex:
        if i == '0':
            zeroes += 4
        else:

            binary = bin(int(hex, scale)).zfill(4)[2:]

            for j in binary:
                if j == '0':
                    zeroes += 1
                else:
                    return zeroes

nonce = 0

start = time.time()

# loop and try hashing nonces in increasing order (1, 2, 3, ...)
while True:

    block_header['nonce'] = nonce

    block_serialised = json.dumps(block_header, sort_keys=True).encode()
    block_hash = hashlib.sha256(hashlib.sha256(block_serialised).digest()).hexdigest()

    # compute number of leading zeroes in hash
    zeroes = get_leading_zeros(block_hash)

    if zeroes > target_zeroes:     # current target - break if hit
        print('Number of zeroes: ' + str(zeroes))
        print('Hash with nonce ' + str(block_header['nonce']) + ': ' + block_hash)
        break

    nonce += 1

# nonce: 11344153

end = time.time()
time_taken = end - start
print('Time taken: ' + str(time_taken) + ' seconds.')
