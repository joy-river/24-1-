def find_ins_idx(r, v):
    for i in range(0, len(r)):
        if v < r[i]:
            return i
    return len(r)


def ins_sort(a):
    result = []
    while a:
        value = a.pop(0)
        ins_idx = find_ins_idx(result, value)
        result.insert(ins_idx, value)
    return result


d = [2, 4, 20, 10, 235, 5, 1, 3, 4, 25, 95,
     34, 589, 182, 395, 430, 12, 20, 45, 32, 50]
print(d)
print(ins_sort(d))
