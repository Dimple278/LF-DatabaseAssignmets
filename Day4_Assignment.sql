SET search_path TO employee;

CREATE TYPE sex_enum AS ENUM ('F', 'M');

-- Create the professions table
CREATE TABLE professions (
    id serial PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255),
    sex sex_enum,
    doj DATE,
    current_date DATE NOT NULL,
    designation VARCHAR(255),
    age INT,
    salary DECIMAL(10,2),
    unit VARCHAR(255),
    leaves_used INT,
    leaves_remaining INT,
    ratings INT,
    past_exp INT
);

-- Copy data from the CSV file into the professions table
COPY professions (
    first_name, last_name, sex, doj, current_date, designation, age, salary, unit, leaves_used, leaves_remaining, ratings, past_exp
)
FROM 'E:\Salary Prediction of Data Professions.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM professions;

-- Question 1: Calculate the average salary by department for all Analysts
WITH analysts AS (
    SELECT *
    FROM professions
    WHERE designation = 'Analyst'
)
SELECT unit AS department, AVG(salary) AS average_salary
FROM analysts
GROUP BY unit;

-- Question 2: List all employees who have used more than 10 leaves.
WITH employees_with_leaves AS (
    SELECT *
    FROM professions
    WHERE leaves_used > 10
)
SELECT *
FROM employees_with_leaves;

-- Question 3: Create a view to show the details of all Senior Analysts.
CREATE VIEW senior_analysts AS
SELECT *
FROM professions
WHERE designation = 'Senior Analyst';
SELECT * FROM senior_analysts;

-- Question 4: Create a materialized view to store the count of employees by department.
CREATE MATERIALIZED VIEW employee_count_by_department AS
SELECT unit AS department, COUNT(*) AS employee_count
FROM professions
GROUP BY unit;

SELECT * FROM employee_count_by_department;

REFRESH MATERIALIZED VIEW employee_count_by_department;

-- Create a procedure to update an employee's salary by their first name and last name.
CREATE OR REPLACE PROCEDURE update_employee_salary(
    emp_first_name VARCHAR,
    emp_last_name VARCHAR,
    new_salary DECIMAL(10,2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE professions
    SET salary = new_salary
    WHERE first_name = emp_first_name AND last_name = emp_last_name;
END;
$$;

CALL update_employee_salary('TOMASA', 'ARMEN', 75000.00);

select * from professions where first_name = 'TOMASA';

 -- Create a procedure to calculate the total number of leaves used across all departments.
CREATE OR REPLACE PROCEDURE calculate_total_leaves_used(
    OUT total_leaves INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT SUM(leaves_used) INTO total_leaves
    FROM professions;
    RAISE NOTICE 'Total leaves used across all departments: %', total_leaves;
END;
$$;
CALL calculate_total_leaves_used(total_leaves);
