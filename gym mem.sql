
create database gigi

CREATE TABLE Address (
    Address_ID INT PRIMARY KEY IDENTITY(1,1),
    Phone VARCHAR(15) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE
);
CREATE TABLE [User] (
    User_ID INT PRIMARY KEY IDENTITY(1,1),
    Username VARCHAR(50) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    Role VARCHAR(20) CHECK (Role IN ('Admin', 'Trainer', 'Member'))
);
CREATE TABLE Admin (
    Admin_ID INT PRIMARY KEY IDENTITY(1,1),
    Full_Name VARCHAR(100) NOT NULL,
    Address_ID INT NOT NULL,
    User_ID INT NOT NULL UNIQUE,

    FOREIGN KEY (Address_ID) REFERENCES Address(Address_ID),
    FOREIGN KEY (User_ID) REFERENCES [User](User_ID)
);

CREATE TABLE Trainer (
    Trainer_ID INT PRIMARY KEY IDENTITY(1,1),
    Full_Name VARCHAR(100) NOT NULL,
    Specialization VARCHAR(100),
    Experience INT CHECK (Experience >= 0),
    Address_ID INT NOT NULL,
    User_ID INT NOT NULL UNIQUE,

    FOREIGN KEY (Address_ID) REFERENCES Address(Address_ID),
    FOREIGN KEY (User_ID) REFERENCES [User](User_ID)
);
CREATE TABLE Member (
    Member_ID INT PRIMARY KEY IDENTITY(1,1),
    Full_Name VARCHAR(100) NOT NULL,
    Gender VARCHAR(10) CHECK (Gender IN ('Male','Female')),
    Date_Of_Birth DATE,
    Join_Date DATE DEFAULT GETDATE(),
    Address_ID INT NOT NULL,
    User_ID INT NOT NULL UNIQUE,

    FOREIGN KEY (Address_ID) REFERENCES Address(Address_ID),
    FOREIGN KEY (User_ID) REFERENCES [User](User_ID)
);
CREATE TABLE Schedule (
    Schedule_ID INT PRIMARY KEY IDENTITY(1,1),
    Trainer_ID INT NOT NULL,
    Class_Name VARCHAR(100),
    Schedule_Date DATE NOT NULL,
    Start_Time TIME NOT NULL,
    End_Time TIME NOT NULL,

    FOREIGN KEY (Trainer_ID) REFERENCES Trainer(Trainer_ID)
);
CREATE TABLE Membership (
    Membership_ID INT PRIMARY KEY IDENTITY(1,1),
    Member_ID INT NOT NULL,
    Type VARCHAR(50) CHECK (Type IN ('Monthly','Quarterly','Yearly')),
    Start_Date DATE NOT NULL,
    End_Date DATE NOT NULL,
    FOREIGN KEY (Member_ID) REFERENCES Member(Member_ID)
);
CREATE TABLE Payment (
    Payment_ID INT PRIMARY KEY IDENTITY(1,1),
    Member_ID INT NOT NULL,
    Amount DECIMAL(10,2) CHECK (Amount > 0),
    Payment_Date DATE DEFAULT GETDATE(),
    Method VARCHAR(20) CHECK (Method IN ('Cash','Card','Mobile')),
    FOREIGN KEY (Member_ID) REFERENCES Member(Member_ID)
);

INSERT INTO Address (Phone, Email) VALUES
('0911000001','admin@gym.com'),
('0911000002','trainer1@gym.com'),
('0911000003','trainer2@gym.com'),
('0911000004','trainer3@gym.com'),
('0911000005','member1@gym.com'),
('0911000006','member2@gym.com'),
('0911000007','member3@gym.com'),
('0911000008','member4@gym.com'),
('0911000009','member5@gym.com'),
('0911000010','member6@gym.com');

INSERT INTO [User] (Username, Password, Role) VALUES
('admin1','admin123','Admin'),

('trainer1','trainer123','Trainer'),
('trainer2','trainer123','Trainer'),
('trainer3','trainer123','Trainer'),

('member1','member123','Member'),
('member2','member123','Member'),
('member3','member123','Member'),
('member4','member123','Member'),
('member5','member123','Member'),
('member6','member123','Member');


INSERT INTO Admin (Full_Name, Address_ID, User_ID)
VALUES ('Main Admin', 1, 1);

INSERT INTO Trainer (Full_Name, Specialization, Experience, Address_ID, User_ID) VALUES
('Abel Tesfaye','Fitness',5,2,2),
('Sara Bekele','Yoga',4,3,3),
('Dawit Alemu','Cardio',6,4,4);

INSERT INTO Member (Full_Name, Gender, Date_Of_Birth, Join_Date, Address_ID, User_ID) VALUES
('Mekdes Girma','Female','2000-05-12',GETDATE(),5,5),
('Yonatan Kebede','Male','1999-02-20',GETDATE(),6,6),
('Ruth Solomon','Female','2001-09-15',GETDATE(),7,7),
('Samuel Hagos','Male','1998-11-03',GETDATE(),8,8),
('Selamawit Tadesse','Female','2002-07-18',GETDATE(),9,9),
('Nahom Tesfaye','Male','2000-01-25',GETDATE(),10,10);

