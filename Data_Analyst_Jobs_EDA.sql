Use jobPostings;


/*
- What are the top-paying data analyst jobs?
- Idebify the top 10 highest-paying Data Analyst roles are available remote.
- Focuses on job postings with specified salaries (reomove nulls)
- Highlight the top-paying opportunities for Data Analysis
*/

SELECT	Top 10
	job_id,
	job_title,
	job_location,
	job_schedule_type,
	salary_year_avg,
	CAST(job_posted_date AS date) AS date,
	name AS company_name
From
	jobPostings..job_postings_fact jpf
	JOIN company_dim cd ON jpf.company_id = cd.company_id
WHERE
    salary_year_avg IS NOT NULL AND
    job_title_short = 'Data Analyst' AND
	job_location = 'Anywhere'
Order BY
	salary_year_avg desc



/*
- What skills are required for the top-paying data analyst jobs?
- Add specific skills required for these roles.
It provides a detailed look at which high-paying jobs demand certain skills,
	helping job seekers understand which skills to develop that align with top salaries.
*/

WITH highest_paying_job AS (
	Select	Top 10
		job_id,
		job_title,
		salary_year_avg,
		name AS company_name
	From
		jobPostings..job_postings_fact jpf
		JOIN company_dim cd ON jpf.company_id = cd.company_id
	WHERE
		salary_year_avg IS NOT NULL AND
		job_title_short = 'Data Analyst' AND
		job_location = 'Anywhere'
	Order BY
		salary_year_avg desc
	)
Select 
	hpj.*,
	skills
From highest_paying_job hpj
	JOIN skills_job_dim skd ON hpj.job_id = skd.job_id
	JOIN skills_dim sk ON skd.skill_id = sk.skill_id
Order BY
		salary_year_avg desc

/*
- What are the most in-demand skills for data analysts?
-Identify the top 5 skills in-demand for analyst jobs.
- Retrieves the top 5 skill with the highest demand in the job market,
	providing insights into the most valuable skills for job seekers.
*/

With remote_jobs AS (
	Select TOP 5
		skill_id,
		COUNT(sjk.job_id) AS demand_count
	From
		jobPostings..job_postings_fact AS jpf
		JOIN skills_job_dim sjk ON jpf.job_id = sjk.job_id
	Where
		jpf.job_work_from_home = 'True' AND 
		jpf.job_title_short = 'Data Analyst'
	Group BY
		skill_id
	Order BY
		demand_count DESC
	)

Select Top 5
	sk.skills AS skill_name,
	demand_count
From 
	remote_jobs
	JOIN skills_dim sk ON sk.skill_id = remote_jobs.skill_id
Order BY
	demand_count desc


-- DB optimazation query
Select Top 5
	skills AS skill_name,
	COUNT(skd.job_id) AS demand_count
From job_postings_fact jpf
	JOIN skills_job_dim skd ON jpf.job_id = skd.job_id
	JOIN skills_dim sk ON skd.skill_id = sk.skill_id
Where
	jpf.job_work_from_home = 'True' AND
	job_title_short = 'Data Analyst' 
Group BY
	skills
Order BY
	demand_count desc



/*
- What are top skills based on salary?
It reveals how different skills imapct salary levels for Analyst and help identify
the most financially rewarding skils to acquire or improve.
*/

Select Top 25
	skills,
	CAST(ROUND(AVG(salary_year_avg), 0) AS decimal) AS avg_salary
From job_postings_fact jpf
	JOIN skills_job_dim skd ON jpf.job_id = skd.job_id
	JOIN skills_dim sk ON skd.skill_id = sk.skill_id
Where
	job_title_short = 'Data Analyst' AND
	salary_year_avg IS NOT NULL AND
    job_work_from_home = 'True'
Group BY
	skills
Order BY
	avg_salary desc


/*
- What are the most optimal skills to learn (aka its in hight-paying or high-demand skill)?
-Identify skill in high-demand and associated whith high salaies for analyst jobs.
Targets skills that offer job security (high demand) and financial benefits (high-paying),
offering strategic insights for career development in analyst roles.
*/

WITH skill_demand AS (
    SELECT 
        sk.skill_id,
        sk.skills,
        COUNT(skd.job_id) AS demand_count
    FROM job_postings_fact jpf
    INNER JOIN skills_job_dim skd ON jpf.job_id = skd.job_id
    INNER JOIN skills_dim sk ON skd.skill_id = sk.skill_id
    WHERE
        jpf.job_title_short LIKE '%analyst%' AND
        jpf.salary_year_avg IS NOT NULL
    GROUP BY
        sk.skill_id, sk.skills
),

average_salary AS (
    SELECT 
        sk.skill_id,
        sk.skills,
        CAST(ROUND(AVG(jpf.salary_year_avg), 0) AS decimal) AS avg_salary
    FROM job_postings_fact jpf
    INNER JOIN skills_job_dim skd ON jpf.job_id = skd.job_id
    INNER JOIN skills_dim sk ON skd.skill_id = sk.skill_id
    WHERE
        jpf.job_title_short LIKE '%analyst%' AND
        jpf.salary_year_avg IS NOT NULL
    GROUP BY
        sk.skill_id, sk.skills
)

SELECT 
    sd.skill_id,
    sd.skills,
    sd.demand_count,
    av.avg_salary
FROM 
	skill_demand sd
	JOIN average_salary av ON sd.skill_id = av.skill_id
ORDER BY 
    sd.demand_count DESC, av.avg_salary;

-- Rewriting the same query more conciselyy
Select 
	sd.skill_id,
	sd.skills,
	COUNT(sj.job_id) AS demand_count,
	ROUND(AVG(jp.salary_year_avg), 0) AS avg_salary
From 
	jobPostings..job_postings_fact jp
	INNER JOIN skills_job_dim sj ON jp.job_id = sj.job_id
	INNER JOIN skills_dim sd ON sj.skill_id = sd.skill_id
Where
	job_title_short like '%analyst%' AND
	salary_year_avg IS NOT NULL
Group BY
	sd.skill_id, sd.skills
HAVING
	COUNT(sj.job_id) > 10
Order BY 
	avg_salary desc,
	demand_count desc
