-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               10.4.32-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             12.14.0.7165
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for neis_db
CREATE DATABASE IF NOT EXISTS `neis_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;
USE `neis_db`;

-- Dumping structure for table neis_db.employers
CREATE TABLE IF NOT EXISTS `employers` (
  `employer_id` int(11) NOT NULL AUTO_INCREMENT,
  `company_name` varchar(255) NOT NULL,
  `industry` varchar(100) NOT NULL,
  `website` varchar(255) DEFAULT NULL,
  `contact_person` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone` varchar(50) NOT NULL,
  `address` text NOT NULL,
  `registered_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `logo_url` varchar(255) DEFAULT NULL,
  `status` varchar(50) DEFAULT 'Active',
  `company_description` text DEFAULT NULL,
  `is_accredited` tinyint(1) DEFAULT 0,
  `accreditation_date` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`employer_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table neis_db.job_applications
CREATE TABLE IF NOT EXISTS `job_applications` (
  `application_id` int(11) NOT NULL AUTO_INCREMENT,
  `seeker_id` int(11) NOT NULL,
  `vacancy_id` int(11) NOT NULL,
  `status` varchar(50) DEFAULT 'Pending',
  `applied_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`application_id`),
  UNIQUE KEY `unique_application` (`seeker_id`,`vacancy_id`),
  KEY `vacancy_id` (`vacancy_id`),
  CONSTRAINT `job_applications_ibfk_1` FOREIGN KEY (`seeker_id`) REFERENCES `job_seekers` (`seeker_id`) ON DELETE CASCADE,
  CONSTRAINT `job_applications_ibfk_2` FOREIGN KEY (`vacancy_id`) REFERENCES `job_vacancies` (`vacancy_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=62 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table neis_db.job_seekers
CREATE TABLE IF NOT EXISTS `job_seekers` (
  `seeker_id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `contact_number` varchar(20) DEFAULT NULL,
  `skills` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_first_time_jobseeker` tinyint(1) DEFAULT 1,
  `middle_name` varchar(100) DEFAULT NULL,
  `suffix` varchar(20) DEFAULT NULL,
  `date_of_birth` varchar(50) DEFAULT NULL,
  `sex` varchar(20) DEFAULT NULL,
  `age` int(11) DEFAULT NULL,
  `religion` varchar(100) DEFAULT NULL,
  `civil_status` varchar(50) DEFAULT NULL,
  `house_no` varchar(255) DEFAULT NULL,
  `barangay` varchar(100) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `province` varchar(100) DEFAULT NULL,
  `tin` varchar(50) DEFAULT NULL,
  `height` varchar(50) DEFAULT NULL,
  `disabilities` text DEFAULT NULL,
  `other_disability` varchar(255) DEFAULT NULL,
  `present_address` text DEFAULT NULL,
  PRIMARY KEY (`seeker_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table neis_db.job_vacancies
CREATE TABLE IF NOT EXISTS `job_vacancies` (
  `vacancy_id` int(11) NOT NULL AUTO_INCREMENT,
  `job_title` varchar(255) NOT NULL,
  `employer_name` varchar(255) NOT NULL,
  `encoded_by_staff_id` int(11) DEFAULT NULL,
  `date_posted` timestamp NOT NULL DEFAULT current_timestamp(),
  `years_experience` int(11) DEFAULT 0,
  `salary` varchar(100) DEFAULT NULL,
  `vacancies_count` int(11) DEFAULT 1,
  `employment_type` varchar(50) DEFAULT NULL,
  `industry` varchar(100) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `job_description` text DEFAULT NULL,
  `qualifications` text DEFAULT NULL,
  `application_deadline` date DEFAULT NULL,
  `job_location_type` varchar(50) DEFAULT 'Local',
  `status` varchar(50) DEFAULT 'Active',
  `employer_career_link` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`vacancy_id`),
  KEY `encoded_by_staff_id` (`encoded_by_staff_id`),
  CONSTRAINT `job_vacancies_ibfk_1` FOREIGN KEY (`encoded_by_staff_id`) REFERENCES `peso_staff` (`staff_id`)
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table neis_db.peso_staff
CREATE TABLE IF NOT EXISTS `peso_staff` (
  `staff_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `role` varchar(50) DEFAULT 'peso_staff',
  `email` varchar(150) DEFAULT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`staff_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table neis_db.recruitment_coordinations
CREATE TABLE IF NOT EXISTS `recruitment_coordinations` (
  `activity_id` int(11) NOT NULL AUTO_INCREMENT,
  `employer_id` int(11) NOT NULL,
  `activity_title` varchar(255) NOT NULL,
  `activity_date` date NOT NULL,
  `activity_type` varchar(100) DEFAULT NULL,
  `status` varchar(50) DEFAULT 'Scheduled',
  `remarks` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`activity_id`),
  KEY `employer_id` (`employer_id`),
  CONSTRAINT `recruitment_coordinations_ibfk_1` FOREIGN KEY (`employer_id`) REFERENCES `employers` (`employer_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table neis_db.seeker_educational_background
CREATE TABLE IF NOT EXISTS `seeker_educational_background` (
  `seeker_id` int(11) NOT NULL,
  `currently_in_school` varchar(10) DEFAULT 'No',
  `secondary_type` varchar(20) DEFAULT 'K12',
  `elem_school` varchar(255) DEFAULT NULL,
  `elem_year_grad` varchar(50) DEFAULT NULL,
  `elem_level` varchar(50) DEFAULT NULL,
  `elem_year_last` varchar(50) DEFAULT NULL,
  `sec_school` varchar(255) DEFAULT NULL,
  `sec_course` varchar(255) DEFAULT NULL,
  `sec_year_grad` varchar(50) DEFAULT NULL,
  `sec_level` varchar(50) DEFAULT NULL,
  `sec_year_last` varchar(50) DEFAULT NULL,
  `tert_school` varchar(255) DEFAULT NULL,
  `tert_course` varchar(255) DEFAULT NULL,
  `tert_year_grad` varchar(50) DEFAULT NULL,
  `tert_level` varchar(50) DEFAULT NULL,
  `tert_year_last` varchar(50) DEFAULT NULL,
  `grad_school` varchar(255) DEFAULT NULL,
  `grad_course` varchar(255) DEFAULT NULL,
  `grad_year_grad` varchar(50) DEFAULT NULL,
  `grad_level` varchar(50) DEFAULT NULL,
  `grad_year_last` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`seeker_id`),
  CONSTRAINT `seeker_educational_background_ibfk_1` FOREIGN KEY (`seeker_id`) REFERENCES `job_seekers` (`seeker_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table neis_db.seeker_eligibilities
CREATE TABLE IF NOT EXISTS `seeker_eligibilities` (
  `eligibility_id` int(11) NOT NULL AUTO_INCREMENT,
  `seeker_id` int(11) NOT NULL,
  `eligibility_name` varchar(255) DEFAULT NULL,
  `date_taken` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`eligibility_id`),
  KEY `seeker_id` (`seeker_id`),
  CONSTRAINT `seeker_eligibilities_ibfk_1` FOREIGN KEY (`seeker_id`) REFERENCES `job_seekers` (`seeker_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table neis_db.seeker_employment_status
CREATE TABLE IF NOT EXISTS `seeker_employment_status` (
  `seeker_id` int(11) NOT NULL,
  `main_status` varchar(50) DEFAULT 'Unemployed',
  `employed_category` varchar(50) DEFAULT NULL,
  `self_employed_type` varchar(100) DEFAULT NULL,
  `self_employed_others` varchar(255) DEFAULT NULL,
  `months_looking` int(11) DEFAULT NULL,
  `unemployed_reason` varchar(100) DEFAULT NULL,
  `unemployed_country` varchar(100) DEFAULT NULL,
  `unemployed_others` varchar(255) DEFAULT NULL,
  `is_ofw` varchar(10) DEFAULT 'No',
  `ofw_country` varchar(100) DEFAULT NULL,
  `is_former_ofw` varchar(10) DEFAULT 'No',
  `former_ofw_country` varchar(100) DEFAULT NULL,
  `former_ofw_return` varchar(50) DEFAULT NULL,
  `has_ofw_family` varchar(10) DEFAULT 'No',
  `ofw_family_member` varchar(50) DEFAULT NULL,
  `ofw_family_country` varchar(100) DEFAULT NULL,
  `is_4ps` varchar(10) DEFAULT 'No',
  `fourps_id` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`seeker_id`),
  CONSTRAINT `seeker_employment_status_ibfk_1` FOREIGN KEY (`seeker_id`) REFERENCES `job_seekers` (`seeker_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table neis_db.seeker_job_preferences
CREATE TABLE IF NOT EXISTS `seeker_job_preferences` (
  `seeker_id` int(11) NOT NULL,
  `is_part_time` tinyint(1) DEFAULT 0,
  `is_full_time` tinyint(1) DEFAULT 0,
  `is_local` tinyint(1) DEFAULT 0,
  `is_overseas` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`seeker_id`),
  CONSTRAINT `seeker_job_preferences_ibfk_1` FOREIGN KEY (`seeker_id`) REFERENCES `job_seekers` (`seeker_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table neis_db.seeker_language_proficiencies
CREATE TABLE IF NOT EXISTS `seeker_language_proficiencies` (
  `seeker_id` int(11) NOT NULL,
  `eng_read` tinyint(1) DEFAULT 0,
  `eng_write` tinyint(1) DEFAULT 0,
  `eng_speak` tinyint(1) DEFAULT 0,
  `eng_understand` tinyint(1) DEFAULT 0,
  `fil_read` tinyint(1) DEFAULT 0,
  `fil_write` tinyint(1) DEFAULT 0,
  `fil_speak` tinyint(1) DEFAULT 0,
  `fil_understand` tinyint(1) DEFAULT 0,
  `man_read` tinyint(1) DEFAULT 0,
  `man_write` tinyint(1) DEFAULT 0,
  `man_speak` tinyint(1) DEFAULT 0,
  `man_understand` tinyint(1) DEFAULT 0,
  `other_language` varchar(100) DEFAULT NULL,
  `oth_read` tinyint(1) DEFAULT 0,
  `oth_write` tinyint(1) DEFAULT 0,
  `oth_speak` tinyint(1) DEFAULT 0,
  `oth_understand` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`seeker_id`),
  CONSTRAINT `seeker_language_proficiencies_ibfk_1` FOREIGN KEY (`seeker_id`) REFERENCES `job_seekers` (`seeker_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table neis_db.seeker_licenses
CREATE TABLE IF NOT EXISTS `seeker_licenses` (
  `license_id` int(11) NOT NULL AUTO_INCREMENT,
  `seeker_id` int(11) NOT NULL,
  `license_name` varchar(255) DEFAULT NULL,
  `valid_until` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`license_id`),
  KEY `seeker_id` (`seeker_id`),
  CONSTRAINT `seeker_licenses_ibfk_1` FOREIGN KEY (`seeker_id`) REFERENCES `job_seekers` (`seeker_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table neis_db.seeker_other_skills
CREATE TABLE IF NOT EXISTS `seeker_other_skills` (
  `seeker_id` int(11) NOT NULL,
  `skills_list` text DEFAULT NULL,
  `others_specify` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`seeker_id`),
  CONSTRAINT `seeker_other_skills_ibfk_1` FOREIGN KEY (`seeker_id`) REFERENCES `job_seekers` (`seeker_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table neis_db.seeker_preferred_locations
CREATE TABLE IF NOT EXISTS `seeker_preferred_locations` (
  `location_id` int(11) NOT NULL AUTO_INCREMENT,
  `seeker_id` int(11) NOT NULL,
  `is_overseas` tinyint(1) DEFAULT 0,
  `location_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`location_id`),
  KEY `seeker_id` (`seeker_id`),
  CONSTRAINT `seeker_preferred_locations_ibfk_1` FOREIGN KEY (`seeker_id`) REFERENCES `job_seekers` (`seeker_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table neis_db.seeker_preferred_occupations
CREATE TABLE IF NOT EXISTS `seeker_preferred_occupations` (
  `occupation_id` int(11) NOT NULL AUTO_INCREMENT,
  `seeker_id` int(11) NOT NULL,
  `job_title` varchar(255) DEFAULT NULL,
  `company_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`occupation_id`),
  KEY `seeker_id` (`seeker_id`),
  CONSTRAINT `seeker_preferred_occupations_ibfk_1` FOREIGN KEY (`seeker_id`) REFERENCES `job_seekers` (`seeker_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table neis_db.seeker_trainings
CREATE TABLE IF NOT EXISTS `seeker_trainings` (
  `training_id` int(11) NOT NULL AUTO_INCREMENT,
  `seeker_id` int(11) NOT NULL,
  `course_name` varchar(255) DEFAULT NULL,
  `date_from` varchar(50) DEFAULT NULL,
  `date_to` varchar(50) DEFAULT NULL,
  `total_hours` int(11) DEFAULT NULL,
  `institution` varchar(255) DEFAULT NULL,
  `certificates_received` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`training_id`),
  KEY `seeker_id` (`seeker_id`),
  CONSTRAINT `seeker_trainings_ibfk_1` FOREIGN KEY (`seeker_id`) REFERENCES `job_seekers` (`seeker_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table neis_db.seeker_work_experiences
CREATE TABLE IF NOT EXISTS `seeker_work_experiences` (
  `experience_id` int(11) NOT NULL AUTO_INCREMENT,
  `seeker_id` int(11) NOT NULL,
  `company_name` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `position` varchar(255) DEFAULT NULL,
  `date_from` varchar(50) DEFAULT NULL,
  `date_to` varchar(50) DEFAULT NULL,
  `status` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`experience_id`),
  KEY `seeker_id` (`seeker_id`),
  CONSTRAINT `seeker_work_experiences_ibfk_1` FOREIGN KEY (`seeker_id`) REFERENCES `job_seekers` (`seeker_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Data exporting was unselected.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
