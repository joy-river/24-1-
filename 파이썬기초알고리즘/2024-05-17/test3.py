def list_pair(l):

    for i in range(len(l) - 1):
        for j in range(i + 1, len(l)):
            print(l[i] + ' - ' + l[j])


l = ["Tom", "Mike", "Jerry", "River", "Jo", "Lisa", "Fred"]

list_pair(l)
