import ecdsa

# put the hex of your public key in the line below
vk_string="7f82f75b557db04fcfd756c9a458a204004f9c9b4efad71b44744bbe1631329495448d3c90738f68a6f173bd00abb95af23be502723bab23f39c9799c9a0bc14"
vk = ecdsa.VerifyingKey.from_string(bytes.fromhex(vk_string),ecdsa.SECP256k1)

message = b'Hello World'

# put your signature for Hello World in the line below
sig_hex = "f48efe56e4825079c589cc53f9c7d867b4038a59e1ff712bc49fa4073655e0f83d130398dde79259675803527953d0b4ea1099e58a87f735b162b4bb67cc7838"
sig = bytes.fromhex(sig_hex)

print("Checking signature")
print("Message: "+str(message))

print("Signature: "+sig_hex)
print("Public key: "+vk_string)
try:
    vk.verify(sig, message)# True
    print('Verification passed')
except ecdsa.keys.BadSignatureError:
    print('Verification failed')