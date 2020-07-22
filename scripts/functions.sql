--funkcje.sql - plik z dwiema funkcjami do obsługi pewnych kwestii finansowych
CREATE OR REPLACE FUNCTION zmien_cene(id_p NUMBER, wartosc NUMBER)
RETURN NUMBER
AS
    nowa_cena NUMBER := 0;
BEGIN
    SELECT cena INTO nowa_cena
    FROM spis_produktow
    WHERE id_produktu = id_p;
    
    nowa_cena := nowa_cena * wartosc;
    
    RETURN nowa_cena;
END;
/

CREATE OR REPLACE FUNCTION sumuj_wydatki(id_k NUMBER)
RETURN NUMBER
AS
    suma_wydatkow NUMBER := 0;
BEGIN
    SELECT c_s INTO suma_wydatkow
    FROM (SELECT ZR.id_klienta, SUM(SP.cena_sprzedazy) AS c_s
        FROM sprzedane_produkty SP
        NATURAL JOIN transakcje T
        INNER JOIN zarejestrowani_klienci ZR
        ON T.id_klienta = ZR.id_klienta
        GROUP BY ZR.id_klienta)
    WHERE id_klienta = id_k;

    RETURN suma_wydatkow;
    EXCEPTION
        WHEN no_data_found THEN
        suma_wydatkow := 0;
        RETURN suma_wydatkow;
END;