-- Create a new database for managing the dentist polyclinic
CREATE DATABASE dentists_polyclinic;

-- Create a table to store insurance information
CREATE TABLE Insurance (
    insurance_id INTEGER NOT NULL, -- Unique identifier for each insurance
    company_name VARCHAR(50) NOT NULL, -- Name of the insurance company
    start_date DATE NOT NULL, -- Start date of the insurance coverage
    end_date DATE NOT NULL, -- End date of the insurance coverage
    co_insurance DECIMAL(5,2), -- Co-insurance percentage
    PRIMARY KEY (insurance_id) -- Set insurance_id as the primary key
);

-- Select insurance IDs that have more than one distinct company name associated with them
SELECT insurance_id
FROM insurance
GROUP BY insurance_id
HAVING COUNT(DISTINCT company_name) > 1;

-- (Concept of Indexing)
-- Creates an index named Insurance_Company_Name on the company_name column of the Insurance table. 
-- This index speeds up queries that search or filter based on company_name by allowing the database to quickly locate rows.
-- ABC Insurance -> [Row 1, Row 3]
-- DEF Insurance -> [Row 4]
-- XYZ Insurance -> [Row 2, Row 5]
CREATE INDEX Insurance_Company_Name
ON Insurance (company_name);

-- Describe the structure of the insurance table
DESC insurance;

-- Retrieve all records from the insurance table
SELECT * FROM insurance;

-- Insert records into the insurance table
INSERT INTO insurance VALUES (101, 'National Insurance Co.Ltd', '2011-03-12', '2020-04-10', 55);
INSERT INTO insurance VALUES (102, 'Go Digital General Insurance', '2011-09-12', '2023-04-10', 40);
INSERT INTO insurance VALUES (103, 'HDFC ERGO General Insurance', '2010-06-01', '2024-05-07', 60);
INSERT INTO insurance VALUES (104, 'HDFC ERGO General Insurance', '2010-06-01', '2024-05-07', 60);
INSERT INTO insurance VALUES (105, 'National Insurance Co.Ltd', '2008-03-09', '2022-09-23', 30);
INSERT INTO insurance VALUES (106, 'National Insurance Co.Ltd', '2008-03-09', '2022-09-23', 30);

-- Describe the structure of the insurance table again to see the updated records
DESC insurance;

-- Retrieve all records from the insurance table again to see the updated records
SELECT * FROM insurance;

-- Create a table to store patient information
CREATE TABLE patient1 (
    patient_id INTEGER NOT NULL, -- Unique identifier for each patient
    polyclinic_name VARCHAR(20) NOT NULL, -- Name of the polyclinic
    patient_name VARCHAR(20) UNIQUE NOT NULL, -- Name of the patient (must be unique)
    dob DATE NOT NULL, -- Date of birth of the patient
    insurance_id INTEGER, -- Foreign key referencing insurance
    FOREIGN KEY (insurance_id) REFERENCES insurance(insurance_id), -- Establish foreign key relationship
    sex CHAR(4) NOT NULL, -- Gender of the patient
    Problem_or_Disease VARCHAR(50) NOT NULL, -- Problem or disease diagnosed
    dno INTEGER NOT NULL, -- Doctor number (foreign key)
    doc_id INTEGER NOT NULL, -- Doctor ID (foreign key)
    registration_time TIME NOT NULL, -- Time of registration
    registration_date DATE NOT NULL, -- Date of registration
    PRIMARY KEY (patient_id), -- Set patient_id as the primary key
    FOREIGN KEY (doc_id) REFERENCES doctor_info(doc_id) -- Establish foreign key relationship
);

-- When you insert, update, or delete a large number of rows in a table that has foreign key constraints, 
-- MySQL will normally check each operation to ensure that it does not violate the foreign key constraints. This can slow down the operation significantly.
-- Disable foreign key checks temporarily for bulk insert operations
SET FOREIGN_KEY_CHECKS=0;

-- Describe the structure of the patient1 table
DESC patient1;

