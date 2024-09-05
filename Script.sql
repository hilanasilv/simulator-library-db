/*Cria o banco de dados*/
CREATE DATABASE lib_telos

/*Altera o contexto do banco de dados para lib_telos*/
USE lib_telos

/*Criação das tabelas Books, Users e Loans*/
CREATE TABLE Books(	
	book_id INT PRIMARY KEY IDENTITY(1,1),
	title VARCHAR(255) NOT NULL,
	author VARCHAR(255) NOT NULL,
	genre VARCHAR(255),
	published_year INT
);

CREATE TABLE Users(
	user_id INT PRIMARY KEY IDENTITY(1,1),
	name VARCHAR(100) NOT NULL,
	email VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Loans(
	loan_id INT PRIMARY KEY IDENTITY(1,1),
	book_id INT FOREIGN KEY REFERENCES Books(book_id),
	user_id INT FOREIGN KEY REFERENCES Users(user_id),
	loan_date DATE NOT NULL,
	return_date DATE
);

/*Altera o tamanho do campo VARCHAR para author e genre*/
ALTER TABLE Books
ALTER COLUMN author VARCHAR(100);

ALTER TABLE Books 
ALTER COLUMN genre VARCHAR(100);

/*Gerenciamento de livros*/

/*Adiciona livros ao catálogo*/
INSERT INTO Books (title, author, genre, published_year)
VALUES ('Entendendo algoritmos - Um Guia Ilustrado Para Programadores e Outros Curiosos', 'Aditya Y. Bhargava', 'Programação', '2017'),
('Introdução à Linguagem SQL: Abordagem Prática Para Iniciantes', 'Thomas Nield', 'Banco de dados', '2016'),
('Aprendendo Git: Um guia prático e visual para os fundamentos do Git', 'Anna Skoulikari', 'Programação', '2024'),
('Mulheres Livres - a luta pela emancipação feminina e a Guerra Civil Espanhola', 'Martha A. Ackelsberg', 'Ciência Política', '2019'),
('Torto Arado', 'Itamar Vieira Junior', 'Ficção', '2019'),
('O Manual Antifascista', 'Mark Bray', 'Ciência Política', '2019'),
('Potências do Tempo', 'David Lapoujade', 'Filosofia', '2013');

/*Atualiza informações de livro*/
UPDATE Books
SET genre = 'Romance'
WHERE book_id = 5;

/*Deleta livro*/
DELETE FROM Books
WHERE title = 'O Manual Antifascista';

/*Busca livros no catálogo por gênero e por data de publicação*/
SELECT * FROM Books
WHERE genre = 'Ciência Política';

SELECT * FROM Books
WHERE published_year BETWEEN 2013 AND 2017;

/*Gerenciamento de usuários*/
/*Adiciona usuários*/
INSERT INTO Users (name, email)
VALUES ('Ana Santos', 'anast@email.com'),
('Icaro Vieira', 'icaro_vieira@email.com'),
('Luana Martins', 'luanam@email.com'),
('Juliane Silva', 'ju@email.com'),
('Pedro Soares', 'pedro_soares@email.com');

/*Atualiza informação de usuário*/
UPDATE Users
SET name = 'Ana Souza'
WHERE user_id = 1;

/*Deleta um usuário através do id*/
DELETE FROM Users
WHERE user_id = 3;

/*Busca usuários e exibe id e nome*/
SELECT user_id, name
FROM Users;

/*Empréstimos de livros*/
/*Registra empréstimos*/
INSERT INTO Loans (book_id, user_id, loan_date)
VALUES (1, 2, GETDATE()), (3, 2, GETDATE());

INSERT INTO Loans (book_id, user_id, loan_date)
VALUES (7, 4, GETDATE());

/*Registra devolução de livro*/
UPDATE Loans 
SET return_date = GETDATE()
WHERE loan_id = 1;

/*Verifica a disponibilidade de livros*/
SELECT CASE WHEN EXISTS(
	SELECT 1 FROM Loans
	WHERE book_id = 1 AND return_date IS NULL
) THEN 'Unavailable' ELSE 'Available' END AS Availabitity;

/*Registra empréstimos*/
INSERT INTO Loans (book_id, user_id, loan_date)
VALUES (5, 4, GETDATE());

/*Gera relatório de livros emprestados (on loan) e devolvidos (return_date)*/
SELECT 
    Books.title,
    Users.name,
    Loans.loan_date,
    CASE 
        WHEN Loans.return_date IS NULL THEN 'On Loan'
        ELSE CONVERT(VARCHAR, Loans.return_date, 103)
    END AS Status
FROM 
    Loans
JOIN 
    Books ON Loans.book_id = Books.book_id
JOIN 
    Users ON Loans.user_id = Users.user_id;

/*Gera relatório dos livros atualmente emprestados (loan_date)*/
SELECT Books.title, Users.name, Loans.loan_date 
FROM Loans
JOIN Books ON Loans.book_id = Books.book_id
JOIN Users ON Loans.user_id = Users.user_id 
WHERE Loans.return_date IS NULL;

/*Registra empréstimos*/
INSERT INTO Loans (book_id, user_id, loan_date)
VALUES (4, 4, GETDATE());

/*Gera relatório de usuários com mais empréstimos em ordem decrescente*/
SELECT Users.name, COUNT(*) AS total_loans
FROM Loans
JOIN Users ON Loans.user_id = Users.user_id
GROUP BY Users.name
ORDER BY total_loans DESC;

/*Subquery para encontrar usuários com mais de 2 empréstimos*/
SELECT Users.name 
FROM Users
WHERE (SELECT COUNT (*) FROM Loans WHERE Loans.user_id = Users.user_id) > 2;

/*Seleciona os usuários e o total de empréstimos, exibe em ordem crescente e a LEFT JOIN inclui usuários que não tem empréstimos registrados*/
SELECT 
	u.name,
	COUNT(l.loan_id) AS TotalLoans
FROM 
	Users u
LEFT JOIN
	Loans l ON u.user_id = l.user_id 
GROUP BY
	u.name
ORDER BY
	TotalLoans ASC;