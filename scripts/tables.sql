--tabele.sql - plik tworzący tabele i wypełniający je danymi
CREATE TABLE adresy (
    id_adresu      NUMBER(4) NOT NULL,
    ulica          VARCHAR2(40 BYTE) NOT NULL,
    numer          NUMBER(4) NOT NULL,
    mieszkanie     NUMBER(4),
    kod_pocztowy   VARCHAR2(40 BYTE) NOT NULL,
    miasto         VARCHAR2(40 BYTE) NOT NULL
);

CREATE TABLE kategorie_produktow (
    id_kategorii      NUMBER(4) NOT NULL,
    nazwa_kategorii   VARCHAR2(40 BYTE) NOT NULL
);

CREATE TABLE pracownicy (
    id_pracownika   NUMBER(4) NOT NULL,
    imie            VARCHAR2(40 BYTE) NOT NULL,
    nazwisko        VARCHAR2(40) NOT NULL
);

CREATE TABLE producenci (
    id_producenta   NUMBER(4) NOT NULL,
    nazwa_firmy     VARCHAR2(40 BYTE) NOT NULL
);

CREATE TABLE spis_produktow (
    id_produktu            NUMBER(4) NOT NULL,
    id_kategorii           NUMBER(4) NOT NULL,
    id_producenta          NUMBER(4) NOT NULL,
    nazwa_produktu         VARCHAR2(40 BYTE) NOT NULL,
    cena                   NUMBER(7, 2) NOT NULL,
    liczba_sztuk_magazyn   NUMBER(4) NOT NULL
);

CREATE TABLE sprzedane_produkty (
    numer_transakcji   NUMBER(4) NOT NULL,
    id_produktu        NUMBER(4) NOT NULL,
    liczba_sztuk       NUMBER(4) NOT NULL,
    cena_sprzedazy     NUMBER(7, 2) NOT NULL
);

CREATE TABLE transakcje (
    numer_transakcji    NUMBER(6) NOT NULL,
    id_klienta          NUMBER(4) NOT NULL,
    data_transakcji     DATE NOT NULL,
    sposób_wysyłki      VARCHAR2(40 BYTE),
    data_realizacji     DATE,
    id_pracownika       NUMBER(4) NOT NULL
);

CREATE TABLE zarejestrowani_klienci (
    id_klienta                  NUMBER(4) NOT NULL,
    id_adresu                   NUMBER(4) NOT NULL,
    imie                        VARCHAR2(40 BYTE) NOT NULL,
    nazwisko                    VARCHAR2(40 BYTE) NOT NULL,
    data_rejestracji            DATE NOT NULL,
    data_ostatniej_transakcji   DATE
);

ALTER TABLE adresy ADD CONSTRAINT adresy_pk PRIMARY KEY ( id_adresu );
ALTER TABLE kategorie_produktow ADD CONSTRAINT kategorie_produktow_pk PRIMARY KEY ( id_kategorii );
ALTER TABLE pracownicy ADD CONSTRAINT pracownicy_pk PRIMARY KEY ( id_pracownika );
ALTER TABLE producenci ADD CONSTRAINT producenci_pk PRIMARY KEY ( id_producenta );
ALTER TABLE spis_produktow ADD CONSTRAINT spis_produktow_pk PRIMARY KEY ( id_produktu );
ALTER TABLE transakcje ADD CONSTRAINT transakcje_pk PRIMARY KEY ( numer_transakcji );
ALTER TABLE zarejestrowani_klienci ADD CONSTRAINT zarejestrowani_klienci_pk PRIMARY KEY ( id_klienta );

ALTER TABLE zarejestrowani_klienci ADD CONSTRAINT adresy_fk FOREIGN KEY ( id_adresu ) REFERENCES adresy ( id_adresu );
ALTER TABLE spis_produktow ADD CONSTRAINT kategorie_produktow_fk FOREIGN KEY ( id_kategorii ) REFERENCES kategorie_produktow ( id_kategorii );
ALTER TABLE transakcje ADD CONSTRAINT pracownicy_fk FOREIGN KEY ( id_pracownika ) REFERENCES pracownicy ( id_pracownika );
ALTER TABLE spis_produktow ADD CONSTRAINT producenci_fk FOREIGN KEY ( id_producenta ) REFERENCES producenci ( id_producenta );
ALTER TABLE sprzedane_produkty ADD CONSTRAINT spis_produktow_fk FOREIGN KEY ( id_produktu ) REFERENCES spis_produktow ( id_produktu );
ALTER TABLE sprzedane_produkty ADD CONSTRAINT transakcje_fk FOREIGN KEY ( numer_transakcji ) REFERENCES transakcje ( numer_transakcji );
ALTER TABLE transakcje ADD CONSTRAINT zarejestrowani_klienci_fk FOREIGN KEY ( id_klienta ) REFERENCES zarejestrowani_klienci ( id_klienta );

ALTER TABLE kategorie_produktow ADD CONSTRAINT nazwa_unique_kat UNIQUE ( nazwa_kategorii );
ALTER TABLE producenci ADD CONSTRAINT nazwa_unique_pro UNIQUE ( nazwa_firmy );
ALTER TABLE transakcje ADD CONSTRAINT wysylka_tr CHECK (sposób_wysyłki IN ('KURIER', 'POCZTA', 'OSOBISTY'));

INSERT INTO kategorie_produktow VALUES (1, 'Procesory');
INSERT INTO kategorie_produktow VALUES (2, 'Płyty główne');
INSERT INTO kategorie_produktow VALUES (3, 'RAM');
INSERT INTO kategorie_produktow VALUES (4, 'Peryferia');
INSERT INTO kategorie_produktow VALUES (5, 'Sprzęt multimedialny');
INSERT INTO kategorie_produktow VALUES (6, 'Akcesoria');

