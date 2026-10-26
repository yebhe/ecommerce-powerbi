# 🧮 Mesures DAX

Le modèle contient **98 mesures** dans la table `_Mesures`. Ce document liste les **mesures de base** de chaque domaine, avec leur formule. La plupart des indicateurs ont des dérivées qui suivent toutes le même schéma :

| Suffixe | Rôle | Exemple |
|---|---|---|
| `LY` | Même période, année précédente (`SAMEPERIODLASTYEAR`) | `CA LY` |
| `%` / `YOY %` | Variation vs N-1, nulle ou vide si pas de N-1 | `CA YOY %` |
| `Affichage` / `Format` | Texte avec flèche ▲ ▼ • (`UNICHAR(11165/11167/8226)`), « — » si vide | `CA YOY Format` |
| `CF` | Couleur pour la mise en forme conditionnelle : `green` / `red` / `grey` ou code hexa | `CF CA`, `Profit YOY CF` |

> 2023 n'a pas de N-1 (le jeu commence au 02/01/2023) : les variations affichent « — ».

---

## 📐 Schéma N-1

```dax
CA LY =
CALCULATE ( [CA], SAMEPERIODLASTYEAR ( dim_date[Date] ) )
```

```dax
CA YOY % =
VAR _ly = [CA LY]
RETURN
    IF ( NOT ISBLANK ( _ly ), DIVIDE ( [CA] - _ly, _ly ) )
```

Les variantes `CF` centralisent la couleur :

```dax
CF CA =
VAR _perc = DIVIDE ( [CA] - [CA LY], [CA LY], 0 )
RETURN SWITCH ( TRUE (), _perc > 0, "green", _perc < 0, "red", "grey" )
```

---

## 💰 Dashboard

| Mesure | Formule |
|---|---|
| `CA` | `SUM(fact_sales[Total_Sales])` |
| `Profit` | `SUM(fact_sales[Profit])` |
| `Shipping cost` | `SUM(fact_sales[Shipping_Cost])` |
| `Nb Orders` | `DISTINCTCOUNT(fact_sales[Order_ID])` |
| `AOV` (panier moyen) | `DIVIDE([CA], [Nb Orders])` |
| `CA LY`, `Profit LY`, `AOV LY`, `Nb Orders LY` | `CALCULATE([…], SAMEPERIODLASTYEAR(dim_date[Date]))` |
| `CA YOY %`, `Profit YOY %`, `AOV %`, `Nb Orders %` | variation vs N-1 (`DIVIDE`) |
| `CF CA`, `CF Profit`, `CF AOV`, `CF Nb Orders` | `green` / `red` / `grey` selon le signe de la variation |
| `CA YOY Format`, `Profit YOY Affichage`, … | texte avec flèche, « — » si pas de N-1 |

### Titres dynamiques

La table `Metrics` (paramètre de champ : CA, Profit, Panier moyen, Nb commandes) pilote les 5 mesures de titre :

```dax
Dynamic Title line chart =
VAR _metrics = MAX ( Metrics[Metrics] )
RETURN
    SWITCH (
        _metrics,
        "CA",           "ÉVOLUTION DES VENTES",
        "Profit",       "ÉVOLUTION DU PROFIT",
        "Panier moyen", "ÉVOLUTION DU PANIER MOYEN",
        "Nb commandes", "ÉVOLUTION DES COMMANDES",
        "ÉVOLUTION DE LA PERFORMANCE"
    )
```

Même principe pour `Dynamic title bar region`, `Dynamic title Customer Segment`, `Dynamic Title Product Category` et `Dynamic Title Country`.

---

## 👥 Customers

| Mesure | Formule |
|---|---|
| `Nb Clients` | `DISTINCTCOUNT(fact_sales[Customer_ID])` |
| `Clients LY` | `CALCULATE([Nb Clients], SAMEPERIODLASTYEAR(dim_date[Date]))` |
| `Ca Moyen Par Client` | `DIVIDE([CA], [Nb Clients], 0)` |
| `Nb Clients Mois Précédent` | `CALCULATE([Nb Clients], DATEADD(dim_date[Date], -1, MONTH))` |
| `Nb Clients Retenu` | clients du mois présents le mois précédent (`INTERSECT` + `DATEADD`) |
| `Nb Clients Churn` | clients du mois précédent absents du mois (`EXCEPT` + `DATEADD`) |
| `Taux de Retention %` | `DIVIDE([Nb Clients Retenu], [Nb Clients Mois Précédent])` |
| `Taux de Churn %` | `DIVIDE([Nb Clients Churn], [Nb Clients Mois Précédent])` |
| `Taux Nouveaux Clients %` | `DIVIDE([Nb Nouveaux Clients], [Nb Clients], 0)` |
| `Derniere Commande` | `MAX(fact_sales[Order_Date])` |
| `Jours depuis dernière commande` | `DATEDIFF(dernière commande, date max du jeu, DAY)` |
| `Classement des Clients par CA` | `RANKX(ALLSELECTED(dim_customer[Customer_Name]), [CA], , DESC)` |
| `Statut Client` | Actif / À surveiller (> 10 j) / À risque (> 20 j) / Inactif |
| `Couleur Status Client` | `#66BB6A` / `#FFB74D` / `#E57373` / `#9A9A9A` |

