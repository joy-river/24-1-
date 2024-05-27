def search_list(a, x):
    n = len(a)
    for i in range(0, n):
        if x == a[i]:
            return i + 1

    return -1


v = [17, 92, 18, 33, 58, 7, 33, 42]


print(search_list(v, 42))
print(search_list(v, 43))
