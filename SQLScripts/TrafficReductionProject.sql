-- ===============================
-- Traffic Reduction Project SQL
-- ===============================

-- 1️⃣ Create database if it doesn't exist
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'TrafficDB')
BEGIN
    CREATE DATABASE TrafficDB;
END
GO

-- 2️⃣ Use the database
USE TrafficDB;
GO

-- 3️⃣ Drop table if exists (safe to rerun)
IF OBJECT_ID('TrafficData', 'U') IS NOT NULL
    DROP TABLE TrafficData;
GO

-- 4️⃣ Create table
CREATE TABLE TrafficData (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Intersection NVARCHAR(50),
    LogTime DATETIME,
    VehicleCount INT,
    AvgSpeed INT
);
GO

-- 5️⃣ Insert sample data
INSERT INTO TrafficData (Intersection, LogTime, VehicleCount, AvgSpeed)
VALUES
('A_MainSt', '2025-01-01 07:00', 120, 15),
('A_MainSt', '2025-01-01 08:00', 150, 12),
('A_MainSt', '2025-01-01 09:00', 90, 25),
('A_MainSt', '2025-01-01 17:00', 160, 10),
('A_MainSt', '2025-01-01 18:00', 180, 8),
('A_MainSt', '2025-01-01 19:00', 140, 12);
GO

-- 6️⃣ Show data with congestion score
SELECT 
    Intersection,
    LogTime,
    VehicleCount,
    AvgSpeed,
    (VehicleCount * (30 - AvgSpeed)) AS CongestionScore
FROM TrafficData;
GO

-- 7️⃣ Show top 3 peak congestion hours
SELECT TOP 3 
    LogTime, VehicleCount, AvgSpeed,
    (VehicleCount * (30 - AvgSpeed)) AS CongestionScore
FROM TrafficData
ORDER BY CongestionScore DESC;
GO

-- 8️⃣ Drop view if exists
IF OBJECT_ID('vw_DailyTrafficSummary', 'V') IS NOT NULL
    DROP VIEW vw_DailyTrafficSummary;
GO

-- 9️⃣ Create daily summary view
CREATE OR ALTER VIEW vw_DailyTrafficSummary AS
SELECT
    CAST(LogTime AS DATE) AS TrafficDate,
    AVG(VehicleCount) AS AvgVehicles,
    AVG(AvgSpeed) AS AvgSpeed,
    AVG(VehicleCount * (30 - AvgSpeed)) AS AvgCongestionScore
FROM TrafficData
GROUP BY CAST(LogTime AS DATE);
GO

-- 10️⃣ Show daily summary
SELECT * FROM vw_DailyTrafficSummary;
GO

-- 11️⃣ Drop procedure if exists
IF OBJECT_ID('GetTrafficReductionPlan', 'P') IS NOT NULL
    DROP PROCEDURE GetTrafficReductionPlan;
GO

-- 12️⃣ Create stored procedure for traffic reduction
CREATE OR ALTER PROCEDURE GetTrafficReductionPlan
AS
BEGIN
    SELECT 
        Intersection,
        LogTime,
        VehicleCount,
        AvgSpeed,
        CASE 
            WHEN VehicleCount > 150 THEN 'Increase green time'
            WHEN AvgSpeed < 15 THEN 'Deploy traffic police'
            ELSE 'Normal traffic'
        END AS Recommendation
    FROM TrafficData;
END;
GO

-- 13️⃣ Execute the procedure
EXEC GetTrafficReductionPlan;
GO
