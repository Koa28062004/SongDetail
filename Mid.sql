-- meow meow
create DATABASE meow
create table Films(
    film_id int not null PRIMARY KEY,
    film_title nvarchar(100) not null,
    film_year int not null,
    film_language nvarchar(20) not null,
    producer_id int not null
)

INSERT INTO Films (film_id, film_title, film_year, film_language, producer_id) VALUES 
(11, N'War 2', 2017, N'ENGLISH', 201),
(12, N'Doctor Strange in the Multiverse of Madness', 2022, N'ENGLISH', 204),
(13, N'Shamshera', 2022, N'HINDI', 203),
(14, N'The Takedown', 2022, N'FRENCH', 202),
(15, N'The French Dispatch', 2021, N'FRENCH', 200),
(16, N'Eiffel', 2021, N'FRENCH', 202),
(17, N'Moments', 2015, N'HINDI', 203),
(18, N'The May', 2019, N'ENGLISH', 201),
(19, N'Venom', 2018, N'ENGLISH', 205),
(20, N'Iron Man 3', 2013, N'ENGLISH', 204);

create table Review(
    review_id int not null PRIMARY KEY IDENTITY(1,1),
    film_id int not null,
    stars int not null check(stars between 1 and 5)
)

SET IDENTITY_INSERT Review ON;

INSERT INTO Review(review_id, film_id, stars) VALUES
(1, 11, 4),
(2, 12, 4),
(3, 13, 5),
(4, 14, 4),
(5, 14, 3),
(6, 15, 2),
(7, 16, 2),
(8, 17, 1),
(9, 17, 4),
(10, 20, 3)

SET IDENTITY_INSERT Review OFF;

create table Producer(
    producer_id int not null PRIMARY KEY,
    producer_name nvarchar(50) not null,
    producer_phone varchar(10) not null check(producer_phone like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
)

INSERT into Producer(producer_id, producer_name, producer_phone) VALUES
(200, N'Wes Anderson', '6735635863'),
(201, N'Faran', '8664297433'),
(202, N'Yash', '8765421167'),
(203, N'Niraj', '7454321986'),
(204, N'Kevin Feige', '8778612978'),
(205, N'Avi Arad', '8987123546')

create TABLE Artist(
    artist_id int not null PRIMARY KEY,
    artist_name nvarchar(50) not null,
    artist_gender char not null check (artist_gender in ('F', 'M'))
)

INSERT INTO Artist(artist_id, artist_name, artist_gender) VALUES
(101, N'Amit', 'M'),
(102, N'Pritam', 'M'),
(103, N'Sreya', 'F'),
(104, N'Sujata', 'F'),
(105, N'Tom Hardy', 'M'),
(106, N'Robert Downey', 'M'),
(107, N'Benedict', 'M'),
(108, N'Bill Murray', 'M')

create table Casting(
    actist_id int not null,
    film_id int not null,
    part nvarchar(20) not null,
    PRIMARY KEY(actist_id, film_id)
)

INSERT INTO Casting(actist_id, film_id, part) VALUES
(101, 17, N'Actor'),
(102, 11, N'Actor'),
(103, 18, N'Actress'),
(103, 17, N'Guest'),
(104, 14, N'Actress'),
(105, 19, N'Actor'),
(106, 20, N'Actor'),
(107, 12, N'Actor'),
(108, 15, N'Actor')

ALTER TABLE Films
ADD CONSTRAINT fk_films_producers
FOREIGN KEY(producer_id) REFERENCES Producer(producer_id)

ALTER TABLE Review
ADD CONSTRAINT fk_review_films
FOREIGN KEY(film_id) REFERENCES Films(film_id)

ALTER TABLE Casting
ADD CONSTRAINT fk_casting_films
FOREIGN KEY(film_id) REFERENCES Films(film_id)

ALTER TABLE Casting
ADD CONSTRAINT fk_casting_artist
FOREIGN KEY(actist_id) REFERENCES Artist(artist_id)

-- Q4
-- a)
SELECT f.film_title
FROM Films f 
JOIN Producer p on f.producer_id = p.producer_id
WHERE p.producer_name = 'Kevin Feige'

-- b)
SELECT a.*
FROM Artist a
WHERE a.artist_id not in (
    select a1.artist_id
    FROM Films f 
    JOIN Casting c on f.film_id = c.film_id
    JOIN Artist a1 on c.actist_id = a1.artist_id
    WHERE f.film_year = 2021 and f.film_year = 2022
)

-- c) 
SELECT f.film_title, r.stars
FROM Films f 
JOIN Review r on f.film_id = r.film_id
WHERE r.stars >= ALL(
    SELECT r1.stars
    FROM Films f1
    JOIN Review r1 on f1.film_id = r1.film_id
    WHERE r.film_id = r1.film_id
)
ORDER BY r.stars DESC

-- d)
UPDATE Review
SET stars = 5
WHERE film_id in (
    SELECT f1.film_id
    FROM Review r1
    JOIN Films f1 on r1.film_id = f1.film_id
    JOIN Producer p1 on f1.producer_id = p1.producer_id
    WHERE p1.producer_name = 'Yash'
)

-- e)
SELECT a.artist_name
FROM Artist a 
JOIN Casting c on a.artist_id = c.actist_id
JOIN Films f on f.film_id = c.film_id
JOIN Review r on f.film_id = r.film_id
WHERE c.part = 'Actor' AND f.film_year = 2022 AND r.stars = 4 
GROUP BY a.artist_name, r.film_id
HAVING COUNT(r.stars) >= 1

-- e)
SELECT distinct f.*
FROM Films f 
JOIN Review r on r.film_id = f.film_id
WHERE f.film_language = 'French' AND 
r.stars <= ALL(
    SELECT r1.stars
    FROM Review r1
    WHERE r1.film_id = r.film_id
)

DELETE FROM Review
WHERE review_id = 3

DROP DATABASE meow