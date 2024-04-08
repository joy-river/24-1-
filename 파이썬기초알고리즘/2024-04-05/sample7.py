def find_min_idx(a):
    n = len(a)
    min_idx = 0

    for i in range(1, n):
        if a[i] < a[min_idx]:
            min_idx = i

    return min_idx


v = [17, 92, 18, 33, 58, 7, 33, 40]
print(v)
print(find_min_idx(v))
