#!/bin/bash

# Create directories
sudo mkdir -p /var/www/html/gutenberg

# Create Flask app
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

# Create systemd service for Flask app
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

# Enable and start Flask app service
sudo systemctl enable flaskapp
sudo systemctl start flaskapp

echo "Initial setup complete."
