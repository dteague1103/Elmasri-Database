STEP 1 Imports
All Python modules imported. Flask web framework, sqlite3 for the database, re for regex validation, os for environment variables, datetime
for timestamps, and functools.wraps for the login_required decorator.
1 import logging
2 import os
3 import re
4 import sqlite3
5 from datetime import datetime
6 from functools import wraps
7
8 from flask import (
9 Flask,
10 flash,
11 g,
12 redirect,
13 render_template_string,
14 request,
15 session,
16 url_for,
17 )
18
STEP 2 Logging & Configuration
Configures Python's built-in logger at DEBUG level with a timestamp format. BASE_DIR resolves the folder containing this file regardless
of where Python is launched from. DB_PATH builds the SQLite file path. CARRIERS is the whitelist of valid shipping carriers used across
the shipments feature.
19 # ---------------------------------------------------------------------------
20 # Logging & Configuration
21 # ---------------------------------------------------------------------------
22 logging.basicConfig(
23 level=logging.DEBUG,
24 format="%(asctime)s %(levelname)-8s %(name)s: %(message)s",
25 datefmt="%Y-%m-%d %H:%M:%S",
26 )
27 logger = logging.getLogger(__name__)
28
29 BASE_DIR = os.path.abspath(os.path.dirname(__file__))
30 DB_PATH = os.path.join(BASE_DIR, "phone_inventory.db")
31
32 CARRIERS = ["FedEx", "UPS", "USPS", "DHL", "OnTrac", "Other"]
33
STEP 3 Shared CSS + Login Template
SHARED_CSS is a multi-line string of CSS injected into every page. Defines CSS custom properties (variables), the topbar, card layout,
form elements, buttons, tables, status tags, carrier colour badges, delete modal, stat cards, and responsive breakpoints.
LOGIN_TEMPLATE is the Jinja2 HTML template for the login page — a centred card with username/password fields.
34 # ---------------------------------------------------------------------------
35 # Shared CSS (injected into every page template)
36 # ---------------------------------------------------------------------------
37 SHARED_CSS = """
38 @import url('https://fonts.googleapis.com/css2?family=DM+Mono:wght@400;500&family=Syne:wght@700;800&display=swap');
39 *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
40
41 :root {
42 --bg: #0d0d0d;
43 --bg2: #111111;
44 --card: #161616;
45 --card2: #1c1c1c;
PhoneVault · Complete Source Code Page 2
46 --border: #222222;
47 --border2: #2a2a2a;
48 --magenta: #e20074;
49 --magenta2: #c8006a;
50 --blue: #569cd6;
51 --green: #4ec99a;
52 --yellow: #f0b429;
53 --red: #ef5350;
54 --purple: #a855f7;
55 --white: #f0f0f0;
56 --grey: #888888;
57 --grey-dk: #444444;
58 --grey-lt: #cccccc;
59 60
61 62 63 64 65 66 67
68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117
118 119 }
body {
font-family: 'DM Mono', monospace;
background: var(--bg);
color: var(--white);
min-height: 100vh;
}
/* ■■ Topbar ■■ */
.topbar {
background: var(--bg2);
border-bottom: 1px solid var(--border);
padding: 0 28px;
height: 62px;
display: flex;
align-items: center;
justify-content: space-between;
position: sticky;
top: 0;
z-index: 100;
box-shadow: 0 2px 20px rgba(0,0,0,0.4);
}
.topbar-left { display: flex; align-items: center; gap: 32px; }
.topbar-logo {
font-family: 'Syne', sans-serif;
font-size: 22px;
font-weight: 800;
color: var(--magenta);
letter-spacing: -0.5px;
text-decoration: none;
}
.topbar-logo span { color: var(--white); }
.topbar-nav { display: flex; gap: 4px; }
.topbar-nav a {
color: var(--grey);
text-decoration: none;
font-size: 11px;
letter-spacing: 1.5px;
text-transform: uppercase;
padding: 6px 12px;
border-radius: 6px;
transition: color 0.15s, background 0.15s;
}
.topbar-nav a:hover { color: var(--white); background: #1e1e1e; }
.topbar-nav a.active { color: var(--magenta); background: rgba(226,0,116,0.08); }
.topbar-right { display: flex; align-items: center; gap: 16px; font-size: 12px; color: var(--grey); }
.topbar-right strong { color: var(--white); }
.topbar-right a {
color: var(--magenta);
text-decoration: none;
font-size: 11px;
letter-spacing: 1px;
text-transform: uppercase;
opacity: 0.8;
transition: opacity 0.15s;
}
.topbar-right a:hover { opacity: 1; }
/* ■■ Layout ■■ */
.wrapper { max-width: 1300px; margin: 0 auto; padding: 28px 24px; }
PhoneVault · Complete Source Code Page 3
120 .page-grid { display: grid; grid-template-columns: 300px 1fr; gap: 22px; align-items: start; }
121
122 /* ■■ Cards ■■ */
123 .card {
124 background: var(--card);
125 border: 1px solid var(--border);
126 border-radius: 14px;
127 padding: 24px;
128 }
129 .card-header {
130 font-family: 'Syne', sans-serif;
131 font-size: 15px;
132 font-weight: 700;
133 color: var(--magenta);
134 margin-bottom: 20px;
135 letter-spacing: -0.3px;
136 display: flex;
137 align-items: center;
138 gap: 8px;
139 }
140 .card-header .count {
141 font-family: 'DM Mono', monospace;
142 font-size: 11px;
143 color: var(--grey-dk);
144 font-weight: 400;
145 }
146 .card-blue .card-header { color: var(--blue); }
147 .card-green .card-header { color: var(--green); }
148
149 /* ■■ Flash messages ■■ */
150 .flash {
151 padding: 11px 16px;
152 border-radius: 8px;
153 margin-bottom: 18px;
154 font-size: 13px;
155 display: flex;
156 align-items: center;
157 gap: 8px;
158 }
159 .flash.error { background: #2d0000; color: #ff6b6b; border: 1px solid #5c0000; }
160 .flash.success { background: #0a2d0a; color: #69e869; border: 1px solid #1a5c1a; }
161
162 /* ■■ Form elements ■■ */
163 .field { margin-bottom: 14px; }
164 .field label {
165 display: block;
166 font-size: 9px;
167 letter-spacing: 2px;
168 text-transform: uppercase;
169 color: var(--grey);
170 margin-bottom: 5px;
171 }
172 .field input,
173 .field select {
174 width: 100%;
175 padding: 10px 13px;
176 background: var(--bg);
177 border: 1px solid #2e2e2e;
178 border-radius: 8px;
179 color: var(--white);
180 font-family: 'DM Mono', monospace;
181 font-size: 13px;
182 transition: border-color 0.2s, box-shadow 0.2s;
183 }
184 .field input:focus,
185 .field select:focus {
186 outline: none;
187 border-color: var(--magenta);
188 box-shadow: 0 0 0 3px rgba(226,0,116,0.12);
189 }
190 .field select option { background: var(--card); }
191
192 /* ■■ Buttons ■■ */
193 .btn {
PhoneVault · Complete Source Code Page 4
194 display: inline-flex;
195 align-items: center;
196 gap: 5px;
197 padding: 8px 14px;
198 border: none;
199 border-radius: 7px;
200 font-family: 'Syne', sans-serif;
201 font-size: 12px;
202 font-weight: 700;
203 cursor: pointer;
204 letter-spacing: 0.3px;
205 transition: opacity 0.15s, transform 0.1s;
206 white-space: nowrap;
207 }
208 .btn:hover { opacity: 0.85; }
209 .btn:active { transform: scale(0.97); }
210 .btn-primary { background: var(--magenta); color: white; width: 100%; justify-content: center; padding: 12px; font-size:
211 .btn-primary:hover { background: var(--magenta2); opacity: 1; }
212 .btn-blue { background: rgba(86,156,214,0.15); color: var(--blue); border: 1px solid rgba(86,156,214,0.3); }
213 .btn-green { background: rgba(78,201,154,0.15); color: var(--green); border: 1px solid rgba(78,201,154,0.3); }
214 .btn-yellow { background: rgba(240,180,41,0.12); color: var(--yellow); border: 1px solid rgba(240,180,41,0.25); }
215 .btn-red { background: rgba(239,83,80,0.10); color: var(--red); border: 1px solid rgba(239,83,80,0.25); }
216 .btn-submit { background: var(--blue); color: white; }
217
218 /* ■■ Table ■■ */
219 .table-wrap { overflow-x: auto; }
220 table { width: 100%; border-collapse: collapse; font-size: 12.5px; }
221 thead th {
222 font-size: 9px;
223 letter-spacing: 2px;
224 text-transform: uppercase;
225 color: var(--grey);
226 padding: 10px 12px;
227 border-bottom: 1px solid var(--border);
228 text-align: left;
229 white-space: nowrap;
230 }
231 tbody tr { transition: background 0.1s; }
232 tbody tr:hover { background: rgba(255,255,255,0.03); }
233 tbody td {
234 padding: 10px 12px;
235 border-bottom: 1px solid rgba(255,255,255,0.04);
236 vertical-align: middle;
237 }
238 .td-mono { font-family: 'DM Mono', monospace; color: var(--grey); font-size: 11px; }
239
240 /* ■■ Status tags ■■ */
241 .tag {
242 display: inline-flex;
243 align-items: center;
244 padding: 3px 9px;
245 border-radius: 999px;
246 font-size: 10px;
247 font-weight: 500;
248 letter-spacing: 0.5px;
249 white-space: nowrap;
250 }
251 .tag.pending { background: rgba(240,180,41,0.12); color: var(--yellow); border: 1px solid rgba(240,180,41,0.3); }
252 .tag.scanned { background: rgba(78,201,154,0.12); color: var(--green); border: 1px solid rgba(78,201,154,0.3); }
253 .tag.in-transit { background: rgba(86,156,214,0.12); color: var(--blue); border: 1px solid rgba(86,156,214,0.3); }
254 .tag.delivered { background: rgba(78,201,154,0.12); color: var(--green); border: 1px solid rgba(78,201,154,0.3); }
255 .tag.delayed { background: rgba(239,83,80,0.12); color: var(--red); border: 1px solid rgba(239,83,80,0.3); }
256
257 /* ■■ Carrier badges ■■ */
258 .carrier { font-weight: 700; font-size: 12px; }
259 .carrier-fedex { color: #ff7733; }
260 .carrier-ups { color: #d4a017; }
261 .carrier-usps { color: #4a90d9; }
262 .carrier-dhl { color: #f5c400; }
263 .carrier-ontrac { color: var(--purple); }
264 .carrier-other { color: var(--grey); }
265
266 /* ■■ Actions ■■ */
267 .actions { display: flex; gap: 6px; flex-wrap: wrap; }
PhoneVault · Complete Source Code Page 5
268 269
270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287 288 289 290 291 292 293 294 295 296 297 298 299 300 301
302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321
322 323 324 325 326
327 328 329 330 331
332 333 334 335 336 337 338 339 340
341 .actions form { margin: 0; }
/* ■■ Delete modal ■■ */
.modal-overlay {
display: none;
position: fixed;
inset: 0;
background: rgba(0,0,0,0.75);
backdrop-filter: blur(4px);
z-index: 200;
align-items: center;
justify-content: center;
}
.modal-overlay.active { display: flex; }
.modal-box {
background: var(--card2);
border: 1px solid var(--border2);
border-radius: 16px;
padding: 32px;
max-width: 380px;
width: 90%;
text-align: center;
box-shadow: 0 20px 60px rgba(0,0,0,0.5);
animation: modal-in 0.2s ease;
.stat-card.m { border-top-color: var(--magenta); .stat-card.b { border-top-color: var(--blue); }
.stat-card.g { border-top-color: var(--green); }
.stat-card.y { border-top-color: var(--yellow); }
.stat-val { .stat-lbl { font-size: 10px; color: var(--grey); .stat-card.m .stat-val { color: var(--magenta); }
.stat-card.b .stat-val { color: var(--blue); }
.stat-card.g .stat-val { color: var(--green); }
}
@keyframes modal-in {
from { opacity: 0; transform: scale(0.95) translateY(8px); }
to { opacity: 1; transform: scale(1) translateY(0); }
}
.modal-icon { font-size: 32px; margin-bottom: 12px; }
.modal-box h3 { font-family: 'Syne', sans-serif; font-size: 17px; color: var(--white); margin-bottom: 8px; }
.modal-box p { font-size: 12px; color: var(--grey); margin-bottom: 22px; line-height: 1.6; }
.modal-actions { display: flex; gap: 10px; justify-content: center; }
/* ■■ Stat cards on top ■■ */
.stats-row { display: grid; grid-template-columns: repeat(4, 1fr); gap: 14px; margin-bottom: 22px; }
.stat-card {
background: var(--card);
border: 1px solid var(--border);
border-radius: 12px;
padding: 16px 20px;
border-top: 2px solid transparent;
}
}
font-family: 'Syne', sans-serif; font-size: 28px; font-weight: 800; line-height: 1; }
letter-spacing: 1px; text-transform: uppercase; margin-top: 5px; }
.stat-card.y .stat-val { color: var(--yellow); }
/* ■■ Shipments form grid ■■ */
.form-grid-3 { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 0 18px; }
.form-grid-3 .span2 { grid-column: span 2; }
.form-grid-3 .span3 { grid-column: span 3; }
/* ■■ Empty state ■■ */
.empty-state { text-align: center; padding: 40px 20px; color: var(--grey-dk); }
.empty-state .icon { font-size: 36px; margin-bottom: 10px; opacity: 0.3; }
.empty-state p { font-size: 13px; }
/* ■■ Responsive ■■ */
@media (max-width: 900px) {
.page-grid { grid-template-columns: 1fr; }
.stats-row { grid-template-columns: repeat(2, 1fr); }
.form-grid-3 { grid-template-columns: 1fr; }
.form-grid-3 .span2, .form-grid-3 .span3 { grid-column: span 1; }
}
"""
# ---------------------------------------------------------------------------
PhoneVault · Complete Source Code Page 6
342 # Templates
343 # ---------------------------------------------------------------------------
344
345 LOGIN_TEMPLATE = """<!DOCTYPE html>
346 color=
"#569cd6"><html lang=
"en">
347 color=
"#569cd6"><head>
348 color=
"#569cd6"><meta charset=
"UTF-8">
349 color=
"#569cd6"><meta name=
"viewport" content=
"width=device-width, initial-scale=1.0">
350 color=
"#569cd6"><title>PhoneVault — Logincolor=
"#569cd6"></title>
351 color=
"#569cd6"><style>
352 {{ shared_css }}
353 .login-page {
354 min-height: 100vh;
355 display: flex;
356 align-items: center;
357 justify-content: center;
358 background: radial-gradient(ellipse at 30% 50%, rgba(226,0,116,0.06) 0%, transparent 60%),
359 var(--bg);
360 }
361 .login-wrap { width: 100%; max-width: 420px; padding: 24px; }
362 .login-brand { margin-bottom: 28px; }
363 .login-brand .logo { font-family: 'Syne', sans-serif; font-size: 32px; font-weight: 800; color: var(--magenta); letter-
364 .login-brand .logo span { color: var(--white); }
365 .login-brand .sub { font-size: 11px; color: var(--grey); letter-spacing: 2px; text-transform: uppercase; margin-top: 4p
366 .login-card { background: var(--card); border: 1px solid var(--border); border-radius: 16px; padding: 36px; }
367 .login-card h2 { font-family: 'Syne', sans-serif; font-size: 18px; font-weight: 700; color: var(--white); margin-bottom
368 .login-hint { margin-top: 18px; font-size: 11px; color: var(--grey-dk); text-align: center; }
369 .login-hint code { color: #555; background: #1e1e1e; padding: 1px 6px; border-radius: 4px; }
370 color=
"#569cd6"></style>
371 color=
"#569cd6"></head>
372 color=
"#569cd6"><body>
373 color=
"#569cd6"><div class=
"login-page">
374 color=
"#569cd6"><div class=
"login-wrap">
375 color=
"#569cd6"><div class=
"login-brand">
376 color=
"#569cd6"><div class=
"logo">Phonecolor=
"#569cd6"><span>Vaultcolor=
"#569cd6"></span>color=
"#569cd6"></div>
377 color=
"#569cd6"><div class=
"sub">Inventory Management Systemcolor=
"#569cd6"></div>
378 color=
"#569cd6"></div>
379 color=
"#569cd6"><div class=
"login-card">
380 color=
"#569cd6"><h2>Sign Incolor=
"#569cd6"></h2>
381 {% with messages = get_flashed_messages(with_categories=true) %}
382 {% for category, message in messages %}
383 color=
"#569cd6"><div class=
"flash {{ category }}">{{ message }}color=
"#569cd6"></div>
384 {% endfor %}
385 {% endwith %}
386 color=
"#569cd6"><form method=
"POST" action=
"{{ url_for('login') }}">
387 color=
"#569cd6"><div class=
"field">
388 color=
"#569cd6"><label for=
"username">Usernamecolor=
"#569cd6"></label>
389 color=
"#569cd6"><input type=
"text" id=
"username" name=
"username" autocomplete=
"username" placeholder=
"Enter use
390 color=
"#569cd6"></div>
391 color=
"#569cd6"><div class=
"field">
392 color=
"#569cd6"><label for=
"password">Passwordcolor=
"#569cd6"></label>
393 color=
"#569cd6"><input type=
"password" id=
"password" name=
"password" autocomplete=
"current-password" placeholde
394 color=
"#569cd6"></div>
395 color=
"#569cd6"><button class=
"btn btn-primary" type=
"submit">Sign Incolor=
"#569cd6"></button>
396 color=
"#569cd6"></form>
397 color=
"#569cd6"><div class=
"login-hint">Demo: color=
"#569cd6"><code>mobileexpertcolor=
"#569cd6"></code> / color
398 color=
"#569cd6"></div>
399 color=
"#569cd6"></div>
400 color=
"#569cd6"></div>
401 color=
"#569cd6"></body>
STEP 4 Inventory Page Template (INDEX_TEMPLATE)
Jinja2 HTML template for the main inventory dashboard. Contains the delete confirmation modal, the sticky topbar with navigation, a 4-card
stats row (total devices, scanned, pending, shipments), the 2-column CSS Grid layout with the scan form on the left and the inventory table
on the right, and the JavaScript that wires up the modal confirmation before any delete POST fires.
402 color=
"#569cd6"></html>"""
403
404
PhoneVault · Complete Source Code Page 7
405 406 407 408 409 410 411 412 413 414
415 416 417 418 419 420 421 422 423 424 425 426 427
428 429 430 431 432 433 434 435 436 437 438 439 440 441
442 443 444 445 446 447 448
449 450 451 452 453 454 455 456 457 458 459 460 461 462 463 464 465 466 467 468
469 470 471 472 473 474 475 476 477 478 INDEX_TEMPLATE = """<!DOCTYPE html>
color=
"#569cd6"><html lang=
"en">
color=
"#569cd6"><head>
color=
"#569cd6"><meta charset=
"UTF-8">
color=
"#569cd6"><meta name=
"viewport" content=
"width=device-width, initial-scale=1.0">
color=
"#569cd6"><title>PhoneVault — Inventorycolor=
"#569cd6"></title>
color=
"#569cd6"><style>{{ shared_css }}color=
"#569cd6"></style>
color=
"#569cd6"></head>
color=
"#569cd6"><body>
<!-- Delete Modal -->
color=
"#569cd6"><div class=
"modal-overlay" id=
"deleteModal">
color=
"#569cd6"><div class=
"modal-box">
color=
"#569cd6"><div class=
"modal-icon">&#128465;color=
"#569cd6"></div>
color=
"#569cd6"><h3>Delete Device?color=
"#569cd6"></h3>
color=
"#569cd6"><p>This will permanently remove the device from inventory.color=
"#569cd6"><br>This action cannot be und
color=
"#569cd6"><div class=
"modal-actions">
color=
"#569cd6"><button class=
"btn btn-red" id=
"confirmDelete">Yes, Deletecolor=
"#569cd6"></button>
color=
"#569cd6"><button class=
"btn" style=
"background:#2a2a2a;color:#ccc;" onclick=
"closeModal('deleteModal')">Cancel
color=
"#569cd6"></div>
color=
"#569cd6"></div>
color=
"#569cd6"></div>
color=
"#569cd6"><div class=
"topbar">
color=
"#569cd6"><div class=
"topbar-left">
color=
"#569cd6"><a class=
"topbar-logo" href=
"{{ url_for('index') }}">Phonecolor=
"#569cd6"><span>Vaultcolor=
"#569cd6"></
color=
"#569cd6"><nav class=
"topbar-nav">
color=
"#569cd6"><a href=
"{{ url_for('index') }}" class=
"active">Inventorycolor=
"#569cd6"></a>
color=
"#569cd6"><a href=
"{{ url_for('shipments') }}">Shipmentscolor=
"#569cd6"></a>
color=
"#569cd6"></nav>
color=
"#569cd6"></div>
color=
"#569cd6"><div class=
"topbar-right">
color=
"#569cd6"><span>Logged in as color=
"#569cd6"><strong>{{ username }}color=
"#569cd6"></strong>color=
"#569cd6"></spa
color=
"#569cd6"><a href=
"{{ url_for('logout') }}">Logoutcolor=
"#569cd6"></a>
color=
"#569cd6"></div>
color=
"#569cd6"></div>
color=
"#569cd6"><div class=
"wrapper">
{% with messages = get_flashed_messages(with_categories=true) %}
{% for category, message in messages %}
color=
"#569cd6"><div class=
"flash {{ category }}">{{ message }}color=
"#569cd6"></div>
{% endfor %}
{% endwith %}
<!-- Stats Row -->
color=
"#569cd6"><div class=
"stats-row">
color=
"#569cd6"><div class=
"stat-card m">
color=
"#569cd6"><div class=
"stat-val">{{ items|length }}color=
"#569cd6"></div>
color=
"#569cd6"><div class=
"stat-lbl">Total Devicescolor=
"#569cd6"></div>
color=
"#569cd6"></div>
color=
"#569cd6"><div class=
"stat-card g">
color=
"#569cd6"><div class=
"stat-val">{{ items|selectattr('status','equalto','Scanned')|list|length }}color=
"
color=
"#569cd6"><div class=
"stat-lbl">Scannedcolor=
"#569cd6"></div>
color=
"#569cd6"></div>
color=
"#569cd6"><div class=
"stat-card y">
color=
"#569cd6"><div class=
"stat-val">{{ items|selectattr('status','equalto','Pending')|list|length }}color=
"
color=
"#569cd6"><div class=
"stat-lbl">Pendingcolor=
"#569cd6"></div>
color=
"#569cd6"></div>
color=
"#569cd6"><div class=
"stat-card b">
color=
"#569cd6"><div class=
"stat-val">{{ shipment_list|length }}color=
"#569cd6"></div>
color=
"#569cd6"><div class=
"stat-lbl">Shipmentscolor=
"#569cd6"></div>
color=
"#569cd6"></div>
color=
"#569cd6"></div>
color=
"#569cd6"><div class=
"page-grid">
<!-- Scan Form -->
color=
"#569cd6"><div class=
"card">
color=
"#569cd6"><div class=
"card-header">&#128247; Scan Devicecolor=
"#569cd6"></div>
color=
"#569cd6"><form method=
"POST" action=
"{{ url_for('scan_inventory') }}">
color=
"#569cd6"><div class=
"field">
color=
"#569cd6"><label>Brandcolor=
"#569cd6"></label>
color=
"#569cd6"><input type=
"text" name=
"brand" placeholder=
"e.g. Apple" required maxlength=
"64">
color=
"#569cd6"></div>
color=
"#569cd6"><div class=
"field">
PhoneVault · Complete Source Code Page 8
479 480 481 482 483 484 485 486 487 488 489 490 491 492 493 494 495 496 497 498 499 500 501 502 503 504 505 506 507 508 509 510 511 512 513 514
515 516 517 518 519 520 521 522 523 524 525 526 527 528 529 530 531 532 533 534 535 536 537 538 539 540 541 542 543 544 545 546 547 548 549 550 551 552 color=
"#569cd6"><label>Modelcolor=
"#569cd6"></label>
color=
"#569cd6"><input type=
"text" name=
"model" placeholder=
"e.g. iPhone 15 Pro" required maxlength=
"128">
color=
"#569cd6"></div>
color=
"#569cd6"><div class=
"field">
color=
"#569cd6"><label>IMEI (15 digits)color=
"#569cd6"></label>
color=
"#569cd6"><input type=
"text" name=
"imei" placeholder=
"000000000000000" required pattern=
"[0-9]{15}"
color=
"#569cd6"></div>
color=
"#569cd6"><div class=
"field">
color=
"#569cd6"><label>Quantitycolor=
"#569cd6"></label>
color=
"#569cd6"><input type=
"number" name=
"quantity" min=
"1" max=
"9999" value=
"1" required>
color=
"#569cd6"></div>
color=
"#569cd6"><div class=
"field">
color=
"#569cd6"><label>Conditioncolor=
"#569cd6"></label>
color=
"#569cd6"><select name=
"condition">
color=
"#569cd6"><option value=
"New">Newcolor=
"#569cd6"></option>
color=
"#569cd6"><option value=
"Used">Usedcolor=
"#569cd6"></option>
color=
"#569cd6"><option value=
"Refurbished">Refurbishedcolor=
"#569cd6"></option>
color=
"#569cd6"></select>
color=
"#569cd6"></div>
color=
"#569cd6"><div class=
"field">
color=
"#569cd6"><label>Locationcolor=
"#569cd6"></label>
color=
"#569cd6"><input type=
"text" name=
"location" placeholder=
"e.g. Warehouse A, Shelf 3" required maxlength
color=
"#569cd6"></div>
color=
"#569cd6"><div class=
"field">
color=
"#569cd6"><label>Link to Shipment (optional)color=
"#569cd6"></label>
color=
"#569cd6"><select name=
"shipment_id">
color=
"#569cd6"><option value=
"">&#8212; None &#8212;color=
"#569cd6"></option>
{% for s in shipment_list %}
color=
"#569cd6"><option value=
"{{ s.id }}">{{ s.carrier }} | {{ s.tracking_number }} | {{ s.supplier }}
{% endfor %}
color=
"#569cd6"></select>
color=
"#569cd6"></div>
color=
"#569cd6"><button class=
"btn btn-primary" type=
"submit">&#10010; Scan Into Inventorycolor=
"#569cd6"></button>
color=
"#569cd6"></form>
color=
"#569cd6"></div>
<!-- Inventory Table -->
color=
"#569cd6"><div class=
"card">
color=
"#569cd6"><div class=
"card-header">
&#128202; Inventory Records
color=
"#569cd6"><span class=
"count">{{ items|length }} devicescolor=
"#569cd6"></span>
color=
"#569cd6"></div>
{% if items %}
color=
"#569cd6"><div class=
"table-wrap">
color=
"#569cd6"><table>
color=
"#569cd6"><thead>
color=
"#569cd6"><tr>
color=
"#569cd6"><th>IMEIcolor=
"#569cd6"></th>
color=
"#569cd6"><th>Devicecolor=
"#569cd6"></th>
color=
"#569cd6"><th>Qtycolor=
"#569cd6"></th>
color=
"#569cd6"><th>Conditioncolor=
"#569cd6"></th>
color=
"#569cd6"><th>Shipmentcolor=
"#569cd6"></th>
color=
"#569cd6"><th>Statuscolor=
"#569cd6"></th>
color=
"#569cd6"><th>Scannedcolor=
"#569cd6"></th>
color=
"#569cd6"><th>Actionscolor=
"#569cd6"></th>
color=
"#569cd6"></tr>
color=
"#569cd6"></thead>
color=
"#569cd6"><tbody>
{% for item in items %}
color=
"#569cd6"><tr>
color=
"#569cd6"><td class=
"td-mono">{{ item.imei }}color=
"#569cd6"></td>
color=
"#569cd6"><td>
color=
"#569cd6"><strong style=
"font-size:13px;">{{ item.brand }} {{ item.model }}color=
"#569cd6"></strong>
color=
"#569cd6"><span style=
"font-size:11px;color:var(--grey);">{{ item.location }}color=
"#569cd6"></span>
color=
"#569cd6"></td>
color=
"#569cd6"><td style=
"font-weight:700;">{{ item.quantity }}color=
"#569cd6"></td>
color=
"#569cd6"><td style=
"font-size:11px;color:var(--grey);">{{ item.condition }}color=
"#569cd6"></td>
color=
"#569cd6"><td>
{% if item.carrier %}
color=
"#569cd6"><span class=
"carrier carrier-{{ item.carrier|lower }}">{{ item.carrier }}color=
"#569cd6">
color=
"#569cd6"><span class=
"td-mono" style=
"font-size:10px;">{{ item.tracking_number }}color=
"#569cd6"><
{% else %}
color=
"#569cd6"><span style=
"color:var(--grey-dk);">&#8212;color=
"#569cd6"></span>
{% endif %}
PhoneVault · Complete Source Code Page 9
553 color=
"#569cd6"></td>
554 color=
"#569cd6"><td>color=
"#569cd6"><span class=
"tag {{ item.status|lower }}">{{ item.status }}color=
555 color=
"#569cd6"><td class=
"td-mono" style=
"font-size:11px;">{{ item.scanned_at[:10] }}color=
"#569cd6"></td>
556 color=
"#569cd6"><td>
557 color=
"#569cd6"><div class=
"actions">
558 {% if item.status != "Scanned" %}
559 color=
"#569cd6"><form method=
"POST" action=
"{{ url_for('mark_scanned', item_id=item.id) }}">
560 color=
"#569cd6"><button class=
"btn btn-green" type=
"submit">&#10003; Scancolor=
"#569cd6"></button>
561 color=
"#569cd6"></form>
562 {% endif %}
563 color=
"#569cd6"><form method=
"POST" action=
"{{ url_for('delete_item', item_id=item.id) }}" class=
564 color=
"#569cd6"><button class=
"btn btn-red" type=
"button" onclick=
"openDelete(this.form)">Delete
565 color=
"#569cd6"></form>
566 color=
"#569cd6"></div>
567 color=
"#569cd6"></td>
568 color=
"#569cd6"></tr>
569 {% endfor %}
570 color=
"#569cd6"></tbody>
571 color=
"#569cd6"></table>
572 color=
"#569cd6"></div>
573 {% else %}
574 color=
"#569cd6"><div class=
"empty-state">
575 color=
"#569cd6"><div class=
"icon">&#128241;color=
"#569cd6"></div>
576 color=
"#569cd6"><p>No devices yet. Scan one to get started.color=
"#569cd6"></p>
577 color=
"#569cd6"></div>
578 {% endif %}
579 color=
"#569cd6"></div>
580 color=
"#569cd6"></div>
581 color=
"#569cd6"></div>
582
583 color=
"#569cd6"><script>
584 let pendingForm = null;
585 function openDelete(form) {
586 pendingForm = form;
587 document.getElementById('deleteModal').classList.add('active');
588 }
589 function closeModal(id) {
590 document.getElementById(id).classList.remove('active');
591 pendingForm = null;
592 }
593 document.getElementById('confirmDelete').addEventListener('click', () => {
594 if (pendingForm) pendingForm.submit();
595 });
596 document.getElementById('deleteModal').addEventListener('click', function(e) {
597 if (e.target === this) closeModal('deleteModal');
598 });
599 color=
"#569cd6"></script>
600 color=
"#569cd6"></body>
601 color=
"#569cd6"></html>"""
STEP 5 Shipments Page Template (SHIPMENTS_TEMPLATE)
Jinja2 HTML template for the /shipments dashboard. Contains the shipment delete modal, the topbar, a 4-card stats row (total, in transit,
delivered, delayed), the 3-column log form with carrier dropdown, tracking number, expected arrival date, supplier, device count, and
optional notes, the full shipments table with context-sensitive action buttons per row status, and the same JS modal pattern used on the
inventory page.
602
603
604 SHIPMENTS_TEMPLATE = """<!DOCTYPE html>
605 color=
"#569cd6"><html lang=
"en">
606 color=
"#569cd6"><head>
607 color=
"#569cd6"><meta charset=
"UTF-8">
608 color=
"#569cd6"><meta name=
"viewport" content=
"width=device-width, initial-scale=1.0">
609 color=
"#569cd6"><title>PhoneVault — Shipmentscolor=
"#569cd6"></title>
610 color=
"#569cd6"><style>{{ shared_css }}color=
"#569cd6"></style>
611 color=
"#569cd6"></head>
612 color=
"#569cd6"><body>
613
614 <!-- Delete Modal -->
615 color=
"#569cd6"><div class=
"modal-overlay" id=
"deleteModal">
PhoneVault · Complete Source Code Page 10
616 617 618 619 620 621 622 623 624 625 626
627 628 629 630 631 632 633 634 635 636 637 638 639 640
641 642 643 644 645 646 647
648 649 650 651 652 653 654 655 656 657 658 659 660 661 662 663 664 665 666 667
668 669 670 671 672 673 674 675 676 677 678 679 680 681 682 683 684 685 686 687 688 689 color=
"#569cd6"><div class=
"modal-box">
color=
"#569cd6"><div class=
"modal-icon">&#128667;color=
"#569cd6"></div>
color=
"#569cd6"><h3>Delete Shipment?color=
"#569cd6"></h3>
color=
"#569cd6"><p>Any linked inventory devices will be color=
"#569cd6"><strong>unlinkedcolor=
"#569cd6"></strong> but n
color=
"#569cd6"><div class=
"modal-actions">
color=
"#569cd6"><button class=
"btn btn-red" id=
"confirmDelete">Yes, Deletecolor=
"#569cd6"></button>
color=
"#569cd6"><button class=
"btn" style=
"background:#2a2a2a;color:#ccc;" onclick=
"closeModal('deleteModal')">Cancel
color=
"#569cd6"></div>
color=
"#569cd6"></div>
color=
"#569cd6"></div>
color=
"#569cd6"><div class=
"topbar">
color=
"#569cd6"><div class=
"topbar-left">
color=
"#569cd6"><a class=
"topbar-logo" href=
"{{ url_for('index') }}">Phonecolor=
"#569cd6"><span>Vaultcolor=
"#569cd6"></
color=
"#569cd6"><nav class=
"topbar-nav">
color=
"#569cd6"><a href=
"{{ url_for('index') }}">Inventorycolor=
"#569cd6"></a>
color=
"#569cd6"><a href=
"{{ url_for('shipments') }}" class=
"active">Shipmentscolor=
"#569cd6"></a>
color=
"#569cd6"></nav>
color=
"#569cd6"></div>
color=
"#569cd6"><div class=
"topbar-right">
color=
"#569cd6"><span>Logged in as color=
"#569cd6"><strong>{{ username }}color=
"#569cd6"></strong>color=
"#569cd6"></spa
color=
"#569cd6"><a href=
"{{ url_for('logout') }}">Logoutcolor=
"#569cd6"></a>
color=
"#569cd6"></div>
color=
"#569cd6"></div>
color=
"#569cd6"><div class=
"wrapper">
{% with messages = get_flashed_messages(with_categories=true) %}
{% for category, message in messages %}
color=
"#569cd6"><div class=
"flash {{ category }}">{{ message }}color=
"#569cd6"></div>
{% endfor %}
{% endwith %}
<!-- Stats -->
color=
"#569cd6"><div class=
"stats-row">
color=
"#569cd6"><div class=
"stat-card b">
color=
"#569cd6"><div class=
"stat-val">{{ shipments|length }}color=
"#569cd6"></div>
color=
"#569cd6"><div class=
"stat-lbl">Total Shipmentscolor=
"#569cd6"></div>
color=
"#569cd6"></div>
color=
"#569cd6"><div class=
"stat-card y">
color=
"#569cd6"><div class=
"stat-val">{{ shipments|selectattr('status','equalto','In Transit')|list|length }}
color=
"#569cd6"><div class=
"stat-lbl">In Transitcolor=
"#569cd6"></div>
color=
"#569cd6"></div>
color=
"#569cd6"><div class=
"stat-card g">
color=
"#569cd6"><div class=
"stat-val">{{ shipments|selectattr('status','equalto','Delivered')|list|length }}color
color=
"#569cd6"><div class=
"stat-lbl">Deliveredcolor=
"#569cd6"></div>
color=
"#569cd6"></div>
color=
"#569cd6"><div class=
"stat-card m">
color=
"#569cd6"><div class=
"stat-val">{{ shipments|selectattr('status','equalto','Delayed')|list|length }}color
color=
"#569cd6"><div class=
"stat-lbl">Delayedcolor=
"#569cd6"></div>
color=
"#569cd6"></div>
color=
"#569cd6"></div>
<!-- Log Shipment Form -->
color=
"#569cd6"><div class=
"card card-blue" style=
"margin-bottom:22px;">
color=
"#569cd6"><div class=
"card-header">&#128667; Log Incoming Shipmentcolor=
"#569cd6"></div>
color=
"#569cd6"><form method=
"POST" action=
"{{ url_for('add_shipment') }}">
color=
"#569cd6"><div class=
"form-grid-3">
color=
"#569cd6"><div class=
"field">
color=
"#569cd6"><label>Carriercolor=
"#569cd6"></label>
color=
"#569cd6"><select name=
"carrier" required>
{% for c in carriers %}
color=
"#569cd6"><option value=
"{{ c }}">{{ c }}color=
"#569cd6"></option>
{% endfor %}
color=
"#569cd6"></select>
color=
"#569cd6"></div>
color=
"#569cd6"><div class=
"field">
color=
"#569cd6"><label>Tracking Numbercolor=
"#569cd6"></label>
color=
"#569cd6"><input type=
"text" name=
"tracking_number" placeholder=
"e.g. 1Z999AA10123456784" maxlength
color=
"#569cd6"></div>
color=
"#569cd6"><div class=
"field">
color=
"#569cd6"><label>Expected Arrivalcolor=
"#569cd6"></label>
color=
"#569cd6"><input type=
"date" name=
"expected_arrival" required>
color=
"#569cd6"></div>
color=
"#569cd6"><div class=
"field span2">
PhoneVault · Complete Source Code Page 11
690 691 692 693 694 695 696 697 698 699 700 701 702 703 704 705
706 707 708 709 710 711 712 713 714 715 716 717 718 719 720 721 722 723 724 725 726 727 728 729 730 731 732 733 734 735 736 737 738 739 740 741 742 743 744 745 746 747 748 749 750 751 752 753 754 755 756 757 758 759 760 761 762 763 color=
"#569cd6"><label>Supplier / Sender Namecolor=
"#569cd6"></label>
color=
"#569cd6"><input type=
"text" name=
"supplier" placeholder=
"e.g. Apple Distribution EMEA" maxlength=
"
color=
"#569cd6"></div>
color=
"#569cd6"><div class=
"field">
color=
"#569cd6"><label>Devices Expectedcolor=
"#569cd6"></label>
color=
"#569cd6"><input type=
"number" name=
"device_count" min=
"1" max=
"9999" value=
"1" required>
color=
"#569cd6"></div>
color=
"#569cd6"><div class=
"field span3">
color=
"#569cd6"><label>Notes (optional)color=
"#569cd6"></label>
color=
"#569cd6"><input type=
"text" name=
"notes" placeholder=
"e.g. Priority flagship shipment" maxlength=
"
color=
"#569cd6"></div>
color=
"#569cd6"></div>
color=
"#569cd6"><button class=
"btn btn-submit" type=
"submit" style=
"margin-top:6px;padding:11px 28px;">&#10010; Log S
color=
"#569cd6"></form>
color=
"#569cd6"></div>
<!-- Shipments Table -->
color=
"#569cd6"><div class=
"card card-blue">
color=
"#569cd6"><div class=
"card-header">
&#128230; Shipment Records
color=
"#569cd6"><span class=
"count">{{ shipments|length }} shipmentscolor=
"#569cd6"></span>
color=
"#569cd6"></div>
{% if shipments %}
color=
"#569cd6"><div class=
"table-wrap">
color=
"#569cd6"><table>
color=
"#569cd6"><thead>
color=
"#569cd6"><tr>
color=
"#569cd6"><th>Carriercolor=
"#569cd6"></th>
color=
"#569cd6"><th>Tracking #color=
"#569cd6"></th>
color=
"#569cd6"><th>Suppliercolor=
"#569cd6"></th>
color=
"#569cd6"><th>Expectedcolor=
"#569cd6"></th>
color=
"#569cd6"><th>Devicescolor=
"#569cd6"></th>
color=
"#569cd6"><th>Logged Bycolor=
"#569cd6"></th>
color=
"#569cd6"><th>Datecolor=
"#569cd6"></th>
color=
"#569cd6"><th>Statuscolor=
"#569cd6"></th>
color=
"#569cd6"><th>Notescolor=
"#569cd6"></th>
color=
"#569cd6"><th>Actionscolor=
"#569cd6"></th>
color=
"#569cd6"></tr>
color=
"#569cd6"></thead>
color=
"#569cd6"><tbody>
{% for s in shipments %}
color=
"#569cd6"><tr>
color=
"#569cd6"><td>color=
"#569cd6"><span class=
"carrier carrier-{{ s.carrier|lower }}">{{ s.carrier }}
color=
"#569cd6"><td class=
"td-mono">{{ s.tracking_number }}color=
"#569cd6"></td>
color=
"#569cd6"><td style=
"font-size:12px;">{{ s.supplier }}color=
"#569cd6"></td>
color=
"#569cd6"><td class=
"td-mono" style=
"font-size:11px;">{{ s.expected_arrival }}color=
"#569cd6"></td>
color=
"#569cd6"><td style=
"font-weight:700;text-align:center;">{{ s.device_count }}color=
"#569cd6"></td>
color=
"#569cd6"><td style=
"font-size:11px;color:var(--grey);">{{ s.logged_by }}color=
"#569cd6"></td>
color=
"#569cd6"><td class=
"td-mono" style=
"font-size:11px;">{{ s.logged_at[:10] }}color=
"#569cd6"></td>
color=
"#569cd6"><td>color=
"#569cd6"><span class=
"tag {{ s.status|lower|replace(' ','-') }}">{{ s.status }}
color=
"#569cd6"><td style=
"font-size:11px;color:var(--grey);max-width:140px;">{{ s.notes or '&#8212;' }}
color=
"#569cd6"><td>
color=
"#569cd6"><div class=
"actions">
{% if s.status == "In Transit" %}
color=
"#569cd6"><form method=
"POST" action=
"{{ url_for('mark_delivered', shipment_id=s.id) }}">
color=
"#569cd6"><button class=
"btn btn-green" type=
"submit">Deliveredcolor=
"#569cd6"></button>
color=
"#569cd6"></form>
color=
"#569cd6"><form method=
"POST" action=
"{{ url_for('mark_delayed', shipment_id=s.id) }}">
color=
"#569cd6"><button class=
"btn btn-yellow" type=
"submit">Delayedcolor=
"#569cd6"></button>
color=
"#569cd6"></form>
{% elif s.status == "Delayed" %}
color=
"#569cd6"><form method=
"POST" action=
"{{ url_for('mark_delivered', shipment_id=s.id) }}">
color=
"#569cd6"><button class=
"btn btn-green" type=
"submit">Deliveredcolor=
"#569cd6"></button>
color=
"#569cd6"></form>
{% endif %}
color=
"#569cd6"><form method=
"POST" action=
"{{ url_for('delete_shipment', shipment_id=s.id) }}" class
color=
"#569cd6"><button class=
"btn btn-red" type=
"button" onclick=
"openDelete(this.form)">Deletecolor
color=
"#569cd6"></form>
color=
"#569cd6"></div>
color=
"#569cd6"></td>
color=
"#569cd6"></tr>
{% endfor %}
color=
"#569cd6"></tbody>
color=
"#569cd6"></table>
PhoneVault · Complete Source Code Page 12
764 color=
"#569cd6"></div>
765 {% else %}
766 color=
"#569cd6"><div class=
"empty-state">
767 color=
"#569cd6"><div class=
"icon">&#128667;color=
"#569cd6"></div>
768 color=
"#569cd6"><p>No shipments logged yet. Log one above.color=
"#569cd6"></p>
769 color=
"#569cd6"></div>
770 {% endif %}
771 color=
"#569cd6"></div>
772 color=
"#569cd6"></div>
773
774 color=
"#569cd6"><script>
775 let pendingForm = null;
776 function openDelete(form) {
777 pendingForm = form;
778 document.getElementById('deleteModal').classList.add('active');
779 }
780 function closeModal(id) {
781 document.getElementById(id).classList.remove('active');
782 pendingForm = null;
783 }
784 document.getElementById('confirmDelete').addEventListener('click', () => {
785 if (pendingForm) pendingForm.submit();
786 });
787 document.getElementById('deleteModal').addEventListener('click', function(e) {
788 if (e.target === this) closeModal('deleteModal');
789 });
790 color=
"#569cd6"></script>
791 color=
"#569cd6"></body>
792 color=
"#569cd6"></html>"""
STEP 6 Database Helpers
get_db() opens a sqlite3 connection on first call per request and stores it on Flask's g object so subsequent calls within the same request
reuse it. row_factory = sqlite3.Row lets columns be accessed by name (item.imei) not just index. init_db() creates both tables if they don't
exist and runs a safe ALTER TABLE migration to add shipment_id to databases that predate the shipments feature.
793
794 # ---------------------------------------------------------------------------
795 # Database Helpers
796 # ---------------------------------------------------------------------------
797
798 def get_db():
799 if "db_conn" not in g:
800 g.db_conn = sqlite3.connect(DB_PATH)
801 g.db_conn.row_factory = sqlite3.Row
802 return g.db_conn
803
804
805 def init_db():
806 with sqlite3.connect(DB_PATH) as conn:
807 conn.execute("""
808 CREATE TABLE IF NOT EXISTS shipments (
809 id INTEGER PRIMARY KEY AUTOINCREMENT,
810 carrier TEXT NOT NULL,
811 tracking_number TEXT NOT NULL,
812 supplier TEXT NOT NULL,
813 device_count INTEGER NOT NULL CHECK(device_count >= 1),
814 expected_arrival TEXT NOT NULL,
815 logged_by TEXT NOT NULL,
816 logged_at TEXT NOT NULL,
817 status TEXT NOT NULL DEFAULT 'In Transit',
818 notes TEXT
819 )
820 """)
821 conn.execute("""
822 CREATE TABLE IF NOT EXISTS inventory (
823 id INTEGER PRIMARY KEY AUTOINCREMENT,
824 brand TEXT NOT NULL,
825 model TEXT NOT NULL,
826 imei TEXT NOT NULL UNIQUE,
PhoneVault · Complete Source Code Page 13
827 quantity INTEGER NOT NULL CHECK(quantity >= 1),
828 condition TEXT NOT NULL,
829 location TEXT NOT NULL,
830 scanned_by TEXT NOT NULL,
831 scanned_at TEXT NOT NULL,
832 status TEXT NOT NULL DEFAULT 'Pending',
833 shipment_id INTEGER REFERENCES shipments(id) ON DELETE SET NULL
834 )
835 """)
836 # Safe migration for existing databases
837 try:
838 conn.execute("ALTER TABLE inventory ADD COLUMN shipment_id INTEGER REFERENCES shipments(id) ON DELETE SET NULL"
839 except sqlite3.OperationalError:
840 pass
841 conn.commit()
842 logger.info("Database initialised.")
843
844
845 # ---------------------------------------------------------------------------
846 # Auth Helpers
847 # ---------------------------------------------------------------------------
848
849 def check_credentials(username: str, password: str) -> bool:
850 """Replace with bcrypt + DB user table before production."""
851 valid_user = os.environ.get("APP_USERNAME", "mobileexpert")
852 valid_pass = os.environ.get("APP_PASSWORD", "inventory123")
853 return username == valid_user and password == valid_pass
854
855
856 def login_required(f):
857 @wraps(f)
858 def decorated(*args, **kwargs):
STEP 7 Auth Helpers
check_credentials() compares the submitted username and password against APP_USERNAME and APP_PASSWORD environment
variables, with demo fallbacks for local development. login_required is a decorator factory that checks session['logged_in'] before every
protected route — redirecting to /login if absent. @wraps(f) preserves the wrapped function's __name__ so Flask's url_for() routing
continues to work on decorated views.
859 if not session.get("logged_in"):
860 flash("Please log in first.", "error")
861 return redirect(url_for("login"))
862 return f(*args, **kwargs)
863 return decorated
864
865
866 # ---------------------------------------------------------------------------
867 # Input Validation
868 # ---------------------------------------------------------------------------
869
870 IMEI_RE = re.compile(r"^\d{15}$")
871 TRACKING_RE = re.compile(r"^[A-Za-z0-9\-]{4,64}$")
872
873
874 def validate_imei(imei: str) -> bool:
875 return bool(IMEI_RE.match(imei))
876
877
878 def validate_quantity(value: str) -> "int | None":
879 try:
880 qty = int(value)
881 return qty if 1 <= qty <= 9999 else None
882 except (ValueError, TypeError):
883 return None
884
885
886 def validate_tracking(tracking: str) -> bool:
887 return bool(TRACKING_RE.match(tracking))
888
889
PhoneVault · Complete Source Code Page 14
890 891 892 893
894 # ---------------------------------------------------------------------------
# App Factory
# ---------------------------------------------------------------------------
app = Flask(__name__)
STEP 8 Input Validation
IMEI_RE and TRACKING_RE are compiled once at import time for efficiency. validate_imei() checks exactly 15 digits. validate_quantity()
casts to int and enforces the [1, 9999] range, returning None as a failure sentinel. validate_tracking() checks 4-64 alphanumeric/hyphen
characters covering all major carrier tracking number formats.
895 896
897
898 899 900 901 902 903
904
905 906 907 908
909
910 app.secret_key = os.environ.get("SECRET_KEY", "change-me-before-production")
@app.teardown_appcontext
def close_db(error):
conn = g.pop("db_conn", None)
if conn is not None:
conn.close()
def render(template, **kwargs):
"""Wrapper that always injects shared_css."""
return render_template_string(template, shared_css=SHARED_CSS, **kwargs)
# ■■ Auth Routes ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
STEP 9 App Instance + Auth Routes
Flask app is instantiated with SECRET_KEY from environment. close_db() teardown ensures the SQLite connection is always closed after
each request. render() is a helper that injects SHARED_CSS into every template call. login() handles GET (render form) and POST
(validate credentials, set session keys, redirect). logout() clears the session entirely.
914 if session.get("logged_in"):
915 return redirect(url_for("index"))
916 if request.method == "POST":
917 username = request.form.get("username",
918 password = request.form.get("password",
919 if check_credentials(username, password):
920 session["logged_in"] = True
921 session["username"] = username
922 flash("Welcome back!", "success")
923 return redirect(url_for("index"))
924 flash("Invalid username or password.", "error")
925 logger.warning("Failed login 911
912 913 @app.route("/login", methods=["GET", "POST"])
def login():
926 927
return render(LOGIN_TEMPLATE)
928
929 930 931 932 @app.route("/logout")
def logout():
session.clear()
return redirect(url_for("login"))
"").strip()
"")
attempt for user: %s", username)
STEP 10 Inventory Routes
index() runs a LEFT JOIN query to fetch inventory rows with carrier/tracking data from their linked shipment, then renders
INDEX_TEMPLATE. scan_inventory() validates all 6 form fields server-side, runs a parameterised INSERT, and catches
sqlite3.IntegrityError for duplicate IMEIs. mark_scanned() runs an UPDATE to flip status. delete_item() runs a DELETE. All routes follow
the Post/Redirect/Get pattern to prevent form resubmission.
933
PhoneVault · Complete Source Code Page 15
934
935 936
937 938 939 940 941 942 943 944 945 946 947 948 949 950 951 952 953 954 955 956 957 958
959
960 961 962 963 964 965 966 967 968 969 970
971 972 973 974 975 976 977 978 979 980 981 982 983 984 985 986 987 988 989 990 991
992 993 994 995 996
997 998 999 1000 1001 1002 1003 1004 1005 1006 1007 # ■■ Inventory Routes ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
@app.route("/")
@login_required
def index():
db = get_db()
items = db.execute("""
SELECT i.*,
s.carrier AS carrier,
s.tracking_number AS tracking_number
FROM inventory i
LEFT JOIN shipments s ON i.shipment_id = s.id
ORDER BY i.id DESC
""").fetchall()
shipment_list = db.execute(
"SELECT id, carrier, tracking_number, supplier FROM shipments ORDER BY id DESC"
).fetchall()
return render(
INDEX_TEMPLATE,
items=items,
shipment_list=shipment_list,
username=session.get("username"),
brand = request.form.get("brand", "").strip()
model = request.form.get("model", "").strip()
imei = request.form.get("imei", "").strip()
qty_raw = request.form.get("quantity", "")
condition = request.form.get("condition", "New")
location = request.form.get("location", "").strip()
shipment_id = request.form.get("shipment_id") or None
)
@app.route("/scan", methods=["POST"])
@login_required
def scan_inventory():
errors = []
if not brand:
errors.append("Brand is required.")
if not model:
errors.append("Model is required.")
if not validate_imei(imei):
errors.append("IMEI must be exactly 15 digits.")
quantity = validate_quantity(qty_raw)
if quantity is None:
errors.append("Quantity must be between 1 and 9999.")
if condition not in ("New", "Used", "Refurbished"):
errors.append("Invalid condition value.")
if not location:
errors.append("Location is required.")
if shipment_id is not None:
try:
shipment_id = int(shipment_id)
except ValueError:
errors.append("Invalid shipment selection.")
shipment_id = None
if errors:
for err in errors:
flash(err, "error")
return redirect(url_for("index"))
try:
db = get_db()
db.execute(
"""INSERT INTO inventory
(brand, model, imei, quantity, condition, location,
scanned_by, scanned_at, shipment_id)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)""",
(
brand, model, imei, quantity, condition, location,
session["username"],
datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
PhoneVault · Complete Source Code Page 16
1008 1009 1010 1011 1012 1013 1014 1015 1016
1017 1018
1019
1020 1021 1022 1023 1024 1025 1026 1027 1028
1029
1030 1031 1032 1033 1034 1035 1036 1037 1038
shipment_id,
),
)
db.commit()
flash(f"Device '{brand} {model}' added successfully.", "success")
logger.info("Device added — IMEI: %s by %s", imei, session["username"])
except sqlite3.IntegrityError:
flash(f"A device with IMEI {imei} already exists.", "error")
return redirect(url_for("index"))
@app.route("/items/color=
"#569cd6"><int:item_id>/mark-scanned", methods=["POST"])
@login_required
def mark_scanned(item_id):
db = get_db()
db.execute("UPDATE inventory SET status = 'Scanned' WHERE id = ?", (item_id,))
db.commit()
flash("Device marked as scanned.", "success")
return redirect(url_for("index"))
@app.route("/items/color=
"#569cd6"><int:item_id>/delete", methods=["POST"])
@login_required
def delete_item(item_id):
db = get_db()
db.execute("DELETE FROM inventory WHERE id = ?", (item_id,))
db.commit()
flash("Device deleted.", "success")
return redirect(url_for("index"))
STEP 11 Shipment Routes
shipments() fetches all shipment rows ordered by most recent. add_shipment() validates carrier whitelist, tracking regex, supplier, device
count, and arrival date before INSERTing. mark_delivered() and mark_delayed() both run UPDATE statements on the status column.
delete_shipment() first unlinks all inventory devices (UPDATE shipment_id = NULL) then DELETEs the shipment row, preserving device
records.
1042 @app.route("/shipments")
1043 @login_required
1044 def shipments():
1045 db = get_db()
1046 rows = db.execute("SELECT * FROM shipments ORDER BY id DESC").fetchall()
1047 return render(
1048 SHIPMENTS_TEMPLATE,
1049 shipments=rows,
1050 carriers=CARRIERS,
1051 username=session.get("username"),
1052 )
1039
1040 1041
1053
1054
1055 1056 1057 1058 1059 1060 1061 1062 1063 1064
1065 1066 1067 1068 1069 1070 # ■■ Shipment Routes ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
@app.route("/shipments/add", methods=["POST"])
@login_required
def add_shipment():
carrier = request.form.get("carrier", "").strip()
tracking_number = request.form.get("tracking_number", "").strip()
supplier = request.form.get("supplier", "").strip()
device_count_raw = request.form.get("device_count", "")
expected_arrival = request.form.get("expected_arrival", "").strip()
notes = request.form.get("notes", "").strip() or None
errors = []
if carrier not in CARRIERS:
errors.append("Invalid carrier selected.")
if not validate_tracking(tracking_number):
errors.append("Tracking number must be 4-64 alphanumeric characters.")
if not supplier:
PhoneVault · Complete Source Code Page 17
1071 errors.append("Supplier name is required.")
1072 device_count = validate_quantity(device_count_raw)
1073 if device_count is None:
1074 errors.append("Device count must be between 1 and 9999.")
1075 if not expected_arrival:
1076 errors.append("Expected arrival date is required.")
1077
1078 if errors:
1079 for err in errors:
1080 flash(err, "error")
1081 return redirect(url_for("shipments"))
1082
1083 db = get_db()
1084 db.execute(
1085 """INSERT INTO shipments
1086 (carrier, tracking_number, supplier, device_count,
1087 expected_arrival, logged_by, logged_at, notes)
1088 VALUES (?, ?, ?, ?, ?, ?, ?, ?)""",
1089 (
1090 carrier, tracking_number, supplier, device_count,
1091 expected_arrival, session["username"],
1092 datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
1093 notes,
1094 ),
1095 )
1096 db.commit()
1097 flash(f"Shipment from {supplier} via {carrier} logged successfully.", "success")
1098 logger.info("Shipment logged — %s %s by %s", carrier, tracking_number, session["username"])
1099 return redirect(url_for("shipments"))
1100
1101
1102 @app.route("/shipments/color=
"#569cd6"><int:shipment_id>/mark-delivered", methods=["POST"])
1103 @login_required
1104 def mark_delivered(shipment_id):
1105 db = get_db()
1106 db.execute("UPDATE shipments SET status = 'Delivered' WHERE id = ?", (shipment_id,))
1107 db.commit()
1108 flash("Shipment marked as delivered.", "success")
1109 return redirect(url_for("shipments"))
1110
1111
1112 @app.route("/shipments/color=
"#569cd6"><int:shipment_id>/mark-delayed", methods=["POST"])
1113 @login_required
1114 def mark_delayed(shipment_id):
1115 db = get_db()
1116 db.execute("UPDATE shipments SET status = 'Delayed' WHERE id = ?", (shipment_id,))
1117 db.commit()
1118 flash("Shipment marked as delayed.", "success")
1119 return redirect(url_for("shipments"))
1120
1121
1122 @app.route("/shipments/color=
"#569cd6"><int:shipment_id>/delete", methods=["POST"])
1123 @login_required
1124 def delete_shipment(shipment_id):
1125 db = get_db()
1126 db.execute("UPDATE inventory SET shipment_id = NULL WHERE shipment_id = ?", (shipment_id,))
1127 db.execute("DELETE FROM shipments WHERE id = ?", (shipment_id,))
1128 db.commit()
1129 flash("Shipment deleted. Linked devices have been unlinked.", "success")
1130 return redirect(url_for("shipments"))
1131
STEP 12 Entry Point
The if __name__ == '__main__' guard means init_db() and app.run() only execute when the file is run directly — not when imported as a
module by a production WSGI server like Gunicorn. FLASK_DEBUG is read from the environment so debug mode is never accidentally
enabled in production.
1132
1133 # ---------------------------------------------------------------------------
1134 # Entry Point
1135 # ---------------------------------------------------------------------------
PhoneVault · Complete Source Code Page 18
1136
1137 if __name__ == "__main__":
1138 init_db()
1139 app.run(debug=os.environ.get("FLASK_DEBUG", "true").lower() == "true")
