def sum_n(n):
    if n == 1:
        return 1

    return sum_n(n - 1) + n


print(sum_n(10))
