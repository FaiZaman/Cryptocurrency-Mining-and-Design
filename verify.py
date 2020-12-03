import ecdsa

# put the hex of your public key in the line below
vk_string = "3326e3bd13675692cd0f430b72f7e51e0c548501ca5708d0429c082f39b655526f\
                bf4067bfb8d8558f9186be5d95c25acc6b1143be77f531da4c2007fcbe8df8"
vk = ecdsa.VerifyingKey.from_string(bytes.fromhex(vk_string), ecdsa.SECP256k1)

message = b'Hello World'

# put your signature for Hello World in the line below
sig_hex = "7c79e6039d8b8931f6944b391813c4789198f8a1bc1bf2ab3f20f9d114b9c51e9227\
                5079c351605c30c103f871b5bc1926562c019ea57c4f4ad590d4c8acd498"
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
