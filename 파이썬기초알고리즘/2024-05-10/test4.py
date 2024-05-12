def RF(n):
    print('Before', n)
    if n > 0:
        RF(n - 1)
        print('After', n)
    else:
        return


RF(5)
