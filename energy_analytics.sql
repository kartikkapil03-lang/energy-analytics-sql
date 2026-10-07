-- ============================================================
-- ENERGY CONSUMPTION, PRODUCTION & SUSTAINABILITY ANALYTICS
-- Portfolio SQL Project | MySQL
-- ============================================================
-- Dataset:
--   100 customers
--   10,000 energy consumption records
--   10,000 energy production records
--   10 production plants
--   20 sustainability initiatives
--
-- Core SQL demonstrated:
--   JOINs | Aggregations | CTEs | RANK | ROW_NUMBER
--   LAG / LEAD | Window SUM | Conditional aggregation
--
-- Portfolio note:
-- Queries are organized around business questions rather than
-- the original assignment numbering.
-- ============================================================


-- ============================================================
-- 1. CUSTOMER DEMAND ANALYTICS
-- ============================================================

-- Q1. Which customer segments account for the most energy demand?
SELECT
    c.segment,
    COUNT(DISTINCT c.customer_id) AS customer_count,
    ROUND(SUM(ec.amount_kwh), 2) AS total_consumption_kwh,
    ROUND(
        100 * SUM(ec.amount_kwh) /
        SUM(SUM(ec.amount_kwh)) OVER (),
        2
    ) AS consumption_share_pct,
    ROUND(
        SUM(ec.amount_kwh) / COUNT(DISTINCT c.customer_id),
        2
    ) AS avg_kwh_per_customer
FROM customers c
JOIN energy_consumption ec
    ON c.customer_id = ec.customer_id
GROUP BY c.segment
ORDER BY total_consumption_kwh DESC;


-- Q2. How does each customer's cumulative consumption change over time?
SELECT
    consumption_id,
    customer_id,
    date,
    energy_type,
    amount_kwh,
    ROUND(
        SUM(amount_kwh) OVER (
            PARTITION BY customer_id
            ORDER BY date, consumption_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ),
        2
    ) AS cumulative_consumption_kwh
FROM energy_consumption
ORDER BY customer_id, date, consumption_id;


-- Q3. Which customers have the highest total and average monthly consumption?
WITH customer_months AS (
    SELECT
        customer_id,
        DATE_FORMAT(date, '%Y-%m') AS month,
        SUM(amount_kwh) AS monthly_consumption_kwh
    FROM energy_consumption
    GROUP BY customer_id, DATE_FORMAT(date, '%Y-%m')
),
customer_summary AS (
    SELECT
        customer_id,
        ROUND(SUM(monthly_consumption_kwh), 2) AS total_consumption_kwh,
        ROUND(AVG(monthly_consumption_kwh), 2) AS avg_monthly_consumption_kwh,
        COUNT(*) AS active_months
    FROM customer_months
    GROUP BY customer_id
)
SELECT
    cs.customer_id,
    c.name,
    c.segment,
    cs.total_consumption_kwh,
    cs.avg_monthly_consumption_kwh,
    cs.active_months
FROM customer_summary cs
JOIN customers c
    ON cs.customer_id = c.customer_id
ORDER BY cs.total_consumption_kwh DESC;


-- Q4. What does the 2023 monthly consumption trend look like for each customer?
-- This replaces a weaker first-vs-last-observation comparison with a true monthly trend.
SELECT
    customer_id,
    DATE_FORMAT(date, '%Y-%m') AS month,
    ROUND(SUM(amount_kwh), 2) AS monthly_consumption_kwh
FROM energy_consumption
WHERE date >= '2023-01-01'
  AND date <  '2024-01-01'
GROUP BY customer_id, DATE_FORMAT(date, '%Y-%m')
ORDER BY customer_id, month;


-- ============================================================
-- 2. PRODUCTION ANALYTICS
-- ============================================================

-- Q5. What is the production mix by energy source?
SELECT
    energy_type,
    ROUND(SUM(amount_kwh), 2) AS total_production_kwh,
    ROUND(
        100 * SUM(amount_kwh) /
        SUM(SUM(amount_kwh)) OVER (),
        2
    ) AS production_share_pct,
    ROUND(SUM(cost_usd), 2) AS total_production_cost_usd,
    ROUND(SUM(cost_usd) / NULLIF(SUM(amount_kwh), 0), 4) AS cost_per_kwh
