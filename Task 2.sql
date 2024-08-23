
DROP DATABASE campTask;

USE master;
GO

-- Set the database to SINGLE_USER mode to disconnect all other users
ALTER DATABASE campTask SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

-- Drop the database
DROP DATABASE campTask;
GO

USE master;
GO

SELECT
    session_id,
    login_name,
    status
FROM sys.dm_exec_sessions
WHERE database_id = DB_ID('campTask');


USE master;
GO

DROP DATABASE campTask;
GO

USE master;
GO

SELECT name
FROM sys.databases
WHERE name = 'campTask';

SELECT dp.name AS PrincipalName, 
       dp.type_desc AS PrincipalType, 
       p.permission_name, 
       p.state_desc AS PermissionState
FROM sys.database_permissions AS p
JOIN sys.database_principals AS dp
    ON p.grantee_principal_id = dp.principal_id
WHERE dp.name = USER_NAME();  -- Shows permissions for the current user

USE master;
GO

ALTER DATABASE campTask SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

USE master;
GO

SELECT name
FROM sys.databases
WHERE name = 'campTask';

USE campTask;
GO

SELECT
    dp.name AS DatabaseRoleName,
    dp.type_desc AS RoleType
FROM sys.database_role_members drm
JOIN sys.database_principals dp
    ON drm.role_principal_id = dp.principal_id
WHERE drm.member_principal_id = USER_ID();

USE master;
GO

SELECT 
    dp.name AS PrincipalName,
    dp.type_desc AS PrincipalType,
    p.permission_name,
    p.state_desc AS PermissionState
FROM sys.database_permissions AS p
JOIN sys.database_principals AS dp
    ON p.grantee_principal_id = dp.principal_id
WHERE dp.name = USER_NAME();

USE master;
GO

SELECT 
    session_id,
    blocking_session_id,
    wait_type,
    wait_time,
    wait_resource
FROM sys.dm_exec_requests
WHERE database_id = DB_ID('campTask');

USE master;
GO

-- Forcefully kill all active connections
DECLARE @sql NVARCHAR(MAX) = '';
SELECT @sql += 'KILL ' + CAST(session_id AS NVARCHAR) + '; '
FROM sys.dm_exec_sessions
WHERE database_id = DB_ID('campTask');

USE master;
GO

DROP DATABASE campTask;
GO




EXEC sp_executesql @sql;



KILL [dbo];


USE master;
GO

SELECT
    session_id,
    login_name,
    status
FROM sys.dm_exec_sessions
WHERE database_id = DB_ID('campTask');


create database campTask

-- Drop tables if they exist
IF OBJECT_ID('CampVisits', 'U') IS NOT NULL
    DROP TABLE CampVisits;

IF OBJECT_ID('Camps', 'U') IS NOT NULL
    DROP TABLE Camps;

IF OBJECT_ID('Participants', 'U') IS NOT NULL
    DROP TABLE Participants;

CREATE TABLE Participants (
    ParticipantID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    MiddleName NVARCHAR(50),
    Gender NVARCHAR(10),
    Email NVARCHAR(100),
    PersonalPhone NVARCHAR(15)
);

CREATE TABLE Camps (
    CampID INT PRIMARY KEY IDENTITY(1,1),
    Title NVARCHAR(100),
    StartDate DATE,
    EndDate DATE,
    Price DECIMAL(10, 2),
    Capacity INT
);

CREATE TABLE CampVisits (
    VisitID INT PRIMARY KEY IDENTITY(1,1),
    ParticipantID INT,
    CampID INT,
    VisitDate DATE,
    FOREIGN KEY (ParticipantID) REFERENCES Participants(ParticipantID),
    FOREIGN KEY (CampID) REFERENCES Camps(CampID)
);

-- Populate Participants table
INSERT INTO Participants (FirstName, LastName, MiddleName, Gender, Email, PersonalPhone)
SELECT
    'FirstName' + CAST(ABS(CHECKSUM(NEWID()) % 10000) AS NVARCHAR(4)),
    'LastName' + CAST(ABS(CHECKSUM(NEWID()) % 10000) AS NVARCHAR(4)),
    'MiddleName' + CAST(ABS(CHECKSUM(NEWID()) % 10000) AS NVARCHAR(4)),
    CASE
        WHEN RAND() < 0.65 THEN 'Female'
        ELSE 'Male'
    END,
    'email' + CAST(ABS(CHECKSUM(NEWID()) % 10000) AS NVARCHAR(4)) + '@example.com',
    '555-' + RIGHT('0000' + CAST(ABS(CHECKSUM(NEWID()) % 10000) AS NVARCHAR(4)), 4)
FROM
    (SELECT TOP 5000 1 AS n FROM master.dbo.spt_values) AS a;

-- Add Age column for this example
ALTER TABLE Participants ADD Age INT;

-- Query to get gender distribution by generational cohorts
SELECT
    Generation,
    SUM(CASE WHEN Gender = 'Male' THEN 1 ELSE 0 END) AS MaleCount,
    SUM(CASE WHEN Gender = 'Female' THEN 1 ELSE 0 END) AS FemaleCount,
    CAST(SUM(CASE WHEN Gender = 'Male' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) * 100 AS MalePercentage,
    CAST(SUM(CASE WHEN Gender = 'Female' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) * 100 AS FemalePercentage
FROM (
    SELECT
        CASE
            WHEN Age BETWEEN 7 AND 12 THEN 'Gen Alpha'
            WHEN Age BETWEEN 13 AND 17 THEN 'Gen Z'
            WHEN Age BETWEEN 18 AND 22 THEN 'Millennials'
            ELSE 'Gen X'
        END AS Generation,
        Gender
    FROM Participants
) AS SubQuery
GROUP BY Generation;
