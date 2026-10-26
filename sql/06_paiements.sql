-- ============================================================================
-- 06 · Indicateurs par méthode de paiement (dossier "Payments" du modèle)
-- ============================================================================
-- Une commande = un paiement : Nb Paiements = Nb Orders.
-- Attendu 2025 (page Paiement) : 681 paiements · CA moyen 242,24
--   profit moyen 79,45 · CA : Credit Card ~58,7 K · PayPal ~51,5 K
--   Bank Transfer ~30,3 K · Cash on Delivery ~24,5 K

SELECT
    payment_method,
    COUNT(DISTINCT order_id)                                  AS nb_paiements,
    ROUND(SUM(total_sales), 2)                                AS ca,
    ROUND(SUM(total_sales) / COUNT(DISTINCT order_id), 2)     AS ca_moyen_paiement,
    ROUND(SUM(profit), 2)                                     AS profit,
    ROUND(SUM(profit) / COUNT(DISTINCT order_id), 2)          AS profit_moyen_paiement,
    ROUND(SUM(total_sales) / SUM(SUM(total_sales)) OVER (), 4) AS part_du_ca
FROM global_ecommerce_sales
WHERE EXTRACT(YEAR FROM order_date) = 2025
GROUP BY payment_method
ORDER BY ca DESC;

-- Variation annuelle du CA par méthode de paiement (pendant des mesures *_LY)

SELECT
    payment_method,
    EXTRACT(YEAR FROM order_date)::INT  AS annee,
    ROUND(SUM(total_sales), 2)          AS ca,
    ROUND(SUM(profit), 2)               AS profit
FROM global_ecommerce_sales
GROUP BY payment_method, annee
ORDER BY payment_method, annee;
