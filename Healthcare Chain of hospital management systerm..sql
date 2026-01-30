# Create the Database
Create database Healthcare_db;
use Healthcare_db;
#drop database Healthcare_db; 


# create the RawData table
create table Raw_Healthcare_data_tb(
Patient_id INT AUTO_INCREMENT PRIMARY KEY,
Name varchar(100),
Age int,
Gender varchar (20),
Blood_Type varchar(4),
Medical_condition varchar(100),
Date_of_Admission Date,
Doctor Varchar(100),
Hospital Varchar(80),
Insurance_Provider Varchar(100),
Billing_Amount decimal(10,2),
Room_Number Varchar (10),
Admission_Type varchar (100),
Discharge_Date date,
Medication varchar(100),
Test_Results varchar(50),
Length_of_Stay int
);

#view
show tables;
select * from Raw_Healthcare_data_tb;

#import of data done here
select * from Raw_Healthcare_data_tb;

SHOW WARNINGS;

# 1 Patient table
create table Patient_tb(
Patient_id int auto_increment Primary key, 
Name varchar(100),
Age int,
Gender varchar(10),
Blood_Type varchar(4)
);
select * from Patient_tb;

# 2 Doctor table
create table Doctor_tb(
Doctor_id int auto_increment Primary key, 
Doctor_Name varchar(100)
);
select * from Doctor_tb;

# 3 Hospital table
create table Hospital_tb(
Hospital_id int auto_increment Primary key, 
Hospital_Name varchar(100)
);
select * from Hospital_tb;

# 4 Insurance table
create table Insurance_tb(
Insurance_id int auto_increment Primary key, 
Insurance_Name varchar(100)
);
select * from Insurance_tb;

# 5 Room table
create table Room_tb(
Room_id int auto_increment primary key,
Room_Number varchar(50)
);
select* from Room_tb;

# 6 Medication table
CREATE TABLE Medication_tb(
Medication_id INT AUTO_INCREMENT PRIMARY KEY,
Medication_Name VARCHAR(100) NOT NULL
);
select * from Medication_tb;

# 7 Medical Condition table
CREATE TABLE Medical_Condition_tb(
Condition_id int auto_increment Primary key,
Condition_Name varchar(100) not null
);
 Select* from Medical_Condition_tb;

# 8  Test table table
CREATE TABLE Test_tb(
Test_id INT AUTO_INCREMENT PRIMARY KEY,
Test_Name VARCHAR(50) NOT NULL
);
Select* from  Test_tb;

# Relation ship tables or Entity tables
# 1 Admission_tb
create Table Admission_tb(
Admission_id int auto_increment primary key,
Patient_id int,
Doctor_id int,
Hospital_id int,
Insurance_id int,
Room_id int,
Admission_Type varchar(30),
Date_of_Admission Date,
Discharge_Date Date,
Length_of_Stay int,
FOREIGN KEY (Patient_ID) REFERENCES Patient_tb(Patient_ID),
FOREIGN KEY (Doctor_ID) REFERENCES Doctor_tb(Doctor_ID),
FOREIGN KEY (Hospital_ID) REFERENCES Hospital_tb(Hospital_ID),
FOREIGN KEY (Insurance_ID) REFERENCES Insurance_tb(Insurance_ID),
FOREIGN KEY (Room_ID) REFERENCES Room_tb(Room_ID)
);
select*from Admission_tb;

# 2 Billing_tb
CREATE TABLE Billing_tb(
Billing_id INT AUTO_INCREMENT PRIMARY KEY,
Admission_id INT NOT NULL,
Billing_Amount DECIMAL(10,2),
FOREIGN KEY (Admission_id) REFERENCES Admission_tb(Admission_id)
);
select*from Billing_tb;

ALTER TABLE Billing_tb
ADD Payment_Status VARCHAR(20) DEFAULT 'Pending';

# 3 Patient_Condition_tb
CREATE TABLE Patient_Medical_Condition_tb(
Patient_id int not null,
Condition_id int not null,
PRIMARY KEY (Patient_id, Condition_id),
FOREIGN KEY (Patient_id) REFERENCES Patient_tb(Patient_id),
FOREIGN KEY (Condition_id) REFERENCES Medical_Condition_tb(Condition_id)
);
select*from Patient_Medical_Condition_tb;

# 3 Prescription_tb
CREATE TABLE Prescription_tb(
Prescription_id INT AUTO_INCREMENT PRIMARY KEY,
Patient_id INT NOT NULL,
Medication_id INT NOT NULL,
Dosage VARCHAR(50),
FOREIGN KEY (Patient_id) REFERENCES Patient_tb(Patient_id),
FOREIGN KEY (Medication_id) REFERENCES Medication_tb(Medication_id)
);
select*from Prescription_tb;

