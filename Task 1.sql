-- Create a new database named 'NewCampTask'
CREATE DATABASE NewCampTask;
GO

-- Use the new database
USE NewCampTask;
GO

-- Create the Participants table in the new database
CREATE TABLE Participants (
    ParticipantID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    MiddleName NVARCHAR(50),
    Gender NVARCHAR(10),
    Email NVARCHAR(100),
    PersonalPhone NVARCHAR(15),
    DateOfBirth DATE
);

-- Insert 5000 random people with specified gender and age distribution
WITH RandomPeople AS (
    SELECT TOP 5000
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS PersonID,
        CONCAT('FirstName', ROW_NUMBER() OVER (ORDER BY (SELECT NULL))) AS FirstName,
        CONCAT('LastName', ROW_NUMBER() OVER (ORDER BY (SELECT NULL))) AS LastName,
        CONCAT('MiddleName', ROW_NUMBER() OVER (ORDER BY (SELECT NULL))) AS MiddleName,
        CASE 
            WHEN RAND() <= 0.65 THEN 'Female'
            ELSE 'Male'
        END AS Gender,
        CONCAT('email', ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), '@example.com') AS Email,
        '555-' + RIGHT('0000' + CAST(ABS(CHECKSUM(NEWID()) % 10000) AS NVARCHAR(4)), 4) AS PersonalPhone,
        CASE
            WHEN RAND() <= 0.18 THEN DATEADD(YEAR, -ABS(CHECKSUM(NEWID()) % 6) - 7, GETDATE())    -- 7-12 years old
            WHEN RAND() <= 0.45 THEN DATEADD(YEAR, -ABS(CHECKSUM(NEWID()) % 2) - 13, GETDATE())   -- 13-14 years old
            WHEN RAND() <= 0.65 THEN DATEADD(YEAR, -ABS(CHECKSUM(NEWID()) % 3) - 15, GETDATE())   -- 15-17 years old
            ELSE DATEADD(YEAR, -ABS(CHECKSUM(NEWID()) % 4) - 18, GETDATE())                      -- 18-19 years old
        END AS DateOfBirth
    FROM master..spt_values v1
    CROSS JOIN master..spt_values v2
)
INSERT INTO Participants (FirstName, LastName, MiddleName, Gender, Email, PersonalPhone, DateOfBirth)
SELECT FirstName, LastName, MiddleName, Gender, Email, PersonalPhone, DateOfBirth
FROM RandomPeople;
GO

select * from Participants