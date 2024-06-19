def find_same_name(a):
    name_dict = {}

    for name in a:
        print(name)

        if name in name_dict:
            name_dict[name] += 1
        else:
            name_dict[name] = 1
        print(name_dict)

    result = set()
    for name in name_dict:
        print(name_dict[name])
        if name_dict[name] == 2:
            result.add(name)

    return result


name = ["Tom", "Jerry", "Tom", "MiKe", "Tom", "Jerry"]

print(find_same_name(name))
