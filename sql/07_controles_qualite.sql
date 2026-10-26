-- ============================================================================
-- 07 · Contrôles qualité — même périmètre que la section du README
-- ============================================================================
-- Tous les contrôles doivent renvoyer 0 anomalie, sauf les ventes à perte (272).
-- ============================================================================

-- 7.1 · Unicité de la clé de commande — attendu : 0 doublon

SELECT
    COUNT(*) AS nb_lignes,                       -- 2 000
    COUNT(DISTINCT order_id) AS ids_distincts,   -- 2 000
    COUNT(*) - COUNT(DISTINCT order_id) AS doublons
FROM global_ecommerce_sales;

-- 7.2 · Valeurs vides — attendu : 0 partout

SELECT
    COUNT(*) FILTER (WHERE order_id         IS NULL OR order_id = '')         AS order_id_vide,
    COUNT(*) FILTER (WHERE order_date       IS NULL)                          AS order_date_vide,
    COUNT(*) FILTER (WHERE customer_name    IS NULL OR customer_name = '')    AS client_vide,
    COUNT(*) FILTER (WHERE product_name     IS NULL OR product_name = '')     AS produit_vide,
    COUNT(*) FILTER (WHERE country          IS NULL OR country = '')          AS pays_vide,
    COUNT(*) FILTER (WHERE payment_method   IS NULL OR payment_method = '')   AS paiement_vide,
    COUNT(*) FILTER (WHERE total_sales      IS NULL)                          AS ca_vide,
    COUNT(*) FILTER (WHERE profit           IS NULL)                          AS profit_vide
FROM global_ecommerce_sales;

-- 7.3 · Cohérence : Total_Sales = Quantity × Unit_Price × (1 - remise)
-- attendu : 0 écart (tolérance 5 centimes)

SELECT COUNT(*) AS ecarts_ca
FROM global_ecommerce_sales
WHERE ABS(quantity * unit_price * (1 - discount_percent / 100.0) - total_sales) > 0.05;

-- 7.4 · Plausibilité des montants
-- attendu : profit_negatif = 272 (ventes à perte), les autres = 0

SELECT
    COUNT(*) FILTER (WHERE profit < 0)              AS profit_negatif,   -- 272
    COUNT(*) FILTER (WHERE profit > total_sales)    AS profit_gt_ca,     -- 0
    COUNT(*) FILTER (WHERE shipping_cost < 0)       AS shipping_negatif, -- 0
    COUNT(*) FILTER (WHERE quantity <= 0)           AS quantite_nulle,   -- 0
    COUNT(*) FILTER (WHERE discount_percent NOT IN (0,5,10,15,20,25,30)) AS remise_hors_barème -- 0
FROM global_ecommerce_sales;

-- 7.5 · Période couverte — attendu : 02/01/2023 → 31/12/2025 (1 095 jours)

SELECT
    MIN(order_date)               AS premiere_commande,
    MAX(order_date)               AS derniere_commande,
    MAX(order_date) - MIN(order_date) + 1 AS jours_calendrier
FROM global_ecommerce_sales;
