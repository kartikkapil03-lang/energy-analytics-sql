# Business Insights

## Executive Summary

This analysis connects customer demand, production performance, carbon efficiency, and sustainability initiatives across an energy-company dataset.

The strongest business findings are:

1. **Industrial customers dominate demand.**  
   Industrial customers represent 36% of the customer base but account for approximately 62.8% of recorded energy consumption.

2. **Electricity is the largest production source.**  
   Electricity contributes approximately 47.2% of total recorded production, while coal and gas each contribute roughly one-quarter.

3. **Wind stands out on cost and carbon efficiency.**  
   Wind represents around 5.6% of output but only about 0.6% of production emissions. Its recorded production cost is also materially lower than the other energy sources in the dataset.

4. **Carbon intensity and total emissions answer different questions.**  
   A plant can have high total emissions because it produces more energy, even when its emissions per kWh are not the highest. Both metrics should be reviewed together.

5. **Monthly production changes should be investigated, not automatically explained.**  
   LAG/LEAD analysis can identify meaningful plant-level changes, but the dataset does not include maintenance, outage, weather, or dispatch information.

6. **Sustainability initiatives differ significantly in measurable impact.**  
   Total savings should be reviewed alongside savings per budget dollar, duration-adjusted savings, and carbon reduction.

## Business Recommendations

- Prioritize industrial customers for demand-management and efficiency initiatives.
- Track monthly production and month-on-month changes at plant level.
- Use both total emissions and emissions per kWh in environmental performance reviews.
- Compare sustainability initiatives using multiple KPIs instead of total savings alone.
- Investigate the scalability of wind using additional capital-cost, capacity-factor, reliability, and grid data.

## Analytical Cautions

- Ranking individual production records is not the same as ranking overall plant performance.
- Monthly plant output should use aggregated production rather than average record size.
- First-vs-last observations do not represent a full annual consumption trend.
- Carbon efficiency should be separated from absolute emissions.
- Time-adjusted sustainability metrics require a consistent duration definition.
