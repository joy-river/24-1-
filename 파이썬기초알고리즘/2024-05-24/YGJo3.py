def find_max_idx(a):
    n = len(a)
    max_idx = 0
    for i in range(1, n):
        if a[i] > a[max_idx]:
            max_idx = i

    return max_idx


d = [2, 4, 5, 1, 3]

print('Maximum Index = ', find_max_idx(d))
print('Maximum Value = ', d[find_max_idx(d)])
