--procedury.sql - procedury obsługujące bazę danych w paczkach
CREATE OR REPLACE PACKAGE zarzadzaj_osobami IS
PROCEDURE dodaj_pracownika(
    imie        VARCHAR2,
    nazwisko    VARCHAR2
);

PROCEDURE zarej_klienta(
    imie        VARCHAR2,
    nazwisko    VARCHAR2,
    ulica       VARCHAR2,
    nr_domu     NUMBER,
    nr_mieszk   NUMBER,
    kod_poczt   VARCHAR2,
    miasto      VARCHAR2
);

END zarzadzaj_osobami;
/

CREATE OR REPLACE PACKAGE zarzadzaj_produktami IS
PROCEDURE dodaj_produkt(
    id_kategorii    NUMBER,
    id_producenta   NUMBER,
    nazwa           VARCHAR2,
    cena            NUMBER,
    l_sztuk         NUMBER
);

PROCEDURE modyfikuj_cene(
    id_prod         NUMBER,
    obnizka         NUMBER
);

PROCEDURE obsluz_dostawe(
    id_prod         NUMBER,
    dostawa         NUMBER
);

END zarzadzaj_produktami;
/

CREATE OR REPLACE PACKAGE zarzadzaj_transakcjami IS
PROCEDURE dodaj_transakcje(
    id_klienta  NUMBER,
    wysyłka     VARCHAR2
);

PROCEDURE dodaj_produkt(
    nr_transakcji   NUMBER,
    id_prod         NUMBER,
    sztuki          NUMBER
);

PROCEDURE suma_kategorii;

END zarzadzaj_transakcjami;
/

CREATE OR REPLACE PACKAGE inne IS
PROCEDURE dodaj_kategorie(
    nazwa   VARCHAR2
);

PROCEDURE dodaj_producenta(
    nazwa   VARCHAR2
);

END inne;
/

CREATE OR REPLACE PACKAGE BODY zarzadzaj_osobami IS
PROCEDURE dodaj_pracownika(
    imie        VARCHAR2,
    nazwisko    VARCHAR2
)
AS
    nowe_id NUMBER;
BEGIN
    SELECT COUNT(*) INTO nowe_id
    FROM pracownicy;
    
    nowe_id := nowe_id + 1;
    INSERT INTO pracownicy VALUES (nowe_id, imie, nazwisko);
    dbms_output.put_line('Witamy nowego pracownika ' || imie || ' ' || nazwisko || ' ID: ' || nowe_id || '!');
END;

PROCEDURE zarej_klienta(
    imie        VARCHAR2,
    nazwisko    VARCHAR2,
    ulica       VARCHAR2,
    nr_domu     NUMBER,
    nr_mieszk   NUMBER,
    kod_poczt   VARCHAR2,
    miasto      VARCHAR2
)
AS
BEGIN
    INSERT INTO adresy VALUES (NULL, ulica, nr_domu, nr_mieszk, kod_poczt, miasto);
    INSERT INTO zarejestrowani_klienci VALUES (NULL, NULL, imie, nazwisko, SYSDATE, NULL);
END;

END zarzadzaj_osobami;
/

CREATE OR REPLACE PACKAGE BODY zarzadzaj_produktami IS

PROCEDURE dodaj_produkt(
    id_kategorii    NUMBER,
    id_producenta   NUMBER,
    nazwa           VARCHAR2,
    cena            NUMBER,
    l_sztuk         NUMBER
)
AS
BEGIN
    IF cena > 0 THEN
        INSERT INTO spis_produktow VALUES (sek_produkt_id.NEXTVAL, id_kategorii, id_producenta, nazwa, cena, l_sztuk);
    ELSE
        dbms_output.put_line('Na pewno nie chcemy zarobic na tym produkcie? -> ' || nazwa);
    END IF;
EXCEPTION
    WHEN others THEN
    dbms_output.put_line('Czy wszystkie dane się zgadzają? Nie moglem dodać produktu!');
END;

PROCEDURE modyfikuj_cene(
    id_prod         NUMBER,
    obnizka         NUMBER
)
AS
    nowa_cena   NUMBER;
BEGIN
    nowa_cena := zmien_cene(id_prod, obnizka);
    
    UPDATE spis_produktow SP
    SET cena = nowa_cena
    WHERE SP.id_produktu = id_prod;
EXCEPTION
    WHEN no_data_found THEN
    dbms_output.put_line('Czy na pewno miales na mysli to ID? -> ' || id_prod);
END;

