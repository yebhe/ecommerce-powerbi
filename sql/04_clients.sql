-- ============================================================================
-- 04 · Indicateurs clients (dossier "Customers" du modèle)
-- ============================================================================

-- 4.1 · KPI clients 2025 : nb clients, CA moyen par client
-- Attendu : 635 clients · CA moyen 259,79 · nouveaux clients 426

SELECT
    COUNT(DISTINCT customer_name)                       AS nb_clients,
    ROUND(SUM(total_sales), 2)                          AS ca,
    ROUND(SUM(total_sales) / COUNT(DISTINCT customer_name), 2) AS ca_moyen_par_client
FROM global_ecommerce_sales
WHERE EXTRACT(YEAR FROM order_date) = 2025;

-- 4.2 · Top 5 clients par CA en 2025 — "Top 5 clients"
-- Attendu : Wei Jackson 2 566,56 · Jamal Hassan 2 327,47 · Joseph Weber ~2 287
--           Lucas Nilsson 2 164,33 · Ivan Santos 2 069,76

SELECT
    customer_name,
    ROUND(SUM(total_sales), 2)   AS ca,
    COUNT(DISTINCT order_id)     AS nb_commandes,
    ROUND(SUM(profit), 2)        AS profit
FROM global_ecommerce_sales
WHERE EXTRACT(YEAR FROM order_date) = 2025
GROUP BY customer_name
ORDER BY ca DESC
LIMIT 5;

-- 4.3 · Nouveaux clients en 2025 — clients dont la 1ʳᵉ commande tombe en 2025
-- Pendant DAX : Nb Nouveaux Clients (MIN(Order_Date) global ∈ période)
-- Attendu : 426

SELECT COUNT(*) AS nb_nouveaux_clients_2025
FROM (
    SELECT customer_name
    FROM global_ecommerce_sales
    GROUP BY customer_name
    HAVING MIN(order_date) >= DATE '2025-01-01'
) t;

-- 4.4 · Rétention et churn mensuels — clients du mois présents le mois précédent
-- Pendant DAX : Nb Clients Retenu / Churn / Taux de Retention % / Taux de Churn %
-- (INTERSECT / EXCEPT avec DATEADD(-1 MONTH))
-- Attendu (carte du rapport, dernier mois) : rétention ≈ 93,5 % · churn ≈ 6,5 %

WITH clients_mois AS (
    SELECT DISTINCT
        DATE_TRUNC('month', order_date)::DATE AS mois,
        customer_name
    FROM global_ecommerce_sales
),
par_mois AS (
    SELECT mois, COUNT(*) AS nb_clients
    FROM clients_mois
    GROUP BY mois
),
retenu AS (
    SELECT c.mois, COUNT(*) AS nb_retenu
    FROM clients_mois c
    JOIN clients_mois p
      ON p.customer_name = c.customer_name
     AND p.mois = c.mois - INTERVAL '1 month'
    GROUP BY c.mois
)
SELECT
    m.mois,
    m.nb_clients,
    LAG(m.nb_clients) OVER (ORDER BY m.mois)                    AS clients_mois_prec,
    COALESCE(r.nb_retenu, 0)                                    AS clients_retenus,
    ROUND(COALESCE(r.nb_retenu, 0)::NUMERIC
          / LAG(m.nb_clients) OVER (ORDER BY m.mois), 4)        AS taux_retention,
    LAG(m.nb_clients) OVER (ORDER BY m.mois)
        - COALESCE(r.nb_retenu, 0)                              AS clients_churn
FROM par_mois m
LEFT JOIN retenu r ON r.mois = m.mois
ORDER BY m.mois;

-- 4.5 · Jours depuis la dernière commande et statut client
-- Pendant DAX : Jours depuis dernière commande / Statut Client
-- Référence = date max du jeu (31/12/2025), comme dans le modèle

WITH derniere AS (
    SELECT
        customer_name,
        MAX(order_date) AS derniere_commande
    FROM global_ecommerce_sales
    GROUP BY customer_name
),
date_max AS (
    SELECT MAX(order_date) AS globale FROM global_ecommerce_sales
)
SELECT
    d.customer_name,
    d.derniere_commande,
    x.globale - d.derniere_commande AS jours_depuis_derniere_commande,
    CASE
        WHEN x.globale - d.derniere_commande > 20 THEN 'À risque'
        WHEN x.globale - d.derniere_commande > 10 THEN 'À surveiller'
        ELSE 'Actif'
    END AS statut_client
FROM derniere d
CROSS JOIN date_max x
ORDER BY jours_depuis_derniere_commande DESC;

-- 4.6 · Classement des clients par CA — pendant DAX : Classement des Clients par CA
-- À utiliser au niveau client : groupé par segment ou pays, le rang vaut 1 partout
-- (le total du groupe dépasse chaque client — cf. limites connues du README)

SELECT
    customer_name,
    customer_segment,
    ROUND(SUM(total_sales), 2)                                   AS ca,
    RANK() OVER (ORDER BY SUM(total_sales) DESC)                 AS rang_ca
FROM global_ecommerce_sales
WHERE EXTRACT(YEAR FROM order_date) = 2025
GROUP BY customer_name, customer_segment
ORDER BY rang_ca;