# 4 Test_Result_tb
CREATE TABLE Test_Result_tb(
Result_id INT AUTO_INCREMENT PRIMARY KEY,
Patient_id INT NOT NULL,
Test_id INT NOT NULL,
Result_Value VARCHAR(50),
FOREIGN KEY (Patient_id) REFERENCES Patient_tb(Patient_id),
FOREIGN KEY (Test_id) REFERENCES Test_tb(Test_id)
);
select*from Test_Result_tb;


 ##                                           Task 2                                                       ##
 
 Insert into Patient_tb (Name, Age, Gender, Blood_type)
 select distinct Name, Age, Gender, Blood_type 
 from Raw_Healthcare_data_tb;
 
 Insert into Doctor_tb(Doctor_Name)
 select distinct Doctor 
 from Raw_Healthcare_data_tb;
 
Insert into Hospital_tb(Hospital_Name)
select distinct Hospital 
from Raw_Healthcare_data_tb;

Insert into Insurance_tb(Insurance_Name)
select distinct Insurance_Provider
from Raw_Healthcare_data_tb;

Insert into Room_tb(Room_Number)
select distinct Room_Number
from Raw_Healthcare_data_tb;

Insert into Medication_tb(Medication_Name)
select distinct Medication
from Raw_Healthcare_data_tb;

Insert into Medical_Condition_tb(Condition_Name)
select distinct Medical_condition
from Raw_Healthcare_data_tb;

Insert into Test_tb(Test_Name)
select distinct Test_Results
from Raw_Healthcare_data_tb;

INSERT INTO Admission_tb
(Patient_id, Doctor_id, Hospital_id, Insurance_id, Room_id,
 Admission_Type, Date_of_Admission, Discharge_Date, Length_of_Stay)
SELECT 
p.Patient_id,
d.Doctor_id,
h.Hospital_id,
i.Insurance_id,
r.Room_id,
raw.Admission_Type,
raw.Date_of_Admission,
raw.Discharge_Date,
raw.Length_of_Stay
FROM Raw_Healthcare_data_tb raw
INNER JOIN Patient_tb p ON raw.Name = p.Name
INNER JOIN Doctor_tb d ON raw.Doctor = d.Doctor_Name
INNER JOIN Hospital_tb h ON raw.Hospital = h.Hospital_Name
INNER JOIN Insurance_tb i ON raw.Insurance_Provider = i.Insurance_Name
INNER JOIN Room_tb r ON raw.Room_Number = r.Room_Number;

INSERT INTO Billing_tb (Admission_id, Billing_Amount)
SELECT 
a.Admission_id,
raw.Billing_Amount
FROM Raw_Healthcare_data_tb raw
INNER JOIN Patient_tb p ON raw.Name = p.Name
INNER JOIN Admission_tb a ON 
a.Patient_id = p.Patient_id
AND a.Date_of_Admission = raw.Date_of_Admission;


SET SQL_SAFE_UPDATES = 0;
UPDATE Billing_tb
SET Payment_Status =
    CASE 
        WHEN RAND() < 0.25 THEN 'Partially Paid'
        WHEN RAND() < 0.50 THEN 'Paid'
        ELSE 'Pending'
    END;

SET SQL_SAFE_UPDATES = 1;


INSERT INTO Patient_Medical_Condition_tb (Patient_id, Condition_id)
SELECT DISTINCT
p.Patient_id,
c.Condition_id
FROM Raw_Healthcare_data_tb raw
INNER JOIN Patient_tb p ON raw.Name = p.Name
INNER JOIN Medical_Condition_tb c ON raw.Medical_condition = c.Condition_Name;


INSERT INTO Prescription_tb (Patient_id, Medication_id, Dosage)
SELECT DISTINCT
p.Patient_id,
m.Medication_id,
null
FROM Raw_Healthcare_data_tb raw
INNER JOIN Patient_tb p ON raw.Name = p.Name
INNER JOIN Medication_tb m ON raw.Medication = m.Medication_Name;

INSERT INTO Test_Result_tb (Patient_id, Test_id, Result_Value)
SELECT DISTINCT
p.Patient_id,
t.Test_id,
raw.Test_Results
FROM Raw_Healthcare_data_tb raw
INNER JOIN Patient_tb p ON raw.Name = p.Name
INNER JOIN Test_tb t ON raw.Test_Results = t.Test_Name;

# Create view

#                                              vw_total_billing_per_hospital
## VIEW 1 — Summary / Aggregation View
CREATE VIEW vw_total_billing_per_hospital AS
SELECT 
    h.Hospital_Name,
    COUNT(a.Admission_id) AS Total_Admissions,
    SUM(b.Billing_Amount) AS Total_Revenue,
    AVG(a.Length_of_Stay) AS Avg_Stay_Days
FROM Admission_tb a
INNER JOIN Hospital_tb h ON a.Hospital_id = h.Hospital_id
INNER JOIN Billing_tb b ON a.Admission_id = b.Admission_id
GROUP BY h.Hospital_Name
ORDER BY Total_Revenue DESC;
select * from vw_total_billing_per_hospital;

#                                                                  vw_monthly_admission_trends

## VIEW 2 — Trend / Performance View
CREATE VIEW vw_monthly_admission_trends AS
SELECT 
    DATE_FORMAT(a.Date_of_Admission, '%Y-%m') AS Month,
    COUNT(a.Admission_id) AS Total_Admissions,
    SUM(b.Billing_Amount) AS Monthly_Revenue,
    AVG(a.Length_of_Stay) AS Avg_Stay
