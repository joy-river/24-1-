def hanoi(n, from_pos, to_pos, aux_pos):
    if n == 1:
        print(from_pos, '->', to_pos)
        return


hanoi(1, 1, 3, 2)
