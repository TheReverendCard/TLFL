#!/bin/bash

# Create directories
sudo mkdir -p /var/www/html/gutenberg/templates

# Create HTML template
sudo bash -c 'cat << EOF > /var/www/html/gutenberg/templates/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Library Hotspot</title>
</head>
<body>
    <h1>Welcome to the Library Hotspot</h1>
    <h2>Top 10 Books</h2>
    <ul>
        {% for book in books %}
        <li>{{ book[1] }} by {{ book[2] }}</li>
        {% endfor %}
    </ul>
</body>
</html>
EOF'

# Remaining steps for Flask app and systemd service
sudo apt-get install -y python3-flask

cat << EOF > /home/pi/app.py
from flask import Flask, render_template
import sqlite3

app = Flask(__name__)

@app.route('/')
def index():
    conn = sqlite3.connect('/mnt/library/library_books.db')
    c = conn.cursor()
    c.execute("SELECT * FROM books LIMIT 10")
    books = c.fetchall()
    conn.close()
    return render_template('index.html', books=books)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
EOF

sudo bash -c 'cat << EOF > /etc/systemd/system/flaskapp.service
[Unit]
Description=Flask App
After=network.target

[Service]
User=pi
WorkingDirectory=/home/pi
ExecStart=/usr/bin/python3 /home/pi/app.py

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl enable flaskapp
sudo systemctl start flaskapp

echo "Initial setup complete."
