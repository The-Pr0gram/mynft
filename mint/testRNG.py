cards = list(range(52))

n = 52
records = [(blockhash, tokenid)]

for i in range(n):
    rnd = hash(blockhash, tokenid) % (n-i)
    cards[rnd], cards[-1] = cards[-1], cards[rnd]

print(cards)