select * from member;
INSERT INTO Schedule (Trainer_ID, Class_Name, Schedule_Date, Start_Time, End_Time) VALUES
(1,'Morning Fitness','2026-01-10','08:00','09:00'),
(1,'Evening Fitness','2026-01-10','17:00','18:00'),
(2,'Yoga Basics','2026-01-11','09:00','10:00'),
(2,'Advanced Yoga','2026-01-11','16:00','17:00'),
(3,'Cardio Blast','2026-01-12','07:00','08:00'),
(3,'HIIT','2026-01-12','18:00','19:00'),
(1,'Strength Training','2026-01-13','10:00','11:00'),
(2,'Stretching','2026-01-13','15:00','16:00'),
(3,'Endurance','2026-01-14','08:00','09:00'),
(1,'Body Building','2026-01-14','17:00','18:00');
select * from Schedule;

INSERT INTO Membership (Member_ID, Type, Start_Date, End_Date) VALUES
(1,'Monthly','2026-01-01','2026-01-31'),
(2,'Monthly','2026-01-01','2026-01-31'),
(3,'Quarterly','2026-01-01','2026-03-31'),
(4,'Yearly','2026-01-01','2026-12-31'),
(5,'Monthly','2026-01-01','2026-01-31'),
(6,'Quarterly','2026-01-01','2026-03-31');

INSERT INTO Membership (Member_ID, Type, Start_Date, End_Date) VALUES
(6,'yearly', '2026-12-12', '2026-12-06')


INSERT INTO Payment (Member_ID, Amount, Payment_Date, Method) VALUES
(1,500,GETDATE(),'Cash'),
(2,500,GETDATE(),'Card'),
(3,1200,GETDATE(),'Mobile'),
(4,3000,GETDATE(),'Card'),
(5,500,GETDATE(),'Cash'),
(6,1200,GETDATE(),'Mobile'),
(1,500,GETDATE(),'Cash'),
(2,500,GETDATE(),'Card'),
(3,1200,GETDATE(),'Mobile'),
(4,3000,GETDATE(),'Card');
--triggers--
GO
CREATE TRIGGER trg_CheckMembershipDates
ON Membership
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE End_Date < Start_Date
    )
    BEGIN
        RAISERROR ('End_Date cannot be before Start_Date', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;


GO
CREATE TRIGGER trg_SetPaymentDate
ON Payment
AFTER INSERT
AS
BEGIN
    UPDATE p
    SET Payment_Date = CAST(GETDATE() AS DATE)
    FROM Payment p
    JOIN inserted i ON p.Payment_ID = i.Payment_ID
    WHERE p.Payment_Date IS NULL;
END;
GO


--procedure--
go
CREATE PROCEDURE AddPayment
    @Member_ID INT,
    @Amount INT,
    @Method VARCHAR(20)
AS
BEGIN
    INSERT INTO Payment (Member_ID, Amount, Payment_Date, Method)
    VALUES (@Member_ID, @Amount, GETDATE(), @Method);
END;
go

CREATE PROCEDURE AddMembership
    @Member_ID INT,
    @Type VARCHAR(20),
    @Start_Date DATE,
    @End_Date DATE
AS
BEGIN
    INSERT INTO Membership (Member_ID, Type, Start_Date, End_Date)
    VALUES (@Member_ID, @Type, @Start_Date, @End_Date);
END;

EXEC AddPayment 1, 750, 'Cash';
SELECT * FROM Payment WHERE Member_ID = 1;

--adding a new user---
/*adding address*/
INSERT INTO Address (Phone, Email)
VALUES ('0911000011', 'newuser@gym.com');

/*Get the new Address_ID*/
DECLARE @NewAddressID INT;
SET @NewAddressID = SCOPE_IDENTITY();

/*add the user*/
INSERT INTO [User] (Username, Password, Role)
VALUES ('newtrainer', 'trainer123', 'Trainer');  -- Change Role as needed

-- Get the new User_ID
DECLARE @NewUserID INT;
SET @NewUserID = SCOPE_IDENTITY();
/* for admin*/
INSERT INTO Admin (Full_Name, Address_ID, User_ID)
VALUES ('New Admin', @NewAddressID, @NewUserID);
/* for trainer*/
INSERT INTO Trainer (Full_Name, Specialization, Experience, Address_ID, User_ID)
VALUES ('New Trainer', 'Yoga', 3, @NewAddressID, @NewUserID);
/*for member*/
INSERT INTO Member (Full_Name, Gender, Date_Of_Birth, Join_Date, Address_ID, User_ID)
VALUES ('New Member', 'Female', '2005-06-12', GETDATE(), @NewAddressID, @NewUserID);

/* if it is a trainer we have to add schedule*/
-- Get the new Trainer_ID
DECLARE @NewTrainerID INT;
SET @NewTrainerID = (SELECT Trainer_ID FROM Trainer WHERE User_ID = @NewUserID);

-- Insert a sample class--
INSERT INTO Schedule (Trainer_ID, Class_Name, Schedule_Date, Start_Time, End_Time)
VALUES (@NewTrainerID, 'Morning Yoga', '2026-01-20', '08:00', '09:00');
/*  if it is a member we have to add membership payment*/

-- Get the new Member_ID
DECLARE @NewMemberID INT;
SET @NewMemberID = (SELECT Member_ID FROM Member WHERE User_ID = @NewUserID);

-- Add Membership
INSERT INTO Membership (Member_ID, Type, Start_Date, End_Date)
VALUES (@NewMemberID, 'Monthly', '2026-01-01', '2026-01-31');

-- Add Payment
INSERT INTO Payment (Member_ID, Amount, Payment_Date, Method)
VALUES (@NewMemberID, 500, GETDATE(), 'Cash');






--testing the triggs--
INSERT INTO Membership (Member_ID, Type, Start_Date, End_Date)
VALUES (1, 'Monthly', '2026-02-10', '2026-02-01');