FROM energy_production
GROUP BY energy_type
ORDER BY total_production_kwh DESC;


-- Q6. Which individual production records are the highest within each energy type?
-- Important: this ranks production EVENTS/RECORDS, not overall plant performance.
WITH ranked_production AS (
    SELECT
        production_id,
        production_plant_id,
        date,
        energy_type,
        amount_kwh,
        RANK() OVER (
            PARTITION BY energy_type
            ORDER BY amount_kwh DESC
        ) AS production_rank
    FROM energy_production
)
SELECT
    production_id,
    production_plant_id,
    date,
    energy_type,
    amount_kwh,
    production_rank
FROM ranked_production
WHERE production_rank <= 3
ORDER BY energy_type, production_rank, production_id;


-- Q7. How does monthly production change for each plant?
WITH monthly_plant_production AS (
    SELECT
        production_plant_id,
        DATE_FORMAT(date, '%Y-%m-01') AS month,
        ROUND(SUM(amount_kwh), 2) AS current_month_production_kwh
    FROM energy_production
    GROUP BY
        production_plant_id,
        DATE_FORMAT(date, '%Y-%m-01')
),
production_changes AS (
    SELECT
        production_plant_id,
        month,
        current_month_production_kwh,
        LAG(current_month_production_kwh) OVER (
            PARTITION BY production_plant_id
            ORDER BY month
        ) AS previous_month_production_kwh,
        LEAD(current_month_production_kwh) OVER (
            PARTITION BY production_plant_id
            ORDER BY month
        ) AS next_month_production_kwh
    FROM monthly_plant_production
)
SELECT
    production_plant_id,
    month,
    current_month_production_kwh,
    previous_month_production_kwh,
    next_month_production_kwh,
    ROUND(
        100 * (
            current_month_production_kwh - previous_month_production_kwh
        ) / NULLIF(previous_month_production_kwh, 0),
        2
    ) AS mom_change_pct
FROM production_changes
ORDER BY production_plant_id, month;


-- Q8. Which plants rank highest by TOTAL monthly production?
-- The original assignment used AVG(record amount); SUM is the more direct plant-output KPI.
WITH monthly_plant_production AS (
    SELECT
        production_plant_id,
        DATE_FORMAT(date, '%Y-%m') AS month,
        ROUND(SUM(amount_kwh), 2) AS monthly_production_kwh
    FROM energy_production
    GROUP BY production_plant_id, DATE_FORMAT(date, '%Y-%m')
),
ranked_plants AS (
    SELECT
        production_plant_id,
        month,
        monthly_production_kwh,
        RANK() OVER (
            PARTITION BY month
            ORDER BY monthly_production_kwh DESC
        ) AS monthly_rank
    FROM monthly_plant_production
)
SELECT
    rp.production_plant_id,
    pp.plant_name,
    rp.month,
    rp.monthly_production_kwh,
    rp.monthly_rank
FROM ranked_plants rp
JOIN production_plants pp
    ON rp.production_plant_id = pp.plant_id
ORDER BY rp.month, rp.monthly_rank, rp.production_plant_id;


-- ============================================================
-- 3. CARBON & SUSTAINABILITY ANALYTICS
-- ============================================================

-- Q9. Which plants have the highest carbon-emission intensity?
SELECT
    pp.plant_id,
    pp.plant_name,
    pp.location,
    pp.energy_type AS primary_energy_type,
    ROUND(SUM(ep.carbon_emission_kg), 2) AS total_emissions_kg,
    ROUND(SUM(ep.amount_kwh), 2) AS total_production_kwh,
    ROUND(
        SUM(ep.carbon_emission_kg) /
        NULLIF(SUM(ep.amount_kwh), 0),
        4
    ) AS carbon_kg_per_kwh