PROCEDURE obsluz_dostawe(
    id_prod         NUMBER,
    dostawa         NUMBER
)
AS
BEGIN
    UPDATE spis_produktow
    SET liczba_sztuk_magazyn = liczba_sztuk_magazyn + dostawa
    WHERE id_produktu = id_prod;
EXCEPTION
    WHEN others THEN
    dbms_output.put_line('Czy na pewno miales na mysli to ID? -> ' || id_prod);
END;

END zarzadzaj_produktami;
/

CREATE OR REPLACE PACKAGE BODY zarzadzaj_transakcjami IS
PROCEDURE dodaj_transakcje(
    id_klienta  NUMBER,
    wysyłka     VARCHAR2
)
AS
    pracownik   PLS_INTEGER;
BEGIN
    SELECT COUNT(*) INTO pracownik
    FROM pracownicy;
    pracownik := dbms_random.value(1, pracownik);
    
    INSERT INTO transakcje VALUES (NULL, id_klienta, SYSDATE, wysyłka, NULL, pracownik);
EXCEPTION
    WHEN others THEN
    dbms_output.put_line('Sprawdz podane dane! -> ' || id_klienta || ' ' || wysyłka);
END;

PROCEDURE dodaj_produkt(
    nr_transakcji   NUMBER,
    id_prod         NUMBER,
    sztuki          NUMBER
)
AS
    cena_jedn       NUMBER;
    sztuk_magazyn   NUMBER;
BEGIN
    SELECT cena, liczba_sztuk_magazyn
    INTO cena_jedn, sztuk_magazyn
    FROM spis_produktow
    WHERE id_prod = id_produktu;
    
    IF (sztuk_magazyn - sztuki) < 0 THEN
        dbms_output.put_line('Za mało sztuk produktu w magazynie!');
    ELSE
        INSERT INTO sprzedane_produkty VALUES (nr_transakcji, id_prod, sztuki, sztuki * cena_jedn);
    END IF;
EXCEPTION
    WHEN others THEN
    dbms_output.put_line('Sprawdź wprowadzane dane!');
END;

PROCEDURE suma_kategorii
AS
CURSOR c IS
    SELECT nazwa_kategorii, SUM(SSP.liczba_sztuk) AS sztuki, SUM(SSP.cena_sprzedazy) AS suma
    FROM kategorie_produktow
    NATURAL JOIN spis_produktow SP
    JOIN sprzedane_produkty SSP ON  SP.id_produktu = SSP.id_produktu
    GROUP BY nazwa_kategorii;

TYPE r_type_kategoria IS RECORD(
    nazwa   kategorie_produktow.nazwa_kategorii%type,
    sztuki  spis_produktow.id_produktu%type,
    suma    sprzedane_produkty.cena_sprzedazy%type
);

r_kategoria r_type_kategoria;
BEGIN
    dbms_output.put_line('Podsumowanie sprzedazy w obrebie kategorii');
    OPEN c;
    LOOP
    FETCH c INTO r_kategoria;
    EXIT WHEN c%NOTFOUND;
    dbms_output.put_line('Dane kategorii: ' || r_kategoria.nazwa || ' | ' || 
                    r_kategoria.sztuki || ' | ' || r_kategoria.suma);
    END LOOP;
    CLOSE c;
END;

END zarzadzaj_transakcjami;
/

CREATE OR REPLACE PACKAGE BODY inne IS

PROCEDURE dodaj_kategorie(
    nazwa   VARCHAR2
)
AS
    nowe_id NUMBER;
BEGIN
    SELECT COUNT(*) INTO nowe_id
    FROM kategorie_produktow;

    nowe_id := nowe_id + 1;
    INSERT INTO kategorie_produktow VALUES (nowe_id, nazwa);
    dbms_output.put_line('Dodano kategorie ' || nazwa || ' o ID ' || nowe_id);
EXCEPTION
    WHEN dup_val_on_index THEN
    dbms_output.put_line('Dana kategoria juz istnieje w bazie danych. -> ' || nazwa);
END;

PROCEDURE dodaj_producenta(
    nazwa   VARCHAR2
)
AS
    nowe_id NUMBER;
BEGIN
    SELECT COUNT(*) INTO nowe_id
    FROM producenci;
    
    nowe_id := nowe_id + 1;
    INSERT INTO producenci VALUES (nowe_id, nazwa);
    dbms_output.put_line('Dodano producenta ' || nazwa || ' o ID ' || nowe_id);
EXCEPTION
    WHEN dup_val_on_index THEN
    dbms_output.put_line('Dany producent juz istnieje w bazie danych. -> ' || nazwa);
END;

END inne;
/