# 📊 Sales & Customer Performance Analysis
### SQL Project | MySQL Workbench

---

## Project Overview

This project simulates a real-world Business Analyst scenario — analyzing sales performance, customer behaviour, and product trends to support data-driven decisions for a **Sales Director**.

The analysis is structured around actual business questions rather than syntax practice — each query answers a specific business problem and concludes with an analytical observation.

> **Dataset:** Sample enterprise dataset | **Period:** Jan 2023 – Apr 2023  
> **Tool:** MySQL Workbench | **Language:** SQL

---

## Database Schema

| Table | Description | Key Columns |
|-------|-------------|-------------|
| customers | Customer master data | customer_id (PK), customer_name |
| orders | Customer order transactions | order_id (PK), customer_id (FK), order_date, amount |
| returns | Order return records | return_id (PK), order_id (FK), return_date, amount |
| products | Product master data | product_id (PK), product_name, category_id (FK) |
| categories | Product category master | category_id (PK), category_name |
| sales | Product-level sales transactions | sale_id (PK), product_id (FK), sale_date, quantity, amount |

### Relationship Map
```
customers ──── orders ──── returns
products  ──── sales
products  ──── categories
```

---

## Business Questions Answered

### Section 1 — Revenue & Growth Analysis
> *How is our revenue performing over time?*

| # | Business Question | SQL Concepts Used |
|---|------------------|-------------------|
| 1 | What is the total sales revenue by month? | GROUP BY, DATE_FORMAT |
| 2 | What is the month-over-month sales growth? | CTE, LAG(), Window Function |
| 3 | What is the monthly net revenue after returns? | CTE, LEFT JOIN, COALESCE |

### Section 2 — Product & Category Performance
> *Which products and categories should we focus on?*

| # | Business Question | SQL Concepts Used |
|---|------------------|-------------------|
| 4 | Which product categories generate the highest revenue? | CTE, INNER JOIN, SUM OVER() |
| 5 | Which products generate the highest sales revenue? | CTE, INNER JOIN, Window Function |
| 6 | Which products generate the highest sales volume? | LEFT JOIN, COALESCE, GROUP BY |
| 7 | Which category generates the highest sales volume? | INNER JOIN, LEFT JOIN, GROUP BY |

### Section 3 — Customer Performance
> *Who are our most valuable customers?*

| # | Business Question | SQL Concepts Used |
|---|------------------|-------------------|
| 8 | Who are our top 10 customers by revenue? | INNER JOIN, GROUP BY, LIMIT |
| 9 | Which customers contribute 80% of total revenue? (Pareto) | CTE, SUM OVER(), Running Total |
| 10 | What is the average order value per customer? | AVG(), GROUP BY, ORDER BY |
| 11 | Which customers have the highest return rate %? | CTE, LEFT JOIN, COALESCE |

---

## SQL Concepts Used

| Concept | Queries |
|---------|---------|
| CTEs (Common Table Expressions) | Q2, Q3, Q4, Q5, Q9, Q11 |
| Window Functions (LAG, SUM OVER, RANK) | Q2, Q4, Q5, Q9 |
| LEFT JOIN | Q3, Q6, Q7, Q11 |
| INNER JOIN | Q4, Q5, Q8, Q10 |
| COALESCE (NULL handling) | Q3, Q6, Q7, Q11 |
| DATE_FORMAT | Q1, Q2, Q3 |
| SQL Views | Section 4 |
| Subqueries | Q9 |
| CONCAT for formatted output | Q2, Q4, Q5, Q11 |

---

## Reusable Views Created

| View Name | Purpose | Used In |
|-----------|---------|---------|
| v_monthly_revenue_summary | Monthly revenue aggregation | Q1, Q2, Q3 logic |
| v_customer_revenue_summary | Customer-level revenue, orders, AOV | Q8, Q9, Q10 logic |
| v_product_sales_summary | Product + category + sales combined | Q4, Q5, Q6, Q7 logic |

---

## Key Analytical Observations

### Revenue & Growth
- **January 2023 recorded the highest revenue at 82,900** — the strongest month in the analysis period
- **Revenue declined consistently month-over-month:** Feb (-10.62%), Mar (-21.05%), Apr (-66.67%) — indicating a sharp downward trend requiring investigation
- In a real business scenario, this consistent decline would trigger an RCA to identify whether the cause is seasonal demand, reduced product availability, or customer churn

### Product & Category Performance
- **Books (13.51%), Electronics (11.40%), and Toys (10.55%)** are the top 3 revenue-contributing categories — together accounting for ~35% of total revenue
- **Tools (3.02%) and Office (3.36%)** are the lowest performing categories — candidates for promotion strategy review or inventory rationalization
- In a real business context, low-volume categories would be analyzed further for margin contribution before deciding on discontinuation vs promotion

### Customer Performance
- **Return rate is uniformly distributed at 10%** across all customers in this dataset — characteristic of sample data
- In a real business scenario, this query would surface customers with return rates above 25-30% for targeted account management intervention
- **Pareto Analysis** confirms that in real-world business data, typically 20% of customers drive 80% of revenue — this query is structured to identify that segment for prioritization

---

## How to Run This Project

```sql
-- Step 1: Set the schema
USE enterprise_analytics;

-- Step 2: Run Section 0 (Data Exploration) first
-- to understand table structure and data quality

-- Step 3: Run Sections 1-3 in order
-- Each query has a business question comment above it

-- Step 4: Run Section 4 to create the 3 Views
-- Then use views for quick ad-hoc reporting:
SELECT * FROM v_monthly_revenue_summary ORDER BY sales_year, sales_month;
SELECT * FROM v_customer_revenue_summary ORDER BY Total_Revenue DESC LIMIT 10;
SELECT * FROM v_product_sales_summary ORDER BY Total_Revenue DESC;
```

---

## Project Structure

```
Sales-Customer-Performance-Analysis/
├── README.md            → Project overview, schema, findings
└── sales_analysis.sql   → Data exploration + 11 queries + 3 Views
```


---

## Author

**Suresh S** — Business Analyst | Renewal & Growth Analytics | SaaS  
📎 [linkedin.com/in/sureshharish](https://linkedin.com/in/sureshharish)  
💻 [github.com/Suresh-Harish](https://github.com/Suresh-Harish)