INSERT INTO producenci VALUES (1, 'Intel');
INSERT INTO producenci VALUES (2, 'AMD');
INSERT INTO producenci VALUES (3, 'Gigabyte');
INSERT INTO producenci VALUES (4, 'MSI');
INSERT INTO producenci VALUES (5, 'ASUS');
INSERT INTO producenci VALUES (6, 'Samsung');
INSERT INTO producenci VALUES (7, 'Logitech');
INSERT INTO producenci VALUES (8, 'AverMedia');
INSERT INTO producenci VALUES (9, 'HP');
INSERT INTO producenci VALUES (10, 'Corsair');

INSERT INTO pracownicy VALUES (1, 'Piotr', 'Gryf');
INSERT INTO pracownicy VALUES (2, 'Brendan', 'Fraser');
INSERT INTO pracownicy VALUES (3, 'Łukasz', 'Pokorzyński');
INSERT INTO pracownicy VALUES (4, 'Clint', 'Eastwood');

INSERT INTO adresy VALUES (100, 'Biskupia', 64, NULL, '04-216', 'Warszawa');
INSERT INTO adresy VALUES (101, 'Grochowska', 56, 41, '04-282', 'Warszawa');
INSERT INTO adresy VALUES (102, 'Rostworowskiego', 30, 20, '01-494', 'Warszawa');
INSERT INTO adresy VALUES (103, 'Północna', 12, NULL, '09-402', 'Płock');
INSERT INTO adresy VALUES (104, 'Niemcewicza', 3, 2, '76-200', 'Słupsk');

INSERT INTO zarejestrowani_klienci VALUES (1, 100, 'Jan', 'Kowalski', TO_DATE('01-04-2018', 'DD-MM-YYYY'), TO_DATE('02-11-2019', 'DD-MM-YYYY'));
INSERT INTO zarejestrowani_klienci VALUES (2, 101, 'Mateusz', 'Pokorzyński', TO_DATE('17-06-2018', 'DD-MM-YYYY'), TO_DATE('21-10-2019', 'DD-MM-YYYY'));
INSERT INTO zarejestrowani_klienci VALUES (3, 102, 'X', 'D', TO_DATE('09-02-2019', 'DD-MM-YYYY'), NULL);
INSERT INTO zarejestrowani_klienci VALUES (4, 103, 'Adam', 'Nowak', TO_DATE('10-10-2019', 'DD-MM-YYYY'), TO_DATE('13-10-2019', 'DD-MM-YYYY'));
INSERT INTO zarejestrowani_klienci VALUES (5, 104, 'Tomasz', 'Kruk', TO_DATE('15-04-2020', 'DD-MM-YYYY'), NULL);

INSERT INTO transakcje VALUES (101, 1, TO_DATE('02-04-2018', 'DD-MM-YYYY'), 'KURIER', TO_DATE('03-04-2018', 'DD-MM-YYYY'), 2);
INSERT INTO transakcje VALUES (102, 4, TO_DATE('13-10-2019', 'DD-MM-YYYY'), 'POCZTA', TO_DATE('15-10-2019', 'DD-MM-YYYY'), 1);
INSERT INTO transakcje VALUES (103, 2, TO_DATE('21-10-2019', 'DD-MM-YYYY'), 'OSOBISTY', TO_DATE('22-10-2019', 'DD-MM-YYYY'), 4);
INSERT INTO transakcje VALUES (104, 1, TO_DATE('02-11-2019', 'DD-MM-YYYY'), 'KURIER', TO_DATE('05-11-2019', 'DD-MM-YYYY'), 1);

INSERT INTO spis_produktow VALUES (1, 1, 2, 'Ryzen 5 3600, 3.6GHz, 32 MB', 859, 7);
INSERT INTO spis_produktow VALUES (2, 2, 4, 'B450-A PRO MAX', 519, 1);
INSERT INTO spis_produktow VALUES (3, 1, 1, 'Core i5-9400F, 2.9GHz, 9 MB', 819, 4);
INSERT INTO spis_produktow VALUES (4, 1, 2, 'Ryzen 7 3700X, 3.6GHz, 32 MB', 1479, 2);
INSERT INTO spis_produktow VALUES (5, 2, 3, 'B365M D3H', 399, 5);
INSERT INTO spis_produktow VALUES (6, 3, 10, 'Vengeance RGB PRO,DDR4,16GB,3200MHz,CL16', 469, 0);
INSERT INTO spis_produktow VALUES (7, 3, 10, 'Vengeance,DDR3,8GB,1600MHz,CL9', 243, 9);
INSERT INTO spis_produktow VALUES (8, 4, 9, '500GB 3.5" SATA III', 318, 2);
INSERT INTO spis_produktow VALUES (9, 5, 9, 'LaserJetPro M404dn', 759, 1);
INSERT INTO spis_produktow VALUES (10, 4, 6, 'S24R350', 589, 3);
INSERT INTO spis_produktow VALUES (11, 4, 7, 'M705', 175, 0);
INSERT INTO spis_produktow VALUES (12, 6, 7, 'C270 HD Webcam', 299, 4);

INSERT INTO sprzedane_produkty VALUES (101, 2, 1, 519);
INSERT INTO sprzedane_produkty VALUES (101, 1, 1, 859);
INSERT INTO sprzedane_produkty VALUES (102, 4, 1, 1250);
INSERT INTO sprzedane_produkty VALUES (103, 11, 1, 175);
INSERT INTO sprzedane_produkty VALUES (104, 6, 2, 938);