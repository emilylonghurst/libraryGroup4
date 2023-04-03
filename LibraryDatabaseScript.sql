create database Library;

use Library;

# Table Creation: book, member, loan, genre, book_genre

-- RENAME TABLE book_genres TO book_genre;


CREATE TABLE book (
    book_id INT NOT NULL AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    author_name VARCHAR(255) NOT NULL,
    publication_date DATE NOT NULL,
    publisher 	VARCHAR(255) NOT NULL,
    description VARCHAR(255) NOT NULL,
    available TINYINT(1) NOT NULL,
    PRIMARY KEY (book_id)
);

CREATE TABLE member (
    member_id INT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    membership_status VARCHAR(20) NOT NULL,
    address VARCHAR(20) NOT NULL,
    PRIMARY KEY (member_id)
);

CREATE TABLE loan (
    loan_id INT NOT NULL AUTO_INCREMENT,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    loan_date DATE NOT NULL,
    due_date DATE NOT NULL,
    days_overdue INT,
    date_returned DATE,
    PRIMARY KEY (loan_id),
    FOREIGN KEY (book_id)
        REFERENCES book (book_id)
        ON DELETE CASCADE,
    FOREIGN KEY (member_id)
        REFERENCES member (member_id)
        ON DELETE CASCADE
);

CREATE TABLE genre (
    genre_id INT NOT NULL AUTO_INCREMENT,
    genre_name VARCHAR(255) NOT NULL,
    PRIMARY KEY (genre_id)
);

CREATE TABLE book_genre (
    book_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY (book_id, genre_id),
    FOREIGN KEY (book_id) REFERENCES book(book_id),
    FOREIGN KEY (genre_id) REFERENCES genre(genre_id)
);

# Inserting filler data

INSERT INTO genre (genre_name) VALUES
('Fiction'),
('Non-fiction'),
('Mystery'),
('Science fiction'),
('History');

INSERT INTO book (title, author_name, publication_date, publisher, description, available) VALUES
('Pride and Prejudice', 'Jane Austen', '1813-01-28', 'Penguin Classics', 'Love and social status in 19th century England.', 0),
('Oliver Twist', 'Charles Dickens', '1838-01-01', 'Penguin Classics', 'Orphan boy in Victorian London.', 0),
('The Adventures of Tom Sawyer', 'Mark Twain', '1876-12-10', 'Harper & Brothers', 'Boyhood adventures in 19th century America.', 0);

INSERT INTO member (first_name, last_name, email, membership_status, address) VALUES
('John', 'Doe', 'johndoe@example.com','Active', '18 Musketeerville'),
('Jane', 'Smith', 'janesmith@example.com','Inactive', '8 Wizard lane'),
('Mike', 'Johnson', 'mikejohnson@example.com', 'Active', '2 London Avenue');

INSERT INTO member (first_name, last_name, email, membership_status, address) 
VALUES 
('James', 'Archer', 'johndoe@gmail.com', 'active', '123 Main St.'),
('Jane', 'Doe', 'janedoe@gmail.com', 'active', '456 Oak Ave.'),
('Bob', 'Smith', 'bobsmith@gmail.com', 'inactive', '789 Pine St.'),
('Mary', 'Johnson', 'maryjohnson@gmail.com', 'active', '1010 Maple Rd.');

INSERT INTO loan (book_id, member_id, loan_date, due_date, days_overdue, date_returned) VALUES
(1, 1, '2023-03-10', '2023-04-10', '0', '2023-04-02'),
(2, 2, '2023-03-12', '2023-04-12', '0', '2023-04-06'),
(3, 3, '2023-03-15', '2023-04-15', '0', '2023-04-10');

INSERT INTO loan (book_id, member_id, loan_date, due_date)
VALUES 
  (1, 4, '2023-03-19', '2023-03-26'),
  (2, 5, '2023-03-19', '2023-03-26'),
  (3, 6, '2023-03-19', '2023-03-26');

INSERT INTO book_genre (book_id, genre_id) VALUES
(1, 1),
(1, 3),
(2, 1),
(2, 5),
(3, 1),
(3, 4);

# Testing all tables

SELECT * FROM genre;
SELECT * FROM book;
SELECT * FROM member;
SELECT * FROM loan;
SELECT * FROM book_genre;

##################### Member Procedures ####################################

# get_books_by_genre (4): As a library member, I want to be able to search books by genre.

DELIMITER //
CREATE PROCEDURE get_books_by_genre(IN search_genre VARCHAR(255))
BEGIN
  SELECT book.title, book.author_name, book.publication_date, book.publisher, book.description, book.available, genre.genre_name
  FROM book
  INNER JOIN book_genre ON book_genre.book_id = book.book_id
  INNER JOIN genre ON book_genre.genre_id = genre.genre_id
  WHERE genre.genre_name = search_genre
  ORDER BY book.title;
END //
DELIMITER ;

# get_member_loans (5): As a librarian, I want to be able to see what books a member has on loan.

DELIMITER //
CREATE PROCEDURE get_member_loans(IN search_name VARCHAR(255))
BEGIN
  SELECT member.first_name, member.last_name, loan.loan_id, loan.loan_date, loan.due_date, loan.days_overdue, loan.date_returned, book.title
  FROM member
  JOIN loan ON member.member_id = loan.member_id
  JOIN book ON loan.book_id = book.book_id
  WHERE member.last_name LIKE CONCAT(search_name, '%');
