import psycopg2
from flask import Flask, render_template, request

app = Flask(__name__)
connect = psycopg2.connect("dbname=tutorial user=postgres password=postgres")
cur = connect.cursor()  # create cursor


@app.route('/')
def main():
    return render_template("main.html")


@app.route('/return', methods=['post'])
def re_turn():
    return render_template("main.html")


@app.route('/print_table', methods=['post'])
def print_table():
    cur.execute("SELECT * FROM users;")
    result = cur.fetchall()

    return render_template("print_table.html", users=result)

@app.route('/register', methods=['post'])
def register():
    id = request.form["id"]
    password = request.form["password"]
    send = request.form["send"]

    cur.execute(f"select * from users where id = '{id}'")
    result = cur.fetchall()
    if send == 'sign up':
        if not result:
            cur.execute(f"insert into users values ('{id}', '{password}')")
            connect.commit()
            return id + " " + password + " " + send
        else:
            return render_template("ID_collision.html")
    else:
        if not result or result[0][1] != password:
            return render_template("login_fail.html")
        else:
            return render_template("login_success.html")



if __name__ == '__main__':
    app.run(debug=True)
