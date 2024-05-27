def sum_square(n):
    result = 0
    for i in range(n + 1):
        result += i * i
    return result


print(sum_square(10))
