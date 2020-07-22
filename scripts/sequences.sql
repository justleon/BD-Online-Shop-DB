--sekwencje.sql - plik tworzacy sekwencje do współpracy z procedurami i funkcjami
CREATE SEQUENCE sek_transakcja_id
      INCREMENT BY 1
      START WITH 105
      NOMAXVALUE
      NOCYCLE;
      
CREATE SEQUENCE sek_klient_id
      INCREMENT BY 1
      START WITH 6
      NOMAXVALUE
      NOCYCLE;
      
CREATE SEQUENCE sek_adres_id
      INCREMENT BY 1
      START WITH 105
      NOMAXVALUE
      NOCYCLE;
      
CREATE SEQUENCE sek_produkt_id
      INCREMENT BY 1
      START WITH 13
      NOMAXVALUE
      NOCYCLE;