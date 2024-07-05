def YGJO(g, start):
    qu = []
    done = set()
    qu.append(start)
    done.add(start)

    while qu:

        p = qu.pop(0)
        print(p)
        for x in g[p]:
            if x not in done:
                qu.append(x)
                done.add(x)
    print(done)


fr_info = {
    "A": ['B', 'C', 'D'],
    "B": ['A', 'E'],
    "C": ['A', 'D'],
    "D": ['A', 'C'],
    "E": ['B'],
    "F": ['G'],
    "G": ['F']
}


YGJO(fr_info, "B")
