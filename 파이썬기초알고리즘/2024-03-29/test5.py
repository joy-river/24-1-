def sum_n(n):
    s = 0
    for i in range(1, n + 1):
        s = s + i

    return s


print(sum_n(329))


def sum_n2(n):
    return n * (n + 1) // 2


print(sum_n2(329))
