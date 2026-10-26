-- ============================================================================
-- 03 · Répartitions du CA (toute la période)
-- ============================================================================

-- 3.1 · CA par région — graphique "Ventes par région"
-- Attendu : Europe 137 006 (28,3 %) · North America 133 876 (27,6 %)
--           Asia Pacific 121 708 (25,1 %) · South America 46 051 (9,5 %)
--           Middle East & Africa 45 918 (9,5 %)

SELECT
    region,
    ROUND(SUM(total_sales), 2)                                AS ca,
    ROUND(SUM(profit), 2)                                     AS profit,
    ROUND(SUM(total_sales) / SUM(SUM(total_sales)) OVER (), 4) AS part_du_ca
FROM global_ecommerce_sales
GROUP BY region
ORDER BY ca DESC;

-- 3.2 · CA par segment client — "Ventes par segment client"
-- Attendu : Consumer 256 288 (52,9 %) · Corporate 146 050 (30,1 %)
--           Home Office 82 221 (17,0 %)

SELECT
    customer_segment,
    ROUND(SUM(total_sales), 2)                                 AS ca,
    ROUND(SUM(profit), 2)                                      AS profit,
    ROUND(SUM(total_sales) / SUM(SUM(total_sales)) OVER (), 4) AS part_du_ca,
    COUNT(DISTINCT customer_name)                              AS nb_clients
FROM global_ecommerce_sales
GROUP BY customer_segment
ORDER BY ca DESC;

-- 3.3 · CA par catégorie de produit — "Ventes par catégorie de produit"
-- Attendu : Furniture 256 275 (52,9 %) · Technology 139 518 (28,8 %)
--           Clothing & Accessories 69 376 (14,3 %) · Office Supplies 19 391 (4,0 %)

SELECT
    product_category,
    ROUND(SUM(total_sales), 2)                                 AS ca,
    ROUND(SUM(profit), 2)                                      AS profit,
    ROUND(SUM(profit) / SUM(total_sales), 4)                   AS taux_de_marge,
    ROUND(SUM(total_sales) / SUM(SUM(total_sales)) OVER (), 4) AS part_du_ca
FROM global_ecommerce_sales
GROUP BY product_category
ORDER BY ca DESC;

-- 3.4 · CA par méthode de paiement — "Répartition du CA par méthode de paiement"
-- Attendu : Credit Card 192 718 (39,8 %) · PayPal 143 113 (29,5 %)
--           Cash on Delivery 77 130 (15,9 %) · Bank Transfer 71 599 (14,8 %)

SELECT
    payment_method,
    COUNT(DISTINCT order_id)                                   AS nb_paiements,
    ROUND(SUM(total_sales), 2)                                 AS ca,
    ROUND(SUM(total_sales) / SUM(SUM(total_sales)) OVER (), 4) AS part_du_ca
FROM global_ecommerce_sales
GROUP BY payment_method
ORDER BY ca DESC;

-- 3.5 · Top 10 pays par CA — "Ventes par pays"

SELECT
    country,
    region,
    ROUND(SUM(total_sales), 2)   AS ca,
    COUNT(DISTINCT order_id)     AS nb_commandes
FROM global_ecommerce_sales
GROUP BY country, region
ORDER BY ca DESC
LIMIT 10;
