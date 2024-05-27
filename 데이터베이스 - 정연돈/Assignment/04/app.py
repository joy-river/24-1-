import psycopg2
from flask import Flask, render_template, request, url_for, flash, redirect, session
from random import choice

app = Flask(__name__)
connect = psycopg2.connect("dbname=tutorial user=postgres password=postgres")
cur = connect.cursor()  # create cursor


def sel_movie(order):
    if not order:
        order = 'rel_date desc'
    if type(order) == int:
        cur.execute(
            f"select id, title, avg(ratings), director, genre, rel_date "
            f"from movies left join reviews on id = mid "
            f"where id = '{order}' "
            f"group by id, title, director, genre, rel_date")
    else:
        cur.execute(
            f"select id, title, avg(ratings), director, genre, rel_date "
            f"from movies left join reviews on id = mid "
            f"group by id, title, director, genre, rel_date order by {order}")
    return cur.fetchall()


def sel_review(order):
    id = session['id']
    if not order:
        order = 'rev_time desc'
    if order == 'follow':
        cur.execute(
            f"select ratings, uid, mid, title, review, rev_time "
            f"from reviews, (select id, title from movies) "
            f"where id = mid and uid in "
            f"(select opid from ties where id = '{id}' and tie = 'follow')")
    else:
        cur.execute(
            f"select ratings, uid, mid, title, review, rev_time "
            f"from reviews, (select id, title from movies) "
            f"where id = mid order by {order}")
    return cur.fetchall()


@app.route('/')
def main():
    return render_template("main.html")


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
            cur.execute(
                f"insert into users values ('{id}', '{password}', '{role}')")
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
            session['id'] = id
            return redirect(url_for('main_page'))
    return render_template('main.html')


@app.route('/main', methods=['get', 'post'])
def main_page():
    id = session['id']
    mov_order = request.form.get('mov_order')
    if mov_order:
        session['mov_order'] = mov_order
    else:
        mov_order = session.get('mov_order', 'rel_date desc')

    rev_order = request.form.get('rev_order')
    if rev_order:
        session['rev_order'] = rev_order
    else:
        rev_order = session.get('rev_order', 'rev_time desc')

    movies = sel_movie(mov_order)
    reviews = sel_review(rev_order)

    return render_template('main_page.html', id=id, movies=movies, reviews=reviews)


@app.route('/movie/<mid>', methods=['get', 'post'])
def movie_info(mid):
    id = session['id']
    movie = sel_movie(int(mid))[0]

    cur.execute(
        f"select ratings, uid, review text, rev_time "
        f"from reviews "
        f"where mid = '{mid}' and uid not in "
        f"(select opid from ties where id = '{id}' and tie = 'mute') ")
    reviews = cur.fetchall()
    back = request.form.get('back')

    return render_template('movie_info.html', id=id, movie=movie, reviews=reviews)


@app.route('/update-review/<mid>', methods=['post'])
def update_review(mid):
    id = session['id']

    mid = int(mid)
    ratings = request.form.get('rating')
    review = request.form.get('review')

    cur.execute(
        f"select uid from reviews where uid = '{id}' and mid = '{mid}'")
    result = cur.fetchone()
    if result:
        cur.execute(
            f"update reviews set ratings = '{ratings}', review = '{review}' "
            f"where uid = '{id}' and mid = '{mid}'")
    else:
        cur.execute(f"insert into reviews values "
                    f"('{mid}', '{id}', '{ratings}', '{review}', now())")

    connect.commit()

    return redirect(url_for('movie_info', mid=mid))


@app.route('/user/<uid>', methods=['get', 'post'])
def user_info(uid):
    id = session['id']

    cur.execute(f"select id, role "
                f"from users "
                f"where id = '{uid}'")
    user = cur.fetchone()

    cur.execute(
        f"select ratings, mid, title, review, rev_time "
        f"from reviews, (select id, title from movies) "
        f"where uid = '{uid}' and id = mid")
    reviews = cur.fetchall()

    cur.execute(f"select id "
                f"from ties "
                f"where opid = '{uid}' and tie='follow'")
    followers = cur.fetchall()

    if id == uid:
        cur.execute(f"select opid "
                    f"from ties "
                    f"where id = '{uid}' and tie='follow'")
        followed = cur.fetchall()
        cur.execute(f"select opid "
                    f"from ties "
                    f"where id = '{uid}' and tie='mute'")
        muted = cur.fetchall()
        cur.execute(f"select id, title "
                    f"from movies")
        movies = cur.fetchall()

        return render_template('user_info.html',
                               id=id, user=user, reviews=reviews,
                               followers=followers,
                               followed=followed,
                               muted=muted, movies=movies)

    return render_template('user_info.html', id=id, user=user,
                           reviews=reviews, followers=followers)


@app.route('/follow-mute/<uid>', methods=['post'])
def follow_mute(uid):
    id = session['id']
    act = request.form.get('act')
    back = request.form.get('back')

    if act == 'follow' or act == 'unmute':
        cur.execute(f"delete "
                    f"from ties "
                    f"where id = '{id}' and opid = '{uid}' and tie = 'mute'")

    if act == 'mute' or act == 'unfollow':
        cur.execute(f"delete "
                    f"from ties "
                    f"where id = '{id}' and opid = '{uid}' and tie = 'follow'")

    if act == 'follow' or act == 'mute':
        cur.execute(f"select * "
                    f"from ties "
                    f"where id = '{id}' and opid='{uid}' and tie = '{act}'")
        result = cur.fetchone()
        if not result:
            cur.execute(f"insert into ties values ('{id}', '{uid}', '{act}')")

    connect.commit()
    return redirect(url_for('user_info', uid=back))


@app.route('/add-movie', methods=['post'])
def add_movie():
    id = session['id']
    title = request.form.get('title')
    director = request.form.get('director')
    genre = request.form.get('genre')
    rel_date = request.form.get('rel_date')
    send = request.form.get('send')

    if send:
        if not title or not director or not rel_date:
            flash('모든 칸이 입력되어야합니다.', category='error')
            return redirect(url_for('user_info', uid=id))
        cur.execute(f"select max(id) "
                    f"from movies")
        result = int(cur.fetchone()[0])
        cur.execute(f"insert into movies values "
                    f"('{result + 1}', '{title}', '{director}',"
                    f" '{genre}', '{rel_date}')")
        connect.commit()

    flash(f"'{title}'이 추가되었습니다.", category='success')
    return redirect(url_for('user_info', uid=id))


@app.route('/delete-movie', methods=['post'])
def delete_movie():
    id = session['id']
    mid = request.form.get('del_movie')
    cur.execute(f"delete "
                f"from reviews "
                f"where mid = '{mid}'")
    cur.execute(f"delete "
                f"from movies "
                f"where id = '{mid}'")
    connect.commit()

    flash(f"id = {mid}번 영화와 리뷰가 삭제되었습니다.", category='delete')
    return redirect(url_for('user_info', uid=id))


@app.route('/random-movie', methods=['post'])
def random_movie():
    genre = request.form.get('genre')
    cur.execute(f"select id "
                f"from movies "
                f"where genre = '{genre}'")
    result = cur.fetchall()

    if result:
        result = choice(result)
        flash("이 영화는 어떤가요?", category='success')
        return redirect(url_for('movie_info', mid=result[0]))
    else:
        flash(f"죄송합니다. '{genre}' 장르의 영화가 없습니다.", category='error')
        return redirect(url_for('main_page'))


if __name__ == '__main__':
    app.secret_key = 'super secret key'
    app.config['SESSION_TYPE'] = 'filesystem'
    app.run(debug=True)
