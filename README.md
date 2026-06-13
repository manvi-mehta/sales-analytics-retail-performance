# Superstore Retail Performance and Profitability Analysis

## Project Overview

This project demonstrates an end-to-end Business Intelligence workflow using SQL, Python, MySQL Data Warehouse, and Power BI.

The objective was to analyze retail sales performance, profitability, customer behavior, product performance, shipping efficiency, and discount impact using the Superstore dataset.

The project follows a complete analytics pipeline:

Raw Data → ETL Pipeline → Data Warehouse → SQL Analysis → Power BI Dashboard

---

## Tech Stack

- Python (Pandas)
- MySQL
- SQL
- Power BI
- GitHub

---

## Project Architecture

1. Data Cleaning and Transformation using Python
2. ETL Pipeline Development
3. Star Schema Data Warehouse Design
4. SQL-based Business Analysis
5. Interactive Power BI Dashboard Creation

Raw CSV Dataset

        │
        
        ▼
Python ETL Pipeline
(Data Cleaning & Transformation)

        │
        
        ▼
MySQL Star Schema Data Warehouse
(Dimensions + Fact Table)

        │
        
        ▼
SQL Business Analysis

        │
        ▼
        
Power BI Interactive Dashboard

        │
        ▼
        
Business Insights & Recommendations

---

## Data Warehouse Design

The project follows a Star Schema consisting of:

### Dimension Tables

- dim_customer
- dim_product
- dim_geography
- dim_date
- dim_shipping

### Fact Table

- fact_sales

---

## Business Questions Solved

- Revenue trend analysis
- Profitability by category
- Regional sales performance
- Discount impact on profitability
- Top customers by revenue
- Shipping mode performance
- Customer segmentation
- Average order value analysis
- Delivery time analysis
- Repeat vs one-time customers
- Most profitable products
- Contribution analysis by category

---

## Dashboard Pages

### Executive Overview

![Executive Overview](Dashboard/Executive%20Overview.png)

---

### Product Performance

![Product Performance](Dashboard/Product%20Performance.png)

---

### Customer Insights

![Customer Insights](Dashboard/Customer%20Insights.png)

---

### Shipping & Discount Analysis

![Shipping Analysis](Dashboard/Shipping%20%26%20Discount%20Analysis.png)

---

## Key Business Insights

- Furniture generated the highest revenue but lower profitability.
- Office Supplies contributed the highest profit.
- Higher discount levels significantly reduced profit margins.
- Standard Class shipping generated the highest sales and overall profit.
- Consumer segment contributed the largest share of revenue.
- Certain products consistently generated losses despite strong sales, highlighting opportunities for pricing or inventory optimization.
- Regional performance varies considerably, suggesting targeted sales and marketing strategies.

---

## Repository Structure

```
sales-analytics-retail-performance
│
├── python/
│   └── etl_pipeline.py
│
├── sql/
│   └── sales_analysis.sql
│
├── dashboard/
│   ├── executive overview.png
│   ├── customer insights.png
│   ├── product performance.png
│   └── shipping & discount analysis.png
│
└── README.md
```

---

## Author

Manvi Mehta

Business Analytics Graduate
Manipal Academy of Higher Education
