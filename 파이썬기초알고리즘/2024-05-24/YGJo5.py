def find_max_idx(a):
    n = len(a)
    max_idx = 0
    for i in range(1, n):
        if a[i] > a[max_idx]:
            max_idx = i

    return max_idx


def sel_sort(a):
    result = []
    while a:
        min_idx = find_max_idx(a)
        value = a.pop(min_idx)
        result.append(value)
    return result


d = [2, 4, 5, 1, 3, 7, 10, 2024, 24]


print('Before Sorting = ', d)
print('Sorted result = ', sel_sort(d))
