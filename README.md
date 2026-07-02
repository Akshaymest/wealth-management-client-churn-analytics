# Wealth Management Client Portfolio & Churn Risk Analytics

## 🎯 Business Problem
A premier wealth management and equity advisory firm observed a noticeable spike in customer account closures (churn) and subsequent drops in Assets Under Management (AUM). The objective of this project was to identify high-risk client accounts experiencing a drop of 50% or more in month-on-month transaction volume, isolate the specific drivers of asset leakage, and evaluate internal advisor performance metrics.

## 🛠️ Tech Stack & Architecture
* **Database Engine:** Microsoft SQL Server (T-SQL)
* **Analytics Platform:** Power BI Desktop
* **Key Methodologies:** Common Table Expressions (CTEs), SQL Window Functions (`LAG`), DAX Data Modeling.

## 📊 Analytical Approach & Core Metrics

### 1. Database & Extraction Logic (SQL)
Leveraged advanced analytical SQL queries utilizing local database partitions to evaluate historical transactional records. Used the `LAG()` window function to dynamically compute month-on-month velocity drop percentages per distinct client partition.

```sql
-- Code snippet showing the core analytical calculation
LAG(TotalAmount, 1) OVER (PARTITION BY ClientID ORDER BY TxMonth)
