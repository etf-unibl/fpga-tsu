Timestamp Unit

Timestamp unit je sistem za detekciju tranzicija ulaznog signala. 
Na jednobitni ulaz se dovodi povorka pravougaonih impulsa proizvoljnog oblika, u smislu da to može biti periodična povoroka proizvoljnog perioda ili aperiodičnni impuls, proizvoljnog trajanja.  
Zadatak sistema je da prepozna trenutke u kojima se dešavaju impulsne promjene na ulazu te da sačuva informacije o pojavi istih. Na ovaj način korisnik može generisati identičnu povorku impulsa prostim čitanjem pohranjenih vrijednosti iz bafera. U baferu čuvamo informacije o trenutku dešavanja tranzicije te vrijednosti signala u tom trenutku.
Sistem se sastoji iz nekoliko modula: 
  - brojač - zadužen za brojanje stvarnog vremena 
  - logika za detekciju ulaza - zadužena za detekciju impulsa
  - registarska mapa - u kojoj se čuvaju trenutne vrijednosti svih podataka od interesa
  - FIFO bafer - bafer za pohranu konačnih vrijednosti od interesa na osnovu kojih korisnik može generisati novu povorku impulsa
  - magistrala za komunikaciju preko Avalon-MM interfejsa - ...

