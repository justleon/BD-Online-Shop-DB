--triggery.sql - plik tworzący triggery do edycji danych wstawianych i edytowanych
CREATE OR REPLACE TRIGGER t_transakcja_id
BEFORE INSERT ON transakcje
FOR EACH ROW
BEGIN  
    IF :NEW.numer_transakcji IS NULL THEN
        SELECT sek_transakcja_id.NEXTVAL
        INTO :NEW.numer_transakcji
        FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER t_transakcja_data
AFTER INSERT ON transakcje
FOR EACH ROW
BEGIN
    UPDATE zarejestrowani_klienci
    SET data_ostatniej_transakcji = :NEW.data_transakcji
    WHERE id_klienta = :NEW.id_klienta;
END;
/

CREATE OR REPLACE TRIGGER t_adres_id
BEFORE INSERT ON adresy
FOR EACH ROW
BEGIN  
    IF :NEW.id_adresu IS NULL THEN
        SELECT sek_adres_id.NEXTVAL
        INTO :NEW.id_adresu
        FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER t_klient_id
BEFORE INSERT ON zarejestrowani_klienci
FOR EACH ROW
BEGIN  
    IF :NEW.id_adresu IS NULL THEN
        SELECT sek_adres_id.CURRVAL
        INTO :NEW.id_adresu
        FROM dual;
    END IF;
    
    IF :NEW.id_klienta IS NULL THEN
        SELECT sek_klient_id.NEXTVAL
        INTO :NEW.id_klienta
        FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER t_klient_rej
AFTER INSERT ON zarejestrowani_klienci
FOR EACH ROW
BEGIN
    dbms_output.put_line('Zarejestrowano ' || :NEW.imie || ' ' || :NEW.nazwisko || '.');
END;
/

CREATE OR REPLACE TRIGGER t_prod_cena
AFTER UPDATE ON spis_produktow
FOR EACH ROW
BEGIN
    IF :OLD.cena != :NEW.cena THEN
        dbms_output.put_line('Zmieniono cene produktu ' || :NEW.nazwa_produktu);
        dbms_output.put_line(:OLD.cena || ' -> ' || :NEW.cena);
    END IF;
END;
/

CREATE OR REPLACE TRIGGER t_prod_dod
AFTER INSERT ON spis_produktow
FOR EACH ROW
BEGIN
    dbms_output.put_line('Dodaję ' || :NEW.nazwa_produktu || ', ID:' || :NEW.id_produktu || '.');
END;
/

CREATE OR REPLACE TRIGGER t_prod_szt
AFTER INSERT ON sprzedane_produkty
FOR EACH ROW
BEGIN
    UPDATE spis_produktow
    SET liczba_sztuk_magazyn = liczba_sztuk_magazyn - :NEW.liczba_sztuk
    WHERE id_produktu = :NEW.id_produktu;
END;
/