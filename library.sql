
create database Library;

use Library;

CREATE TABLE books (
    book_id INT NOT NULL AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    author_name VARCHAR(255) NOT NULL,
    publication_date DATE NOT NULL,
    publisher 	VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    PRIMARY KEY (book_id)
);

CREATE TABLE members (
    member_id INT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    membership_status VARCHAR(20) NOT NULL,
    address VARCHAR(20) NOT NULL,
    PRIMARY KEY (member_id)
);

CREATE TABLE loans (
    loan_id INT NOT NULL AUTO_INCREMENT,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    loan_date DATE NOT NULL,
    due_date DATE NOT NULL,
    days_overdue INT NOT NULL,
    date_returned DATE NOT NULL,
    PRIMARY KEY (loan_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);

CREATE TABLE genres (
    genre_id INT NOT NULL AUTO_INCREMENT,
    genre_name VARCHAR(255) NOT NULL,
    PRIMARY KEY (genre_id)
);

CREATE TABLE book_genres (
    book_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY (book_id, genre_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id)
);


INSERT INTO genres (genre_name) VALUES
('Fiction'),
('Non-fiction'),
('Mystery'),
('Science fiction'),
('History');

INSERT INTO books (title, author_name, publication_date, publisher, description) VALUES
('Pride and Prejudice', 'Jane Austen', '1813-01-28', 'Penguin Classics', 'Love and social status in 19th century England.'),
('Oliver Twist', 'Charles Dickens', '1838-01-01', 'Penguin Classics', 'Orphan boy in Victorian London.'),
('The Adventures of Tom Sawyer', 'Mark Twain', '1876-12-10', 'Harper & Brothers', 'Boyhood adventures in 19th century America.');

INSERT INTO members (first_name, last_name, email, membership_status, address) VALUES
('John', 'Doe', 'johndoe@example.com','Active', '18 Musketeerville'),
('Jane', 'Smith', 'janesmith@example.com','Inactive', '8 Wizard lane'),
('Mike', 'Johnson', 'mikejohnson@example.com', 'Active', '2 London Avenue');

INSERT INTO loans (book_id, member_id, loan_date, due_date, days_overdue, date_returned) VALUES
(1, 1, '2023-03-10', '2023-04-10', '0', '2023-04-02'),
(2, 2, '2023-03-12', '2023-04-12', '0', '2023-04-06'),
(3, 3, '2023-03-15', '2023-04-15', '0', '2023-04-10');

INSERT INTO book_genres (book_id, genre_id) VALUES
(1, 1),
(1, 3),
(2, 1),
(2, 5),
(3, 1),
(3, 4);


SELECT * FROM genres;
SELECT * FROM books;
SELECT * FROM members;
SELECT * FROM loans;
SELECT * FROM book_genres;
