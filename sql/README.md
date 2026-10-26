# 🗄️ Requêtes SQL

Requêtes qui reproduisent en SQL les indicateurs du rapport Power BI, à partir du fichier
[`../data/global_ecommerce_sales.csv`](../data/global_ecommerce_sales.csv). Les résultats
attendus (calculés sur le fichier source) sont indiqués en commentaire dans chaque requête.

## Prérequis

1. Charger le CSV dans une table nommée `global_ecommerce_sales` (types : `Order_Date` en date,
   `Quantity` en entier, `Discount_Percent`, `Unit_Price`, `Total_Sales`, `Shipping_Cost`, `Profit`
   en numérique, le reste en texte).
2. Requêtes écrites en **SQL standard**, testables sous PostgreSQL. Adaptations rapides :
   - MySQL : `DATE_TRUNC('month', order_date)` → `DATE_FORMAT(order_date, '%Y-%m-01')`
   - SQL Server : `DATE_TRUNC` → `DATEADD(month, DATEDIFF(month, 0, order_date), 0)`
   - `EXTRACT(YEAR FROM …)` est standard partout.

## Fichiers

| Fichier | Contenu | Pendant DAX |
|---|---|---|
| `01_kpi_globaux.sql` | CA, profit, frais de port, commandes, panier moyen, marge | `CA`, `Profit`, `Nb Orders`, `AOV`, `Taux de Marge %` |
| `02_evolution_annuelle.sql` | CA et indicateurs par année + variation N-1 | `CA LY`, `CA YOY %` |
| `03_repartitions.sql` | CA par région, segment, catégorie, méthode de paiement, pays | graphiques du Dashboard |
| `04_clients.sql` | clients, nouveaux clients, rétention / churn mensuels, statut, classement | dossier `Customers` |
| `05_produits.sql` | produits, CA / profit moyens, taux de marge, part du CA, top 5 | dossier `Products` |
| `06_paiements.sql` | indicateurs par méthode de paiement | dossier `Payments\kpi1-3` |
| `07_controles_qualite.sql` | unicité des clés, valeurs vides, cohérence des montants | section Contrôles qualité |
