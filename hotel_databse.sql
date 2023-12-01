--PROJEKT IDS(2021/2022)
--NAME: Ján Šprlák
--LOGINS: xsprla01
--ZADANIE: hotel
---------------------------------------------TABLES----------------------------------------------
/*Vztah generalizacia-specializacia je spraveny tak, ze bezny host ako nadtyp ma iba povinne neprazdne
udaje a ako podtyp - admin musi mat nastavene dalsie atributy.*/

/*Doplnili sme dalšie foreign keys podľa požiadavky z hodnotenia druhej časti projektu */

--------------------------------------------DROPS------------------------------------------------
DROP SEQUENCE "osoba";
DROP SEQUENCE "rezervacia";
DROP SEQUENCE "personal";
DROP SEQUENCE "sluzby";
DROP TABLE Sluzby;
DROP TABLE Personal;
DROP TABLE Osoba_entity;
DROP TABLE Rezervacia;
DROP TABLE Izba;
--DROP MATERIALIZED VIEW nezaplatene_rezervacie;

CREATE TABLE Izba (
    cislo_izby INTEGER NOT NULL CHECK(cislo_izby BETWEEN 0 AND 100) primary key,
    pocet_miest INTEGER NOT NULL CHECK(pocet_miest BETWEEN 0 AND 5),
    typ_izby VARCHAR(35) NOT NULL,
    obsadenost VARCHAR(20) NOT NULL,
    pripravenost VARCHAR(20) NOT NULL,

    CONSTRAINT CHK_typ_izby CHECK(typ_izby IN('štandart', 'promo izba', 'promo izba s výhľadom na more', 'prezidentský apartmán')),
    CONSTRAINT CHK_obsadenost CHECK(obsadenost IN('obsadená', 'neobsadená')),
    CONSTRAINT CHK_pripravenost CHECK(pripravenost IN('pripravená', 'nepripravená'))

);

CREATE TABLE Rezervacia (
    id_rezervacie INT DEFAULT NULL PRIMARY KEY,
    datum_vytvorenia TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    prichod TIMESTAMP NOT NULL,
    odchod TIMESTAMP NOT NULL,
    pocet_dospelych INT DEFAULT(1) NOT NULL,
    pocet_deti INT DEFAULT(0) NOT NULL,
    typ_stravy VARCHAR(20) NOT NULL,
    typ_rezervacie VARCHAR(15) NOT NULL,
    sposob_platby VARCHAR(25) NOT NULL,
    zvlastne_poziadavky VARCHAR(200),
    stav VARCHAR(15),
    izba INT,

    CONSTRAINT CHK_typ_stravy CHECK(typ_stravy IN('veganská', 'bezlepková', 'klasická', 'bez stravy')),
    CONSTRAINT CHK_typ_rezervacie CHECK(typ_rezervacie IN('all inclusive', 'plná penzia', 'polopenzia', 'večera', 'raňajky', 'bez stravy')),
    CONSTRAINT CHK_sposob_platby CHECK(sposob_platby IN('hotovosť', 'karta', 'paypal', 'prevod na účet')),
    CONSTRAINT CHK_stav CHECK(stav IN('zaplatená', 'nezaplatená', 'stornovaná')),

    FOREIGN KEY(izba) REFERENCES Izba (cislo_izby)
);

