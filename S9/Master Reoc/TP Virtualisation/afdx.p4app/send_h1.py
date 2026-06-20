from scapy.all import Ether, Raw, sendp
import sys
import random, string
import time

def randomword(max_length):
    length = random.randint(1, max_length)
    return ''.join(random.choice(string.lowercase) for i in range(length))

VL_dst = "03:00:00:00:00:01"
data = randomword(1500)

p = Ether(dst=VL_dst)/Raw(load=data)
print (p.show())

it = 0
while it<1000:
    sendp(p, iface = "h1-eth0")
    time.sleep(2/1000)
    it += 1
