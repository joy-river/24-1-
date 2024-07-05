def find_min_idx(a):
    n = len(a)
    min_idx = 0
    for i in range(1, n):
        if a[i] < a[min_idx]:
            min_idx = i

    return min_idx


d = [2, 4, 5, 1, 3]

print('Minimum Index = ', find_min_idx(d))
print('Minimum Value = ', d[find_min_idx(d)])