-- Insert records into the patient1 table
INSERT INTO patient1 VALUES
(1, 'Dental Polyclinic', 'Mr.Mohit', '1967-03-25', 101, 'M', 'Soft tissue Inflammation', 1, 100, '17:00:00', '2022-03-19'),
(2, 'Dental Polyclinic', 'Mr.Andrews', '1978-02-04', 102, 'M', 'Gum Disease', 2, 300, '14:00:00', '2022-03-20'),
(3, 'Dental Polyclinic', 'Mrs.Sneha', '1987-07-28', 103, 'F', 'Deep Decay', 1, 200, '17:00:00', '2022-03-21'),
(4, 'Dental Polyclinic', 'Mr.Ramesh', '1983-08-21', 104, 'M', 'Cavities', 3, 400, '21:00:00', '2022-03-19'),
(5, 'Dental Polyclinic', 'Ms.Khushi', '1998-01-16', 105, 'F', 'Missing Teeth', 3, 400, '17:00:00', '2022-03-20'),
(6, 'Dental Polyclinic', 'Ms.Franceska', '2000-03-19', 106, 'F', 'Mobile Teeth', 3, 500, '18:00:00', '2022-03-19');

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS=1;

-- Retrieve all records from the patient1 table
SELECT * FROM patient1;

-- Describe the structure of the patient1 table again to see the updated records
DESC patient1;

-- Create a table to store patient phone numbers
CREATE TABLE PATIENT_PHONE (
    patient_id INTEGER NOT NULL, -- Foreign key referencing patient1
    FOREIGN KEY (patient_id) REFERENCES patient1(patient_id), -- Establish foreign key relationship
    Phone_number NUMERIC NOT NULL -- Phone number of the patient
);

-- Insert records into the patient_phone table
INSERT INTO patient_phone VALUES
(1, 9821000690),
(1, 8999452345),
(2, 9811223300),
(2, 9786577724),
(3, 9013211091),
(4, 9210747010),
(5, 9900887045),
(5, 9900889085),
(6, 9601887095);

-- Describe the structure of the patient_phone table
DESC patient_phone;

-- Retrieve all records from the patient_phone table
SELECT * FROM patient_phone;

-- Update the co-insurance percentage for insurance policies that have expired before the patient’s registration date in clinic
-- This query updates the co_insurance to 0 for policies that have expired before the patient registered,
-- meaning that the expired insurance no longer contributes to coverage and the patient will be responsible for the full charge.
UPDATE INSURANCE
JOIN PATIENT1
ON PATIENT1.INSURANCE_ID = INSURANCE.INSURANCE_ID AND INSURANCE.END_DATE < PATIENT1.REGISTRATION_DATE
SET INSURANCE.co_insurance = 0;

-- Select patient names and IDs from visits, grouping by patient
SELECT patient_name, patient_id
FROM VISITS
GROUP BY patient_name, patient_id
HAVING COUNT(DISTINCT Final_Details) > 1;

-- Create a table to store visit information based on registration criteria
-- Populate it with the results of a SELECT query.
CREATE TABLE VISITS AS (
    -- Select the columns to be included in the new table
    SELECT patient_name, patient_id, registration_time, registration_date,
    -- Compute a new column 'Final_Details' based on the value of 'registration_time' and 'registration_date'
    CASE
        WHEN registration_time < '16:00:00' THEN 'SORRY ! COME WITHIN THE SPECIFIED TIMINGS'
        WHEN registration_time > '20:30:00' THEN 'SORRY ! COME WITHIN THE SPECIFIED TIMINGS'
        WHEN DAYNAME(registration_date) NOT IN ('MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY') THEN
            'SORRY ! WE ARE OPEN ONLY FROM MONDAY-SATURDAY'
        ELSE 'REGISTRATION CAN BE DONE'
    END AS Final_Details    -- Alias the computed column as 'Final_Details'
    FROM patient1
);

-- Retrieve all records from the visits table
SELECT * FROM VISITS;

-- Alter the visits table to add a foreign key constraint on patient_id
ALTER TABLE VISITS ADD CONSTRAINT FOREIGN KEY (patient_id) REFERENCES patient1(patient_id);

-- Alter the visits table to add a primary key constraint on patient_id
ALTER TABLE VISITS ADD CONSTRAINT PRIMARY KEY(patient_id);

-- Alter the visits table to add a foreign key constraint on patient_name
ALTER TABLE VISITS ADD CONSTRAINT FOREIGN KEY (patient_name) REFERENCES patient1(patient_name);

-- Describe the structure of the visits table
DESC visits;

-- Create a table to store previous visits of patients
CREATE TABLE previous_visits (
    patient_id INTEGER NOT NULL, -- Foreign key referencing patient1
    FOREIGN KEY (patient_id) REFERENCES patient1(patient_id), -- Establish foreign key relationship
    visits DATE NOT NULL, -- Date of previous visit
    prev_treatment_taken_from_this_clinic VARCHAR(50) NOT NULL -- Treatment history
);

