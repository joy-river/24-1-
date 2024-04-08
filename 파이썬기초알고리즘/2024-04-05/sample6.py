def find_min(a):
    n = len(a)
    min_a = a[0]

    for i in range(1, n):
        if a[i] < min_a:
            min_a = a[i]

    return min_a


v = [17, 92, 18, 33, 58, 7, 33, 40]
print(v)
print(find_min(v))
