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
Identify the top 5 skills that are most frequently mentioned in job postings. 
Find the skill IDs with the highest counts in skill_job_dim table, 
and then join this result with the skills_dim table to get skills names.
*/

WITH most_skills AS (
	Select
		skill_id,
		COUNT(*) AS skill_count
	From 
		jobPostings..skills_job_dim
	Group BY
		skill_id 
	)
Select Top 5
	sd.skills,
	ms.skill_count
From jobPostings..skills_dim AS sd
	 JOIN most_skills AS ms ON sd.skill_id = ms.skill_id
Order BY
	skill_count desc



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
    FROM 
		job_postings_fact jpf
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


/*
Determine the size category ("Small", "Medium", "Large") for each company by first identifying the number of job postings they have. 
Calculate the total number of job postings per company.
A company is considered 'Small if it has less than 10 job postings'.
'Medium when the number of job postings is between 10 and 50'.
'Large if it has more than 50 job postings'.
Aggregate job counts per company before classifying them based on size.
*/

WITH CompanyJobCount AS (
	Select 
		company_id,
		COUNT(*) AS jobTotal
	From 
		jobPostings..job_postings_fact
	Group BY
		company_id
	)
Select 
	cd.name,
	jobTotal,
	CASE
		When jobTotal < 10 Then 'Small'
		When jobTotal BETWEEN 10 AND 50 Then 'Medium'
		ELSE 'Large'
	END AS company_size_cat
From 
	CompanyJobCount cjc
		JOIN company_dim cd ON cjc.company_id = cd.company_id
Order BY
	jobTotal


/*

*/

-- Create a temporary table to hold the skills and their corresponding salaries
CREATE TABLE #SkillSalaries (
		job_title_short nvarchar(100), 
		salary_year_avg DECIMAL,
		skill nvarchar(100)
)

INSERT INTO 
	#SkillSalaries
SELECT 
    job_title_short,
    salary_year_avg,
    skills
	FROM 
		jobPostings..job_postings_fact jpf
		JOIN skills_job_dim sj ON jpf.job_id = sj.job_id
		JOIN skills_dim sd ON sj.skill_id = sd.skill_id;

-- Common Table Expression (CTE) to calculate salary statistics for each skill
WITH SalaryStats AS (
    SELECT 
        job_title_short, 
		skill,
        AVG(salary_year_avg) AS avg_salary, 
        MAX(salary_year_avg) AS max_salary, 
        MIN(salary_year_avg) AS min_salary
    FROM 
        #SkillSalaries
    GROUP BY 
       job_title_short, skill
)
-- Select the skill and its salary statistics, ordering by average salary in descending order
SELECT 
    skill, 
    avg_salary, 
    max_salary, 
    min_salary
FROM 
    SalaryStats
Where
	job_title_short = 'Data Analyst'
ORDER BY 
    avg_salary DESC;



/*

*/

WITH SalaryDistribution AS (
    SELECT 
		ss.skill, 
		jpf.job_title_short,
		jpf.salary_year_avg, 
		NTILE(100) OVER (PARTITION BY skill ORDER BY jpf.salary_year_avg) AS percentile
    FROM jobPostings..job_postings_fact jpf
	JOIN #SkillSalaries ss ON jpf.job_title_short = ss.job_title_short
)
SELECT 
	skill, 
	percentile, 
	AVG(salary_year_avg) AS avg_salary
FROM 
	SalaryDistribution
Where
	job_title_short = 'Data Analyst' AND
	salary_year_avg IS NOT NULL
GROUP BY 
	skill, percentile
ORDER BY 
	skill, percentile;

select top 2 * from job_postings_fact where salary_hour_avg is not null;


/*

*/

WITH DataAnalystJobs AS (
    SELECT 
        jp.job_id, 
        jp.job_title_short
    FROM 
        jobPostings..job_postings_fact jp
    JOIN 
        jobPostings..skills_job_dim sjd ON jp.job_id = sjd.job_id
    WHERE 
        jp.job_title_short LIKE '%Data Analyst%'  
),

-- CTE to count the number of times each skill appears in Data Analyst jobs
SkillCounts AS (
    SELECT 
        sjd.skill_id, 
        COUNT(sjd.skill_id) AS skill_count 
    FROM 
        DataAnalystJobs daj
    JOIN 
        jobPostings..skills_job_dim sjd ON daj.job_id = sjd.job_id
    GROUP BY 
        sjd.skill_id 
),

-- CTE to calculate the total number of Data Analyst jobs
TotalJobs AS (
    SELECT 
        COUNT(*) AS total_jobs  
    FROM 
        DataAnalystJobs
),

-- CTE to calculate skill percentages based on total job counts
SkillPercentages AS (
    SELECT 
        sc.skill_id, 
        sd.skills, 
        sc.skill_count, 
        CAST(ROUND(CAST(sc.skill_count AS DECIMAL(10, 2)) / tj.total_jobs * 100, 0) AS INT) AS skill_percentage 
    FROM 
        SkillCounts sc
    JOIN 
        jobPostings..skills_dim sd ON sc.skill_id = sd.skill_id
    CROSS JOIN 
        TotalJobs tj  -- Joins to get total job counts for percentage calculation
),

-- CTE to rank skills by percentage for each job title
RankedSkills AS (
    SELECT 
        daj.job_title_short, 
        sp.skills, 
        sp.skill_percentage,
        ROW_NUMBER() OVER (PARTITION BY daj.job_title_short, sp.skills ORDER BY sp.skill_percentage DESC) AS rn  -- Ranks skills within each job title
    FROM 
        DataAnalystJobs daj
    JOIN 
        jobPostings..skills_job_dim sjd ON daj.job_id = sjd.job_id
    JOIN 
        SkillPercentages sp ON sjd.skill_id = sp.skill_id
)

-- Final selection to get the top skill percentage for each job title and skill
SELECT 
    job_title_short, 
    skills, 
    skill_percentage
FROM 
    RankedSkills
WHERE 
    rn = 1  -- Selects only the top-ranked skill for each job title
ORDER BY 
    skill_percentage DESC; 




/*

*/

/*
CREATE VIEW JobSkillsCompany AS
SELECT 
    jpf.job_title_short,
    STRING_AGG(sd.skills, ', ') AS skills,
    cd.name AS company_name
FROM 
    jobPostings..job_postings_fact jpf
JOIN 
    skills_job_dim sjd ON jpf.job_id = sjd.job_id
JOIN 
    skills_dim sd ON sjd.skill_id = sd.skill_id
JOIN 
    company_dim cd ON jpf.company_id = cd.company_id
GROUP BY 
    jpf.job_title_short, cd.name;*/


SELECT TOP 5 * FROM JobSkillsCompany