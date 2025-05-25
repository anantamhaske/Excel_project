#Question no. 1 (A)

SELECT employeeNumber, firstName, lastName
FROM employees
WHERE jobTitle = 'Sales Rep'
AND reportsTo = 1102;


#Question no. 1 (B)

SELECT DISTINCT productLine
FROM products
WHERE productLine LIKE '%cars';


#Question no. 2

SELECT customerNumber, customerName,
       CASE
           WHEN country IN ('USA', 'Canada') THEN 'North America'
           WHEN country IN ('UK', 'France', 'Germany') THEN 'Europe'
           ELSE 'Other'
       END AS CustomerSegment
FROM customers;


#Question no. 3 (A)

SELECT productCode, SUM(quantityOrdered) AS totalQuantity
FROM OrderDetails
GROUP BY productCode
ORDER BY totalQuantity DESC
LIMIT 10;

#Question no. 3 (B)

SELECT MONTHNAME(paymentDate) AS month, COUNT(checkNumber) AS totalPayments
FROM Payments
GROUP BY month
HAVING totalPayments > 20
ORDER BY totalPayments DESC;


#Question no. 4 (A)

CREATE DATABASE Customers_Orders;
USE Customers_Orders;
CREATE TABLE Customers1 (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,           -- Primary key with auto-increment
    first_name VARCHAR(50) NOT NULL,                      -- First name, cannot be null
    last_name VARCHAR(50) NOT NULL,                       -- Last name, cannot be null
    email VARCHAR(255) UNIQUE,                            -- Unique constraint on email
    phone_number VARCHAR(20)                              -- Phone number with no specific constraint
);

#Question no. 4 (B)

CREATE TABLE Orders1 (
    orderNumber INT AUTO_INCREMENT PRIMARY KEY,
    customerNumber INT,
    order_date DATE,
    total_amount DECIMAL(10, 2),
    
    -- Foreign key constraint referencing the Customers table
    CONSTRAINT fk_customer
        FOREIGN KEY (customerNumber) REFERENCES Customers(customerNumber),
    
    -- Check constraint to ensure total_amount is always positive
    CONSTRAINT chk_total_amount CHECK (total_amount > 0)
);


#Question no. 5

SELECT c.country, COUNT(o.orderNumber) AS order_count
FROM Customers AS c
INNER JOIN Orders AS o ON c.customerNumber = o.customerNumber
GROUP BY c.country
ORDER BY order_count DESC
LIMIT 5;

DESCRIBE Customers;
DESCRIBE Orders;


#Question no. 6

CREATE TABLE project1 (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(50) NOT NULL,
    Gender ENUM('Male', 'Female') NOT NULL,
    ManagerID INT
);
INSERT INTO project1 (FullName, Gender, ManagerID) VALUES
('John Doe', 'Male', NULL),    -- John has no manager
('Jane Smith', 'Female', 1),    -- Jane reports to John
('Sam Brown', 'Male', 1),       -- Sam reports to John
('Lisa White', 'Female', 2),    -- Lisa reports to Jane
('Tom Green', 'Male', 2);       -- Tom reports to Jane

SELECT 
    e.FullName AS EmployeeName,
    m.FullName AS ManagerName
FROM 
    project1 AS e
LEFT JOIN 
    project1 AS m ON e.ManagerID = m.EmployeeID;
    
    
#Question no. 7

CREATE TABLE facility1 (
    Facility_ID INT,
    Name VARCHAR(100),
    State VARCHAR(100),
    Country VARCHAR(100)
);
ALTER TABLE facility1
MODIFY Facility_ID INT AUTO_INCREMENT PRIMARY KEY;
ALTER TABLE facility1
ADD City VARCHAR(100) NOT NULL AFTER Name;


#Question no. 8

CREATE VIEW product_category_sales AS
SELECT 
    pl.productLine,
    SUM(od.quantityOrdered * od.priceEach) AS total_sales,
    COUNT(DISTINCT o.orderNumber) AS number_of_orders
FROM 
    ProductLines AS pl
JOIN 
    Products AS p ON pl.productLine = p.productLine
JOIN 
    OrderDetails AS od ON p.productCode = od.productCode
JOIN 
    Orders AS o ON od.orderNumber = o.orderNumber
GROUP BY 
    pl.productLine;
    
    SELECT * FROM product_category_sales;
    
    
#Question no. 9

DELIMITER //

