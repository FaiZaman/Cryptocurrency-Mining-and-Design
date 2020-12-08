import ecdsa

# put the hex of your public key in the line below
vk_string = "f729c8db1fea7e9d9fd597be530af83e21e0053f549f0b1b6f6e5727b3c4e2a90f9de49e0c43a9e18c0ef1f9a13ccbf1b0d0c3fc4e13d3c92ef4922094b10527"
vk = ecdsa.VerifyingKey.from_string(bytes.fromhex(vk_string), ecdsa.SECP256k1)

message = b'Hello World'

# put your signature for Hello World in the line below
sig_hex = "e215145b90d703ff5a894e5bfdb931395d657735fe8a61c1a8b288c551b1a496cb9a1e2eff3304846ccecca3e15786ae18eaf98b7d61b4fadb95941ad29410d7"
sig = bytes.fromhex(sig_hex)

print("Checking signature")
print("Message: " + str(message))

print("Signature: " + sig_hex)
print("Public key: " + vk_string)

try:
    vk.verify(sig, message) # True
    print('Verification passed')

except ecdsa.keys.BadSignatureError:
    print('Verification failed')
