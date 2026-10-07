# Data Dictionary

## customers

| Column | Description |
|---|---|
| customer_id | Unique customer identifier |
| name | Customer name |
| address | Customer address |
| segment | Customer segment such as residential, commercial, or industrial |
| join_date | Date the customer joined |

## energy_consumption

| Column | Description |
|---|---|
| consumption_id | Unique consumption record identifier |
| customer_id | Customer foreign key |
| date | Consumption date |
| energy_type | Energy type consumed |
| amount_kwh | Energy consumed in kWh |
| cost_usd | Recorded consumption cost in USD |

## energy_production

| Column | Description |
|---|---|
| production_id | Unique production record identifier |
| production_plant_id | Production plant foreign key |
| date | Production date |
| energy_type | Energy type produced |
| amount_kwh | Energy produced in kWh |
| cost_usd | Recorded production cost in USD |
| carbon_emission_kg | Recorded carbon emissions in kg |

## production_plants

| Column | Description |
|---|---|
| plant_id | Unique production plant identifier |
| plant_name | Production plant name |
| location | Plant location |
| capacity_kwh | Maximum production capacity |
| energy_type | Primary energy type |

## sustainability_initiatives

The source case-study documentation identifies fields including initiative ID, initiative name, start date, and end date.  
The analysis files also use budget, energy-savings, and carbon-reduction fields present in the supplied dataset.
