--Plik zawierajacy wszelkie skrypty testowe sprawdzajace wszystkie procedury i funkcje + inne zapytania.
--Każda sekcja testów jest odpowienio oznaczona ramką w komentarzach.

--------------------
--TEST PACZKI inne--
--------------------
BEGIN
    inne.dodaj_kategorie('Laptopy');
    inne.dodaj_kategorie('Gotowe stacje robocze');
    
    --wyjątek - dana kategoria juz istnieje w bazie danych
    inne.dodaj_kategorie('Procesory');
END;
/
SELECT * FROM kategorie_produktow
ORDER BY id_kategorii;
/

BEGIN
    inne.dodaj_producenta('Elgato');
    inne.dodaj_producenta('DELL');
    
    --wyjątek - dany producent juz istnieje w bazie danych
    inne.dodaj_producenta('ASUS');
END;
/
SELECT * FROM producenci;
/

---------------------------------
--TEST PACZKI zarzadzaj_osobami--
---------------------------------
--przy procedurze zarej_klienta z tej paczki są wykorzystywane triggery ( t_adres_id , t_klient_id , t_klient_rej )
BEGIN
    zarzadzaj_osobami.dodaj_pracownika('Janko', 'Muzykant');
    zarzadzaj_osobami.dodaj_pracownika('Rafał', 'Trzaskowski');
    
    zarzadzaj_osobami.zarej_klienta('Andrzej', 'Duda', 'Nowogrodzka', 84, 86, '02-018', 'Warszawa');
END;
/

------------------------------------
--TEST PACZKI zarzadzaj_produktami--
------------------------------------
--wykorzystywane są triggery ( t_prod_cena , t_prod_dod )
--wykorzystywana jest f-cja zmien_cene w procedurze modyfikuj_cene
BEGIN
    zarzadzaj_produktami.modyfikuj_cene(4, 0.7);
    --wyjatek - dany produkt nie istnieje
    zarzadzaj_produktami.modyfikuj_cene(20, 0.5);
    
    zarzadzaj_produktami.obsluz_dostawe(6, 12);
    --dany produkt nie istnieje - update nie zachodzi
    zarzadzaj_produktami.obsluz_dostawe(56, 12);
    
    zarzadzaj_produktami.dodaj_produkt(2, 3, 'B450 AORUS ELITE', 529, 6);
    zarzadzaj_produktami.dodaj_produkt(7, 4, 'Alpha 15 (A3DD-032XPL)', 3529, 2);
    --wyjatek - ktores z ID nie jest poprawne
    zarzadzaj_produktami.dodaj_produkt(2, 15, 'X570 GAMING X', 829, 8);
    --ostrzezenie - cena ponizej 0
    zarzadzaj_produktami.dodaj_produkt(2, 3, 'GA-A320M-S2H', -120, 1);
END;
/

--------------------------------------
--TEST PACZKI zarzadzaj_transakcjami--
--------------------------------------
--wykorzystywane są triggery ( t_transakcja_id , t_transakcja_data , t_prod_szt )
BEGIN
    zarzadzaj_transakcjami.dodaj_transakcje(5, 'KURIER');
    zarzadzaj_transakcjami.dodaj_transakcje(4, 'POCZTA');
    
    --wyjatek - niepoprawne dane
    zarzadzaj_transakcjami.dodaj_transakcje(3, 'DPS');
    zarzadzaj_transakcjami.dodaj_transakcje(100, 'OSOBISTY');
    
    zarzadzaj_transakcjami.dodaj_produkt(105, 14, 1);
    zarzadzaj_transakcjami.dodaj_produkt(106, 10, 1);
    --ostrzezenie - brak towaru w magazynie
    zarzadzaj_transakcjami.dodaj_produkt(106, 11, 1);
    --wyjatek - niepoprawny numer transakcji
    zarzadzaj_transakcjami.dodaj_produkt(1061, 1, 1);
END;
/

-------------------
--INNE TESTY BAZY--
-------------------
--ile transakcji dokonano w obrębie jednej kategorii
SELECT nazwa_kategorii, COUNT(numer_transakcji)
FROM kategorie_produktow
LEFT OUTER JOIN spis_produktow ON spis_produktow.id_kategorii = kategorie_produktow.id_kategorii
LEFT OUTER JOIN sprzedane_produkty ON sprzedane_produkty.id_produktu = spis_produktow.id_produktu
GROUP BY nazwa_kategorii;
/
--ile transakcji dokonał każdy z pracowników
SELECT imie, nazwisko, cnt
FROM (SELECT P.id_pracownika, COUNT(T.numer_transakcji) AS cnt
      FROM transakcje T
      RIGHT OUTER JOIN pracownicy P ON T.id_pracownika = P.id_pracownika
      GROUP BY P.id_pracownika
      ORDER BY P.id_pracownika)
NATURAL JOIN pracownicy;
/
--ile produktów danej firmy zostało sprzedane
SELECT nazwa_firmy, SUM(liczba_sztuk) AS produkty
FROM producenci
FULL OUTER JOIN spis_produktow ON producenci.id_producenta = spis_produktow.id_producenta
LEFT OUTER JOIN sprzedane_produkty ON spis_produktow.id_produktu = sprzedane_produkty.id_produktu
GROUP BY nazwa_firmy
ORDER BY nazwa_firmy;
/

--zapytania wykorzystujace fcję sumuj_wydatki
DECLARE
    suma_kosztow    NUMBER;
BEGIN
    dbms_output.put_line('Test f-kcji sumuj_wydatki:');
    suma_kosztow := sumuj_wydatki(1);
    dbms_output.put_line('Klient o ID 1 wydal u nas ' || suma_kosztow || ' zl.');
    --sprawdzamy działanie syt. wyjątkowej w funkcji, klient o ID 3 nie kupił jeszcze nic
    suma_kosztow := sumuj_wydatki(3);
    dbms_output.put_line('A klient o ID 3 - ' || suma_kosztow || ' zl.');
END;
/

--teraz z użyciem kursora do zebrania id klientów, którzy dokonali zakupów
DECLARE
    suma_kosztow    NUMBER;
BEGIN
    dbms_output.put_line('Teraz sumuj_wydatki z uzyciem kursora:');
    FOR REKORD IN (SELECT ZK.id_klienta AS id_k
                   FROM transakcje T
                   INNER JOIN zarejestrowani_klienci ZK ON T.id_klienta = ZK.id_klienta
                   GROUP BY ZK.id_klienta
                   ORDER BY ZK.id_klienta)
    LOOP
        suma_kosztow := sumuj_wydatki(REKORD.id_k);
        dbms_output.put_line('ID: ' || REKORD.id_k || ' Koszty: ' || suma_kosztow || ' zl.');
    END LOOP;
END;
/