-- Select patient IDs and visit dates from previous visits, grouping by patient
SELECT patient_id, visits
FROM previous_visits
GROUP BY patient_id, visits
HAVING COUNT(DISTINCT prev_treatment_taken_from_this_clinic) > 1;

-- Insert records into the previous_visits table
INSERT INTO previous_visits VALUES
(1, '2017-08-11', 'Root Canal'),
(1, '2019-02-07', 'Root Canal'),
(2, '2016-12-11', 'Gums'),
(2, '2018-12-11', 'Gums'),
(3, '2018-03-10', 'Cavities'),
(4, '2018-03-23', 'Missing Teeth'),
(5, '2017-10-25', 'Mobile Teeth');

-- Retrieve all records from the previous_visits table
SELECT * FROM previous_visits;

-- Describe the structure of the previous_visits table
DESC previous_visits;

-- Create a table for new patients who have no previous visits
-- Create this new table 'new_patients' based on the data from 'patient1'
CREATE TABLE new_patients AS (
    SELECT patient_id, patient_name, insurance_id     -- Select relevant columns from 'patient1'
    FROM patient1 
    WHERE NOT EXISTS (        -- Include only those patients who are not present in the 'previous_visits' table
        SELECT patient_id 
        FROM previous_visits 
        WHERE patient1.patient_id = previous_visits.patient_id
    )
);

-- Add a column for new patients with a welcome message
ALTER TABLE new_patients ADD New_patient VARCHAR(50) DEFAULT 'WELCOME! YOUR FIRST CHECKUP IS FREE' NOT NULL;

-- Add a column for discount given to new patients
ALTER TABLE new_patients ADD discount_given DECIMAL(5,2) DEFAULT 100;

-- Set patient_id as the primary key for new_patients table
ALTER TABLE new_patients ADD PRIMARY KEY (patient_id);

-- Establish foreign key relationships for new_patients table
ALTER TABLE new_patients ADD FOREIGN KEY (patient_id) REFERENCES patient1(patient_id);
ALTER TABLE new_patients ADD FOREIGN KEY (patient_name) REFERENCES patient1(patient_name);
ALTER TABLE new_patients ADD FOREIGN KEY (insurance_id) REFERENCES patient1(insurance_id);

-- Retrieve all records from the new_patients table
SELECT * FROM new_patients;

-- Describe the structure of the new_patients table
DESCRIBE new_patients;

-- Create a table for regular patients who have had at least two previous visits
-- Create this new table 'regular_patients' based on the data from 'patient1'
CREATE TABLE regular_patients AS
SELECT patient_id, patient_name, insurance_id        -- Select relevant columns from 'patient1'
FROM patient1                    -- Include only those patients whose IDs are present in the subquery results
WHERE patient_id IN (            -- Subquery to find patients with at least 2 visits
    SELECT patient_id
    FROM previous_visits
    GROUP BY patient_id
    HAVING COUNT(previous_visits.patient_id) >= 2
);

-- Add a column for discount given to regular patients
ALTER TABLE regular_patients ADD discount_given DECIMAL(5,2) DEFAULT 10;

-- Set patient_id as the primary key for regular_patients table
ALTER TABLE regular_patients ADD PRIMARY KEY(patient_id);

-- Establish foreign key relationships for regular_patients table
ALTER TABLE regular_patients ADD FOREIGN KEY (patient_id) REFERENCES patient1(patient_id);
ALTER TABLE regular_patients ADD FOREIGN KEY (patient_name) REFERENCES patient1(patient_name);
ALTER TABLE regular_patients ADD FOREIGN KEY (insurance_id) REFERENCES patient1(insurance_id);

-- Retrieve all records from the regular_patients table
SELECT * FROM regular_patients;

-- Describe the structure of the regular_patients table
DESC regular_patients;

-- Create a table to store doctor information
CREATE TABLE doctor_info (
    doc_id INTEGER NOT NULL PRIMARY KEY, -- Unique identifier for each doctor
    salary_slipno INTEGER NOT NULL UNIQUE, -- Unique salary slip number for each doctor
    doc_name VARCHAR(20) NOT NULL, -- Name of the doctor
    Dep_no INTEGER NOT NULL, -- Department number (foreign key)
    Dep_name VARCHAR(20) NOT NULL, -- Department name (foreign key)
    FOREIGN KEY (Dep_no) REFERENCES department(Dep_no), -- Establish foreign key relationship
    FOREIGN KEY (Dep_name) REFERENCES department(dep_name) -- Establish foreign key relationship
);

