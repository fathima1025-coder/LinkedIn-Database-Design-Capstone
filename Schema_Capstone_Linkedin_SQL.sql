-- ========================================================
-- PROFESSIONAL NETWORKING PLATFORM DATABASE SCHEMA (DDL)
-- ========================================================

-- Drop tables if they already exist (in reverse dependency order)
DROP TABLE IF EXISTS job_applications CASCADE;
DROP TABLE IF EXISTS connections CASCADE;
DROP TABLE IF EXISTS experiences CASCADE;
DROP TABLE IF EXISTS posts CASCADE;
DROP TABLE IF EXISTS jobs CASCADE;
DROP TABLE IF EXISTS companies CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- 1. PARENT TABLE: users
CREATE TABLE users (
user_id SERIAL PRIMARY KEY,
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL,
email VARCHAR(100) UNIQUE NOT NULL,
headline VARCHAR(200),
city VARCHAR(50),
country VARCHAR(50),
resume_url VARCHAR(255),
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. PARENT TABLE: companies
CREATE TABLE companies (
company_id SERIAL PRIMARY KEY,
company_name VARCHAR(120) NOT NULL,
industry VARCHAR(80),
headquarters_city VARCHAR(50),
headquarters_country VARCHAR(50),
website_url VARCHAR(255),
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. CHILD TABLE: jobs (references companies)
CREATE TABLE jobs (
job_id SERIAL PRIMARY KEY,
company_id INT NOT NULL,
title VARCHAR(120) NOT NULL,
location VARCHAR(120),
workplace_type VARCHAR(20), -- e.g., 'Remote', 'On-site', 'Hybrid'
is_active BOOLEAN DEFAULT TRUE,
posted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
CONSTRAINT fk_jobs_company
FOREIGN KEY (company_id) 
REFERENCES companies (company_id)
ON DELETE CASCADE
);

-- 4. CHILD TABLE: posts (references users)
CREATE TABLE posts (
post_id SERIAL PRIMARY KEY,
user_id INT NOT NULL,  
content TEXT NOT NULL,
likes_count INT DEFAULT 0,
views_count INT DEFAULT 0,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
CONSTRAINT fk_posts_user
FOREIGN KEY (user_id) 
REFERENCES users (user_id) 
ON DELETE CASCADE
);

-- 5. JUNCTION / CHILD TABLE: experiences (references users and companies)
CREATE TABLE experiences (
experience_id SERIAL PRIMARY KEY,
user_id INT NOT NULL,
company_id INT NOT NULL,
job_title VARCHAR(100) NOT NULL,
employment_type VARCHAR(30), -- e.g., 'Full-time', 'Contract', 'Internship'
start_date DATE NOT NULL,
end_date DATE,
is_current BOOLEAN DEFAULT FALSE,
CONSTRAINT fk_experiences_user
FOREIGN KEY (user_id) 
REFERENCES users (user_id)
ON DELETE CASCADE,
CONSTRAINT fk_experiences_company
FOREIGN KEY (company_id)
REFERENCES companies (company_id)
ON DELETE CASCADE
);

-- 6. JUNCTION TABLE: connections (self-referencing users)
CREATE TABLE connections (
user_id_1 INT NOT NULL,
user_id_2 INT NOT NULL,
status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'accepted', 'rejected'
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
PRIMARY KEY (user_id_1, user_id_2),
CONSTRAINT fk_connections_user1
FOREIGN KEY (user_id_1) 
REFERENCES users (user_id) 
ON DELETE CASCADE,
CONSTRAINT fk_connections_user2
FOREIGN KEY (user_id_2) 
REFERENCES users (user_id)
ON DELETE CASCADE,
CONSTRAINT chk_no_self_connect
CHECK (user_id_1 <> user_id_2)
);

-- 7. CHILD / JUNCTION TABLE: job_applications (references jobs and users)
CREATE TABLE job_applications (
application_id SERIAL PRIMARY KEY,
job_id INT NOT NULL,
user_id INT NOT NULL,
willing_to_relocate BOOLEAN DEFAULT FALSE,
status VARCHAR(50) DEFAULT 'submitted', -- 'submitted', 'in_review', 'interview', 'rejected', 'hired'
applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
CONSTRAINT fk_applications_job
FOREIGN KEY (job_id)
REFERENCES jobs (job_id) 
ON DELETE CASCADE,
CONSTRAINT fk_applications_user
FOREIGN KEY (user_id) 
REFERENCES users (user_id) 
ON DELETE CASCADE,
CONSTRAINT uq_user_job_application 
UNIQUE (job_id, user_id) -- prevents duplicate applications for the same job
);



-- ========================================================
-- DATA INSERTION
-- ========================================================

-- 1. Insert Users
INSERT INTO users (first_name, last_name, email, headline, city, country, resume_url) VALUES
('Aarav', 'Sharma', 'aarav.sharma@example.com', 'Senior Data Scientist | Python & ML', 'Bengaluru', 'India', 'https://cloud.storage/resumes/aarav.pdf'),
('Priya', 'Nair', 'priya.nair@example.com', 'Full Stack Engineer | React & Node', 'Chennai', 'India', 'https://cloud.storage/resumes/priya.pdf'),
('Rahul', 'Verma', 'rahul.verma@example.com', 'Product Manager | SaaS Growth', 'Hyderabad', 'India', 'https://cloud.storage/resumes/rahul.pdf'),
('Sneha', 'Patel', 'sneha.patel@example.com', 'Cloud Architect | AWS & Kubernetes', 'Pune', 'India', 'https://cloud.storage/resumes/sneha.pdf'),
('Vikram', 'Rao', 'vikram.rao@example.com', 'Backend Developer | Go & PostgreSQL', 'Bengaluru', 'India', 'https://cloud.storage/resumes/vikram.pdf');

-- 2. Insert Companies
INSERT INTO companies (company_name, industry, headquarters_city, headquarters_country, website_url) VALUES
('Nexura Tech', 'Information Technology', 'Bengaluru', 'India', 'https://nexuratech.com'),
('FinScale Solutions', 'Fintech', 'Mumbai', 'India', 'https://finscalesolutions.com'),
('CloudSphere Labs', 'Cloud Computing', 'Hyderabad', 'India', 'https://cloudspherelabs.io');

-- 3. Insert Jobs (references companies)
INSERT INTO jobs (company_id, title, location, workplace_type, is_active) VALUES
(1, 'Lead Data Engineer', 'Bengaluru', 'Hybrid', TRUE),
(1, 'Senior Backend Engineer', 'Bengaluru', 'On-site', TRUE),
(2, 'Product Operations Analyst', 'Mumbai', 'Remote', TRUE),
(3, 'Cloud Infrastructure Engineer', 'Hyderabad', 'Remote', TRUE),
(2, 'Frontend Developer', 'Mumbai', 'Hybrid', FALSE);

-- 4. Insert Experiences (references users and companies)
INSERT INTO experiences (user_id, company_id, job_title, employment_type, start_date, end_date, is_current) VALUES
(1, 1, 'Data Engineer', 'Full-time', '2021-06-01', '2023-12-31', FALSE),
(1, 1, 'Senior Data Scientist', 'Full-time', '2024-01-01', NULL, TRUE),
(2, 2, 'Software Engineer', 'Full-time', '2022-03-15', NULL, TRUE),
(3, 2, 'Associate PM', 'Full-time', '2020-08-01', '2023-05-30', FALSE),
(4, 3, 'DevOps Specialist', 'Contract', '2023-01-10', NULL, TRUE);

-- 5. Insert Posts (references users)
INSERT INTO posts (user_id, content, likes_count, views_count) VALUES
(1, 'Excited to announce our machine learning pipeline just hit 99.8% uptime!', 142, 1850),
(2, 'Clean architecture and maintainable code save more time than fast hacks ever will.', 89, 920),
(3, 'Three product management principles I learned after launching 5 SaaS tools this year.', 310, 4200),
(4, 'Migrating microservices to Kubernetes: here is what we learned along the way.', 215, 2750);

-- 6. Insert Connections (self-referencing users)
INSERT INTO connections (user_id_1, user_id_2, status, created_at, updated_at) VALUES
(1, 2, 'accepted', '2024-02-10 10:00:00', '2024-02-10 11:30:00'),
(1, 3, 'accepted', '2024-03-01 09:15:00', '2024-03-01 14:00:00'),
(2, 4, 'pending', '2024-05-18 16:45:00', '2024-05-18 16:45:00'),
(3, 5, 'accepted', '2024-06-12 08:30:00', '2024-06-12 12:10:00'),
(4, 5, 'rejected', '2024-07-02 14:20:00', '2024-07-03 09:00:00');

-- 7. Insert Job Applications (references jobs and users)
INSERT INTO job_applications (job_id, user_id, willing_to_relocate, status) VALUES
(1, 1, FALSE, 'interview'),
(2, 2, TRUE, 'in_review'),
(3, 3, FALSE, 'submitted'),
(4, 4, TRUE, 'hired'),
(2, 5, TRUE, 'submitted');

SELECT 
    u.first_name || ' ' || u.last_name AS applicant_name,
    c.company_name,
    j.title AS applied_position,
    ja.status AS application_status,
    ja.applied_at
FROM job_applications ja
JOIN users u ON ja.user_id = u.user_id
JOIN jobs j ON ja.job_id = j.job_id
JOIN companies c ON j.company_id = c.company_id;

--Query 1: Active Job Openings by Company

SELECT c.company_name, c.industry, COUNT(j.job_id) AS total_active_jobs
FROM companies c
INNER JOIN jobs j ON c.company_id = j.company_id
WHERE j.is_active = TRUE
GROUP BY c.company_id, c.company_name, c.industry
ORDER BY total_active_jobs DESC
LIMIT 5;

--Query 2: Job Application Outcomes and Hiring Rate by Company

SELECT c.company_name,COUNT(a.application_id) AS total_applications,COUNT(CASE WHEN a.status = 'hired' THEN 1 END)
AS hired_applicants,
ROUND(COUNT(CASE WHEN a.status = 'hired' THEN 1 END) * 100.0/ NULLIF(COUNT(a.application_id), 0),2) AS hiring_rate_percent
FROM companies c
JOIN jobs j
ON c.company_id = j.company_id
LEFT JOIN job_applications a
ON j.job_id = a.job_id
GROUP BY c.company_id, c.company_name
HAVING COUNT(a.application_id) > 0
ORDER BY hiring_rate_percent DESC;

-- Query 3: LinkedIn Post Engagement Analysis

SELECT 
p.post_id,
CONCAT(u.first_name, ' ', u.last_name) AS user_name,
p.likes_count,
p.views_count,
ROUND(p.likes_count * 100.0 / NULLIF(p.views_count, 0),2) AS engagement_rate_percent
--calc percentage views and NULLIF prevents a division-by-zero error if a post has zero views.
FROM posts p
INNER JOIN users u--it connects each post to its post_id and name
ON p.user_id = u.user_id
ORDER BY engagement_rate_percent DESC;--- ORDER BY ranks posts from the highest engagement rate to the lowest.

--Query 4:Active Job Opportunities by Company and Location — Using CTE
WITH active_jobs AS(
SELECT company_id,location FROM jobs
WHERE is_active=TRUE --keeps only active jobs
)
SELECT company_id,location, 
COUNT (company_id) AS total_active_jobs --counts job in each group
FROM active_jobs
GROUP BY company_id,location--groups job by company and location
ORDER BY total_active_jobs DESC;

--Query 5: Company-wise Job Application Analysis
WITH application_status AS(
SELECT
c.company_id,c.company_name,j.job_id,a.application_id,a.status
FROM companies c	
JOIN jobs j
ON c.company_id=j.company_id
JOIN job_applications a
ON j.job_id=a.job_id
)
SELECT
company_id,company_name,job_id,application_id,status,
COUNT(*)OVER (PARTITION BY company_id)AS total_company_applications
FROM application_status
ORDER BY company_id;
