# Forgotten Drain Cavern

## 1. Yleiskuvaus

**Teema:**\
Luolamainen dungeon, inspiroitunut Old School Runescapen Lumbridge
Sewers -tyylisestä ympäristöstä.

**Ympäristö sisältää:** - Kiviseiniä - Matalia lattiaa pitkin kulkevia
vesipuroja - Lammikoita - Kostean ja hämärän tunnelman

------------------------------------------------------------------------

## 2. Ydinmekaniikat

-   Pelaajalla käytössä vain perusliikkuminen ja basic attack
-   Tutorial-tyyliset viholliskohtaamiset (yksinkertainen AI)
-   Ympäristön kautta tapahtuva tarinankerronta
-   Puolikkaan esineen mekaniikka, joka vaaditaan boss-huoneeseen
    pääsyyn

------------------------------------------------------------------------

## 3. Dungeonin Kulku & Huonejako

-   Entrance → Small Safe Room (ei vihollisia, rauhallinen aloitusalue)
-   Slime Corridor (ensimmäinen taistelukohtaaminen -- Slime-viholliset)
-   Water Split Room (vesipuro jakaa reitin kahteen suuntaan)
-   Bat Ledge Room (viholliset: Lepakot, sisältää puolikas esine A)
-   Frog Pool Room (viholliset: Sammakot, sisältää puolikas esine B)
-   Kun puolikas A ja puolikas B yhdistetään → pääsy Boss-huoneeseen
    avautuu
-   Slime Boss Room (suurempi areena, yksinkertainen
    boss-käyttäytyminen)
-   Exit (palauttaa pelaajan takaisin central towniin)

------------------------------------------------------------------------

## 4. Vihollissuunnittelun Huomiot

-   **Slime:** Hidas liike, perus kosketusvahinko
-   **Lepakko:** Nopeampi, pienempi osumalaatikko, epäsäännöllinen
    liikerata
-   **Sammakko:** Keskinopea, hieman enemmän HP:tä kuin slime
-   **Slime Boss:** Suurempi versio, mahdollinen jakautumismekaniikka
    tai maaisku

------------------------------------------------------------------------

## 5. Ympäristösuunnittelun Tavoitteet

-   Käytetään valitun tilepackin 16x16 luolatilejä
-   Kiviseinät epätasaisilla reunoilla
-   Vesipuroja kulkemassa huoneiden läpi
-   Pieniä lammikoita sammakkohuoneessa
-   Tummempi valaistus boss-alueella
-   Ambient-äänet:
    -   Vesitippojen ääni
    -   Luolakaiku
    -   Etäiset slime-äänet

------------------------------------------------------------------------

## 6. Pelaajakokemuksen Tavoite

Dungeon 1:n jälkeen pelaaja: - Ymmärtää perustaistelun - On kokenut
ensimmäisen boss-taistelun - Ymmärtää dungeon-rakenteen logiikan
