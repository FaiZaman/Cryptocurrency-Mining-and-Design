import hashlib
import ecdsa

# An the previous block header - do not change any fields
previous_block_header = {
  "previousBlockHash": "651c16a0226d2ddd961c9391dc11f703c5972f05805c4fb45ab1469dda1d4b98",
  "payloadLength": 209,
  "totalAmountNQT": "383113873926",
  "generationSignature": "9737957703d4eb54efdff91e15343266123c5f15aaf033292c9903015af817f1",
  "generator": "11551286933940986965",
  "generatorPublicKey": "feb823bac150e799fbfc124564d4c1a72b920ec26ce11a07e3efda51ca9a425f",
  "baseTarget": 1229782938247303,
  "payloadHash": "06888a0c41b43ad79c4e4991e69372ad4ee34da10d6d26f30bc93ebdf7be5be0",
  "generatorRS": "NXT-MT4P-AHG4-A4NA-CCMM2",
  "nextBlock": "6910370859487179428",
  "requestProcessingTime": 0,
  "numberOfTransactions": 1,
  "blockSignature": "0d237dadff3024928ea4e5e33613413f73191f04b25bad6b028edb97711cbd08c525c374c3e2684ce149a9abb186b784437d01e2ad13046593e0e840fd184a60",
  "transactions": ["14074549945874501524"],
  "version": 3,
  "totalFeeNQT": "200000000",
  "previousBlock": "15937514651816172645",
  "cumulativeDifficulty": "52911101533010235",
  "block": "662053617327350744",
  "height": 2254868,
  "timestamp": 165541326
}

# you should edit the effective balance to be the last two digits from your user id
effective_balance = 75


