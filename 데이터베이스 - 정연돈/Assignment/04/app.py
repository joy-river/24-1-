import psycopg2
from flask import Flask, render_template, request, url_for, flash, redirect

app = Flask(__name__)
connect = psycopg2.connect("dbname=tutorial user=postgres password=postgres")
cur = connect.cursor()  # create cursor


@app.route('/')
def main():
    return render_template("main.html")

@app.route('/main/<id>', methods=['get', 'post'])
def mainpage(id):
    cur.execute("select * from movies")
    result = cur.fetchall()
    return render_template('mainpage.html', id=id, movies = result)

@app.route('/register', methods=['get', 'post'])
def register():
    id = request.form["id"]
    password = request.form["password"]
    role = request.form["role"]
    send = request.form["send"]

    if id == '':
        flash("ID가 입력 되지 않았습니다. ID를 입력해주세요.", 'error')
        return render_template("main.html")
    if password == '':
        flash("비밀번호가 입력 되지 않았습니다. 비밀번호를 입력해주세요.", 'error')
        return render_template("main.html")

    cur.execute(f"select * from users where id = '{id}'")
    result = cur.fetchall()
    if send == 'sign up':
        if not result:
            cur.execute(f"insert into users values ('{id}', '{password}', '{role}')")
            connect.commit()
            flash("회원가입 성공! 가입하신 ID로 로그인 해주세요.", 'success')
        else:
            flash("이미 가입되어 있는 ID 입니다.", 'error')
    else:
        if not result:
            flash('가입되어있지 않은 ID 입니다. 먼저 회원가입을 진행해주세요.', 'error')
        elif result[0][1] != password:
            flash('비밀번호가 틀립니다. 다시 입력해주세요.', 'error')
        else:
            return redirect(url_for('mainpage', id=id))
    return render_template('main.html')


if __name__ == '__main__':
    app.secret_key = 'super secret key'
    app.config['SESSION_TYPE'] = 'filesystem'
    app.run(debug=True)
