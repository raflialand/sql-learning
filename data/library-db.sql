-- Library Management System Database
-- RDBMS: SQLite

-- Drop tables if exist (in reverse dependency order)
DROP TABLE IF EXISTS fines;
DROP TABLE IF EXISTS loans;
DROP TABLE IF EXISTS book_copies;
DROP TABLE IF EXISTS author_books;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS authors;
DROP TABLE IF EXISTS publishers;
DROP TABLE IF EXISTS genres;

-- Genres
CREATE TABLE genres (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT
);

-- Publishers
CREATE TABLE publishers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    address TEXT,
    website TEXT,
    phone TEXT
);

-- Authors
CREATE TABLE authors (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    bio TEXT,
    nationality TEXT
);

-- Books
CREATE TABLE books (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    subtitle TEXT,
    genre_id INTEGER REFERENCES genres(id),
    publisher_id INTEGER REFERENCES publishers(id),
    isbn TEXT UNIQUE,
    published_year INTEGER,
    pages INTEGER,
    edition TEXT
);

-- Author-Books Junction (many-to-many)
CREATE TABLE author_books (
    author_id INTEGER REFERENCES authors(id),
    book_id INTEGER REFERENCES books(id),
    PRIMARY KEY (author_id, book_id)
);

-- Book Copies (physical copies of books)
CREATE TABLE book_copies (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    book_id INTEGER REFERENCES books(id),
    barcode TEXT UNIQUE,
    condition TEXT,
    acquisition_date TEXT,
    notes TEXT
);

-- Members
CREATE TABLE members (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    address TEXT,
    membership_date TEXT NOT NULL,
    membership_type TEXT DEFAULT 'standard'
);

-- Loans
CREATE TABLE loans (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    member_id INTEGER REFERENCES members(id),
    book_copy_id INTEGER REFERENCES book_copies(id),
    loan_date TEXT NOT NULL,
    due_date TEXT NOT NULL,
    return_date TEXT,
    notes TEXT
);

-- Fines
CREATE TABLE fines (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    loan_id INTEGER REFERENCES loans(id),
    amount REAL NOT NULL,
    issued_date TEXT NOT NULL,
    paid_date TEXT,
    paid_amount REAL
);

-- ==================== SAMPLE DATA ====================

-- Genres
INSERT INTO genres (name, description) VALUES
    ('Fiction', 'Imaginary stories including novels, short stories, and poetry'),
    ('Non-Fiction', 'Factual accounts and informational books'),
    ('Science Fiction', 'Futuristic and speculative fiction'),
    ('Mystery', 'Crime and detective fiction'),
    ('Biography', 'Accounts of real persons lives');

-- Publishers
INSERT INTO publishers (name, address, website, phone) VALUES
    ('Penguin Random House', 'New York, NY', 'https://www.penguinrandomhouse.com', '212-555-0100'),
    ('HarperCollins', 'New York, NY', NULL, '212-555-0200'),
    ('Simon Schuster', 'New York, NY', 'https://www.simonandschuster.com', '212-555-0300'),
    ('Macmillan', 'London, UK', 'https://www.macmillan.com', NULL),
    ('Scholastic', 'New York, NY', 'https://www.scholastic.com', '212-555-0500');

-- Authors
INSERT INTO authors (name, email, phone, bio, nationality) VALUES
    ('George Orwell', 'orwell@example.com', NULL, 'English novelist and essayist', 'British'),
    ('Jane Austen', NULL, NULL, 'English novelist known for romantic fiction', 'British'),
    ('Isaac Asimov', 'asimov@example.com', '555-0101', 'Russian-born American writer', 'American'),
    ('Agatha Christie', 'christie@example.com', NULL, 'Queen of Crime mystery novels', 'British'),
    ('Mark Twain', NULL, '555-0102', NULL, 'American'),
    ('Stephen King', 'king@example.com', '555-0103', 'American horror fiction author', 'American'),
    ('J.K. Rowling', NULL, NULL, 'British author of Harry Potter series', 'British'),
    ('Paulo Coelho', 'coelho@example.com', '555-0104', 'Brazilian lyricist and novelist', 'Brazilian');

