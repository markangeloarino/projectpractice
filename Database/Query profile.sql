CREATE TABLE IF NOT EXISTS seeker_employment_status (
    seeker_id INT PRIMARY KEY,
    main_status VARCHAR(50) DEFAULT 'Unemployed', 
    employed_category VARCHAR(50), 
    self_employed_type VARCHAR(100),
    self_employed_others VARCHAR(255),
    months_looking INT,
    unemployed_reason VARCHAR(100),
    unemployed_country VARCHAR(100),
    unemployed_others VARCHAR(255),
    is_ofw VARCHAR(10) DEFAULT 'No',
    ofw_country VARCHAR(100),
    is_former_ofw VARCHAR(10) DEFAULT 'No',
    former_ofw_country VARCHAR(100),
    former_ofw_return VARCHAR(50),
    has_ofw_family VARCHAR(10) DEFAULT 'No',
    ofw_family_member VARCHAR(50),
    ofw_family_country VARCHAR(100),
    is_4ps VARCHAR(10) DEFAULT 'No',
    fourps_id VARCHAR(100),
    FOREIGN KEY (seeker_id) REFERENCES job_seekers(seeker_id) ON DELETE CASCADE
);

-- Core Preferences (Part-time, Full-time, Local, Overseas)
CREATE TABLE IF NOT EXISTS seeker_job_preferences (
    seeker_id INT PRIMARY KEY,
    is_part_time BOOLEAN DEFAULT 0,
    is_full_time BOOLEAN DEFAULT 0,
    is_local BOOLEAN DEFAULT 0,
    is_overseas BOOLEAN DEFAULT 0,
    FOREIGN KEY (seeker_id) REFERENCES job_seekers(seeker_id) ON DELETE CASCADE
);

-- Preferred Occupations (Dynamic Rows 1 to 3)
CREATE TABLE IF NOT EXISTS seeker_preferred_occupations (
    occupation_id INT AUTO_INCREMENT PRIMARY KEY,
    seeker_id INT NOT NULL,
    job_title VARCHAR(255),
    company_name VARCHAR(255),
    FOREIGN KEY (seeker_id) REFERENCES job_seekers(seeker_id) ON DELETE CASCADE
);

-- Preferred Locations (Dynamic Rows 1 to 3)
CREATE TABLE IF NOT EXISTS seeker_preferred_locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    seeker_id INT NOT NULL,
    is_overseas BOOLEAN DEFAULT 0,
    location_name VARCHAR(255),
    FOREIGN KEY (seeker_id) REFERENCES job_seekers(seeker_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS seeker_language_proficiencies (
    seeker_id INT PRIMARY KEY,
    eng_read BOOLEAN DEFAULT 0, eng_write BOOLEAN DEFAULT 0, eng_speak BOOLEAN DEFAULT 0, eng_understand BOOLEAN DEFAULT 0,
    fil_read BOOLEAN DEFAULT 0, fil_write BOOLEAN DEFAULT 0, fil_speak BOOLEAN DEFAULT 0, fil_understand BOOLEAN DEFAULT 0,
    man_read BOOLEAN DEFAULT 0, man_write BOOLEAN DEFAULT 0, man_speak BOOLEAN DEFAULT 0, man_understand BOOLEAN DEFAULT 0,
    other_language VARCHAR(100),
    oth_read BOOLEAN DEFAULT 0, oth_write BOOLEAN DEFAULT 0, oth_speak BOOLEAN DEFAULT 0, oth_understand BOOLEAN DEFAULT 0,
    FOREIGN KEY (seeker_id) REFERENCES job_seekers(seeker_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS seeker_educational_background (
    seeker_id INT PRIMARY KEY,
    currently_in_school VARCHAR(10) DEFAULT 'No',
    secondary_type VARCHAR(20) DEFAULT 'K12',
    
    elem_school VARCHAR(255), elem_year_grad VARCHAR(50), elem_level VARCHAR(50), elem_year_last VARCHAR(50),
    sec_school VARCHAR(255), sec_course VARCHAR(255), sec_year_grad VARCHAR(50), sec_level VARCHAR(50), sec_year_last VARCHAR(50),
    tert_school VARCHAR(255), tert_course VARCHAR(255), tert_year_grad VARCHAR(50), tert_level VARCHAR(50), tert_year_last VARCHAR(50),
    grad_school VARCHAR(255), grad_course VARCHAR(255), grad_year_grad VARCHAR(50), grad_level VARCHAR(50), grad_year_last VARCHAR(50),
    
    FOREIGN KEY (seeker_id) REFERENCES job_seekers(seeker_id) ON DELETE CASCADE
);

-- V. Technical/Vocational Training[cite: 13]
CREATE TABLE IF NOT EXISTS seeker_trainings (
    training_id INT AUTO_INCREMENT PRIMARY KEY,
    seeker_id INT NOT NULL,
    course_name VARCHAR(255),
    date_from VARCHAR(50),
    date_to VARCHAR(50),
    total_hours INT,
    institution VARCHAR(255),
    certificates_received VARCHAR(255),
    FOREIGN KEY (seeker_id) REFERENCES job_seekers(seeker_id) ON DELETE CASCADE
);

-- VI. Civil Service Eligibility[cite: 14]
CREATE TABLE IF NOT EXISTS seeker_eligibilities (
    eligibility_id INT AUTO_INCREMENT PRIMARY KEY,
    seeker_id INT NOT NULL,
    eligibility_name VARCHAR(255),
    date_taken VARCHAR(50),
    FOREIGN KEY (seeker_id) REFERENCES job_seekers(seeker_id) ON DELETE CASCADE
);

-- VI. Professional Licenses[cite: 14]
CREATE TABLE IF NOT EXISTS seeker_licenses (
    license_id INT AUTO_INCREMENT PRIMARY KEY,
    seeker_id INT NOT NULL,
    license_name VARCHAR(255),
    valid_until VARCHAR(50),
    FOREIGN KEY (seeker_id) REFERENCES job_seekers(seeker_id) ON DELETE CASCADE
);

-- VII. Work Experience[cite: 15]
CREATE TABLE IF NOT EXISTS seeker_work_experiences (
    experience_id INT AUTO_INCREMENT PRIMARY KEY,
    seeker_id INT NOT NULL,
    company_name VARCHAR(255),
    address VARCHAR(255),
    position VARCHAR(255),
    date_from VARCHAR(50),
    date_to VARCHAR(50),
    status VARCHAR(100),
    FOREIGN KEY (seeker_id) REFERENCES job_seekers(seeker_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS seeker_other_skills (
    seeker_id INT PRIMARY KEY,
    skills_list TEXT, -- Will store something like "Auto Mechanic, Driver, Plumber"
    others_specify VARCHAR(255),
    FOREIGN KEY (seeker_id) REFERENCES job_seekers(seeker_id) ON DELETE CASCADE
);

ALTER TABLE job_seekers
ADD COLUMN IF NOT EXISTS present_address TEXT;