-- Insert records into the doctor_info table
INSERT INTO doctor_info VALUES
(100, 100, 'Dr. Rai', 1, 'Endodontist'),
(200, 101, 'Dr. Pathak', 1, 'Endodontist'),
(300, 102, 'Dr. Suneeta', 2, 'Periodontist'),
(400, 103, 'Dr. David', 3, 'General Dentist'),
(500, 104, 'Dr. James', 3, 'General Dentist');

-- Alter the doctor_info table to add a foreign key constraint on salary_slipno
ALTER TABLE doctor_info ADD CONSTRAINT FOREIGN KEY (salary_slipno) REFERENCES doc_salary (salary_slipno);

-- Describe the structure of the doctor_info table
DESC doctor_info;

-- Retrieve all records from the doctor_info table
SELECT * FROM doctor_info;

-- Create a table to store doctor phone numbers
CREATE TABLE doctor_phone (
    doc_id INTEGER NOT NULL, -- Foreign key referencing doctor_info
    FOREIGN KEY (doc_id) REFERENCES doctor_info(doc_id), -- Establish foreign key relationship
    Phone_number NUMERIC NOT NULL -- Phone number of the doctor
);

-- Insert records into the doctor_phone table
INSERT INTO doctor_phone VALUES
(100, 9821054690),
(100, 8976452345),
(200, 9811223344),
(200, 9786574624),
(300, 9143211091),
(400, 9213447010),
(500, 9900887755);

-- Describe the structure of the doctor_phone table
DESC doctor_phone;

-- Retrieve all records from the doctor_phone table
SELECT * FROM doctor_phone;

-- Create a table to store doctor salaries
CREATE TABLE doc_salary (
    salary_slipno INTEGER PRIMARY KEY, -- Unique identifier for each salary slip
    salary NUMERIC NOT NULL, -- Salary amount
    Number_of_years_working INTEGER NOT NULL, -- Number of years the doctor has been working
    FOREIGN KEY (salary_slipno) REFERENCES doctor_info(salary_slipno) -- Establish foreign key relationship with doctor_info
);

-- Insert salary records for doctors into the doc_salary table
INSERT INTO doc_salary VALUES (100, 500000, 4); -- Doctor with salary slip number 100, earning 500,000 with 4 years of experience
INSERT INTO doc_salary VALUES (101, 250200, 1); -- Doctor with salary slip number 101, earning 250,200 with 1 year of experience
INSERT INTO doc_salary VALUES (102, 512200, 5); -- Doctor with salary slip number 102, earning 512,200 with 5 years of experience
INSERT INTO doc_salary VALUES (103, 700000, 8); -- Doctor with salary slip number 103, earning 700,000 with 8 years of experience
INSERT INTO doc_salary VALUES (104, 656666, 6); -- Doctor with salary slip number 104, earning 656,666 with 6 years of experience

-- Describe the structure of the doc_salary table to view its columns and types
DESC doc_salary;

-- Retrieve all records from the doc_salary table
SELECT * FROM doc_salary;

-- Create a table to store department information
CREATE TABLE department (
    dep_no INTEGER NOT NULL, -- Unique identifier for each department
    dep_name VARCHAR(20) UNIQUE NOT NULL, -- Name of the department (must be unique)
    PRIMARY KEY (dep_no) -- Set dep_no as the primary key
);

-- Insert department records into the department table
INSERT INTO department VALUES (1, 'Endodontist'); -- Department for endodontics
INSERT INTO department VALUES (2, 'Periodontist'); -- Department for periodontics
INSERT INTO department VALUES (3, 'General Dentist'); -- Department for general dentistry

-- Describe the structure of the department table
DESC department;

-- Retrieve all records from the department table
SELECT * FROM department;

-- Create a table to store endodontist treatment information
CREATE TABLE endodontist (
    doc_id INTEGER NOT NULL, -- Foreign key referencing doctor_info
    FOREIGN KEY (doc_id) REFERENCES doctor_info(doc_id), -- Establish foreign key relationship with doctor_info
    root_canal VARCHAR(100) NOT NULL, -- Description of the root canal treatment
    charges INTEGER NOT NULL -- Charges for the treatment
);

-- Insert endodontist treatment records into the endodontist table
INSERT INTO endodontist VALUES (100, 'Soft tissue inflammation', 4000); -- Treatment for doc_id 100
INSERT INTO endodontist VALUES (200, 'Deep decay', 7000); -- Treatment for doc_id 200

-- Describe the structure of the endodontist table
DESC endodontist;

