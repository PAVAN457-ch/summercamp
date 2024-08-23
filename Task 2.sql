
create database campTask



USE CampTask;
GO

-- Drop the tables if they exist
IF OBJECT_ID('CampVisits', 'U') IS NOT NULL
    DROP TABLE CampVisits;

IF OBJECT_ID('Camps', 'U') IS NOT NULL
    DROP TABLE Camps;

IF OBJECT_ID('Participants', 'U') IS NOT NULL
    DROP TABLE Participants;

-- Create the Participants table with the DateOfBirth column
CREATE TABLE Participants (
    ParticipantID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50),
    MiddleName NVARCHAR(50),
    LastName NVARCHAR(50),
    DateOfBirth DATE,  -- DateOfBirth column added here
    Gender NVARCHAR(10),
    Email NVARCHAR(100),
    PersonalPhone NVARCHAR(15)
);

-- Create the Camps table
CREATE TABLE Camps (
    CampID INT PRIMARY KEY IDENTITY(1,1),
    Title NVARCHAR(100),
    StartDate DATE,
    EndDate DATE,
    Price DECIMAL(10, 2),
    Capacity INT
);

-- Create the CampVisits table
CREATE TABLE CampVisits (
    VisitID INT PRIMARY KEY IDENTITY(1,1),
    ParticipantID INT,
    CampID INT,
    VisitDate DATE,
    FOREIGN KEY (ParticipantID) REFERENCES Participants(ParticipantID),
    FOREIGN KEY (CampID) REFERENCES Camps(CampID)
);

DECLARE @i INT = 1;
DECLARE @Gender NVARCHAR(10);
DECLARE @DateOfBirth DATE;

WHILE @i <= 5000
BEGIN
    -- Determine Gender based on the 65% girls, 35% boys distribution
    IF RAND() < 0.65 
        SET @Gender = 'Female';
    ELSE 
        SET @Gender = 'Male';

    -- Determine DateOfBirth based on the specified age distribution
    DECLARE @AgeGroup FLOAT = RAND() * 100;
    
    IF @AgeGroup < 18
        SET @DateOfBirth = DATEADD(YEAR, -FLOOR(RAND() * 6) - 7, GETDATE());  -- 7-12 years old (18%)
    ELSE IF @AgeGroup < 45
        SET @DateOfBirth = DATEADD(YEAR, -FLOOR(RAND() * 2) - 13, GETDATE());  -- 13-14 years old (27%)
    ELSE IF @AgeGroup < 65
        SET @DateOfBirth = DATEADD(YEAR, -FLOOR(RAND() * 3) - 15, GETDATE());  -- 15-17 years old (20%)
    ELSE
        SET @DateOfBirth = DATEADD(YEAR, -FLOOR(RAND() * 5) - 18, GETDATE());  -- 18-19 years old (remaining 35%)

    -- Insert the generated data into the Participants table
    INSERT INTO Participants (FirstName, MiddleName, LastName, DateOfBirth, Gender, Email, PersonalPhone)
    VALUES (
        'FirstName' + CAST(@i AS NVARCHAR(50)),  -- Generating dummy names
        'MiddleName' + CAST(@i AS NVARCHAR(50)),
        'LastName' + CAST(@i AS NVARCHAR(50)),
        @DateOfBirth,
        @Gender,
        'email' + CAST(@i AS NVARCHAR(50)) + '@example.com',  -- Generating dummy emails
        '555-' + RIGHT('0000' + CAST(@i AS NVARCHAR(15)), 4)  -- Generating dummy phone numbers
    );

    -- Increment the counter
    SET @i = @i + 1;
END;

-- Confirm the distribution
SELECT Gender, COUNT(*) AS Count
FROM Participants
GROUP BY Gender;

SELECT 
    CASE
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) BETWEEN 7 AND 12 THEN '7-12'
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) BETWEEN 13 AND 14 THEN '13-14'
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) BETWEEN 15 AND 17 THEN '15-17'
        ELSE '18-19'
    END AS AgeGroup,
    COUNT(*) AS Count
FROM Participants
GROUP BY 
    CASE
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) BETWEEN 7 AND 12 THEN '7-12'
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) BETWEEN 13 AND 14 THEN '13-14'
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) BETWEEN 15 AND 17 THEN '15-17'
        ELSE '18-19'
    END;