-- Books
INSERT INTO books (title, subtitle, genre_id, publisher_id, isbn, published_year, pages, edition) VALUES
    ('1984', 'A Novel', 3, 1, '978-0451524935', 1949, 328, '1st'),
    ('Pride and Prejudice', NULL, 1, 2, '978-0141439518', 1813, 432, 'Classic'),
    ('Foundation', 'The Empire Trilogy', 3, 3, '978-0553293357', 1951, 244, '1st'),
    ('Murder on the Orient Express', NULL, 4, 4, '978-0062693662', 1934, 256, '1st'),
    ('The Adventures of Tom Sawyer', NULL, 5, 5, '978-0486400778', 1876, 274, '1st'),
    ('The Shining', NULL, 3, 1, '978-0307743657', 1977, 447, '1st'),
    ('Harry Potter and the Sorcerers Stone', NULL, 1, 2, '978-0590353427', 1997, 309, '1st'),
    ('The Alchemist', 'A Fable About Following Your Dream', 1, 3, '978-0062315007', 1988, 208, '1st'),
    ('1984', 'Special Edition', 3, 4, '978-0451524936', 1949, 350, 'Anniversary'),
    ('Brave New World', NULL, 3, 5, '978-0060850524', 1932, 288, '1st'),
    ('The Great Gatsby', NULL, 1, 1, '978-0743273565', 1925, 180, '1st'),
    ('To Kill a Mockingbird', NULL, 1, 3, '978-0061120084', 1960, 336, '1st'),
    ('The Hobbit', 'There and Back Again', 1, 4, '978-0547928227', 1937, 310, '1st'),
    ('Fahrenheit 451', NULL, 3, 2, '978-1451673319', 1953, 249, '1st'),
    ('And Then There Were None', NULL, 4, 5, '978-0062305053', 1939, 272, '1st');

-- Author-Books (linking authors to books)
INSERT INTO author_books (author_id, book_id) VALUES
    (1, 1),   -- George Orwell -> 1984
    (2, 2),   -- Jane Austen -> Pride and Prejudice
    (3, 3),   -- Isaac Asimov -> Foundation
    (4, 4),   -- Agatha Christie -> Murder on the Orient Express
    (5, 5),   -- Mark Twain -> Tom Sawyer
    (6, 6),   -- Stephen King -> The Shining
    (7, 7),   -- J.K. Rowling -> Harry Potter
    (8, 8),   -- Paulo Coelho -> The Alchemist
    (1, 9),   -- George Orwell -> 1984 Special Edition
    (1, 10),  -- George Orwell -> Brave New World
    (1, 14),  -- George Orwell -> Fahrenheit 451
    (4, 15);  -- Agatha Christie -> And Then There Were None

-- Book Copies (multiple copies of some books)
INSERT INTO book_copies (book_id, barcode, condition, acquisition_date, notes) VALUES
    (1, 'BK001A', 'Good', '2020-01-15', NULL),
    (1, 'BK001B', 'Fair', '2020-01-15', 'Worn cover'),
    (2, 'BK002A', 'Excellent', '2019-06-20', NULL),
    (2, 'BK002B', NULL, '2021-03-10', 'Condition not assessed'),
    (3, 'BK003A', 'Good', '2020-05-01', NULL),
    (4, 'BK004A', 'Good', '2018-11-25', NULL),
    (5, 'BK005A', 'Fair', '2019-02-14', 'Pages yellowed'),
    (6, 'BK006A', 'Excellent', '2021-08-30', NULL),
    (6, 'BK006B', NULL, '2022-01-10', NULL),
    (7, 'BK007A', 'Good', '2022-06-15', NULL),
    (8, 'BK008A', 'Excellent', '2020-09-01', NULL),
    (9, 'BK009A', 'Good', '2023-01-20', 'New acquisition'),
    (10, 'BK010A', NULL, '2019-07-15', 'Needs condition check'),
    (11, 'BK011A', 'Good', '2021-04-22', NULL),
    (12, 'BK012A', 'Excellent', '2020-12-01', NULL),
    (13, 'BK013A', 'Good', '2019-10-30', NULL),
    (13, 'BK013B', 'Fair', '2020-02-15', 'Binding loose'),
    (14, 'BK014A', NULL, '2022-08-10', 'New copy'),
    (15, 'BK015A', 'Good', '2021-05-05', NULL),
    (15, 'BK015B', 'Excellent', '2022-03-20', NULL);

-- Members
INSERT INTO members (name, email, phone, address, membership_date, membership_type) VALUES
    ('Alice Johnson', 'alice@library.com', '555-1001', '123 Oak Street, New York', '2022-01-10', 'premium'),
    ('Bob Williams', NULL, '555-1002', '456 Maple Ave, Los Angeles', '2021-06-15', 'standard'),
    ('Carol Davis', 'carol@email.com', NULL, NULL, '2023-02-20', 'standard'),
    ('David Brown', 'david@library.com', '555-1003', '789 Pine Road, Chicago', '2020-11-08', 'premium'),
    ('Eve Martinez', NULL, NULL, NULL, '2023-05-01', 'standard'),
    ('Frank Garcia', 'frank@email.com', '555-1004', '321 Cedar Lane, Houston', '2021-09-12', 'standard'),
    ('Grace Wilson', NULL, '555-1005', '654 Birch Blvd, Phoenix', '2022-07-25', 'premium'),
    ('Henry Taylor', 'henry@library.com', NULL, '987 Elm Street, Philadelphia', '2020-03-30', 'standard'),
    ('Ivy Anderson', 'ivy@email.com', '555-1006', '147 Spruce Way, San Antonio', '2023-01-15', 'standard'),
    ('Jack Thomas', NULL, NULL, '258 Willow Drive, San Diego', '2022-10-05', 'standard');

