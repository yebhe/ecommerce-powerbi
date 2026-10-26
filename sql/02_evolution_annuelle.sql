-- ============================================================================
-- 02 · Évolution annuelle : CA, profit, commandes + variation vs N-1
-- ============================================================================
-- Pendant DAX : CA LY / CA YOY % (SAMEPERIODLASTYEAR)
-- Attendu :
--   2023 : 164 443 | 2024 : 155 151 (-5,7 %) | 2025 : 164 965 (+6,3 %)
-- ============================================================================

WITH annuel AS (
    SELECT
        EXTRACT(YEAR FROM order_date)::INT      AS annee,
        SUM(total_sales)                        AS ca,
        SUM(profit)                             AS profit,
        COUNT(DISTINCT order_id)                AS nb_commandes,
        COUNT(DISTINCT customer_name)           AS nb_clients
    FROM global_ecommerce_sales
    GROUP BY 1
)
SELECT
    annee,
    ROUND(ca, 2)                                                    AS ca,
    ROUND(profit, 2)                                                AS profit,
    nb_commandes,
    nb_clients,
    ROUND(LAG(ca) OVER (ORDER BY annee), 2)                         AS ca_n1,
    ROUND(ca / LAG(ca) OVER (ORDER BY annee) - 1, 4)                AS ca_yoy
FROM annuel
ORDER BY annee;

-- Évolution mensuelle 2025 (courbe "Évolution des ventes" du Dashboard)
-- Attendu (extrait) : janv 12 320 · févr 7 340 · mars 7 770 · avr 16 400 · mai 17 620 …

SELECT
    DATE_TRUNC('month', order_date)::DATE   AS mois,
    ROUND(SUM(total_sales), 2)              AS ca,
    ROUND(SUM(profit), 2)                   AS profit,
    COUNT(DISTINCT order_id)                AS nb_commandes
FROM global_ecommerce_sales
WHERE EXTRACT(YEAR FROM order_date) = 2025
GROUP BY 1
ORDER BY 1;
