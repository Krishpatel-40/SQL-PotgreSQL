DROP TABLE job_applied 

INSERT INTO job_applied(
  job_id,
  application_sent_date,
  custom_resume,
  resume_file_name,
  cv_sent,
  cv_file_name,
  status
) VALUES (
 ( 1,
  '2023-05-01',
  true,
  'resume.pdf',
  true,
  'cv.docx',
  'applied'),
  (
    2,
    '2023-05-02',
    false,
    null,
    false,
    null,
    'applied'
  ),
  (
    3,
    '2023-05-03',
    true,
    'resume.docx',
    true,
    'cv.pdf',
    'applied'
  ),
  (
    4,
    '2023-05-04',
    false,
    null,
    false,
    null,
    'applied'
  ),
  (
    5,
    '2023-05-05',
    true,
    'resume.docx',
    true,
    'cv.pdf',
    'applied'
  )
)

select job_title_short,
       job_title,
	   salary_hour_avg*8 as daily_salary,
	   salary_hour_avg*8*365 as annual_package,
	   salary_hour_avg,
       job_location        
 from job_postings_fact 
 where salary_hour_avg > 0
 order by annual_package desc
 Limit 5

 select job_title_short,
       job_title,
	   salary_hour_avg*8 as daily_salary,
	   salary_hour_avg*8*365 as annual_package,
	   salary_hour_avg,
       job_location,
	   company.name,
	   company.link
 from job_postings_fact as jobs
 left join company_dim as company on company.company_id = jobs.company_id 
 where salary_hour_avg > 0 and company.link is not null
 order by annual_package desc
 Limit 50

select job_title_short,
  avg(salary_year_avg) as Annual_Average
from public.job_postings_fact
group by job_title_short
order by Annual_Average desc
Limit 50

select 
	AVG(salary_year_avg) as yearly_avg,
	AVG(salary_hour_avg) as hourly_avg,
	job_schedule_type
from job_postings_fact
where EXTRACT (DAY from job_posted_date) >0
	  AND EXTRACT (month from job_posted_date)>5
	  AND EXTRACT (year from job_posted_date) >2022 
group by job_schedule_type

select 
	count(job_id),
	Extract (month from job_posted_date at time zone 'utc' at time zone 'America/New_York')  as months_count 
FROM public.job_postings_fact
where (extract(year from job_posted_date) = 2023) 
group by months_count
order by months_count

SELECT
	count (job_id),
	case 
		when (salary_year_avg > 0 AND salary_year_avg<320000) then 'Low'
		when (salary_year_avg > 320000 AND salary_year_avg<640000) then 'medium'
		when (salary_year_avg > 640000 AND salary_year_avg<960000) then 'high'
	else 'no bucket'
end as bucket_type	
FROM public.job_postings_fact
where salary_year_avg is not null and job_title_short = 'Data Analyst'
group by bucket_type

with sub_query as (
	select count(job_id),company_id
	from job_postings_fact
	group by company_id
)

select name as company_name
from company_dim
Left join sub_query on sub_query.company_id = company_dim.company_id

with idtomaligai as (SELECT count(job_id) as job_per_skill,skill_id
FROM public.skills_job_dim
group by skill_id
ORDER by job_per_skill DESC
limit 5)

select skills_dim.skills , skills_dim.skill_id , idtomaligai.job_per_skill
from idtomaligai 
left join skills_dim on idtomaligai.skill_id = skills_dim.skill_id

with idtomaligai as (SELECT count(*) as job_per_skill,skill_id
FROM public.skills_job_dim
inner join job_postings_fact on job_postings_fact.job_id = skills_job_dim.job_id
where job_postings_fact.job_work_from_home = true
group by skill_id
)

select skills_dim.skills , skills_dim.skill_id , idtomaligai.job_per_skill
from idtomaligai 
inner join skills_dim on idtomaligai.skill_id = skills_dim.skill_id
ORDER by idtomaligai.job_per_skill DESC
limit 5 