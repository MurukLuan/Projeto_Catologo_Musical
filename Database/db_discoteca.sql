
-- Para detalhes recomendamos que leia rapiadamente nosso arquivo README.
-- Bons estudos! 

-- --------------------------------------Criando a database ----------------------------------------------------

CREATE DATABASE IF NOT EXISTS db_discoteca
CHARACTER SET utf8mb4
COLLATE utf8mb4_general_ci;


-- ----------------------------------------- Criando tabelas ----------------------------------------------------

USE db_discoteca;

CREATE TABLE IF NOT EXISTS gravadora (
    id_gravadora INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome  		 VARCHAR(20) NOT NULL,
CONSTRAINT PK_id_gravadora PRIMARY KEY (id_gravadora)
) AUTO_INCREMENT = 1 CHARSET utf8mb4;

CREATE TABLE IF NOT EXISTS artista (
    id_artista INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome VARCHAR(50) NOT NULL,
    dt_nascimento DATE,
CONSTRAINT PK_id_artista PRIMARY KEY (id_artista)
) AUTO_INCREMENT = 1 CHARSET utf8mb4;

CREATE TABLE IF NOT EXISTS genero (
    id_genero INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome VARCHAR(20),
	CONSTRAINT PK_id_genero PRIMARY KEY (id_genero)
) AUTO_INCREMENT = 1 CHARSET utf8mb4;

INSERT INTO gravadora  VALUES ('1','Independente');
INSERT INTO artista  (id_artista, nome)  VALUES ('1','Desconhecido');
INSERT INTO genero	   VALUES ('1','Outros');

CREATE TABLE IF NOT EXISTS disco (
		id_disco	INT UNSIGNED NOT NULL AUTO_INCREMENT,
    titulo_disco 	VARCHAR(50)  NOT NULL,
     tempo_disco 	FLOAT UNSIGNED NOT NULL DEFAULT '0',
  ano_lancamento 	YEAR NOT NULL,
      id_artista	INT UNSIGNED NOT NULL DEFAULT '1',
    id_gravadora 	INT UNSIGNED NOT NULL DEFAULT '1',
       id_genero   	INT UNSIGNED NOT NULL DEFAULT '1',
CONSTRAINT PK_id_disco 	     PRIMARY KEY (id_disco),
CONSTRAINT FK_id_artista     FOREIGN KEY (id_artista)   REFERENCES artista (id_artista),
CONSTRAINT FK_id_gravadora   FOREIGN KEY (id_gravadora) REFERENCES gravadora (id_gravadora),
CONSTRAINT FK_id_genero 	 FOREIGN KEY (id_genero)    REFERENCES genero (id_genero)
) AUTO_INCREMENT = 1 CHARSET utf8mb4;

CREATE TABLE IF NOT EXISTS musica (
    id_musica 		INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome 			VARCHAR(50) NOT NULL,
    tempo_musica 	FLOAT UNSIGNED,
    id_disco 		INT UNSIGNED NOT NULL,
CONSTRAINT CK_tempo_musica CHECK (tempo_musica >=0 AND tempo_musica <=20), -- valida o tempo de cada musica entre 0 a 20 minutos
CONSTRAINT PK_id_musica PRIMARY KEY (id_musica),
CONSTRAINT FK_id_disco  FOREIGN KEY (id_disco) REFERENCES disco (id_disco) ON DELETE CASCADE
) AUTO_INCREMENT = 1 CHARSET utf8mb4;


--  --------------------------------- Criando triggers para automatizar certos campos e rotinas -------------------------------------

DELIMITER //
CREATE TRIGGER TR_tempo_disco_insert
AFTER INSERT
ON musica
FOR EACh ROW
	BEGIN
		DECLARE total_musica FLOAT;
        SET total_musica = (SELECT SUM(tempo_musica) FROM musica WHERE id_disco = NEW.id_disco);
		UPDATE disco SET tempo_disco = total_musica WHERE id_disco = NEW.id_disco;
    END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER TR_tempo_disco_update
AFTER UPDATE
ON musica
FOR EACh ROW
	BEGIN
		DECLARE total_musica FLOAT;
        SET total_musica = (SELECT SUM(tempo_musica) FROM musica WHERE id_disco = NEW.id_disco);
		UPDATE disco SET tempo_disco = total_musica WHERE id_disco = NEW.id_disco;
    END //
DELIMITER ;




-- ------------------------------ Criando views para proteger a integridade de nossas tabelas ----------------------------------------------

CREATE VIEW VW_gravadoras AS
SELECT  g.id_gravadora 'Codigo da gravadora',
		g.nome Gravadora, 
		COUNT(g.id_gravadora) 'Total de discos'
FROM gravadora g
LEFT JOIN disco d 
	ON d.id_gravadora = g.id_gravadora
GROUP BY g.id_gravadora;
;

CREATE VIEW VW_artistas AS
SELECT  
	a.id_artista 'Codigo do artista',
    a.nome Artista,
	CASE 
		WHEN a.dt_nascimento IS NULL THEN "Não cadastrado"
	  ELSE  (SELECT TIMESTAMPDIFF(YEAR,a.dt_nascimento,CURDATE()))
	END "idade",
	COUNT(a.id_artista) 'Total de discos'
