-- ============================================================================
-- 01 · KPI globaux du dashboard (sans filtre, toute la période 2023-2025)
-- ============================================================================
-- Attendu :
--   CA total      = 484 559,34
--   Profit        = 158 872,32
--   Frais de port = 25 804
--   Commandes     = 2 000
--   Panier moyen  = 242,28
--   Taux de marge = 0,328 (32,8 %)
--   Clients       = 1 534
--   Produits      = 40
-- ============================================================================

SELECT
    ROUND(SUM(total_sales), 2)                                   AS ca_total,
    ROUND(SUM(profit), 2)                                        AS profit_total,
    ROUND(SUM(shipping_cost), 2)                                 AS frais_de_port,
    COUNT(DISTINCT order_id)                                     AS nb_commandes,
    ROUND(SUM(total_sales) / COUNT(DISTINCT order_id), 2)        AS panier_moyen,
    ROUND(SUM(profit) / SUM(total_sales), 4)                     AS taux_de_marge,
    COUNT(DISTINCT customer_name)                                AS nb_clients,
    COUNT(DISTINCT product_name)                                 AS nb_produits,
    COUNT(DISTINCT country)                                      AS nb_pays
FROM global_ecommerce_sales;

-- Même résultat filtré sur l'année 2025 (page Dashboard du rapport) :
--   CA = 164 965 · Profit = 54 102 · Commandes = 681 · Panier moyen = 242,24

SELECT
    ROUND(SUM(total_sales), 2)                                   AS ca_2025,
    ROUND(SUM(profit), 2)                                        AS profit_2025,
    COUNT(DISTINCT order_id)                                     AS nb_commandes_2025,
    ROUND(SUM(total_sales) / COUNT(DISTINCT order_id), 2)        AS panier_moyen_2025,
    COUNT(DISTINCT customer_name)                                AS nb_clients_2025
FROM global_ecommerce_sales
WHERE EXTRACT(YEAR FROM order_date) = 2025;
