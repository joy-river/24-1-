def ins_sort2(a):
    n = len(a)
    for i in range(1, n):
        key = a[i]
        j = i - 1
        while j >= 0 and a[j] > key:
            a[j + 1] = a[j]
            j -= 1  # j = j - 1
            print(a)
        a[j + 1] = key
        print(a)


d = [2, 4, 5, 1, 3, 10, 525, 430, 3, 50]
print('initial data', d)
ins_sort2(d)
print(d)
