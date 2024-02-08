Timestamp Unit

Timestamp unit je sistem za detekciju tranzicija ulaznog signala. 
Na jednobitni ulaz se dovodi povorka pravougaonih impulsa proizvoljnog oblika, u smislu da to može biti periodična povoroka proizvoljnog perioda ili aperiodičnni impuls, proizvoljnog trajanja.  
Zadatak sistema je da prepozna trenutke u kojima se dešavaju impulsne promjene na ulazu i da sačuva informacije o pojavi tih promjena, tako da korisnik može da nezavisno generiše identične impulse nezavisno od ovog sistema.  
Sistem se sastoji iz nekoliko modula: 
  - brojač - zadužen za brojanje stvarnog vremena 
  - logika za detekciju ulaza - zadužena za detekciju impulsa
  - registarska mapa - u kojoj se čuvaju trenutne vrijednosti svih podataka od interesa
  - FIFO bafer - u kojem se čuvaju trenuci pojave impulsa
  - magistrala za komunikaciju preko Avalon-MM interfejsa - ...

