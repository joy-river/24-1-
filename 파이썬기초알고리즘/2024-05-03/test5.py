def gcd(a, b):
    i = min(a, b)
    while True:
#        print(i)
        if a % i == 0 and b % i == 0:
            return i
        i = i - 1;
        
print(gcd(81000, 50004))
