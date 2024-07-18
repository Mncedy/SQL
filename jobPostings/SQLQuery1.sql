-- Create database jobPostings
-- use jobPostings;

Select Top 5 *
From jobPostings..job_postings_fact

Select Top 5 *
From jobPostings..company_dim

Select Top 8 *
From jobPostings..skills_dim

Select *
From jobPostings..skills_job_dim

Select job_id, 
	   job_title_short,
	   job_location, 
	   job_via as job_posted_site, 
	   job_posted_date, 
	   salary_year_avg as yearly_salary
From jobPostings..job_postings_fact

Select 
	   posting.job_id, 
	   posting.job_title_short,
	   companies.name
From jobPostings..job_postings_fact as posting
	Left JOIN jobPostings..company_dim as companies
	ON posting.company_id = companies.company_id

ALTER TABLE jobPostings..job_postings_fact
ALTER COLUMN salary_year_avg decimal;

UPDATE skills_dim
SET skills = 'powerbi'
WHERE skills = 'sas' AND
	skill_id = 186;



Select
	   sk.skills as skill_name,
	   COUNT(sk_to_job.job_id) as number_of_jobs,
	   AVG(CAST(postings.salary_year_avg AS decimal)) as average_salary
From jobPostings..skills_dim as sk
	LEFT JOIN skills_job_dim as sk_to_job on sk.skill_id = sk_to_job.skill_id
	LEFT JOIN job_postings_fact as postings on sk_to_job.job_id = postings.job_id
Group BY
	   sk.skills
Order BY 
	   average_salary desc