CREATE PROCEDURE Get_country_payments2(
    IN input_year INT,
    IN input_country VARCHAR(100)
)
BEGIN
    SELECT 
        YEAR(p.paymentDate) AS payment_year,
        c.country,
        FORMAT(SUM(p.amount), 0) AS total_amount_k
    FROM 
        Customers AS c
    JOIN 
        Payments AS p ON c.customernumber = p.customernumber 
    WHERE 
        YEAR(p.paymentDate) = input_year AND
        c.country = input_country
    GROUP BY 
        payment_year, c.country;
END //

DELIMITER ;

CALL Get_country_payments2(2023, 'USA');


#Question no. 10 (A)

SELECT 
    c.customernumber,
    c.customername,
    COUNT(o.ordernumber) AS order_count,
    RANK() OVER (ORDER BY COUNT(o.ordernumber) DESC) AS order_rank
FROM 
    Customers AS c
LEFT JOIN 
    Orders AS o ON c.customernumber = o.customernumber
GROUP BY 
    c.customernumber, c.customername
ORDER BY 
    order_rank;
    
    #Question no. 10 (B)
    
WITH MonthlyOrderCounts AS (
    SELECT 
        YEAR(orderDate) AS order_year,
        MONTH(orderDate) AS month_number,  
        MONTHNAME(orderDate) AS month_name,
        COUNT(ordernumber) AS order_count
    FROM 
        Orders
    GROUP BY 
        YEAR(orderDate), MONTH(orderDate), MONTHNAME(orderDate)  -- Added MONTHNAME here
),
YearlyOrderCounts AS (
    SELECT 
        order_year,
        SUM(order_count) AS total_orders
    FROM 
        MonthlyOrderCounts
    GROUP BY 
        order_year
),
YoYChange AS (
    SELECT 
        current.order_year,
        current.total_orders,
        COALESCE((current.total_orders - previous.total_orders) / NULLIF(previous.total_orders, 0) * 100, 0) AS yoy_percentage
    FROM 
        YearlyOrderCounts AS current
    LEFT JOIN 
        YearlyOrderCounts AS previous ON current.order_year = previous.order_year + 1
)
 
SELECT 
    moc.order_year,
    moc.month_name,
    moc.order_count,
    COALESCE(yoy.yoy_percentage, 0) AS yoy_percentage,
    CONCAT(FORMAT(COALESCE(yoy.yoy_percentage, 0), 0), '%') AS formatted_yoy
FROM 
    MonthlyOrderCounts AS moc
LEFT JOIN 
    YoYChange AS yoy ON moc.order_year = yoy.order_year
ORDER BY 
    moc.order_year, moc.month_number;
    
    

#Question no. 11

SELECT 
    p.productLine,
    COUNT(*) AS product_count
FROM 
    Products AS p
WHERE 
    p.buyPrice > (SELECT AVG(buyPrice) FROM Products)
GROUP BY 
    p.productLine;
    
    
#Question no. 12

CREATE TABLE Emp_EH3 (
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(100),
    EmailAddress VARCHAR(100)
);
DELIMITER $$

CREATE PROCEDURE InsertEmp1 (
    IN p_EmpID INT,
    IN p_EmpName VARCHAR(100),
    IN p_EmailAddress VARCHAR(100)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Handle the exception
        SELECT 'Error occurred' AS ErrorMessage;
    END;

    -- Insert the values into the Emp_EH3 table
    INSERT INTO Emp_EH3 (EmpID, EmpName, EmailAddress)
    VALUES (p_EmpID, p_EmpName, p_EmailAddress);
    
    COMMIT;  -- Commit the transaction
END $$

DELIMITER ;
CALL InsertEmp(1, 'John Doe', 'john.doe@example.com');


#Question no. 13

CREATE TABLE Emp_BIT2 (
    Name VARCHAR(50),
    Occupation VARCHAR(50),
    Working_date DATE,
    Working_hours INT
);

INSERT INTO Emp_BIT2 (Name, Occupation, Working_date, Working_hours) VALUES
('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', 11);

DELIMITER //

CREATE TRIGGER before_insert_Emp_BIT2
BEFORE INSERT ON Emp_BIT2
FOR EACH ROW
BEGIN
    IF NEW.Working_hours < 0 THEN
        SET NEW.Working_hours = ABS(NEW.Working_hours);
    END IF;
END //

DELIMITER ;


























