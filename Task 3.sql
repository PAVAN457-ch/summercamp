
CREATE DATABASE Summer;
GO

USE Summer;
GO

CREATE TABLE participant (
    ParticipantID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    MiddleName NVARCHAR(50),
    Gender NVARCHAR(10),
    Email NVARCHAR(100),
    PersonalPhone NVARCHAR(15),
    DateOfBirth DATE,
    Generation NVARCHAR(20)
);
-- Start the loop to insert participants
DECLARE @i INT = 1;

WHILE @i <= 5000
BEGIN
    -- Declare the variables inside the loop
    DECLARE @FirstName VARCHAR(50);
    DECLARE @MiddleName VARCHAR(50);
    DECLARE @LastName VARCHAR(50);
    DECLARE @PersonalPhone VARCHAR(20);
    DECLARE @Gender VARCHAR(10);
    DECLARE @DateOfBirth DATE;
    DECLARE @AgeGroup FLOAT;

    -- Generate random data for each participant
    SET @FirstName = 'FirstName' + CAST(@i AS VARCHAR);
    SET @MiddleName = 'MiddleName' + CAST(@i AS VARCHAR);
    SET @LastName = 'LastName' + CAST(@i AS VARCHAR);
    SET @PersonalPhone = '555-' + RIGHT('0000' + CAST(@i AS VARCHAR), 4);

    -- Gender distribution (65% girls, 35% boys)
    IF RAND() < 0.65 
        SET @Gender = 'Female';
    ELSE
        SET @Gender = 'Male';

    -- Adjust the Age distribution to ensure diversity
    SET @AgeGroup = RAND() * 100;
    IF @AgeGroup < 25
        SET @DateOfBirth = DATEADD(YEAR, -FLOOR(RAND() * 6) - 7, GETDATE()); -- Gen Alpha (7-12 years old)
    ELSE IF @AgeGroup < 50
        SET @DateOfBirth = DATEADD(YEAR, -FLOOR(RAND() * 14) - 25, GETDATE()); -- Gen Z (13-24 years old)
    ELSE IF @AgeGroup < 75
        SET @DateOfBirth = DATEADD(YEAR, -FLOOR(RAND() * 16) - 39, GETDATE()); -- Millennials (25-40 years old)
    ELSE
        SET @DateOfBirth = DATEADD(YEAR, -FLOOR(RAND() * 18) - 55, GETDATE()); -- Gen X (41-59 years old)

    -- Insert the participant into the table
    INSERT INTO participant (FirstName, MiddleName, LastName, PersonalPhone, Gender, DateOfBirth)
    VALUES (@FirstName, @MiddleName, @LastName, @PersonalPhone, @Gender, @DateOfBirth);

    -- Increment the counter
    SET @i = @i + 1;
END;

WITH GenderCounts AS (
    SELECT
        CASE
            WHEN YEAR(DateOfBirth) BETWEEN 1946 AND 1964 THEN 'Gen X'
            WHEN YEAR(DateOfBirth) BETWEEN 1965 AND 1980 THEN 'Millennials'
            WHEN YEAR(DateOfBirth) BETWEEN 1981 AND 1996 THEN 'Gen Z'
            ELSE 'Gen Alpha'
        END AS Generation,
        Gender,
        COUNT(*) AS Count
    FROM participant
    GROUP BY
        CASE
            WHEN YEAR(DateOfBirth) BETWEEN 1946 AND 1964 THEN 'Gen X'
            WHEN YEAR(DateOfBirth) BETWEEN 1965 AND 1980 THEN 'Millennials'
            WHEN YEAR(DateOfBirth) BETWEEN 1981 AND 1996 THEN 'Gen Z'
            ELSE 'Gen Alpha'
        END,
        Gender
),
TotalCounts AS (
    SELECT
        Generation,
        SUM(Count) AS Total
    FROM GenderCounts
    GROUP BY Generation
)
SELECT
    gc.Generation,
    gc.Gender,
    (CAST(gc.Count AS FLOAT) / tc.Total) * 100 AS Percentage
FROM GenderCounts gc
JOIN TotalCounts tc ON gc.Generation = tc.Generation
ORDER BY
    gc.Generation,
    gc.Gender;