-- Create a table to store periodontist treatment information
CREATE TABLE periodontist (
    doc_id INTEGER NOT NULL PRIMARY KEY, -- Unique identifier for each periodontist
    FOREIGN KEY (doc_id) REFERENCES doctor_info(doc_id), -- Establish foreign key relationship with doctor_info
    gums VARCHAR(100) NOT NULL, -- Description of the gum treatment
    price INTEGER NOT NULL -- Price for the treatment
);

-- Insert periodontist treatment records into the periodontist table
INSERT INTO periodontist VALUES (300, 'Gum Disease', 6000); -- Treatment for doc_id 300

-- Retrieve all records from the periodontist table
SELECT * FROM periodontist;

-- Describe the structure of the periodontist table
DESC periodontist;

-- Create a table to store general dentist treatment information
CREATE TABLE gen_dentist (
    doc_id INTEGER NOT NULL, -- Foreign key referencing doctor_info
    FOREIGN KEY (doc_id) REFERENCES doctor_info(doc_id), -- Establish foreign key relationship with doctor_info
    cavities_OR_missing_teeth_OR_mobile_teeth VARCHAR(20) NOT NULL, -- Description of the treatment
    PRICE INTEGER NOT NULL -- Price for the treatment
);

-- Insert general dentist treatment records into the gen_dentist table
INSERT INTO gen_dentist VALUES (400, 'Cavities', 2000); -- Treatment for doc_id 400
INSERT INTO gen_dentist VALUES (400, 'Missing Teeth', 2500); -- Treatment for doc_id 400
INSERT INTO gen_dentist VALUES (400, 'Mobile Teeth', 2700); -- Treatment for doc_id 400
INSERT INTO gen_dentist VALUES (500, 'Cavities', 3000); -- Treatment for doc_id 500
INSERT INTO gen_dentist VALUES (500, 'Missing Teeth', 3500); -- Treatment for doc_id 500
INSERT INTO gen_dentist VALUES (500, 'Mobile Teeth', 3700); -- Treatment for doc_id 500

-- Retrieve all records from the gen_dentist table
SELECT * FROM gen_dentist;

-- Describe the structure of the gen_dentist table
DESC gen_dentist;

-- Create new table 'TOTAL_BILL' based on the calculated charges from different conditions
CREATE TABLE TOTAL_BILL AS (
    -- Select relevant columns along with calculated charges
    SELECT Patient_id, insurance_id, patient_name,
    CASE
        WHEN (patient1.doc_id=100 AND Dno=1) THEN (SELECT charges FROM endodontist WHERE doc_id=100)    -- If doc_id is 100 and Dno is 1, retrieve the charges from the 'endodontist' table for doc_id 100
        WHEN (patient1.doc_id=200 AND Dno=1) THEN (SELECT charges FROM endodontist WHERE doc_id=200)
        WHEN (patient1.doc_id=300 AND Dno=2) THEN (SELECT price FROM periodontist WHERE doc_id=300)
        WHEN (patient1.doc_id=400 AND Dno=3 AND Problem_or_Disease LIKE 'Cavities') THEN (SELECT price FROM gen_dentist WHERE (doc_id=400 AND cavities_OR_missing_teeth_OR_mobile_teeth LIKE 'Cavities'))
        WHEN (patient1.doc_id=400 AND Dno=3 AND Problem_or_Disease LIKE 'Missing Teeth') THEN (SELECT price FROM gen_dentist WHERE (doc_id=400 AND cavities_OR_missing_teeth_OR_mobile_teeth LIKE 'Missing Teeth'))
        WHEN (doc_id=400 AND Dno=3 AND Problem_or_Disease LIKE 'Mobile Teeth') THEN (SELECT price FROM gen_dentist WHERE (doc_id=400 AND cavities_OR_missing_teeth_OR_mobile_teeth LIKE 'Mobile Teeth'))
        WHEN (doc_id=500 AND Dno=3 AND Problem_or_Disease LIKE 'Cavities') THEN (SELECT price FROM gen_dentist WHERE (doc_id=500 AND cavities_OR_missing_teeth_OR_mobile_teeth LIKE 'Cavities'))
        WHEN (doc_id=500 AND Dno=3 AND Problem_or_Disease LIKE 'Missing Teeth') THEN (SELECT price FROM gen_dentist WHERE (doc_id=500 AND cavities_OR_missing_teeth_OR_mobile_teeth LIKE 'Missing Teeth'))
        WHEN (doc_id=500 AND Dno=3 AND Problem_or_Disease LIKE 'Mobile Teeth') THEN (SELECT price FROM gen_dentist WHERE (doc_id=500 AND cavities_OR_missing_teeth_OR_mobile_teeth LIKE 'Mobile Teeth'))
        ELSE 0 -- Default case if no conditions are met
    END AS charges    -- Finalizes the CASE statement and assigns the calculated value to the 'charges' column, this column represents the total charges based on the specified conditions
    FROM patient1     -- Source table for patient data
);

