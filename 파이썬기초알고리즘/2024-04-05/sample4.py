def find_max(a):
    n = len(a)
    max_a = a[0]

    for i in range(1, n):
        if a[i] > max_a:
            max_a = a[i]

    return max_a


v = [17, 92, 18, 33, 58, 7, 33, 40]
print(v)
print(find_max(v))
