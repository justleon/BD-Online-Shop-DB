--drop.sql - plik odpowiedzialny za wyczyszczenie bazy danych w celu przygotowania środowiska
DROP TABLE adresy CASCADE CONSTRAINTS;
DROP TABLE kategorie_produktow CASCADE CONSTRAINTS;
DROP TABLE pracownicy CASCADE CONSTRAINTS;
DROP TABLE producenci CASCADE CONSTRAINTS;
DROP TABLE spis_produktow CASCADE CONSTRAINTS;
DROP TABLE sprzedane_produkty CASCADE CONSTRAINTS;
DROP TABLE transakcje CASCADE CONSTRAINTS;
DROP TABLE zarejestrowani_klienci CASCADE CONSTRAINTS;

DROP SEQUENCE sek_transakcja_id;
DROP SEQUENCE sek_klient_id;
DROP SEQUENCE sek_adres_id;
DROP SEQUENCE sek_produkt_id;

DROP FUNCTION zmien_cene;
DROP FUNCTION sumuj_wydatki;

DROP PACKAGE zarzadzaj_osobami;
DROP PACKAGE zarzadzaj_produktami;
DROP PACKAGE zarzadzaj_transakcjami;
DROP PACKAGE inne;

ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '.,';