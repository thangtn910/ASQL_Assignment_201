--ASQL Assignment 201

--Problem Descriptions:
--You work as a Database Developer for ABC Inc. The company uses RDBMS for project management.
--The fragments of database schema are given in figure below.
--As shown, the Project database contains four tables: Projects, Employee, Project_Modules and Work_Done.

USE master
GO

IF EXISTS( SELECT name FROM sys.databases WHERE name = N'ABC')
DROP DATABASE ABC
GO

CREATE DATABASE ABC
GO

USE ABC
GO

CREATE TABLE [dbo].[Projects](
       ProjectID			INT				IDENTITY(1,1)		PRIMARY KEY,
	   ProjectName			VARCHAR(50)		NOT NULL,
	   ProjectStartDate		DATETIME		NOT NULL,
	   ProjectDescription	VARCHAR(255)	NOT NULL,
	   ProjectDetail		VARCHAR(255)	NOT NULL,
	   ProjectCompletedOn	DATETIME		NOT NULL
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Employee] (
       EmployeeID			INT				IDENTITY(1,1)		PRIMARY KEY,
	   EmployeeLastName		VARCHAR(20)		NOT NULL,
	   EmployeeFirstName	VARCHAR(20)		NOT NULL,
	   EmployeeHireDate		DATETIME		NOT NULL,
	   EmployeeStatus		VARCHAR(255)	NOT NULL,
	   SupervisorID			INT				NOT NULL	FOREIGN KEY REFERENCES Employee(EmployeeID),
	   SocialSecurityNumber	INT				NOT NULL
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Project_Modules] (
       ModuleID						INT				IDENTITY(1,1)		PRIMARY KEY,
	   ProjectID					INT				NOT NULL	FOREIGN KEY REFERENCES [Projects](ProjectID),
	   EmployeeID					INT				NOT NULL	FOREIGN KEY REFERENCES [Employee](EmployeeID),
	   ProjectModulesDate			DATETIME		NOT NULL,
	   ProjectModulesCompledOn		DATETIME		NOT NULL,
	   ProjectModulesDescription	VARCHAR(255)	NOT NULL
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Work_Done](
       WorkDoneID			INT				IDENTITY(1,1)		PRIMARY KEY,
	   ModuleID				INT				NOT NULL			FOREIGN KEY REFERENCES [Project_Modules](ModuleID),
	   WorkDoneDate			DATETIME		NOT NULL,
	   WorkDoneDescription	VARCHAR(255)	NOT NULL,
	   WorkDoneStatus		VARCHAR(255)	NOT NULL
) ON [PRIMARY]
GO

--1. Create the tables (with the most appropriate field/column constraints & types) 
--and add at least 3 records into each created table.

INSERT INTO [dbo].[Projects](ProjectName, ProjectStartDate, ProjectDescription, ProjectDetail, ProjectCompletedOn)
VALUES	('Ngan hang', '2022/01/01', N'Công nghệ mới','Java','2022/06/08'),
		('Quan doi', '2022/02/02', N'Công nghệ cũ','ReactJS','2022/05/22'),
		('Nhà hàng', '2022/03/03', N'Công nghệ vừa','.NET','2022/07/16')
GO

INSERT INTO [dbo].[Employee] (EmployeeLastName, EmployeeFirstName, EmployeeHireDate, EmployeeStatus, SupervisorID, SocialSecurityNumber)
VALUES	('Trần','Thắng','2016/02/02','Working',1,123456),
		('Nguyễn','Tâm','2017/02/02','Working',1,123457),
		('Lê','Đức','2018/02/02','Working',2,123458),
		('Võ','Thiện','2019/02/02','Working',2,123459)
GO

INSERT INTO [dbo].[Project_Modules] (ProjectID, EmployeeID, ProjectModulesDate, ProjectModulesCompledOn, ProjectModulesDescription)
VALUES	(1,1,'2022/06/01','2022/06/05','good'),
		(1,2,'2022/06/01','2022/06/01','goodd'),
		(2,1,'2022/06/01','2022/06/23','good'),
		(1,3,'2022/06/01','2022/06/02','gooddd'),
		(3,4,'2022/06/01','2022/07/01','goodd'),
		(3,1,'2022/06/01','2022/06/30','goodddd')
GO

--2. Write a stored procedure (with parameter) to print out the modules that a specific employee has been working on.
GO
IF OBJECT_ID('dbo.uspGetModules','p') IS NOT NULL
	DROP PROCEDURE dbo.uspGetModules;
GO

CREATE PROCEDURE dbo.uspGetModules
@employeeID INT
AS
	SET NOCOUNT ON;
	SELECT e.EmployeeLastName+','+e.EmployeeFirstName,p.ProjectName
	FROM Employee e 
	INNER JOIN Project_Modules pm ON e.EmployeeID = pm.EmployeeID
	INNER JOIN Projects p ON pm.ProjectID = p.ProjectID
	WHERE e.EmployeeID = @employeeID
RETURN 
GO

EXEC dbo.uspGetModules 5

PRINT @ModuleName
GO

-- 4. Write the trigger(s) to prevent the case that the end user to input invalid Projects 
-- and Project Modules information
CREATE TRIGGER trgInsertProject
ON [dbo].[Project_Modules]	
AFTER INSERT
AS 
	DECLARE @ProjectStartDate DATETIME, @ProjectModulesDate DATETIME;
	DECLARE @ProjectCompletedOn DATETIME, @ProjectModulesCompletedOn DATETIME;

	SELECT @ProjectModulesDate = ProjectModulesDate FROM inserted;
	SELECT @ProjectModulesCompletedOn = ProjectModulesCompledOn FROM inserted;

	SELECT @ProjectStartDate = ProjectStartDate
	FROM dbo.Projects p
	INNER JOIN inserted i ON p.ProjectID = i.ProjectID

	SELECT @ProjectCompletedOn = ProjectCompletedOn
	FROM dbo.Projects p
	INNER JOIN inserted i ON p.ProjectID = i.ProjectID
	
	IF(@ProjectStartDate > @ProjectModulesDate OR @ProjectModulesCompletedOn > @ProjectCompletedOn)
		BEGIN
			PRINT 'you inputed invalid Projects and Project Modules information'
			ROLLBACK TRAN
		END
GO

INSERT INTO [dbo].[Projects](ProjectName, ProjectStartDate, ProjectDescription, ProjectDetail, ProjectCompletedOn)
VALUES	(N'Mỹ', '2022/02/14', N'Công nghệ mới','Python','2022/10/10')
GO

INSERT INTO dbo.Project_Modules(ProjectID, EmployeeID, ProjectModulesDate, ProjectModulesCompledOn, ProjectModulesDescription)
VALUES	(4,2,'2022/06/09','2022/10/10','good')
GO

SELECT * FROM dbo.Project_Modules