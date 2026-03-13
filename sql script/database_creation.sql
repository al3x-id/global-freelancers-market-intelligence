IF DB_ID('freelancers') IS NULL
BEGIN
	CREATE DATABASE freelancers;
END

GO
USE freelancers;
GO

SELECT name FROM sys.tables;
GO

-- Import dataset with SQL server import wizard

SELECT * FROM global_freelancers_raw;


SELECT * 
INTO global_freelancers
FROM global_freelancers_raw;