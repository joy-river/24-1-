def fact(a):
    f = 1
    for i in range(1, a + 1):
        f = f * i
    return f

print(fact(50))
