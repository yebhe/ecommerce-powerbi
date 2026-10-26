# 📁 Données

Le fichier CSV est **inclus** dans ce dépôt, dans ce dossier : [`global_ecommerce_sales.csv`](global_ecommerce_sales.csv). Ce sont des données de démonstration, fictives, qui ne représentent aucune entreprise réelle.

## Origine

Jeu de données public à vocation pédagogique sur les ventes d'un site e-commerce, utilisé ici comme support d'apprentissage Power BI.

## Fichier

Un seul fichier plat, **une ligne par commande**. Power Query l'éclate ensuite en 1 table de faits et 5 dimensions, auxquelles s'ajoutent le calendrier calculé `dim_date` et le paramètre de champ `Metrics`.

| Fichier | Contenu | Lignes | Colonnes |
|---|---|---:|---:|
| `global_ecommerce_sales.csv` | Commandes e-commerce (client, produit, montants, paiement) | 2 000 | 15 |

| Colonne | Type | Contenu |
|---|---|---|
| `Order_ID` | texte | identifiant de commande, unique |
| `Order_Date` | date | 02/01/2023 → 31/12/2025 |
| `Customer_Name` | texte | 1 534 clients |
| `Customer_Segment` | texte | Consumer, Corporate, Home Office |
| `Country` | texte | 20 pays |
| `Region` | texte | Asia Pacific, Europe, Middle East & Africa, North America, South America |
| `Product_Category` | texte | Clothing & Accessories, Furniture, Office Supplies, Technology |
| `Product_Name` | texte | 40 produits |
| `Quantity` | entier | 1 à 15 articles |
| `Unit_Price` | décimal | prix unitaire |
| `Discount_Percent` | nombre | 0, 5, 10, 15, 20, 25 ou 30 % |
| `Total_Sales` | décimal | = `Quantity` × `Unit_Price` × (1 − remise) |
| `Shipping_Cost` | décimal | frais de port |
| `Profit` | décimal | marge de la commande (272 valeurs négatives) |
| `Payment_Method` | texte | Bank Transfer, Cash on Delivery, Credit Card, PayPal |

Aucune valeur vide. `Order_ID` est unique sur les 2 000 lignes.

## Brancher les données au rapport

1. Ouvrir `yebhe_financial_last.pbix` dans **Power BI Desktop**.
2. **Accueil → Transformer les données → Gérer les paramètres**.
3. Renseigner `chemin_source` avec le chemin **complet du dossier** `data` (sans le nom du fichier).
   Exemple : `C:\projets\ecom_p1_last\data`
4. Fermer l'éditeur et cliquer sur **Actualiser**.
5. Contrôler : 2 000 lignes dans `fact_sales`, CA total ≈ 484 559 €.

## Points d'attention

- Le fichier est lu en UTF-8, séparateur virgule. Les montants (`Unit_Price`, `Total_Sales`, `Shipping_Cost`, `Profit`) et `Discount_Percent` sont convertis avec la locale **en-US** (point décimal) dans la requête `sales_ecommerce`. Une conversion en fr-FR casserait les décimaux.
- Les clés des dimensions (`Customer_ID`, `Country_ID`, `Product_ID`, `Segment_ID`, `Payment_ID`) n'existent pas dans le fichier : elles sont recréées dans Power Query par colonne d'index après déduplication. Elles sont **positionnelles** : si l'ordre de la source change, les clés changent.
- `fact_sales` récupère ces clés par fusions LeftOuter (`Table.NestedJoin`) sur les libellés (nom client, pays + région, produit + catégorie, segment, méthode de paiement).
- `dim_date` n'est pas issue du fichier : c'est une table calculée DAX (`CALENDAR` entre la première et la dernière `Order_Date`).
- 272 commandes (13,6 %) ont un `Profit` négatif : ce sont des ventes à perte, conservées telles quelles (voir le [README principal](../README.md#-limites-connues)).
