# Energy Consumption, Production & Sustainability Analytics

## Project Overview

This project analyzes an energy company’s customer demand, production performance, operating cost, carbon emissions, and sustainability initiatives using MySQL.

The goal is to connect the **demand side** of the business with the **supply and sustainability side** so that management can understand:

- Which customer segments drive the most energy consumption
- How production is distributed across energy sources and plants
- How plant output changes over time
- Which plants and energy sources have the highest carbon impact
- Which sustainability initiatives deliver the strongest measurable savings
- Where operational and sustainability priorities should be focused

---

## Business Problem

The company wants a clearer view of how energy is consumed, produced, and managed across the organization.

The analysis focuses on four business questions:

1. **Customer Demand** — Who consumes the most energy and where is demand concentrated?
2. **Production Performance** — How much energy is produced, by which sources, and how does plant output change over time?
3. **Carbon Efficiency** — Which plants and energy sources create the greatest environmental impact?
4. **Sustainability Effectiveness** — Which initiatives generate the strongest energy savings and budget efficiency?

---

## Dataset

The project uses five related datasets:

| Dataset | Description |
|---|---|
| `customers` | Customer profile, segment, address, and join date |
| `energy_consumption` | Customer-level energy usage and cost records |
| `energy_production` | Plant-level production, cost, and carbon-emission records |
| `production_plants` | Production plant details, capacity, location, and energy type |
| `sustainability_initiatives` | Sustainability programmes, budgets, savings, and carbon reduction |

### Dataset Scale

- **100 customers**
- **10,000 consumption records**
- **10,000 production records**
- **10 production plants**
- **20 sustainability initiatives**
- Analysis period: **May 2021 – May 2024**

---

## Tools & SQL Techniques

**Database:** MySQL

SQL concepts demonstrated:

- Multi-table `JOIN`s
- Aggregations using `SUM`, `AVG`, `COUNT`
- Common Table Expressions (`CTEs`)
- Window functions
- `RANK()`
- `ROW_NUMBER()`
- `LAG()` and `LEAD()`
- Running totals
- Conditional and ratio-based calculations
- Monthly time-series analysis
- KPI and business-metric construction

---

## Analysis Structure

### 1. Customer Demand Analytics

The customer analysis evaluates:

- Consumption by customer segment
- Cumulative customer energy usage
- Total and average monthly consumption
- High-consumption customers
- Monthly consumption trends

### 2. Production Analytics

The production analysis covers:

- Production mix by energy source
- Production cost per kWh
- Top production records within each energy type
- Monthly plant production
- Month-on-month production changes
- Plant rankings based on total monthly production

### 3. Carbon & Sustainability Analytics

The sustainability analysis evaluates:

- Plant-level carbon intensity
- Total plant emissions
- Carbon intensity by energy source
- Production share vs emission share
- Sustainability initiative rankings
- Energy savings relative to programme budget
- Time-adjusted savings performance

---

## Key Insights

### 1. Industrial customers dominate energy demand

Industrial customers represent **36% of the customer base** but account for approximately **62.8% of total recorded energy consumption**.

This makes the industrial segment the strongest target for demand-management and energy-efficiency initiatives.

---

### 2. Electricity and gas demand are almost evenly split

Customer-side consumption is approximately:

- **Electricity:** 3.61M kWh
- **Gas:** 3.59M kWh

Their aggregate recorded cost per kWh is also very similar.

---

### 3. Electricity is the largest production source

Electricity contributes approximately **47.2% of total production**.

Coal and gas each contribute roughly one-quarter, while wind accounts for approximately **5.6%**.

---

### 4. Wind stands out on both cost and carbon efficiency

Wind represents only around **5.6% of total production**, but contributes roughly **0.6% of recorded production emissions**.

Its recorded carbon intensity is around one-tenth of the other energy sources in the dataset.

Wind also has the lowest recorded production cost per kWh:

- **Wind:** ~\$0.035/kWh
- **Coal / Gas / Electricity:** ~\$0.10/kWh

This makes wind distinct on both environmental and recorded operating-cost metrics.

---

### 5. Carbon priority depends on the metric used

