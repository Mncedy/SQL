use jobPostings;

Select Top 5 *
From jobPostings..job_postings_fact

Select Top 5 *
From jobPostings..company_dim

Select  *
From jobPostings..skills_dim
-- Where skills like '%power%' OR skills like '%tableau%'

Select Top 5 *
From jobPostings..skills_job_dim

-- Create indexes on foreign key columns gor better perfomance
/* Create Index idx_company ON job_postings_fact (company_id);
Create Index idx_skill_id ON skills_job_dim (skill_id);
Create Index idx_job_id ON skills_job_dim (job_id); */

ALTER TABLE jobPostings..job_postings_fact
ALTER COLUMN job_posted_date DATETIME;

-- Display columns for time zone conversion
SELECT Top 5
	job_title_short,
	job_location,
	job_posted_date AT TIME ZONE 'UTC' AS UTC,
	job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time' AS EST,
	DATEPART(YEAR, job_posted_date) AS Year_Date,
	DATEPART(Month, job_posted_date) AS Month_Date,
	DATEPART(DAY, job_posted_date) AS Month_Day,
	CAST(job_posted_date AS DATE) AS Date,
	CAST(job_posted_date AS TIME) AS Time
FROM 
	jobPostings..job_postings_fact;



SELECT 
	COUNT(job_id) AS Job,
	DATEPART(Month, job_posted_date) AS Month
FROM 
	jobPostings..job_postings_fact
Where
	job_title_short = 'Business Analyst'
Group BY
	DATEPART(Month, job_posted_date)
Order By
	Job desc


-- Creating tables for each month
SELECT 
    *
INTO 
    january_jobs
FROM 
    jobPostings..job_postings_fact
WHERE 
    DATEPART(Month, job_posted_date) = 1;

SELECT 
    *
INTO 
    february_jobs
FROM 
    jobPostings..job_postings_fact
WHERE 
    DATEPART(Month, job_posted_date) = 2;


-- This method queries the INFORMATION_SCHEMA.COLUMNS view to get information about columns in a specific table.
SELECT 
    COLUMN_NAME,
    DATA_TYPE
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_NAME = 'job_postings_fact';


-- Change the column data type to DECIMAL
ALTER TABLE jobPostings..job_postings_fact
ALTER COLUMN salary_year_avg DECIMAL(18,2);



SELECT 
	COUNT(job_id) AS numJobs,
	CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'Singapore' THEN 'Ideally'
        ELSE 'Hybrid'
    END AS loc_cat
FROM 
    jobPostings..job_postings_fact	
Where
	job_title_short = 'Business Analyst'
Group BY
	CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'Singapore' THEN 'Ideally'
        ELSE 'Hybrid'
    END 

Select TOP 5 *
From (
	SELECT 
    *
	FROM 
    jobPostings..job_postings_fact
WHERE 
    DATEPART(Month, job_posted_date) = 7
	) AS july_jobs;

With sep_jobs AS (
	SELECT *
	FROM 
		jobPostings..job_postings_fact
	WHERE 
		DATEPART(Month, job_posted_date) = 9
	)
Select *
From sep_jobs;


/* 
- Find the companies that have the most job opennings.
- Get the total number of job postings per company id.
- Return the total number of jobs with the company name.
*/

WITH jobCount AS (
    Select
        company_id,
        COUNT(*) AS job_count
    From
        jobPostings..job_postings_fact
    Group BY 
        company_id
)

Select Top 5
	cd.name AS company_name,
	jc.job_count
From company_dim cd
	 JOIN jobCount jc ON jc.company_id = cd.company_id
Order BY
	job_count desc
	






/*
- Find the count of the number of remote job postings per skill.
- Display the top 5 skills by their demand in remote jobs.
- Include skill_id, name, and count of postings requiring the skills.
*/

With remote_jobs AS (
	Select
		skill_id,
		COUNT(*) AS skill_count
	From
		jobPostings..skills_job_dim AS sj
		JOIN job_postings_fact jpf ON jpf.job_id = sj.job_id
	Where
		jpf.job_work_from_home = 'True' AND 
		jpf.job_title_short = 'Business Analyst'
	Group BY
		skill_id
	)

Select Top 5
	sk.skill_id,
	sk.skills AS skill_name,
	skill_count
From 
	remote_jobs
INNER JOIN skills_dim sk ON sk.skill_id = remote_jobs.skill_id
Order BY
	skill_count desc

Select
	job_title_short,
	company_id,
	job_location
From
	jobPostings..january_jobs
UNION 
Select
	job_title_short,
	company_id,
	job_location
From
	jobPostings..february_jobs
UNION 
Select
	job_title_short,
	company_id,
	job_location
From
	jobPostings..march_jobs



/*
- Get the corresponding skill and skill type for each job posting in in q1.
- Include those without any skills too.
Look at the skills and skill type for each job that has a salary greater then 65000 in q1
*/

SELECT 
    jp.job_id,
    jp.job_title_short,
    CAST(jp.salary_year_avg AS FLOAT) AS salary_year_avg,
    s.skills
FROM (
		jobPostings..job_postings_fact jp
	LEFT JOIN 
		jobPostings..skills_job_dim sj ON jp.job_id = sj.job_id
	LEFT JOIN 
		jobPostings..skills_dim s ON sj.skill_id = s.skill_id
	) 
WHERE 
    jp.salary_year_avg > 65000
    AND DATEPART(Quarter, jp.job_posted_date) = 1 AND
	skills IS NOT NULL
ORDER BY 
    salary_year_avg desc;

/*
- Find job postings from 1st quarter that have salary > 65000
- Combine job posting tables from the 1st quater
- Get job postings whith avg yearly salary > 65000
*/

SELECT 
    job_title_short,
    job_location,
    job_via,
    CAST(job_posted_date AS DATE) AS date_posted,
    salary_year_avg
FROM (
    SELECT
        *
    FROM
        jobPostings..january_jobs
    UNION ALL
    SELECT
        *
    FROM
        jobPostings..february_jobs
    UNION ALL
    SELECT
        *
    FROM
        jobPostings..march_jobs
) AS Q1_Jobs
WHERE
    salary_year_avg > 65000 AND
    job_title_short = 'Data Analyst'
ORDER BY
    salary_year_avg DESC;

