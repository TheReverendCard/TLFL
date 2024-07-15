#!/bin/bash

# Install required packages
sudo apt-get update && sudo apt-get install -y sqlite3 rsync

# Create directories
mkdir -p /mnt/library/gutenberg

# Create SQLite database
sqlite3 /mnt/library/library_books.db <<EOF
CREATE TABLE books (
    id INTEGER PRIMARY KEY,
    title TEXT,
    author TEXT,
    download_link TEXT,
    popularity INTEGER
);
EOF

# Rsync from Project Gutenberg
rsync -av --delete --max-size=10m --exclude="*/tmp" rsync://mirrors.xmission.com/gutenberg/ /mnt/library/gutenberg

echo "Library setup complete."
