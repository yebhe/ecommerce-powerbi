-- ============================================================================
-- 05 · Indicateurs produits (dossier "Products" du modèle)
-- ============================================================================

-- 5.1 · KPI produits 2025 : nb produits vendus, CA moyen, profit moyen, marge
-- Attendu : 40 produits · CA moyen 4 124,13 · profit moyen 1 352,56 · marge 32,8 %

SELECT
    COUNT(DISTINCT product_name)                                     AS nb_produits,
    ROUND(SUM(total_sales) / COUNT(DISTINCT product_name), 2)        AS ca_moyen_par_produit,
    ROUND(SUM(profit) / COUNT(DISTINCT product_name), 2)             AS profit_moyen_produit,
    ROUND(SUM(profit) / SUM(total_sales), 4)                         AS taux_de_marge
FROM global_ecommerce_sales
WHERE EXTRACT(YEAR FROM order_date) = 2025;

-- 5.2 · Top 5 produits par CA en 2025 — "Top 5 produits"
-- Attendu : Standing Desk Converter ~17,3 K · Ergonomic Office Chair ~15,2 K
--           Wireless Bluetooth Headphones ~14,0 K · Mesh Back Task Chair ~13,0 K
--           Filing Cabinet 3-Drawer ~9,8 K

SELECT
    product_name,
    product_category,
    ROUND(SUM(total_sales), 2)                                   AS ca,
    ROUND(SUM(profit), 2)                                        AS profit,
    ROUND(SUM(profit) / SUM(total_sales), 4)                     AS taux_de_marge,
    ROUND(SUM(total_sales) / SUM(SUM(total_sales)) OVER (), 4)   AS part_du_ca
FROM global_ecommerce_sales
WHERE EXTRACT(YEAR FROM order_date) = 2025
GROUP BY product_name, product_category
ORDER BY ca DESC
LIMIT 5;

-- 5.3 · Part du CA de chaque produit (toute la période)
-- Pendant DAX : Part du produit CA = CA / CA tous produits

SELECT
    product_name,
    ROUND(SUM(total_sales), 2)                                   AS ca,
    ROUND(SUM(total_sales) / SUM(SUM(total_sales)) OVER (), 4)   AS part_du_ca
FROM global_ecommerce_sales
GROUP BY product_name
ORDER BY part_du_ca DESC;

-- 5.4 · Produits vendus à perte — 272 lignes de commande à profit < 0 au total
-- Utile pour la piste d'amélioration "creuser les ventes à perte"

SELECT
    product_name,
    product_category,
    COUNT(*)                     AS lignes_a_perte,
    ROUND(SUM(profit), 2)        AS profit_cumule_a_perte
FROM global_ecommerce_sales
WHERE profit < 0
GROUP BY product_name, product_category
ORDER BY profit_cumule_a_perte
LIMIT 10;
