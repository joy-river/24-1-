def find_pair(a):
    n = len(a)
    result = set()
    count = 0
    for i in range(0, n - 2):
        for j in range(i + 1, n - 1):
            for k in range(j + 1, n):
                print(a[i], '-', a[j], '-', a[k])
                count = count + 1
    print(count)


name = ['Tom', 'Jerry', 'Mike', 'Jo', 'Lee', 'Park']
print(name)
find_pair(name)
