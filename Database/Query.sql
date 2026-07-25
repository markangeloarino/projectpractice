CREATE TABLE IF NOT EXISTS job_seekers (
    seeker_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    contact_number VARCHAR(20),
    skills TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 1. Create the Staff Table
CREATE TABLE IF NOT EXISTS peso_staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    role VARCHAR(50) DEFAULT 'peso_staff'
);

-- 2. Create the dummy staff member (This becomes staff_id = 1)
INSERT INTO peso_staff (name, role) VALUES ('Test Staff Member', 'peso_staff');

-- 3. Create the Job Vacancies Table
CREATE TABLE IF NOT EXISTS job_vacancies (
    vacancy_id INT AUTO_INCREMENT PRIMARY KEY,
    job_title VARCHAR(255) NOT NULL,
    employer_name VARCHAR(255) NOT NULL,
    encoded_by_staff_id INT NOT NULL, 
    date_posted TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- This is the rule that was blocking you!
    FOREIGN KEY (encoded_by_staff_id) REFERENCES peso_staff(staff_id) 
);

CREATE TABLE IF NOT EXISTS job_applications (
    application_id INT AUTO_INCREMENT PRIMARY KEY,
    seeker_id INT NOT NULL,
    vacancy_id INT NOT NULL,
    status VARCHAR(50) DEFAULT 'Pending',
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (seeker_id) REFERENCES job_seekers(seeker_id) ON DELETE CASCADE,
    FOREIGN KEY (vacancy_id) REFERENCES job_vacancies(vacancy_id) ON DELETE CASCADE,
    UNIQUE KEY unique_application (seeker_id, vacancy_id) -- Prevents applying to the same job twice
);


CREATE TABLE IF NOT EXISTS employers (
    employer_id INT AUTO_INCREMENT PRIMARY KEY,
    company_name VARCHAR(255) NOT NULL,
    industry VARCHAR(100) NOT NULL,
    website VARCHAR(255), -- Optional
    contact_person VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(50) NOT NULL,
    address TEXT NOT NULL,
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE job_vacancies
ADD COLUMN IF NOT EXISTS years_experience INT DEFAULT 0,
ADD COLUMN IF NOT EXISTS salary VARCHAR(100),
ADD COLUMN IF NOT EXISTS vacancies_count INT DEFAULT 1,
ADD COLUMN IF NOT EXISTS employment_type VARCHAR(50),
ADD COLUMN IF NOT EXISTS industry VARCHAR(100),
ADD COLUMN IF NOT EXISTS location VARCHAR(255),
ADD COLUMN IF NOT EXISTS job_description TEXT,
ADD COLUMN IF NOT EXISTS qualifications TEXT,
ADD COLUMN IF NOT EXISTS application_deadline DATE,
ADD COLUMN IF NOT EXISTS job_location_type VARCHAR(50) DEFAULT 'Local';

ALTER TABLE employers 
ADD COLUMN logo_url VARCHAR(255),
ADD COLUMN status VARCHAR(50) DEFAULT 'Active';


-- Drop the old table if it exists so we can recreate it properly
DROP TABLE IF EXISTS peso_staff;

CREATE TABLE IF NOT EXISTS peso_staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('Admin', 'Staff') DEFAULT 'Staff' -- Defines the separation
);

-- Create one Admin and one Staff for testing
INSERT INTO peso_staff (name, email, password_hash, role) 
VALUES 
('System Admin', 'admin@naga.gov.ph', '$2b$10$X7.mQ3R8bH5wzH6g5vU7ouJ.3v3Z7Z5Z7Z5Z7Z5Z7Z5Z7Z5Z7Z5Z7', 'Admin'),
('Mediated Entry Officer', 'staff@naga.gov.ph', '$2b$10$X7.mQ3R8bH5wzH6g5vU7ouJ.3v3Z7Z5Z7Z5Z7Z5Z7Z5Z7Z5Z7Z5Z7', 'Staff');


ALTER TABLE job_vacancies
ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'Active';

ALTER TABLE employers
ADD COLUMN IF NOT EXISTS company_description TEXT;


ALTER TABLE job_vacancies
ADD COLUMN IF NOT EXISTS employer_career_link VARCHAR(255);

UPDATE peso_staff SET role = 'Job Poster' WHERE role = 'Staff';
-- Or you can change individual records:
UPDATE peso_staff SET role = 'Job Matcher' WHERE email = 'some_staff@naga.gov.ph';


ALTER TABLE job_seekers
ADD COLUMN IF NOT EXISTS is_first_time_jobseeker TINYINT(1) DEFAULT 1,
ADD COLUMN IF NOT EXISTS middle_name VARCHAR(100),
ADD COLUMN IF NOT EXISTS suffix VARCHAR(20),
ADD COLUMN IF NOT EXISTS date_of_birth VARCHAR(50),
ADD COLUMN IF NOT EXISTS sex VARCHAR(20),
ADD COLUMN IF NOT EXISTS age INT,
ADD COLUMN IF NOT EXISTS religion VARCHAR(100),
ADD COLUMN IF NOT EXISTS civil_status VARCHAR(50),
ADD COLUMN IF NOT EXISTS house_no VARCHAR(255),
ADD COLUMN IF NOT EXISTS barangay VARCHAR(100),
ADD COLUMN IF NOT EXISTS city VARCHAR(100),
ADD COLUMN IF NOT EXISTS province VARCHAR(100),
ADD COLUMN IF NOT EXISTS tin VARCHAR(50),
ADD COLUMN IF NOT EXISTS height VARCHAR(50),
ADD COLUMN IF NOT EXISTS disabilities TEXT,
ADD COLUMN IF NOT EXISTS other_disability VARCHAR(255);

ALTER TABLE employers
ADD COLUMN IF NOT EXISTS is_accredited BOOLEAN DEFAULT 0,
ADD COLUMN IF NOT EXISTS accreditation_date TIMESTAMP NULL;

CREATE TABLE IF NOT EXISTS recruitment_coordinations (
    activity_id INT AUTO_INCREMENT PRIMARY KEY,
    employer_id INT NOT NULL,
    activity_title VARCHAR(255) NOT NULL,
    activity_date DATE NOT NULL,
    activity_type VARCHAR(100), -- e.g., 'Job Fair', 'Interview Schedule', 'Monitoring'
    status VARCHAR(50) DEFAULT 'Scheduled',
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employer_id) REFERENCES employers(employer_id) ON DELETE CASCADE
);