CREATE TABLE Osoba_entity (
    id_osoby INT DEFAULT NULL PRIMARY KEY,
    meno VARCHAR(20) NOT NULL,
    priezvisko VARCHAR(20) NOT NULL,
    datum_narodenia DATE NOT NULL,
    telefonne_cislo VARCHAR(15) NOT NULL,
    email VARCHAR(50) NOT NULL,
    adresa VARCHAR(50) NOT NULL,
    mesto VARCHAR(20) NOT NULL,
    psc INT NOT NULL,
    miesto_vydania_cestovneho_dokladu VARCHAR(50) NOT NULL,
    admin_cislo INT,
    admin_prava INT,
    id_rezervacie INT,

    CONSTRAINT CHK_admin CHECK(admin_prava IN('0852', '7780')),

    FOREIGN KEY(id_rezervacie) REFERENCES Rezervacia (id_rezervacie)
);
CREATE TABLE Personal (
    id_personalu INT DEFAULT NULL PRIMARY KEY,
    meno VARCHAR(20) NOT NULL,
    priezvisko VARCHAR(20) NOT NULL,
    datum_narodenia DATE  NOT NULL,
    telefonne_cislo VARCHAR(15) NOT NULL,
    email VARCHAR(50) NOT NULL,
    adresa VARCHAR(50) NOT NULL,
    mesto VARCHAR(20) NOT NULL,
    psc INT NOT NULL,
    obcianstvo VARCHAR(50) NOT NULL,
    zameranie VARCHAR(50) NOT NULL,
    dostupnost VARCHAR(20) NOT NULL,

    CONSTRAINT CHK_dostupnost CHECK(dostupnost IN('dostupný', 'nedostupný'))

);

CREATE TABLE Sluzby (
    id_sluzby INT DEFAULT NULL PRIMARY KEY,
    typ_sluzby VARCHAR(30) NOT NULL,
    id_osoby INT,
    id_personalu INT,

    CONSTRAINT CHK_typ_sluzby CHECK(typ_sluzby IN('wellness', 'oprava závady', 'upratovacia služby', 'detský kútik')),

    FOREIGN KEY(id_osoby) REFERENCES Osoba_entity (id_osoby),
    FOREIGN KEY(id_personalu) REFERENCES Personal (id_personalu)
);

-------------------------------------------TRIGGERS----------------------------------------------
-- 1. Trigger pre automaticky generované kľúče v tabuľke Rezervacia
CREATE SEQUENCE "rezervacia";
CREATE OR REPLACE TRIGGER rezervacia
	BEFORE INSERT ON Rezervacia
	FOR EACH ROW
BEGIN
	IF :NEW.id_rezervacie IS NULL THEN
		:NEW.id_rezervacie := "rezervacia".NEXTVAL;
	END IF;
END;

-- 2. Trigger pre automaticky generované kľúče v tabuľke Osoba_entity
CREATE SEQUENCE "osoba";
CREATE OR REPLACE TRIGGER osoba
	BEFORE INSERT ON Osoba_entity
	FOR EACH ROW
BEGIN
	IF :NEW.id_osoby IS NULL THEN
		:NEW.id_osoby := "osoba".NEXTVAL;
	END IF;
END;

-- 3. Trigger pre automaticky generované kľúče v tabuľke Personal
CREATE SEQUENCE "personal";
CREATE OR REPLACE TRIGGER personal
	BEFORE INSERT ON Personal
	FOR EACH ROW
BEGIN
	IF :NEW.id_personalu IS NULL THEN
		:NEW.id_personalu := "personal".NEXTVAL;
	END IF;
END;

-- 4. Trigger pre automaticky generované kľúče v tabuľke Sluzby
CREATE SEQUENCE "sluzby";
CREATE OR REPLACE TRIGGER sluzby
	BEFORE INSERT ON Sluzby
	FOR EACH ROW
BEGIN
	IF :NEW.id_sluzby IS NULL THEN
		:NEW.id_sluzby := "sluzby".NEXTVAL;
	END IF;
END;



-------------------------------------------TABLES----------------------------------------------

INSERT INTO Izba VALUES('2','4','promo izba s výhľadom na more','obsadená','pripravená');
INSERT INTO Izba VALUES('28','2','štandart','neobsadená','pripravená');
INSERT INTO Izba VALUES('56','3','promo izba','obsadená','pripravená');

