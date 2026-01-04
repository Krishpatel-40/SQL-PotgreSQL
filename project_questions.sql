-- Q1) what are the top-paying-jobs for my role (Data Analyst)
select
  job_id,
  job_title,
  job_location,
  job_schedule_type,
  salary_year_avg,
  job_posted_date,
  company_dim.name
FROM
  job_postings_fact
left join company_dim on company_dim.company_id = job_postings_fact.company_id   
WHERE
   job_title_short='Data Analyst' and job_work_from_home=true and salary_year_avg is NOT NULL
ORDER BY salary_year_avg DESC
LIMIT 10 

-- Q2) what are the skill required for these top-paying-jobs
select
  job_postings_fact.job_id,
  job_title,
  salary_year_avg,
  company_dim.name,
  skills_dim.skills
FROM
  job_postings_fact
left join company_dim on company_dim.company_id = job_postings_fact.company_id 
inner join skills_job_dim on skills_job_dim.job_id = job_postings_fact.job_id
inner join skills_dim on skills_dim.skill_id = skills_job_dim.skill_id  
WHERE
   job_title_short='Data Analyst' and job_work_from_home=true and salary_year_avg is NOT NULL
ORDER BY salary_year_avg DESC
LIMIT 10 

-- Q3) what are the most in-demand skill for my job role (Data Analyst)
select
  count(job_postings_fact.job_id),
  skills_dim.skills
FROM
  job_postings_fact
left join company_dim on company_dim.company_id = job_postings_fact.company_id 
inner join skills_job_dim on skills_job_dim.job_id = job_postings_fact.job_id
inner join skills_dim on skills_dim.skill_id = skills_job_dim.skill_id  
WHERE
   job_title_short='Data Analyst' and job_work_from_home=true and salary_year_avg is NOT NULL
GROUP BY skills_dim.skills
ORDER BY count(job_postings_fact.job_id) DESC
LIMIT 5

-- Q4) what are the top skils based on salary for my role (Data Analyst) ?
select
  skills_dim.skills,
 Round(Avg(job_postings_fact.salary_year_avg),0) as avg_salary
FROM
  job_postings_fact
inner join skills_job_dim on skills_job_dim.job_id = job_postings_fact.job_id
inner join skills_dim on skills_dim.skill_id = skills_job_dim.skill_id  
WHERE
   job_title_short='Data Analyst'
   and job_work_from_home=true
   and salary_year_avg is NOT NULL
GROUP BY skills_dim.skills
ORDER BY avg_salary DESC
LIMIT 5 

-- Q5) whar are the most optimal skills to learn
--  (optimal : high demand and high paying )

with as high_salary(
  select
  skills_job_dim.skill_id,
  skills_dim.skills,
 Round(Avg(job_postings_fact.salary_year_avg),0) as avg_salary
FROM
  job_postings_fact
inner join skills_job_dim on skills_job_dim.job_id = job_postings_fact.job_id
inner join skills_dim on skills_dim.skill_id = skills_job_dim.skill_id  
WHERE
   job_title_short='Data Analyst'
   and job_work_from_home=true
   and salary_year_avg is NOT NULL
),
 high_demand(
  select
  skills_dim.skill_id,
  count(job_postings_fact.job_id) as demand_count,
  skills_dim.skills
FROM
  job_postings_fact
left join company_dim on company_dim.company_id = job_postings_fact.company_id 
inner join skills_job_dim on skills_job_dim.job_id = job_postings_fact.job_id
inner join skills_dim on skills_dim.skill_id = skills_job_dim.skill_id  
WHERE
   job_title_short='Data Analyst' and job_work_from_home=true and salary_year_avg is NOT NULL
)

select 
    high_salary.skill_id,
    high_salary.skills,
    demand_count,
    avg_salary
from 
high_salary
inner join high_demand on high_salary.skill_id = high_demand.skill_id


