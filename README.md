# Wealth Management Client Portfolio & Churn Risk Analytics

## 🎯 Business Problem
A premier wealth management and equity advisory firm observed a noticeable spike in customer account closures (churn) and subsequent drops in Assets Under Management (AUM). The objective of this project was to identify high-risk client accounts experiencing a drop of 50% or more in month-on-month transaction volume, isolate the specific drivers of asset leakage, and evaluate internal advisor performance metrics.

## 🛠️ Tech Stack & Architecture
* **Database Engine:** Microsoft SQL Server (T-SQL)
* **Analytics Platform:** Power BI Desktop
* **Key Methodologies:** Common Table Expressions (CTEs), SQL Window Functions (`LAG`), DAX Data Modeling.

---

## 📊 Analytical Approach & Core Metrics

### 1. Database & Extraction Logic (SQL)
Leveraged advanced analytical SQL queries utilizing local database partitions to evaluate historical transactional records. Used the `LAG()` window function to dynamically compute month-on-month velocity drop percentages per distinct client partition.

```sql
WITH MonthlySummary AS (
    SELECT 
        ClientID,
        AdvisorID,
        DATEFROMPARTS(YEAR(TransactionDate), MONTH(TransactionDate), 1) AS TxMonth,
        SUM(TransactionAmount) AS TotalAmount,
        MAX(AUM) AS CurrentAUM
    FROM Client_Transactions
    GROUP BY ClientID, AdvisorID, DATEFROMPARTS(YEAR(TransactionDate), MONTH(TransactionDate), 1)
),
MoMCalculation AS (
    SELECT 
        ClientID,
        AdvisorID,
        TxMonth,
        TotalAmount,
        CurrentAUM,
        LAG(TotalAmount, 1) OVER (PARTITION BY ClientID ORDER BY TxMonth) AS PrevMonthAmount
    FROM MonthlySummary
)
SELECT *,
    CASE 
        WHEN PrevMonthAmount IS NULL THEN 0
        ELSE ((TotalAmount - PrevMonthAmount) / PrevMonthAmount) * 100 
    END AS MoM_Drop_Percentage
FROM MoMCalculation;

```

### 2. Business Intelligence & DAX Modeling (Power BI)

Imported the optimized T-SQL query layer natively into Power BI Desktop via Import mode. Designed an analytical layer and implemented specific Data Analysis Expressions (DAX) to drive executive decision-making:

* **Total Portfolio Assets Under Management (AUM):** Evaluates cumulative managed assets.
```dax
Total_AUM = SUM('Query1'[CurrentAUM])

```


* **High-Risk Churn Population:** Dynamically isolates unique clients displaying a dangerous transactional drop of 50% or worse.
```dax
High_Risk_Churn_Count = 
CALCULATE(
    DISTINCTCOUNT('Query1'[ClientID]),
    'Query1'[MoM_Drop_Percentage] <= -50
)

```



---

## 📈 Executive Dashboard Design

The dashboard template transforms raw transactional rows into clear metric cards and structured tracking charts:

* **Executive KPI Cards:** Positioned prominently at the top to track Total AUM (4.14M) and High-Risk Churn Count (2 accounts) at a single glance.
* **Advisor Performance Allocation (Leakage Chart):** An interactive clustered bar chart mapping internal advisors against customer account churn flags to systematically pinpoint performance anomalies.

---

## 💡 Strategic Executive Insights

* **Systemic Attrition Captured:** Safely isolated 2 major high-net-worth customer records matching the exact high-risk profile rules before complete account capital flight.
* **Advisor Attribution Check:** Cross-filtering reveals that 100% of high-risk portfolio churn originates from accounts assigned exclusively under `AdvisorID: 5002`. This strongly indicates a localized relationship-management bottleneck rather than a wider market downturn, giving leadership a clear target for operational intervention.