Churn et rétention comparent le mois courant au mois précédent :

```dax
Nb Clients Churn =
COALESCE (
    COUNTROWS (
        EXCEPT (
            CALCULATETABLE (
                VALUES ( fact_sales[Customer_ID] ),
                DATEADD ( dim_date[Date], -1, MONTH )
            ),
            VALUES ( fact_sales[Customer_ID] )
        )
    ),
    0
)
```

Nouveaux clients = première commande dans la période :

```dax
Nb Nouveaux Clients =
COUNTROWS (
    FILTER (
        VALUES ( dim_customer[Customer_ID] ),
        CALCULATE (
            MIN ( fact_sales[Order_Date] ),
            REMOVEFILTERS ( dim_date ),
            REMOVEFILTERS ( dim_country ),
            REMOVEFILTERS ( dim_product ),
            REMOVEFILTERS ( dim_payment ),
            REMOVEFILTERS ( dim_segment )
        ) IN VALUES ( dim_date[Date] )
    )
)
```

> ⚠️ `Classement des Clients par CA` n'est pertinent que dans un visuel listant les clients : au niveau segment ou pays, le total du groupe dépasse chaque client et le rang vaut 1 partout (aucune relation `dim_segment` → `dim_customer`).

## 📦 Products

| Mesure | Formule |
|---|---|
| `Nb Products` | `DISTINCTCOUNT(fact_sales[Product_ID])` |
| `Ca Moyen Par produit` | `DIVIDE([CA], [Nb Products])` |
| `Profit Moyen Produit` | `DIVIDE([Profit], [Nb Products])` |
| `Taux de Marge %` | `DIVIDE([Profit], [CA])` |
| `Taux de Marge LY %` | `DIVIDE([Profit LY], [CA LY])` |
| `Part du produit CA` | `DIVIDE([CA], CALCULATE([CA], ALL(dim_product[Product_Name])))` |
| `Nb Products LY`, `Ca Moyen par Produit LY`, `Profit Moyen Produit LY` | variantes N-1 |

Chaque indicateur a ses dérivés `%` (variation), `Affichage` (texte fléché) et `CF` (couleur). `Taux de Marge details CF` utilise des seuils : gris si vide, rouge si < 0, vert si ≥ 30 %, gris clair sinon.

## 💳 Payments (`Payments\kpi1`, `kpi2`, `kpi3`)

Trois KPI déclinés selon le même motif base / LY / % / Affichage / CF :

| Mesure | Formule |
|---|---|
| `Nb Paiements` | `DISTINCTCOUNT(fact_sales[Order_ID])` (= `Nb Orders`) |
| `CA Moyen par Paiement` | `DIVIDE([CA], [Nb Paiements])` |
| `Profit Moyen par Paiement` | `DIVIDE([Profit], [Nb Paiements])` |

> `Nb Paiements` duplique `Nb Orders` : dans ce jeu, une commande = un paiement.

---

## 🗂️ Dossiers d'affichage

```
_Mesures
├── Dashboard        (CA, Profit, Shipping, Nb Orders, AOV + LY/%/Affichage/CF,
│                     titres dynamiques × 5)
├── Customers        (Nb Clients, rétention, churn, nouveaux clients,
│                     CA moyen, statut, classement + badges et couleurs)
├── Products         (Nb Products, CA/profit moyens, taux de marge,
│                     part du CA + LY/%/Affichage/CF)
└── Payments
    ├── kpi1         (Nb Paiements + dérivés)
    ├── kpi2         (CA moyen par paiement + dérivés)
    └── kpi3         (Profit moyen par paiement + dérivés)
```

## 🔧 Conventions et points d'attention

- Les couleurs sont écrites **en dur** dans les mesures `CF` (`"green"`, `"red"`, `"grey"`, `#2ECC71`, `#E74C3C`, `#9A9A9A`) — pas de mesure technique centralisée.
- Les badges vides affichent « — » (ou « Aucune Vente » pour `Part du Produit CA Affichage`).
- Aucune mesure n'utilise `TODAY()` : `Jours depuis dernière commande` compare à la date maximale du jeu de données.
- Le paramètre de champ `Metrics` vaut : `CA` → 0, `Profit` → 1, `Panier moyen` → `[AOV]`, `Nb commandes` → `[Nb Orders]`.