INSERT INTO Rezervacia (datum_vytvorenia,prichod,odchod,pocet_dospelych,pocet_deti,typ_stravy,typ_rezervacie,sposob_platby,zvlastne_poziadavky,stav,izba) VALUES (DEFAULT,TO_DATE('15/07/99', 'DD/MM/YYYY'),TO_DATE('17/07/99', 'DD/MM/YYYY'),DEFAULT,DEFAULT,'bezlepková','all inclusive','karta',NULL,'zaplatená', '2');
INSERT INTO Rezervacia (datum_vytvorenia,prichod,odchod,pocet_dospelych,pocet_deti,typ_stravy,typ_rezervacie,sposob_platby,zvlastne_poziadavky,stav,izba) VALUES (DEFAULT,TO_DATE('15/07/99', 'DD/MM/YYYY'),TO_DATE('16/07/99', 'DD/MM/YYYY'),DEFAULT, DEFAULT,'bez stravy','polopenzia','prevod na účet',NULL,'nezaplatená', '28');
INSERT INTO Rezervacia (datum_vytvorenia,prichod,odchod,pocet_dospelych,pocet_deti,typ_stravy,typ_rezervacie,sposob_platby,zvlastne_poziadavky,stav,izba) VALUES(DEFAULT,TO_DATE('15/07/99', 'DD/MM/YYYY'),TO_DATE('18/07/99', 'DD/MM/YYYY'),DEFAULT,DEFAULT,'bez stravy','polopenzia','prevod na účet',NULL,'nezaplatená', '56');

INSERT INTO Osoba_entity (meno, priezvisko, datum_narodenia, telefonne_cislo, email, adresa, mesto, psc, miesto_vydania_cestovneho_dokladu,id_rezervacie) VALUES('Jan','Novák',TO_DATE('15/07/99', 'DD/MM/YYYY'),'0904647386','xnovak01@knihovna.cz','Vokrinkova 23','Praha','98403','Slovensko','1');
INSERT INTO Osoba_entity (meno, priezvisko, datum_narodenia, telefonne_cislo, email, adresa, mesto, psc, miesto_vydania_cestovneho_dokladu,id_rezervacie) VALUES('Juraj','Peselka',TO_DATE('15/07/99', 'DD/MM/YYYY'),'0905424246','xpeselka02@knihovna.cz','Jandaskova 23','Brno','62100','Česká republika','2');
INSERT INTO Osoba_entity (meno, priezvisko, datum_narodenia, telefonne_cislo, email, adresa, mesto, psc, miesto_vydania_cestovneho_dokladu,id_rezervacie) VALUES('Petr','Santler',TO_DATE('15/07/99', 'DD/MM/YYYY'),'091568246','xsantl0@knihovna.cz','kralovska 3','Brno','62100','Česká republika','3');

INSERT INTO Personal (meno, priezvisko, datum_narodenia, telefonne_cislo, email, adresa, mesto, psc, obcianstvo ,zameranie ,dostupnost ) VALUES ('Jan','Novák',TO_DATE('15/07/99', 'DD/MM/YYYY'),'0904647386','xnovak01@knihovna.cz','Vokrinkova 23','Lučenec','98403','slovenske', 'upratovačka', 'dostupný');
INSERT INTO Personal (meno, priezvisko, datum_narodenia, telefonne_cislo, email, adresa, mesto, psc, obcianstvo ,zameranie ,dostupnost ) VALUES ('Juraj','Peselka',TO_DATE('15/07/99', 'DD/MM/YYYY'),'0905424246','xpeselka02@knihovna.cz','Jandaskova 23','Brno','62100','Ceske', 'maser', 'nedostupný');
INSERT INTO Personal (meno, priezvisko, datum_narodenia, telefonne_cislo, email, adresa, mesto, psc, obcianstvo ,zameranie ,dostupnost ) VALUES ('Petr','Santler',TO_DATE('15/07/99', 'DD/MM/YYYY'),'091568246','xsantl0@knihovna.cz','kralovska 3','Brno','62100','Ceske', 'upratovačka', 'nedostupný');

