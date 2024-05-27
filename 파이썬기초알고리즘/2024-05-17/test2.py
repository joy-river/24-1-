def list_min(l):

    result = l[0]

    for e in l:
        if e < result:

            result = e
    return result


l = [20, 525, 34, 3, 7, 47, 36, 97, 2, 60]

print(list_min(l))
