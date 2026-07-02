WITH MonthlySummary AS (
    SELECT 
        ClientID,
        AdvisorID,
        -- Truncates dates to the first day of the month in SQL Server
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
        -- Fetches the previous month's total transaction volume for that specific client
        LAG(TotalAmount, 1) OVER (PARTITION BY ClientID ORDER BY TxMonth) AS PrevMonthAmount
    FROM MonthlySummary
)
SELECT 
    ClientID,
    AdvisorID,
    TxMonth,
    TotalAmount,
    PrevMonthAmount,
    CurrentAUM,
    -- Calculate percentage change safely handling any potential division by zero
    CASE 
        WHEN PrevMonthAmount IS NULL THEN 0
        ELSE ((TotalAmount - PrevMonthAmount) / PrevMonthAmount) * 100 
    END AS MoM_Drop_Percentage
FROM MoMCalculation;