-- Retrieve all records from the total_bill table
SELECT * FROM total_bill;

-- Describe the structure of the total_bill table
DESC total_bill;

-- Disable safe updates to allow updates on the total_bill table
SET SQL_SAFE_UPDATES = 0;

-- Add a column for discounts given to patients in the total_bill table
ALTER TABLE total_bill ADD discount_given INTEGER NOT NULL;

-- Update the total_bill table to apply discounts for regular patients
UPDATE total_bill e
INNER JOIN regular_patients r ON e.patient_id = r.patient_id
SET e.discount_given = (charges * r.discount_given / 100.00); -- Calculate discount based on charges

-- Retrieve updated records from the total_bill table
SELECT * FROM total_bill;

-- Update the total_bill table to apply discounts for new patients
UPDATE total_bill e
INNER JOIN new_patients n ON e.patient_id = n.patient_id
SET e.discount_given = (charges * n.discount_given / 100.00); -- Calculate discount based on charges

-- Retrieve updated records from the total_bill table
SELECT * FROM total_bill;

-- Add a column for charges after discount in the total_bill table
ALTER TABLE total_bill ADD column charge_after_discount INTEGER NOT NULL;

-- Update the total_bill table to calculate charges after applying discounts
UPDATE total_bill SET charge_after_discount = charges - discount_given;

-- Add a column for money covered by insurance in the total_bill table
ALTER TABLE total_bill ADD Money_Insurance INTEGER NOT NULL;

-- Update the total_bill table to calculate insurance coverage
UPDATE total_bill e
INNER JOIN insurance i ON e.insurance_id = i.insurance_id
SET Money_insurance = ((charge_after_discount) * co_insurance / 100.00); -- Calculate insurance amount

-- Retrieve updated records from the total_bill table
SELECT * FROM total_bill;

-- Add a column for patient payment amount in the total_bill table
ALTER TABLE total_bill ADD Patient_Pay INTEGER NOT NULL;

-- Update the total_bill table to calculate insurance coverage amount
UPDATE total_bill e
INNER JOIN insurance i ON e.insurance_id = i.insurance_id -- Join total_bill table with insurance table based on insurance_id
SET e.Money_insurance = CASE
    WHEN i.co_insurance = 0 THEN 0 -- If co-insurance is 0%, set Money_insurance to 0
    ELSE (e.charge_after_discount * i.co_insurance / 100.00) -- Otherwise, calculate the insurance amount
END;

-- Describe the structure of the total_bill table
DESC total_bill;

-- Add a column for bill number in the total_bill table
ALTER TABLE total_bill ADD bill_no INTEGER NOT NULL;

-- Add a primary key constraint on bill_no and patient_id
ALTER TABLE total_bill ADD PRIMARY KEY(bill_no, patient_id);

-- Modify the bill_no column to auto-increment
ALTER TABLE total_bill MODIFY COLUMN bill_no INTEGER NOT NULL AUTO_INCREMENT;

-- Add a column for cashier ID in the total_bill table
ALTER TABLE total_bill ADD cashier_id INTEGER NOT NULL;

-- Add foreign key constraints for cashier_id and insurance_id in the total_bill table
ALTER TABLE total_bill ADD FOREIGN KEY(cashier_id) REFERENCES cashier(cashier_id);
ALTER TABLE total_bill ADD FOREIGN KEY(Insurance_id) REFERENCES patient1(insurance_id);
ALTER TABLE total_bill ADD FOREIGN KEY(patient_id) REFERENCES patient1(patient_id);
ALTER TABLE total_bill ADD FOREIGN KEY(patient_name) REFERENCES patient1(patient_name);

-- Update cashier_id based on bill number
UPDATE total_bill SET cashier_id = 301 WHERE (bill_no % 2 = 0); -- Even bill numbers assigned to cashier 301
UPDATE total_bill SET cashier_id = 302 WHERE (bill_no % 2 != 0); -- Odd bill numbers assigned to cashier 302

-- Describe the structure of the total_bill table
DESC total_bill;

-- Create a table to store dependents of patients
CREATE TABLE dependents (
    depen_name VARCHAR(100), -- Name of the dependent
    phone_no NUMERIC NOT NULL, -- Phone number of the dependent
    patient_id INTEGER, -- Foreign key referencing patient1
    FOREIGN KEY(patient_id) REFERENCES patient1(patient_id), -- Establish foreign key relationship with patient1
    PRIMARY KEY(patient_id, depen_name) -- Set composite primary key
);