The plant with the highest **carbon intensity** is not necessarily the plant with the highest **total emissions**.

This is important because:

- **Total emissions** show absolute environmental impact.
- **Emissions per kWh** show relative carbon efficiency.

Both metrics should be reviewed together when prioritizing environmental improvements.

---

### 6. Monthly plant output varies meaningfully

Using monthly aggregation with `LAG()` and `LEAD()` allows production changes to be identified for each plant.

The SQL can identify **where and when production changed**, but the dataset does not contain enough operational information to determine whether the cause was maintenance, weather, outages, capacity limitations, or dispatch decisions.

---

### 7. Sustainability initiatives differ significantly in performance

The strongest initiative generated approximately **95.6K kWh in energy savings**.

Initiatives become more useful for management comparison when evaluated using several measures rather than total savings alone:

- Total energy savings
- Savings per budget dollar
- Duration-adjusted savings
- Carbon reduction

---

## Business Recommendations

### Prioritize industrial demand-management initiatives

Because industrial customers account for the majority of recorded consumption, efficiency programmes focused on this group have the greatest potential to influence total demand.

### Monitor plant performance using monthly KPIs

Plant output should be reviewed using monthly production and month-on-month change metrics so that unusual movements can be investigated early.

### Evaluate carbon performance using both total emissions and intensity

Plants should not be prioritized using only one environmental metric.

A high-output plant may have high total emissions while still being relatively efficient on a per-kWh basis.

### Evaluate sustainability programmes using multiple KPIs

Management should combine:

- Energy savings
- Budget efficiency
- Duration-adjusted savings
- Carbon reduction

rather than ranking initiatives using total savings alone.

### Investigate the scalability of wind production

Wind performs strongly on both recorded cost per kWh and carbon intensity in this dataset.

However, investment decisions would require additional information such as capital cost, plant capacity, reliability, capacity factor, and grid constraints.

---

## Analytical Improvements Made

The original case-study questions were refined before being presented as a portfolio project.

Key improvements include:

- Reframed “best plants” as **top production records** where the SQL ranks individual records rather than aggregated plant performance.
- Replaced average production-record values with **total monthly plant production** where plant output is the intended KPI.
- Replaced a first-vs-last observation comparison with a **true monthly consumption trend**.
- Separated **total carbon emissions** from **carbon intensity per kWh**.
- Standardized sustainability duration using days before calculating time-adjusted savings.

These refinements ensure that the SQL calculation matches the actual business question.

---

## Limitations

The analysis is based only on the fields available in the source datasets.

The project does **not** contain:

- Plant outage or maintenance data
- Weather conditions
- Capacity-utilization history
- Electricity dispatch data
- Capital expenditure for energy technologies
- Customer tariff or pricing-plan details
- External sustainability benchmarks

Therefore, the SQL can identify patterns and performance differences but cannot always explain the operational cause behind them.

---

## Repository Structure

```text
energy-analytics-sql/
│
├── README.md
├── energy_analytics.sql
│
├── data/
│   ├── customers.csv
│   ├── energy_consumption.csv
│   ├── energy_production.csv
│   ├── production_plants.csv
│   └── sustainability_initiatives.csv
│
└── docs/
    └── insights.md
```

---

## Portfolio Positioning

This project is presented as an **end-to-end energy analytics case study**, rather than a collection of disconnected SQL exercises.

It demonstrates the ability to:

- Understand a relational business dataset
- Translate business questions into SQL analysis
- Use intermediate and advanced SQL techniques
- Build meaningful KPIs
- Distinguish between similar but different metrics
- Convert technical outputs into business recommendations

---

## Next Upgrade

The next stage of the project is to extend the SQL analysis into **Power BI** using a simple analytical model:

- `Customers` — Dimension
- `Production Plants` — Dimension
- `Date` — Dimension
- `Energy Consumption` — Fact
- `Energy Production` — Fact
- `Sustainability Initiatives` — Supporting table

Recommended dashboard pages:

1. **Energy Overview**
2. **Customer Demand**
3. **Plant Performance**
4. **Carbon & Sustainability**

This would extend the project from SQL analysis into data modelling, KPI design, and executive visualization.
