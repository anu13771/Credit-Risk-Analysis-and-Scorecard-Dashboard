USE CreditRiskDB;

CREATE TABLE Borrowers (
    borrower_id INT PRIMARY KEY,
    age INT,
    income DECIMAL(10,2),
    employment_years INT
);

CREATE TABLE Loans (
    loan_id INT PRIMARY KEY,
    borrower_id INT,
    loan_amount DECIMAL(10,2),
    tenure_months INT,
    interest_rate DECIMAL(5,2)
);
CREATE TABLE Payments (
    payment_id INT PRIMARY KEY,
    loan_id INT,
    payment_date DATE,
    due_date DATE,
    amount_paid DECIMAL(10,2)
);

USE CreditRiskDB;

INSERT INTO Borrowers VALUES
(1, 25, 400000, 2),
(2, 35, 800000, 8),
(3, 45, 1200000, 15),
(4, 29, 300000, 3),
(5, 52, 600000, 20);

INSERT INTO Loans VALUES
(101, 1, 200000, 24, 13.5),
(102, 2, 500000, 36, 11.2),
(103, 3, 800000, 48, 9.5),
(104, 4, 150000, 18, 15.0),
(105, 5, 300000, 24, 12.0);

INSERT INTO Payments VALUES
(1, 101, '2024-01-07', '2024-01-05', 9000),
(2, 101, '2024-02-10', '2024-02-05', 9000),
(3, 102, '2024-01-04', '2024-01-05', 15000),
(4, 103, '2024-01-20', '2024-01-05', 20000),
(5, 104, '2024-01-06', '2024-01-05', 8000),
(6, 105, '2024-01-25', '2024-01-05', 12000);


SELECT * FROM Borrowers;
SELECT * FROM Loans;
SELECT * FROM Payments;

USE CreditRiskDB;

SELECT *
INTO Clean_Borrowers
FROM Borrowers
WHERE income IS NOT NULL
  AND age BETWEEN 18 AND 65;

SELECT *
INTO Clean_Payments
FROM Payments
WHERE payment_date IS NOT NULL
  AND due_date IS NOT NULL;

SELECT * FROM Clean_Borrowers;
SELECT * FROM Clean_Payments;


IF OBJECT_ID('Loan_Features', 'U') IS NOT NULL
    DROP TABLE Loan_Features;

SELECT
    b.borrower_id,
    l.loan_amount * 1.0 / b.income AS loan_to_income_ratio
INTO Loan_Features
FROM Clean_Borrowers b
JOIN Loans l 
    ON b.borrower_id = l.borrower_id;

SELECT * FROM Loan_Features;

SELECT
    b.borrower_id,
    b.age,
    b.income,
    ISNULL(pf.avg_delay_days, 0) AS avg_delay_days,
    ISNULL(pf.late_payment_count, 0) AS late_payment_count,
    ISNULL(lf.loan_to_income_ratio, 0) AS loan_to_income_ratio
INTO Credit_Risk_Features_Final
FROM Clean_Borrowers b
LEFT JOIN Payment_Features_v2 pf 
    ON b.borrower_id = pf.borrower_id
LEFT JOIN Loan_Features lf 
    ON b.borrower_id = lf.borrower_id;




-- STEP 1: Create Payment Features (if not done yet)
IF OBJECT_ID('Payment_Features_v2', 'U') IS NOT NULL
    DROP TABLE Payment_Features_v2;

SELECT
    l.borrower_id,
    AVG(DATEDIFF(DAY, p.due_date, p.payment_date)) AS avg_delay_days,
    SUM(CASE WHEN p.payment_date > p.due_date THEN 1 ELSE 0 END) AS late_payment_count
INTO Payment_Features_v2
FROM Payments p
JOIN Loans l
    ON p.loan_id = l.loan_id
GROUP BY l.borrower_id;

-- STEP 2: Merge features again including payment features
IF OBJECT_ID('Credit_Risk_Features_Final_v2', 'U') IS NOT NULL
    DROP TABLE Credit_Risk_Features_Final_v2;

SELECT
    b.borrower_id,
    b.age,
    b.income,
    ISNULL(pf.avg_delay_days, 0) AS avg_delay_days,
    ISNULL(pf.late_payment_count, 0) AS late_payment_count,
    ISNULL(lf.loan_to_income_ratio, 0) AS loan_to_income_ratio
INTO Credit_Risk_Features_Final_v2
FROM Clean_Borrowers b
LEFT JOIN Payment_Features_v2 pf 
    ON b.borrower_id = pf.borrower_id
LEFT JOIN Loan_Features lf 
    ON b.borrower_id = lf.borrower_id;

-- STEP 3: Assign points for each feature and calculate total score
IF OBJECT_ID('Credit_Risk_Scores', 'U') IS NOT NULL
    DROP TABLE Credit_Risk_Scores;

SELECT
    borrower_id,
    age,
    income,
    avg_delay_days,
    late_payment_count,
    loan_to_income_ratio,
    
    -- Age points
    CASE 
        WHEN age < 30 THEN 20
        WHEN age BETWEEN 30 AND 50 THEN 30
        ELSE 25
    END AS age_points,
    
    -- Loan-to-Income points
    CASE 
        WHEN loan_to_income_ratio < 0.2 THEN 40
        WHEN loan_to_income_ratio BETWEEN 0.2 AND 0.5 THEN 30
        ELSE 10
    END AS lti_points,
    
    -- Average delay points
    CASE 
        WHEN avg_delay_days = 0 THEN 50
        WHEN avg_delay_days BETWEEN 1 AND 10 THEN 30
        ELSE 10
    END AS delay_points,
    
    -- Late payment count points
    CASE 
        WHEN late_payment_count = 0 THEN 50
        WHEN late_payment_count BETWEEN 1 AND 2 THEN 30
        ELSE 10
    END AS late_count_points,
    
    -- Total score
    (CASE 
        WHEN age < 30 THEN 20
        WHEN age BETWEEN 30 AND 50 THEN 30
        ELSE 25
    END +
    CASE 
        WHEN loan_to_income_ratio < 0.2 THEN 40
        WHEN loan_to_income_ratio BETWEEN 0.2 AND 0.5 THEN 30
        ELSE 10
    END +
    CASE 
        WHEN avg_delay_days = 0 THEN 50
        WHEN avg_delay_days BETWEEN 1 AND 10 THEN 30
        ELSE 10
    END +
    CASE 
        WHEN late_payment_count = 0 THEN 50
        WHEN late_payment_count BETWEEN 1 AND 2 THEN 30
        ELSE 10
    END) AS total_score
INTO Credit_Risk_Scores
FROM Credit_Risk_Features_Final_v2;

-- STEP 4: Segment borrowers into risk levels
IF OBJECT_ID('Credit_Risk_Segments', 'U') IS NOT NULL
    DROP TABLE Credit_Risk_Segments;

SELECT *,
    CASE 
        WHEN total_score >= 120 THEN 'Low Risk'
        WHEN total_score >= 90 THEN 'Medium Risk'
        ELSE 'High Risk'
    END AS risk_segment
INTO Credit_Risk_Segments
FROM Credit_Risk_Scores;

-- Checking final result
SELECT * FROM Credit_Risk_Segments;


