import logging
import os
import sqlite3
from functools import wraps
from datetime import datetime

from flask import (
    Flask,
    flash,
    g,
    jsonify,
    redirect,
    render_template_string,
    request,
    session,
    url_for,
)

# ---------------------------------------------------------------------------
# Logging & Configuration
# ---------------------------------------------------------------------------
logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s %(levelname)-8s %(name)s: %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger(__name__)

BASE_DIR = os.path.abspath(os.path.dirname(__file__))
DB_PATH = os.path.join(BASE_DIR, "phone_inventory.db")

# ---------------------------------------------------------------------------
# HTML Templates (Combined for brevity, logic remains identical)
# ---------------------------------------------------------------------------
LOGIN_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Phone Inventory Login</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f4f4f8; margin: 0; padding: 0; }
        .container { width: 360px; margin: 90px auto; background: #fff; padding: 28px; border-radius: 10px; box-shadow: 0 4px 14px rgba(0,0,0,0.12); }
        h1 { text-align: center; color: #e20074; margin-top: 0; }
        label { font-weight: bold; display: block; margin-top: 12px; }
        input { width: 100%; padding: 10px; margin-top: 6px; border: 1px solid #ccc; border-radius: 6px; box-sizing: border-box; }
        button { width: 100%; margin-top: 18px; padding: 12px; background: #e20074; color: white; border: none; border-radius: 6px; font-size: 15px; cursor: pointer; }
        .flash { padding: 10px; border-radius: 6px; margin-bottom: 12px; }
        .flash.error { background: #ffe5e5; color: #9d0000; }
        .flash.success { background: #e8f7e8; color: #1d6b1d; }
        .note { margin-top: 14px; font-size: 13px; color: #555; text-align: center; }
        code { background: #f2f2f2; padding: 2px 5px; border-radius: 4px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Phone Inventory</h1>
        {% with messages = get_flashed_messages(with_categories=true) %}
            {% if messages %}
                {% for category, message in messages %}
                    <div class="flash {{ category }}">{{ message }}</div>
                {% endfor %}
            {% endif %}
        {% endwith %}
        <form method="POST" action="{{ url_for('login_post') }}">
            <label for="username">Employee Username</label>
            <input type="text" id="username" name="username" required>
            <label for="password">Password</label>
            <input type="password" id="password" name="password" required>
            <button type="submit">Log In</button>
        </form>
        <div class="note"> Demo login: <code>mobileexpert</code> / <code>inventory123</code> </div>
    </div>
</body>
</html>
"""

INDEX_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Phone Inventory System</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f6f7fb; margin: 0; padding: 0; }
        .topbar { background: #111; color: white; padding: 16px 24px; display: flex; justify-content: space-between; align-items: center; }
        .topbar h1 { margin: 0; font-size: 22px; }
        .topbar .right a { color: white; text-decoration: none; margin-left: 16px; font-weight: bold; }
        .wrapper { width: 95%; max-width: 1200px; margin: 24px auto; }
        .grid { display: grid; grid-template-columns: 1fr 2fr; gap: 24px; }
        .card { background: white; border-radius: 12px; padding: 20px; box-shadow: 0 3px 12px rgba(0,0,0,0.08); }
        .card h2 { margin-top: 0; color: #e20074; }
        label { font-weight: bold; display: block; margin-top: 12px; }
        input, select { width: 100%; padding: 10px; margin-top: 6px; border: 1px solid #ccc; border-radius: 6px; box-sizing: border-box; }
        button { margin-top: 16px; padding: 10px 14px; border: none; border-radius: 6px; cursor: pointer; font-weight: bold; }
        .primary { background: #e20074; color: white; }
        .danger { background: #c62828; color: white; }
        .success-btn { background: #2e7d32; color: white; }
        .flash { padding: 10px; border-radius: 6px; margin-bottom: 12px; }
        .flash.error { background: #ffe5e5; color: #9d0000; }
        .flash.success { background: #e8f7e8; color: #1d6b1d; }
        table { width: 100%; border-collapse: collapse; margin-top: 12px; font-size: 14px; }
        th, td { padding: 10px; border-bottom: 1px solid #e5e5e5; text-align: left; }
        .tag { padding: 4px 8px; border-radius: 999px; font-size: 12px; font-weight: bold; }
        .tag.pending { background: #fff3cd; color: #8a6d3b; }
        .tag.scanned { background: #d4edda; color: #155724; }
        .small-form { display: inline; }
    </style>
</head>
<body>
    <div class="topbar">
        <h1>Phone Inventory System</h1>
        <div class="right">
            <span>Logged in as <strong>{{ username }}</strong></span>
            <a href="{{ url_for('logout') }}">Logout</a>
        </div>
    </div>
    <div class="wrapper">
        {% with messages = get_flashed_messages(with_categories=true) %}
            {% if messages %}{% for category, message in messages %}
                <div class="flash {{ category }}">{{ message }}</div>
            {% endfor %}{% endif %}
        {% endwith %}
        <div class="grid">
            <div class="card">
                <h2>Scan Inventory</h2>
                <form method="POST" action="{{ url_for('scan_inventory') }}">
                    <label>Brand</label><input type="text" name="brand" required>
                    <label>Model</label><input type="text" name="model" required>
                    <label>IMEI</label><input type="text" name="imei" required>
                    <label>Quantity</label><input type="number" name="quantity" min="1" value="1" required>
                    <label>Condition</label>
                    <select name="condition">
                        <option value="New">New</option><option value="Used">Used</option>
                    </select>
                    <label>Location</label><input type="text" name="location" required>
                    <button class="primary" type="submit">Scan Into Inventory</button>
                </form>
            </div>
            <div class="card">
                <h2>Inventory Records</h2>
                {% if items %}
                <table>
                    <thead>
                        <tr><th>IMEI</th><th>Device</th><th>Qty</th><th>Status</th><th>Actions</th></tr>
                    </thead>
                    <tbody>
                        {% for item in items %}
                        <tr>
                            <td>{{ item.imei }}</td>
                            <td>{{ item.brand }} {{ item.model }}</td>
                            <td>{{ item.quantity }}</td>
                            <td><span class="tag {{ item.status|lower }}">{{ item.status }}</span></td>
                            <td>
                                {% if item.status != "Scanned" %}
                                <form class="small-form" method="POST" action="{{ url_for('mark_scanned', item_id=item.id) }}">
                                    <button class="success-btn" type="submit">Mark Scanned</button>
                                </form>
                                {% endif %}
                                <form class="small-form" method="POST" action="{{ url_for('delete_item', item_id=item.id) }}">
                                    <button class="danger" type="submit">Delete</button>
                                </form>
                            </td>
                        </tr>
                        {% endfor %}
                    </tbody>
                </table>
                {% else %}<p>No records found.</p>{% endif %}
            </div>
        </div>
    </div>
</body>
</html>
"""

# ---------------------------------------------------------------------------
# Database Helpers
# ---------------------------------------------------------------------------
def get_db():
    if "db_conn" not in g:
        g.db_conn = sqlite3.connect(DB_PATH)
        g.db_conn.row_factory = sqlite3.Row
    return g.db_conn

def init_db():
    with sqlite3.connect(DB_PATH) as conn:
        conn.execute("""
            CREATE TABLE IF NOT EXISTS inventory (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                brand TEXT NOT NULL,
                model TEXT NOT NULL,
                imei TEXT NOT NULL UNIQUE,
                quantity INTEGER NOT NULL,
                condition TEXT NOT NULL,
                location TEXT NOT NULL,
                scanned_by TEXT NOT NULL,
                scanned_at TEXT NOT NULL,
                status TEXT NOT NULL DEFAULT 'Pending'
            )
        """)
        conn.commit()
    logger.info("Database initialized.")

# ---------------------------------------------------------------------------
# Auth Wrapper
# ---------------------------------------------------------------------------
def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not session.get("logged_in"):
            flash("Please log in first.", "error")
            return redirect(url_for("login"))
        return f(*args, **kwargs)
    return decorated_function

# ---------------------------------------------------------------------------
# App Logic
# ---------------------------------------------------------------------------
app = Flask(__name__)
app.secret_key = "development-key-123" # Use env var in production

@app.teardown_appcontext
def close_db(error):
    conn = g.pop("db_conn", None)
    if conn is not None:
        conn.close()

@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        user = request.form.get("username")
        pw = request.form.get("password")
        if user == "mobileexpert" and pw == "inventory123":
            session["logged_in"] = True
            session["username"] = user
            flash("Logged in!", "success")
            return redirect(url_for("index"))
        flash("Invalid credentials.", "error")
    return render_template_string(LOGIN_TEMPLATE)

@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("login"))

@app.route("/")
@login_required
def index():
    db = get_db()
    rows = db.execute("SELECT * FROM inventory ORDER BY id DESC").fetchall()
    return render_template_string(INDEX_TEMPLATE, items=rows, username=session.get("username"))

@app.route("/scan", methods=["POST"])
@login_required
def scan_inventory():
    try:
        db = get_db()
        db.execute(
            "INSERT INTO inventory (brand, model, imei, quantity, condition, location, scanned_by, scanned_at) VALUES (?,?,?,?,?,?,?,?)",
            (request.form['brand'], request.form['model'], request.form['imei'], request.form['quantity'], 
             request.form['condition'], request.form['location'], session['username'], datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
        )
        db.commit()
        flash("Device added.", "success")
    except sqlite3.IntegrityError:
        flash("IMEI already exists.", "error")
    return redirect(url_for("index"))

@app.route("/items/<int:item_id>/mark-scanned", methods=["POST"])
@login_required
def mark_scanned(item_id):
    db = get_db()
    db.execute("UPDATE inventory SET status = 'Scanned' WHERE id = ?", (item_id,))
    db.commit()
    return redirect(url_for("index"))

@app.route("/items/<int:item_id>/delete", methods=["POST"])
@login_required
def delete_item(item_id):
    db = get_db()
    db.execute("DELETE FROM inventory WHERE id = ?", (item_id,))
    db.commit()
    return redirect(url_for("index"))

if __name__ == "__main__":
    init_db()
    app.run(debug=True)