-- Insert dependent records into the dependents table
INSERT INTO dependents VALUES ('Ramesh', 9165625400, 1); -- Dependent for patient_id 1
INSERT INTO dependents VALUES ('Fin', 9165623880, 2); -- Dependent for patient_id 2
INSERT INTO dependents VALUES ('Lokesh', 9789879765, 3); -- Dependent for patient_id 3
INSERT INTO dependents VALUES ('Abhishek', 9914323523, 4); -- Dependent for patient_id 4
INSERT INTO dependents VALUES ('Anjali', 9678229119, 5); -- Dependent for patient_id 5
INSERT INTO dependents VALUES ('Arthur', 9678229119, 5); -- Another dependent for patient_id 5

-- Retrieve all records from the dependents table
SELECT * FROM dependents;

-- Describe the structure of the dependents table
DESC dependents;

-- Create a table to store medical history of patients
CREATE TABLE medic_hist (
    patient_id INTEGER, -- Foreign key referencing patient1
    FOREIGN KEY(patient_id) REFERENCES patient1(patient_id), -- Establish foreign key relationship with patient1
    past_treatment VARCHAR(50), -- Description of past treatments
    allergies VARCHAR(50), -- Allergies of the patient
    pain_tooth VARCHAR(50), -- Tooth pain description
    heart_probs VARCHAR(50), -- Heart problems of the patient
    other_illness VARCHAR(50), -- Other illnesses of the patient
    PRIMARY KEY(patient_id, past_treatment) -- Set composite primary key
);

-- Insert medical history records into the medic_hist table
INSERT INTO medic_hist VALUES (1, 'Root Canal', 'Penicillin', NULL, 'High BP', 'Diabetes'); -- Patient 1
INSERT INTO medic_hist VALUES (2, 'Root Canal', NULL, 'Upper Left Tooth', NULL, 'Rhinitis'); -- Patient 2
INSERT INTO medic_hist VALUES (3, 'Loose Teeth', 'Pollen', NULL, 'High BP', 'Arthritis'); -- Patient 3
INSERT INTO medic_hist VALUES (4, 'Decay', 'Pollen', 'Lower Left Side', NULL, NULL); -- Patient 4
INSERT INTO medic_hist VALUES (5, 'Gingivitis', 'Lignocaine', 'Lower Right Side', 'High BP', 'Cardiac Problem'); -- Patient 5
INSERT INTO medic_hist VALUES (1, 'Loose teeth', NULL, 'Upper Left Tooth', NULL, 'Rhinitis'); -- Patient 1

-- Retrieve all records from the medic_hist table
SELECT * FROM medic_hist;

-- Describe the structure of the medic_hist table
DESC medic_hist;

-- Create a table to store cashier information
CREATE TABLE cashier (
    Name VARCHAR(20) NOT NULL, -- Name of the cashier
    cashier_id INTEGER NOT NULL PRIMARY KEY, -- Unique identifier for each cashier
    salary INTEGER NOT NULL -- Salary of the cashier
);

-- Insert cashier records into the cashier table
INSERT INTO cashier VALUES ('Amit', 301, 3000); -- Cashier Amit
INSERT INTO cashier VALUES ('Rohit', 302, 400); -- Cashier Rohit

-- Count the number of cashiers in the cashier table
SELECT COUNT(*) FROM cashier;

-- Retrieve all records from the cashier table
SELECT * FROM cashier;

-- Create a table to store cashier phone numbers
CREATE TABLE cashier_PHONE (
    cashier_id INTEGER NOT NULL, -- Foreign key referencing cashier
    FOREIGN KEY(cashier_id) REFERENCES cashier(cashier_id), -- Establish foreign key relationship with cashier
    Phone_number NUMERIC NOT NULL -- Phone number of the cashier
);

-- Insert phone numbers for cashiers into the cashier_phone table
INSERT INTO cashier_phone VALUES (301, 9999765642), (301, 6542758545), (302, 8645324455), (302, 7689000678); -- Cashier phone numbers

-- Add a primary key constraint on phone_number in the cashier_phone table
ALTER TABLE cashier_phone ADD CONSTRAINT PRIMARY KEY(phone_number);

-- Describe the structure of the cashier table
DESC cashier;

-- Describe the structure of the cashier_phone table
DESC cashier_phone;

-- Retrieve distinct cashier IDs from the cashier_phone table
SELECT DISTINCT cashier_id FROM cashier_phone;

