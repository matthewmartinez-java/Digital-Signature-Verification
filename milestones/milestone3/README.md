# Milestone 3: Business Requirements and Implementation (15 points)

In this milestone, students will apply their database model to real business requirements specifically designed for the use cases in their project.

## Milestone 2: Table of Contents

1. [Database Business Requirements Implementation](#head1)
2. [Grading Rubrics](#head2)
3. [Submission Guidelines](#head3)

---

## <a id="head1"></a> Database Business Requirements Implementation (15 points)

**Note: This section does not require any work to be added to the technical documentation from previous milestones.**

You will create and implement at least **10 business requirements** that align with the unique features described in the product summary from **Milestone 1**. These requirements must be challenging and address critical aspects of your database, setting your project apart from competitors.

Your requirements should include:

- Complex calculations
- Solutions to real business challenges within the scope of your database
- Dynamic data management
- Integration with external systems
- High levels of security and performance, in line with your non-functional database requirements
- Intuitive and user-friendly implementations
- Use of all SQL concepts you've learned in this course

Ensure that these requirements address the challenges described in the unique features section of **Milestone 1**.

### Steps:

1. **Create a new file named `requirements.sql`.**

2. In this file, implement your business requirements using the following SQL components:

- For each business requirement:
  - **State the purpose** of the problem to be solved.
  - **Describe the problem** in detail.
  - **Explain the challenges** that the problem presents.
  - **Mention any assumptions** that must be considered for the solution.
  - **Create an implementation plan** for solving the problem.
  - **Implement the business requirement**.

- SQL Components that you may want to use in your implementations: 

  - **Triggers**:
    - **BEFORE INSERT, DELETE, UPDATE**: Implement triggers that execute before data is inserted, deleted, or updated. These are useful for validation, data transformation, or preventing certain operations.
    - **AFTER INSERT, DELETE, UPDATE**: Implement triggers that execute after data is modified. These are useful for logging changes, updating related tables, or triggering actions based on data modification.

  - **Functions**:
    - **DETERMINISTIC Functions**: Create functions that always return the same result given the same input values. These are ideal for calculations or queries that do not depend on external factors.
    - **NON-DETERMINISTIC Functions**: Create functions where the result may vary even with the same input. These are typically used for time-sensitive data, such as current timestamps or random values.
    - **User-defined Functions**: Implement user-defined functions, especially those you’ve learned in the SQL permissions topic. These might involve handling custom logic or interacting with user permissions for specific roles.

  - **Procedures**:
    - **Without Parameters**: Write stored procedures that do not require input or output parameters. These can be used for general actions like database maintenance or reports that do not require dynamic inputs.
    - **With IN Parameters**: Write procedures that take input parameters. These are useful for scenarios where the user provides data to modify or query the database.
    - **With IN and OUT Parameters**: Write procedures that both accept input and return output. These are typically used for complex operations where data is passed into the procedure and results are returned to the caller (e.g., calculations or updates that need feedback).

  - **Scheduled Events**:
    - **Daily Tasks**: Create scheduled events to handle routine daily tasks, such as backing up data, cleaning old logs, or performing data consistency checks.
    - **Monthly Tasks**: Create scheduled events for monthly tasks, such as updating reports, recalculating aggregate values, or creating new records based on business logic.


   
   

   > **Note**: You can use more than one SQL component (trigger, function, procedure, scheduled event) in the implementation of each business requirement, as demonstrated in the examples below.

3. **Upload the `requirements.sql` file** to this directory. When implementing your business requirements, follow the format provided in the examples below.

### Example Business Requirements:

Below are two examples of business requirements implemented for the `LibrarySystemDB` database:


```mysql
 -- This file provides a SQL based solution to the following database
 -- business requirements for the LibrarySystemDB database
    
 USE LibrarySystemDB;
 
 /*
     Business Requirements #1
     ----------------------------------------------------
     Purpose: Role-Based Access Control with Expiry Dates
     
     Description: The system must implement a role-based access control (RBAC) 
                  mechanism that restricts user access to specific features 
                  based on their assigned roles (e.g., Admin, Librarian Manager, Librarian, Customer). 
                  Each role assignment should have an expiration date, after which the user's access 
                  to the associated features will be automatically revoked. 
     
     Challenge:   This system needs to ensure that role assignments are dynamically checked during each user interaction, 
                  and that expired roles are removed or flagged for renewal. Managing this dynamic access control, 
                  while maintaining security and performance, poses a significant challenge.
     
     Implementation Plan:
        1. Create a stored procedure to assign a role to a user
        2. Create a trigger to revoke expired roles
        3. Create a function to check an active role
        4. Create a stored procedure to access a protected feature
        5. Provide example usage
  
  */
  
  DELIMITER $$
  -- 1 
  CREATE PROCEDURE AssignUserRole( IN p_user_id INT, IN p_role_id INT, IN p_expires DATE)
  BEGIN
      -- Insert a new role assignment for the user
      INSERT INTO UserRole (user_id, role_id, expires)
      VALUES (p_user_id, p_role_id, p_expires);
  END$$ 

 -- 2 
 
 CREATE TRIGGER RevokeExpiredRole
 BEFORE INSERT ON UserRole
 FOR EACH ROW
 BEGIN
     DECLARE v_today DATE;
     SET v_today = CURDATE();
    
    -- Check if the role assignment has already expired
     IF NEW.expires < v_today THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot assign an expired role to the user.';
    END IF;
 END$$

 -- 3
 
 CREATE FUNCTION IsUserRoleActive(p_user_id INT, p_role_id INT)
 RETURNS BOOLEAN
 DETERMINISTIC
 BEGIN
    DECLARE v_is_active BOOLEAN;
    
    -- Check if the user's role is still active
    SELECT COUNT(*) > 0 INTO v_is_active
    FROM UserRole
    WHERE user_id = p_user_id
    AND role_id = p_role_id
    AND expires >= CURDATE();
    
    RETURN v_is_active;
 END$$

-- 4 

 CREATE PROCEDURE AccessFeature(
    IN p_user_id INT,
    IN p_role_id INT
 )
 BEGIN
    DECLARE v_is_active BOOLEAN;
    
    -- Check if the user's role is active
    SET v_is_active = IsUserRoleActive(p_user_id, p_role_id);
    
    IF v_is_active THEN
        -- Proceed with the feature access
        SELECT 'Access Granted' AS Status;
    ELSE
        -- Deny access
        SELECT 'Access Denied: Role has expired or is not assigned' AS Status;
    END IF;
 END$$

 DELIMITER ;

-- 5
 CALL AssignUserRole(1, 2, '2025-01-01');
 CALL AccessFeature(1, 2);

/*
     Business Requirements #2
     ----------------------------------------------------
     Purpose: Comprehensive User Profile Management with Derived Attributes
     
     Description: The system must manage detailed user profiles that include derived attributes, such as age, 
                  and composite attributes like full name and date of birth. Additionally, the system should 
                  allow users to have multiple phone numbers stored as a composite, multi-value attribute. 
     
     Challenge:   The challenge lies in ensuring that derived attributes are automatically updated as base data 
                  changes (e.g., recalculating a user's age on their birthday), and in handling the storage and 
                  retrieval of multi-value attributes efficiently. This requirement demands advanced data modeling 
                  and the implementation of triggers or stored procedures to maintain data integrity. 
     
     Assumptions: None 
     
     Implementation Plan:
        1. Create a Trigger to Automatically Generate 'fullname' and 'age' Attributes by the time the user inserts a
           new registered user. 
        2. Same as in (1) but when the user updates a registered user
        3. Create a View to Simplify Access to User Profiles
        4. Create a Stored Procedure to Update Multiple Phone Numbers
        5. Provide an Example Usage
  
  */

 DELIMITER $$

-- 1 
 CREATE TRIGGER before_user_insert
 BEFORE INSERT ON RegisteredUser
 FOR EACH ROW
 BEGIN
    -- Generate the fullname from the name and lastname
    SET NEW.fullname = CONCAT(NEW.name, ' ', NEW.lastname);
    
    -- Calculate age from the date of birth
    SET NEW.age = YEAR(CURDATE()) - YEAR(NEW.dob);
    
    -- Handle cases where the user's birthday hasn't occurred yet this year
    IF MONTH(NEW.dob) > MONTH(CURDATE()) OR (MONTH(NEW.dob) = MONTH(CURDATE()) AND DAY(NEW.dob) > DAY(CURDATE())) THEN
        SET NEW.age = NEW.age - 1;
    END IF;
 END$$
 
 -- 2
 CREATE TRIGGER before_user_update
 BEFORE UPDATE ON RegisteredUser
 FOR EACH ROW
 BEGIN
    -- Generate the fullname from the name and lastname
    SET NEW.fullname = CONCAT(NEW.name, ' ', NEW.lastname);
    
    -- Calculate age from the date of birth
    SET NEW.age = YEAR(CURDATE()) - YEAR(NEW.dob);
    
    -- Handle cases where the user's birthday hasn't occurred yet this year
    IF MONTH(NEW.dob) > MONTH(CURDATE()) OR (MONTH(NEW.dob) = MONTH(CURDATE()) AND DAY(NEW.dob) > DAY(CURDATE())) THEN
        SET NEW.age = NEW.age - 1;
    END IF;
 END$$
 
 -- 3
 CREATE VIEW UserProfile AS
 SELECT 
    user_id,
    email,
    address,
    fullname,
    phone_number,
    dob,
    age
 FROM RegisteredUser;

-- 4
 CREATE PROCEDURE UpdateUserPhoneNumbers(
    IN p_user_id INT,
    IN p_phone_numbers VARCHAR(255)
 )
 BEGIN
    UPDATE RegisteredUser
    SET phone_number = p_phone_numbers
    WHERE user_id = p_user_id;
 END$$
 
 DELIMITER ;
 
 -- 5
 INSERT INTO RegisteredUser (user_id, email, address, name, lastname, dob, phone_number)
 VALUES (4, 'john.doe@example.com', 1, 'John', 'Doe', '1990-01-01', '555-1234');
 
 CALL UpdateUserPhoneNumbers(4, '555-1234, 555-5678');
 
 SELECT * FROM UserProfile;






```

---



# <a id="head2"></a> Grading Rubrics

The following grading rubrics will be used by the TA and the instructor to evaluate your work for this milestone:

1. **Completion of Sections**
   - All sections of this milestone must be fully completed. Incomplete work or assignments that do not strictly follow the submission guidelines will receive a non-passing grade. No exceptions.

2. **AI Detection**
   - If your work is flagged by our AI detection tools, it will receive a temporary grade of zero until the issue is resolved. If there is compelling evidence that the work was created by AI tools like ChatGPT, we will follow university policies regarding academic dishonesty.

3. **Final Grades**
   - Once a grade is assigned, it will not be changed unless there was an error in the grading process by the TA or instructor. Please refer to the syllabus for details on the grade appeal process.

4. **Late Submissions**
   - Late submissions will incur penalties. A 10% deduction will be applied for each day the assignment is overdue, up to a maximum of three days. After three days, the assignment will be considered not submitted and will receive a grade of zero.

### Detailed Section Grading

Our TAs will use the following rubrics to grade your milestone:

#### Database Business Requirements Implementation (15 points)
- (-15 points) for no work submitted.
- (-2.5 points) if the `requirements.sql` file runs with errors. The file must execute smoothly without errors to receive credit.
- (-2.5 points) if a demonstration of how the implementations work is not provided in the file.
- (-1 point) for each business requirement that is not implemented correctly or is missing.

#### Extra Credit Opportunity (2 points)
- (+2 points) for implementing solutions at an industry-grade level

> **Grading rubrics are applied consistently to ensure fairness for all students. Every student's work is evaluated according to the same criteria outlined in the rubrics. This approach helps maintain objectivity and transparency in the grading process.**

---

# <a id="head3"></a> Submission Guidelines

Please follow these submission guidelines carefully:

- **Upload your `requirements.sql` file** into this directory. If your file is not found in this directory at the time of grading, it will be considered as not submitted, even if it was mistakenly placed in a different directory.
- **On Canvas**: Use the assignment submission link to provide a URL that links directly to the Milestone 3 folder in your repository.

> **These submission guidelines are essential to ensure fair and consistent grading for everyone. It is crucial that your submission strictly follows these instructions. Failure to comply with these guidelines may result in significant point deductions.**

---

Way to go! 💪. You've completed industry-grade level work in this milestone. Now, as we move into Milestone 4, it's time to take things up a notch. ORM (Object-Relational Mapping) is a game-changer in how modern applications interact with databases, and mastering it will put you at the forefront of backend development. You’re stepping into one of the most powerful and widely-used techniques in the industry. Get ready to dive into more serious, cutting-edge work that’s in demand everywhere! 🌟🚀