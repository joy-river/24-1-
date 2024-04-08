def sum_n(n):
    s = 0
    for i in range(1, n + 1):
        s = s + i ** 2
    return s


print(sum_n(20))


def sum_n2(n):
    return n * (n + 1) * (2 * n + 1) // 6


print(sum_n2(20))