-- Loans
INSERT INTO loans (member_id, book_copy_id, loan_date, due_date, return_date, notes) VALUES
    (1, 1, '2024-01-15', '2024-02-15', '2024-02-10', NULL),
    (2, 3, '2024-01-20', '2024-02-20', '2024-02-22', 'Returned late - minor fine'),
    (3, 5, '2024-02-01', '2024-03-01', '2024-02-28', NULL),
    (1, 6, '2024-02-10', '2024-03-10', NULL, 'Still borrowed'),
    (4, 7, '2024-02-15', '2024-03-15', '2024-03-20', 'Returned late - fine issued'),
    (5, 9, '2024-02-20', '2024-03-20', NULL, 'Still borrowed'),
    (2, 10, '2024-03-01', '2024-03-31', '2024-03-28', NULL),
    (6, 11, '2024-03-05', '2024-04-05', NULL, 'Still borrowed'),
    (7, 13, '2024-03-10', '2024-04-10', '2024-04-08', NULL),
    (3, 15, '2024-03-15', '2024-04-15', NULL, 'Still borrowed'),
    (8, 17, '2024-03-20', '2024-04-20', '2024-04-25', 'Returned late - fine issued'),
    (9, 19, '2024-03-25', '2024-04-25', NULL, 'Still borrowed'),
    (1, 2, '2024-04-01', '2024-05-01', '2024-04-28', NULL),
    (4, 4, '2024-04-05', '2024-05-05', NULL, 'Still borrowed'),
    (10, 8, '2024-04-10', '2024-05-10', '2024-05-12', 'Returned late - fine issued'),
    (2, 12, '2024-04-15', '2024-05-15', NULL, 'Still borrowed'),
    (5, 14, '2024-04-20', '2024-05-20', NULL, 'Still borrowed'),
    (6, 16, '2024-04-25', '2024-05-25', '2024-05-20', NULL),
    (7, 18, '2024-05-01', '2024-06-01', NULL, 'Still borrowed'),
    (8, 20, '2024-05-05', '2024-06-05', NULL, 'Still borrowed');

-- Fines
INSERT INTO fines (loan_id, amount, issued_date, paid_date, paid_amount) VALUES
    (2, 2.00, '2024-02-22', '2024-02-25', 2.00),
    (5, 5.00, '2024-03-20', NULL, NULL),
    (8, 0.00, '2024-04-05', NULL, NULL),
    (11, 5.00, '2024-04-25', '2024-04-28', 5.00),
    (15, 2.00, '2024-05-12', NULL, NULL),
    (6, 0.00, '2024-03-20', NULL, NULL),
    (10, 0.00, '2024-04-15', NULL, NULL),
    (12, 0.00, '2024-04-25', NULL, NULL);

-- ==================== QUERY EXAMPLES ====================

-- Find members without phone
-- SELECT * FROM members WHERE phone IS NULL;

-- Find members without email
-- SELECT * FROM members WHERE email IS NULL;

-- Find books not returned
-- SELECT m.name, b.title, l.loan_date, l.due_date
-- FROM loans l
-- JOIN members m ON l.member_id = m.id
-- JOIN book_copies bc ON l.book_copy_id = bc.id
-- JOIN books b ON bc.book_id = b.id
-- WHERE l.return_date IS NULL;

-- Find unpaid fines
-- SELECT m.name, b.title, f.amount, f.issued_date
-- FROM fines f
-- JOIN loans l ON f.loan_id = l.id
-- JOIN members m ON l.member_id = m.id
-- JOIN book_copies bc ON l.book_copy_id = bc.id
-- JOIN books b ON bc.book_id = b.id
-- WHERE f.paid_date IS NULL;

-- Find authors without email
-- SELECT * FROM authors WHERE email IS NULL;

-- Find publishers without website
-- SELECT * FROM publishers WHERE website IS NULL;

-- Find book copies with unknown condition
-- SELECT bc.barcode, b.title, bc.condition, bc.notes
-- FROM book_copies bc
-- JOIN books b ON bc.book_id = b.id
-- WHERE bc.condition IS NULL;

-- Find members without phone AND without email
-- SELECT * FROM members WHERE phone IS NULL AND email IS NULL;

-- Find loans that were returned late
-- SELECT m.name, b.title, l.loan_date, l.due_date, l.return_date
-- FROM loans l
-- JOIN members m ON l.member_id = m.id
-- JOIN book_copies bc ON l.book_copy_id = bc.id
-- JOIN books b ON bc.book_id = b.id
-- WHERE l.return_date > l.due_date;
