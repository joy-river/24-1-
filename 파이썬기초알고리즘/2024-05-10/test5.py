import turtle as t


def spiral(sp_len):

    print(sp_len)
    if sp_len <= 5:
        return

    t.forward(sp_len)
    t.right(90)
    spiral(sp_len*0.95)


t.speed(0)
spiral(300)
t.hideturtle()
