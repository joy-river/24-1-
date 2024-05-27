def sel_sort(a):
    n = len(a)
    for i in range(0, n-1):
        min_idx = i
        for j in range(i + 1, n):
            if a[j] < a[min_idx]:
                min_idx = j
                a[i], a[min_idx] = a[min_idx], a[i]


d = [2, 4, 5, 1, 3, 7, 10, 2024, 24]


print('Before Sorting = ', d)
sel_sort(d)
print('Sorted result = ', d)

x = [1, 2, 3]
print(x)
x[0], x[2] = x[2], x[0]
print(x)