-- Count distinct cashier IDs in the cashier_phone table
SELECT COUNT(DISTINCT(cashier_id)) FROM cashier_phone;

-- Retrieve all records from the cashier_phone table
SELECT * FROM cashier_phone;

-- Some Questions Related To Above Database

-- Question 01: Retrieve patients with a history of high blood pressure
-- This query selects all patients from 'patient1' who have 'High BP' recorded in their medical history.
SELECT * 
FROM patient1 
WHERE patient_id IN (
    SELECT patient_id 
    FROM medic_hist 
    WHERE heart_probs = 'High BP'
);

-- Question 02: Join cashier and cashier_phone tables to retrieve cashier details
-- This query retrieves the names, IDs, salaries, and phone numbers of cashiers by joining the 'cashier' and 'cashier_phone' tables.
-- The join uses a comma-separated list of tables, which performs a Cartesian product filtered by the ON condition.
SELECT 
    cashier.Name, 
    cashier.cashier_id, 
    salary, 
    phone_number 
FROM 
    cashier, 
    cashier_phone 
WHERE 
    cashier.cashier_id = cashier_phone.cashier_id;

-- Left outer join to include cashiers without phone numbers
-- This query performs a LEFT OUTER JOIN to include all cashiers, even those who do not have an associated phone number.
SELECT 
    cashier.name, 
    cashier.cashier_id, 
    salary, 
    phone_number 
FROM 
    cashier 
LEFT OUTER JOIN 
    cashier_phone 
ON 
    cashier.cashier_id = cashier_phone.cashier_id;

-- Question 03: Retrieve patients who do not have any dependents
-- This query retrieves all patients from 'patient1' who do not have entries in the 'dependents' table.
SELECT * 
FROM patient1 
WHERE patient_id NOT IN (
    SELECT patient_id 
    FROM dependents
);

-- Question 04: Retrieve doctor information for doctors with multiple phone numbers
-- This query retrieves details of doctors who have more than one phone number.
-- It joins the 'doctor_info', 'doctor_phone', and 'doc_salary' tables to provide comprehensive information.
SELECT 
    doctor_info.doc_id, 
    doc_name, 
    dep_no, 
    dep_name, 
    phone_number, 
    doctor_info.salary_slipno, 
    salary, 
    Number_of_years_working
FROM 
    doctor_info, 
    doctor_phone, 
    doc_salary 
WHERE 
    doctor_info.doc_id IN (
        SELECT doc_id 
        FROM doctor_phone 
        GROUP BY doc_id 
        HAVING COUNT(doc_id) >= 2
    )
    AND doctor_info.doc_id = doctor_phone.doc_id 
    AND doc_salary.salary_slipno = doctor_info.salary_slipno;

-- Another way to retrieve doctor information for doctors with multiple phone numbers
-- This query retrieves all columns from 'doctor_info' for doctors who have more than one phone number.
-- It uses a subquery to identify doctors with multiple phone numbers.
SELECT * 
FROM doctor_info 
WHERE doctor_info.doc_id IN (
    SELECT doc_id 
    FROM doctor_phone 
    GROUP BY doc_id 
    HAVING COUNT(doc_id) >= 2
);

-- Question 05: Retrieve general dentist treatments for Dr. David
-- This query retrieves all treatment details from the 'gen_dentist' table for Dr. David.
-- It uses a subquery to find the 'doc_id' for Dr. David from 'doctor_info'.
SELECT * 
FROM gen_dentist 
WHERE doc_id IN (
    SELECT doc_id 
    FROM doctor_info 
    WHERE doc_name = 'Dr. David'
);

-- Question 06: Retrieve endodontist treatment details along with doctor info
-- This query joins the 'endodontist' and 'doctor_info' tables to retrieve treatment details and corresponding doctor information.
SELECT 
    endodontist.doc_id, 
    doc_name, 
    root_canal, 
    charges, 
    dep_name 
FROM 
    endodontist 
JOIN 
    doctor_info 
ON 
    endodontist.doc_id = doctor_info.doc_id;

-- Question 07: Retrieve doctors with salaries above the average salary
-- This query retrieves doctor details whose salaries are above the average salary from the 'doc_salary' table.
-- It uses a subquery to find the average salary and another subquery to filter doctors based on this average.
SELECT * 
FROM doctor_info 
WHERE salary_slipno IN (
    SELECT salary_slipno 
    FROM doc_salary 
    WHERE salary > (
        SELECT AVG(salary) 
        FROM doc_salary
    )
);
