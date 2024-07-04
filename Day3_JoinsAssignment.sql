SET search_path TO student_management;

-- Create Students table
CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100),
    student_major VARCHAR(100)
);

-- Create Courses table
CREATE TABLE Courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100),
    course_description VARCHAR(255)
);

-- Create Enrollments table
CREATE TABLE Enrollments (
    enrollment_id INT PRIMARY KEY,
    student_id INT,
    course_id INT,
    enrollment_date DATE,
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

-- Insert data into Students table
INSERT INTO Students (student_id, student_name, student_major) VALUES
(1, 'Alice', 'Computer Science'),
(2, 'Bob', 'Biology'),
(3, 'Charlie', 'History'),
(4, 'Diana', 'Mathematics');

-- Insert data into Courses table
INSERT INTO Courses (course_id, course_name, course_description) VALUES
(101, 'Introduction to CS', 'Basics of Computer Science'),
(102, 'Biology Basics', 'Fundamentals of Biology'),
(103, 'World History', 'Historical events and cultures'),
(104, 'Calculus I', 'Introduction to Calculus'),
(105, 'Data Structures', 'Advanced topics in CS');

-- Insert data into Enrollments table
INSERT INTO Enrollments (enrollment_id, student_id, course_id, enrollment_date) VALUES
(1, 1, 101, '2023-01-15'),
(2, 2, 102, '2023-01-20'),
(3, 3, 103, '2023-02-01'),
(4, 1, 105, '2023-02-05'),
(5, 4, 104, '2023-02-10'),
(6, 2, 101, '2023-02-12'),
(7, 3, 105, '2023-02-15'),
(8, 4, 101, '2023-02-20'),
(9, 1, 104, '2023-03-01'),
(10, 2, 104, '2023-03-05');

-- Retrieve the list of students and their enrolled courses.
SELECT 
    S.student_name,
    C.course_name
FROM 
    Enrollments E
INNER JOIN 
    Students S ON E.student_id = S.student_id
INNER JOIN 
    Courses C ON E.course_id = C.course_id;

 -- List all students and their enrolled courses, including those who haven't enrolled in any course.
SELECT 
    S.student_name,
    C.course_name
FROM 
    Students S
LEFT JOIN 
    Enrollments E ON S.student_id = E.student_id
LEFT JOIN 
    Courses C ON E.course_id = C.course_id;

 -- Display all courses and the students enrolled in each course, including courses with no enrolled students.
SELECT 
    C.course_name,
    S.student_name
FROM 
    Courses C
RIGHT JOIN 
    Enrollments E ON C.course_id = E.course_id
RIGHT JOIN 
    Students S ON E.student_id = S.student_id;

-- Find pairs of students who are enrolled in at least one common course.
SELECT 
    S1.student_name AS Student1,
    S2.student_name AS Student2,
    C.course_name
FROM 
    Enrollments E1
INNER JOIN 
    Enrollments E2 ON E1.course_id = E2.course_id AND E1.student_id < E2.student_id
INNER JOIN 
    Students S1 ON E1.student_id = S1.student_id
INNER JOIN 
    Students S2 ON E2.student_id = S2.student_id
INNER JOIN 
    Courses C ON E1.course_id = C.course_id;

 -- Retrieve students who are enrolled in 'Introduction to CS' but not in 'Data Structures'.
SELECT 
    S.student_name
FROM 
    Students S
INNER JOIN 
    Enrollments E1 ON S.student_id = E1.student_id
INNER JOIN 
    Courses C1 ON E1.course_id = C1.course_id
WHERE 
    C1.course_name = 'Introduction to CS'
    AND S.student_id NOT IN (
        SELECT 
            E2.student_id
        FROM 
            Enrollments E2
        INNER JOIN 
            Courses C2 ON E2.course_id = C2.course_id
        WHERE 
            C2.course_name = 'Data Structures'
    );

-- List all students along with a row number based on their enrollment date in ascending order.
SELECT 
    S.student_name,
    E.enrollment_date,
    ROW_NUMBER() OVER (ORDER BY E.enrollment_date ASC) AS row_number
FROM 
    Enrollments E
INNER JOIN 
    Students S ON E.student_id = S.student_id;

-- Rank students based on the number of courses they are enrolled in, handling ties by assigning the same rank.
SELECT 
    S.student_name,
    COUNT(E.course_id) AS num_courses_enrolled,
    RANK() OVER (ORDER BY COUNT(E.course_id) DESC) AS rank
FROM 
    Students S
LEFT JOIN 
    Enrollments E ON S.student_id = E.student_id
GROUP BY 
    S.student_name;

-- Determine the dense rank of courses based on their enrollment count across all students
SELECT 
    C.course_name,
    COUNT(E.student_id) AS enrollment_count,
    DENSE_RANK() OVER (ORDER BY COUNT(E.student_id) DESC) AS dense_rank
FROM 
    Courses C
LEFT JOIN 
    Enrollments E ON C.course_id = E.course_id
GROUP BY 
    C.course_name;