FROM Admission_tb a
INNER JOIN Billing_tb b ON a.Admission_id = b.Admission_id
GROUP BY DATE_FORMAT(a.Date_of_Admission, '%Y-%m')
ORDER BY Month;
select * from vw_monthly_admission_trends;


 ##                                           Task 3                                                       ##
#Query 1
#Which doctors generated the highest total billing amount and it is the asset for the hospital.
SELECT 
    d.Doctor_Name,
    COUNT(a.Admission_id) AS Total_Patients,
    SUM(b.Billing_Amount) AS Total_Revenue
FROM Doctor_tb d
INNER JOIN Admission_tb a ON d.Doctor_id = a.Doctor_id
INNER JOIN Billing_tb b ON a.Admission_id = b.Admission_id
GROUP BY d.Doctor_Name
ORDER BY Total_Revenue DESC;
#How many patients each doctor treated  
#Total revenue generated by each doctor  
#Identifies top performing doctors based on revenue contribution

#Query 2
#Which hospitals have an average stay length greater than 5 days?
SELECT 
    h.Hospital_Name,
    AVG(a.Length_of_Stay) AS Avg_Stay
FROM Hospital_tb h
INNER JOIN Admission_tb a ON h.Hospital_id = a.Hospital_id
GROUP BY h.Hospital_Name
HAVING AVG(a.Length_of_Stay) > 5;
#Helps identify hospitals with longer patient stays, which may indicate:
#- More severe cases  
#- Inefficient discharge processes  


#Query 3
#Categorize patients based on billing amount.
SELECT 
    p.Name,
    b.Billing_Amount,
    CASE
        WHEN b.Billing_Amount > 5000 THEN 'High Billing'
        WHEN b.Billing_Amount BETWEEN 2000 AND 5000 THEN 'Medium Billing'
        ELSE 'Low Billing'
    END AS Billing_Category
FROM Patient_tb p
INNER JOIN Admission_tb a ON p.Patient_id = a.Patient_id
INNER JOIN Billing_tb b ON a.Admission_id = b.Admission_id;
#This classifies patients into High, Medium, or Low billing categories.
#Identifying high‑cost patients  
#Financial segmentation  

#Query 4 — Subquery (Correlated)
#Find patients whose billing amount is above the average billing of all patients.
SELECT 
    p.Name,
    b.Billing_Amount
FROM Patient_tb p
INNER JOIN Admission_tb a ON p.Patient_id = a.Patient_id
INNER JOIN Billing_tb b ON a.Admission_id = b.Admission_id
WHERE b.Billing_Amount > (
    SELECT AVG(Billing_Amount) FROM Billing_tb
);
#A subquery calculates the overall average billing, and the outer query returns patients above that threshold.
#Identifies high‑value or high‑risk patients, useful for:Insurance claims, Cost management, Financial forecasting  


# Query 5 Window Function
sELECT * FROM pATIENT_TB;
#Rank patients based on their billing amount (highest to lowest).
SELECT 
    p.Name,
    b.Billing_Amount,
    RANK() OVER (ORDER BY b.Billing_Amount DESC) AS Billing_Rank
FROM Patient_tb p
INNER JOIN Admission_tb a ON p.Patient_id = a.Patient_id
INNER JOIN Billing_tb b ON a.Admission_id = b.Admission_id;
###Procedure:Get total billing for a given patient
#This stored procedure accepts a patient name and returns the total billing amount for that patient.
### Function: Calculate length of stay category

##FUNCTION==
DELIMITER $$
CREATE FUNCTION StayCategory(stay INT)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE category VARCHAR(20);

    IF stay > 10 THEN
        SET category = 'Long Stay';
    ELSEIF stay BETWEEN 5 AND 10 THEN
        SET category = 'Medium Stay';
    ELSE
        SET category = 'Short Stay';
    END IF;

    RETURN category;
END $$
DELIMITER ;
### **Explanation**
#This function categorizes a patient’s stay length into:Long Stay, Medium Stay, Short Stay  


#                                                           Task 5                                                       #
# query which is need to be optimised.
SELECT 
    p.Name,
    b.Billing_Amount
FROM Patient_tb p
JOIN Admission_tb a ON p.Patient_id = a.Patient_id
JOIN Billing_tb b ON a.Admission_id = b.Admission_id
WHERE b.Billing_Amount > (SELECT AVG(Billing_Amount) FROM Billing_tb);

# 1st optomisation
CREATE INDEX idx_billing_amount ON Billing_tb(Billing_Amount);
CREATE INDEX idx_patient ON Admission_tb(Patient_id);


#  2nd optimisation
SET @avg_bill = (SELECT AVG(Billing_Amount) FROM Billing_tb);

SELECT 
    p.Name,
    b.Billing_Amount
FROM Patient_tb p
JOIN Admission_tb a ON p.Patient_id = a.Patient_id
JOIN Billing_tb b ON a.Admission_id = b.Admission_id
WHERE b.Billing_Amount > @avg_bill;