END//
DELIMITER ;

#################### Librarian Procedures ##################################

# check_in_book (13a): As a librarian, I want to be able to check in books.

DELIMITER //
CREATE PROCEDURE check_in_book(IN p_book_id INT, IN p_member_id INT, IN p_return_date DATE)
BEGIN
  DECLARE loan_count INT;

  SELECT COUNT(*) INTO loan_count
  FROM loan
  WHERE book_id = p_book_id AND member_id = p_member_id AND date_returned IS NULL;

  IF loan_count = 1 THEN
    UPDATE loan
    SET date_returned = p_return_date,
        days_overdue = CASE
                          WHEN p_return_date > due_date THEN DATEDIFF(p_return_date, due_date)
                          ELSE 0
                       END

    WHERE book_id = p_book_id AND member_id = p_member_id AND date_returned IS NULL;

    SELECT loan_date, due_date,
           CASE
              WHEN p_return_date > due_date THEN DATEDIFF(p_return_date, due_date)
              ELSE 0
           END AS days_overdue, p_return_date

    FROM loan
    WHERE book_id = p_book_id AND member_id = p_member_id AND date_returned = p_return_date;

  ELSE
    SELECT 'Error: Book is not currently checked out by the specified member' AS message;

  END IF;
END //
DELIMITER ;

# check_out_book (13b): As a librarian I want to be able to check out books.

DELIMITER //
CREATE PROCEDURE check_out_book(IN p_book_id INT, IN p_member_id INT, OUT p_loan_id INT)
BEGIN
    DECLARE v_due_date DATE;
    DECLARE v_loan_id INT;
    SET v_due_date = DATE_ADD(NOW(), INTERVAL 1 MONTH);
    INSERT INTO loan (book_id, member_id, loan_date, due_date)
    VALUES (p_book_id, p_member_id, NOW(), v_due_date);
    SET v_loan_id = LAST_INSERT_ID();
    SET p_loan_id = v_loan_id;
END //

DELIMITER ;

# get_member_details (15): As a librarian, I want to be able to search members by last name.

DELIMITER //
CREATE PROCEDURE get_member_details(IN search_name VARCHAR(255))
BEGIN
 SELECT * FROM member WHERE last_name LIKE CONCAT(search_name, '%');
END //
DELIMITER ;

############### Creating Users ##################################################

# Creating User: library_member

SHOW GRANTS FOR 'library_member'@'localhost';

create user'library_member'@'localhost' identified by 'librarypassword';

GRANT SELECT ON library.book to 'library_member'@'localhost';
GRANT SELECT ON library.loan to 'library_member'@'localhost';
GRANT SELECT ON library.book_genre to 'library_member'@'localhost';

GRANT EXECUTE ON PROCEDURE library.get_books_by_genre TO 'library_member'@'localhost';

##################################################################################

# Creating User: librarian

SHOW GRANTS FOR 'librarian'@'localhost';

create user'librarian'@'localhost' identified by 'librarianpassword';

grant select, update, delete, execute on library.book to 'librarian'@'localhost';


# Grant select for each table

GRANT SELECT ON library.book TO 'librarian'@'localhost';
GRANT SELECT ON library.member TO 'librarian'@'localhost';
GRANT SELECT ON library.loan TO 'librarian'@'localhost';
GRANT SELECT ON library.genre TO 'librarian'@'localhost';
GRANT SELECT ON library.book_genre TO 'librarian'@'localhost';

# Grant insert for each table

GRANT INSERT ON library.book TO 'librarian'@'localhost';
GRANT INSERT ON library.member TO 'librarian'@'localhost';
GRANT INSERT ON library.loan TO 'librarian'@'localhost';
GRANT INSERT ON library.genre TO 'librarian'@'localhost';
GRANT INSERT ON library.book_genre TO 'librarian'@'localhost';

# Grant update for each table

GRANT UPDATE ON library.book TO 'librarian'@'localhost';
GRANT UPDATE ON library.member TO 'librarian'@'localhost';
GRANT UPDATE ON library.loan TO 'librarian'@'localhost';
GRANT UPDATE ON library.genre TO 'librarian'@'localhost';
GRANT UPDATE ON library.book_genre TO 'librarian'@'localhost';

# Grant delete for each table

GRANT DELETE ON library.book TO 'librarian'@'localhost';
GRANT DELETE ON library.member TO 'librarian'@'localhost';
GRANT DELETE ON library.loan TO 'librarian'@'localhost';
GRANT DELETE ON library.genre TO 'librarian'@'localhost';
GRANT DELETE ON library.book_genre TO 'librarian'@'localhost';

# Grant procedure permissions

GRANT EXECUTE ON PROCEDURE get_member_loans TO 'librarian'@'localhost';
GRANT EXECUTE ON PROCEDURE get_member_details TO 'librarian'@'localhost';
GRANT EXECUTE ON PROCEDURE check_in_book TO 'librarian'@'localhost';
GRANT EXECUTE ON PROCEDURE check_out_book TO 'librarian'@'localhost';