FROM artista a
LEFT JOIN disco d 
	ON d.id_artista = a.id_artista
GROUP BY a.id_artista;

CREATE VIEW VW_discos AS
SELECT  d.id_disco 'Codigo do disco',
		d.titulo_disco 'Titulo do Disco', 
		d.tempo_disco 'Tempo do disco',
        d.ano_lancamento 'Ano de lançamento',
        a.nome artista,
        ge.nome genero ,
        g.nome gravadora
FROM disco d 
JOIN gravadora g
	ON d.id_gravadora = g.id_gravadora
JOIN artista a
	ON d.id_artista = a.id_artista
JOIN genero ge
	ON d.id_genero = ge.id_genero;

CREATE VIEW VW_musicas AS
SELECT m.nome 'Música', 
		m.tempo_musica 'Duração',
        d.titulo_disco Disco,
        a.nome Artista
FROM musica m
JOIN disco d
	ON d.id_disco = m.id_disco
JOIN artista a
	ON a.id_artista = d.id_artista;


-- ------------------------------ Criando funções -----------------------------------------------

DELIMITER //
CREATE FUNCTION FN_maiuscula (texto VARCHAR(255))
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE tamanho INT;
    DECLARE contador INT;

    SET tamanho   = CHAR_LENGTH(texto);
    SET texto = LOWER(texto); -- Opcional mas pode ser util quando quiser formatar textos
    SET contador = 0;

    WHILE (contador < tamanho) DO
        IF (MID(texto,contador,1) = ' ' OR contador = 0) THEN
            IF (contador < tamanho) THEN
                SET texto = CONCAT(
                    LEFT(texto,contador),
						UPPER(MID(texto,contador + 1,1)),
                    RIGHT(texto,tamanho - contador - 1)
                );
            END IF;
        END IF;
        SET contador = contador + 1;
    END WHILE;

    RETURN texto;
END //
DELIMITER ;


-- ------------------------------------------Criando Procedures -----------------------------

DELIMITER \\
CREATE PROCEDURE SP_insert_gravadora (g_nome VARCHAR(20))
BEGIN
	INSERT INTO gravadora (nome) VALUES (FN_maiuscula(g_nome));
END \\
DELIMITER ;



DELIMITER \\
CREATE PROCEDURE SP_insert_genero (ge_nome VARCHAR(20))
BEGIN
	INSERT INTO genero (nome) VALUES (FN_maiuscula(ge_nome));
END \\
DELIMITER ;



DELIMITER \\
CREATE PROCEDURE SP_insert_artista (a_nome VARCHAR(50), nascimento DATE)
BEGIN
	DECLARE valida_data DATE;
	SET valida_data = (SELECT CURDATE());
    
		IF NOT (nascimento <= valida_data)
			THEN
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Data inválida';
            ELSE 
				INSERT INTO artista (nome, dt_nascimento) VALUES (FN_maiuscula(a_nome), nascimento);
        END IF;
END \\
DELIMITER ;


DELIMITER \\
CREATE PROCEDURE SP_insert_disco (d_titulo VARCHAR(50), ano YEAR, cod_artista INT , cod_gravadora INT, cod_genero INT, OUT cod_disco INT)
BEGIN
	DECLARE valida_ano YEAR; 
	DECLARE valida_artista INT;
    DECLARE valida_gravadora INT; 
    DECLARE valida_genero INT;
        
	SET valida_ano = (SELECT YEAR(CURDATE()));
    SET valida_artista = (SELECT MAX(id_artista) FROM artista);
    SET valida_gravadora = (SELECT MAX(id_gravadora) FROM gravadora);
    SET valida_genero = (SELECT MAX(id_genero) FROM genero);


	IF NOT(ano <= valida_ano) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ano inválido';
          
     ELSEIF (ano <= valida_ano) THEN     
				IF cod_artista > valida_artista THEN 
					SET cod_artista = '1';
				END IF;

                IF cod_gravadora > valida_gravadora THEN 
					SET cod_gravadora = '1';
				END IF;
						
                IF cod_genero > valida_genero THEN 
					SET cod_genero = '1';
				END IF;
                
		INSERT INTO disco (titulo_disco, ano_lancamento, id_artista, id_gravadora,id_genero) VALUES (FN_maiuscula(d_titulo), ano, cod_artista, cod_gravadora, cod_genero);

	ELSE 

		INSERT INTO disco (titulo_disco, ano_lancamento, id_artista, id_gravadora,id_genero) VALUES (FN_maiuscula(d_titulo), ano, cod_artista, cod_gravadora, cod_genero);

	END IF;
 SET cod_disco = (SELECT MAX(id_disco) FROM disco);   
END \\
DELIMITER ;


DELIMITER \\
CREATE PROCEDURE SP_insert_musica (titulo VARCHAR(50),duracao FLOAT, cod_disco INT)
BEGIN
	DECLARE valida_disco INT;
    SET valida_disco = (SELECT MAX(id_disco) FROM disco);
    
    IF cod_disco > valida_disco OR cod_disco < '0' THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Disco inválido';
	ELSE
		IF duracao < 0 THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Duração de música invalida';
		ELSE
			INSERT INTO musica (nome, tempo_musica, id_disco) VALUES (FN_maiuscula(titulo), duracao, cod_disco);
		END IF;
    END IF;
END\\
DELIMITER ;