INSERT INTO Sluzby (typ_sluzby ,id_osoby ,id_personalu ) VALUES ('wellness', '1', '3');
INSERT INTO Sluzby (typ_sluzby ,id_osoby ,id_personalu ) VALUES('upratovacia služby', '3' , '2');
INSERT INTO Sluzby (typ_sluzby ,id_osoby ,id_personalu ) VALUES('detský kútik', '3' , '2' );

-------------------------------------------SELECTORS----------------------------------------------
SELECT * FROM Osoba_entity;
SELECT * FROM Rezervacia;
SELECT * FROM Personal;
SELECT * FROM Izba;
SELECT * FROM Sluzby;

/*Vypis pocet hosti z kazdej krajiny*/
SELECT miesto_vydania_cestovneho_dokladu, COUNT(*) pocet_hosti FROM Osoba_entity GROUP BY miesto_vydania_cestovneho_dokladu;

/*Vypis pocet personalu a zameranie, na ktore je personal dostupny*/
SELECT zameranie, COUNT (*) pocet_dostupnych_zamestnancov FROM Personal WHERE dostupnost='dostupný' GROUP BY zameranie;

/*Spojenie tabuliek Osoba_entity a Rezervacia*/
SELECT * FROM Osoba_entity NATURAL JOIN Rezervacia;

/*Spojenie tabuliek Sluzby a Personal*/
SELECT * FROM Sluzby NATURAL JOIN Personal;

/* spojenie troch tabuliek: Osoba_entity Rezervacia a Izba*/
SELECT * FROM Osoba_entity NATURAL JOIN Rezervacia NATURAL JOIN Izba;

/*Select obsahujúci príkaz EXISTS, pomocou ktorého vyfiltrujeme všetkých hostí, ktorí platili kartou*/
SELECT * FROM Osoba_entity WHERE EXISTS (SELECT sposob_platby FROM Rezervacia WHERE Rezervacia.sposob_platby= 'karta' AND Osoba_entity.id_rezervacie = Rezervacia.id_rezervacie);

/*Vyfiltruje z tabulky Osoba_entity vsetky osoby, ktore su z rovnakeho mesta ako personal.*/
SELECT * FROM Osoba_entity WHERE mesto IN (SELECT mesto FROM Personal);

-----------------------------------------EXPLAIN PLAN--------------------------------------------------

-- Vypíše mesiac a počet rezervácií v každom mesiaci za daný rok podľa počtu hostí pochádzajúcich z Českej republiky
EXPLAIN PLAN FOR
SELECT TO_CHAR(datum_vytvorenia, 'MM') mesiac, COUNT (*) pocet_rezervacii
FROM Rezervacia NATURAL JOIN Osoba_entity
WHERE miesto_vydania_cestovneho_dokladu = 'Česká republika'
  AND datum_vytvorenia BETWEEN
    TO_DATE('01/01/2022', 'DD/MM/YYYY') AND
    TO_DATE('31/12/2022', 'DD/MM/YYYY')
GROUP BY TO_CHAR(datum_vytvorenia, 'MM');

-- Výpis
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Vytvorenie indexu pre krajiny odkiaľ hostia pochádzajú
CREATE INDEX idx on OSOBA_ENTITY(miesto_vydania_cestovneho_dokladu);

-- Druhý pokus s indexom
EXPLAIN PLAN FOR
SELECT TO_CHAR(datum_vytvorenia, 'MM') mesiac, COUNT (*) pocet_rezervacii
FROM Rezervacia NATURAL JOIN Osoba_entity
WHERE miesto_vydania_cestovneho_dokladu = 'Česká republika'
  AND datum_vytvorenia BETWEEN
    TO_DATE('01/01/2022', 'DD/MM/YYYY') AND
    TO_DATE('31/12/2022', 'DD/MM/YYYY')
GROUP BY TO_CHAR(datum_vytvorenia, 'MM');

-- Výpis
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Odstránenie indexu
DROP index idx;