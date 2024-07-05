def max_n(l, n):
    if n == len(l) - 1:
        return l[n - 1]

    return max(max_n(l, n + 1), l[n])


l = [20, 525, 34, 3, 7, 47, 36, 97, 2, 60]

print(max_n(l, 0))