FROM production_plants pp
JOIN energy_production ep
    ON pp.plant_id = ep.production_plant_id
GROUP BY
    pp.plant_id,
    pp.plant_name,
    pp.location,
    pp.energy_type
ORDER BY carbon_kg_per_kwh DESC
LIMIT 5;


-- Q10. Which plants contribute the most TOTAL emissions?
SELECT
    pp.plant_id,
    pp.plant_name,
    ROUND(AVG(ep.carbon_emission_kg), 2) AS avg_emissions_per_record_kg,
    ROUND(SUM(ep.carbon_emission_kg), 2) AS total_emissions_kg,
    ROUND(
        SUM(ep.carbon_emission_kg) /
        NULLIF(SUM(ep.amount_kwh), 0),
        4
    ) AS carbon_kg_per_kwh
FROM production_plants pp
JOIN energy_production ep
    ON pp.plant_id = ep.production_plant_id
GROUP BY pp.plant_id, pp.plant_name
ORDER BY total_emissions_kg DESC;


-- Q11. How do energy sources compare on output, cost and carbon intensity?
SELECT
    energy_type,
    ROUND(SUM(amount_kwh), 2) AS total_production_kwh,
    ROUND(
        100 * SUM(amount_kwh) /
        SUM(SUM(amount_kwh)) OVER (),
        2
    ) AS production_share_pct,
    ROUND(SUM(cost_usd), 2) AS total_cost_usd,
    ROUND(SUM(cost_usd) / NULLIF(SUM(amount_kwh), 0), 4) AS cost_per_kwh,
    ROUND(SUM(carbon_emission_kg), 2) AS total_emissions_kg,
    ROUND(
        100 * SUM(carbon_emission_kg) /
        SUM(SUM(carbon_emission_kg)) OVER (),
        2
    ) AS emission_share_pct,
    ROUND(
        SUM(carbon_emission_kg) /
        NULLIF(SUM(amount_kwh), 0),
        4
    ) AS carbon_kg_per_kwh
FROM energy_production
GROUP BY energy_type
ORDER BY total_production_kwh DESC;


-- Q12. Which sustainability initiatives generate the largest energy savings?
SELECT
    initiative_id,
    initiative_name,
    start_date,
    end_date,
    ROUND(energy_savings_kwh, 2) AS energy_savings_kwh,
    RANK() OVER (
        ORDER BY energy_savings_kwh DESC
    ) AS savings_rank
FROM sustainability_initiatives
ORDER BY savings_rank, initiative_id;


-- Q13. Which initiatives are most efficient relative to budget?
SELECT
    initiative_id,
    initiative_name,
    ROUND(budget_usd, 2) AS budget_usd,
    ROUND(energy_savings_kwh, 2) AS energy_savings_kwh,
    ROUND(
        energy_savings_kwh / NULLIF(budget_usd, 0),
        4
    ) AS kwh_saved_per_budget_dollar,
    ROUND(carbon_reduction_kg, 2) AS carbon_reduction_kg
FROM sustainability_initiatives
ORDER BY kwh_saved_per_budget_dollar DESC;


-- Q14. How quickly do sustainability initiatives deliver savings?
-- Duration is standardized in DAYS to avoid zero/partial-month issues.
SELECT
    initiative_id,
    initiative_name,
    start_date,
    end_date,
    DATEDIFF(end_date, start_date) + 1 AS duration_days,
    ROUND(energy_savings_kwh, 2) AS total_energy_savings_kwh,
    ROUND(
        energy_savings_kwh /
        NULLIF(DATEDIFF(end_date, start_date) + 1, 0),
        2
    ) AS avg_daily_savings_kwh,
    ROUND(
        (
            energy_savings_kwh /
            NULLIF(DATEDIFF(end_date, start_date) + 1, 0)
        ) * 30.44,
        2
    ) AS estimated_avg_monthly_savings_kwh
FROM sustainability_initiatives
ORDER BY estimated_avg_monthly_savings_kwh DESC;


-- ============================================================
-- END OF PORTFOLIO ANALYSIS
-- ============================================================
