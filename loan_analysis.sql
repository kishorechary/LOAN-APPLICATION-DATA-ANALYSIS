create database  loan_analysis;
use loan_analysis;
create table customers( customer_id varchar(20), age int, gender varchar(10), city varchar(50), 
income bigint, employment_type varchar(50), credit_score int);
create table loan_applications( application_id varchar(20), customer_id varchar(20),
 loan_amount bigint,loan_type varchar(50), interest_rate decimal(5,2), tenure_months int,
 application_date date);
create table loan_status( appliaction_id varchar(20), stage varchar(50), status varchar(20), 
processing_days int, rejection_reason varchar(100));
create table marketing_channel (customer_id varchar(20), source_channel varchar(50),campaign_cost decimal(10,2));
select count(*) from customers;
select count(*) from loan_applications;
select count(*) from loan_status;
select count(*) from marketing_channel;
select * from customers limit 500000;
select * from loan_applications limit 500000;
select * from loan_status limit 500000;
select * from marketing_channel limit 500000;

select customer_id,count(*) from customers group by customer_id having count(*)>1;
select application_id ,count(*) from loan_applications group by application_id having count(*)>1;


select * from customers where customer_id is null;
select * from loan_applications where application_id is null;
select * from loan_status where status is null;

alter table loan_status rename column appliaction_id to application_id ;
select count(*) from customers c join loan_applications i on c.customer_id=i.customer_id;
select count(*) from loan_applications i join loan_status s on i.application_id = s.application_id;

#business analysis
select count(*) as total_application from loan_applications;
select sum(loan_amount) as total_loan_value from loan_applications;
select avg(loan_amount) as avg_loan_amount from loan_applications;

#approval rate 
select (count(case when status='Approved' then 1 end )/count(*) *100) as approval_rate  from loan_status;

#rejection rate 
select (count(case when status='Rejected' then 1 end)/count(*)*100) as rejection_rate from loan_status;

#rejection reason
select rejection_reason, count(*) as reason_count from loan_status where status='rejected' group by rejection_reason order by reason_count desc;
SELECT status,COUNT(*) AS total_count FROM loan_status GROUP BY status;

#marketing performance
select source_channel, count(*) as total_count from marketing_channel group by source_channel order by total_count desc;

#loan_type
select loan_type ,count(*) as total_count from loan_applications group by loan_type order by total_count desc; 

#customer_analysis
select age ,count(*) from customers group by age;

#age_grouping
select case when age between 18 and 25 then '18-25'
 when age between 26 and 35 then '26-35'
 when age between 36 and 45 then '36-45'
 else '45<'
 end as age_group,count(*) from customers group by age_group; 


#gender
select gender , count(*) as count from customers group by gender;

#approval by loan_type
select la.loan_type,ls.status,count(*) as total from loan_applications la join loan_status ls on la.application_id =ls.application_id  group by la.loan_type, ls.status;

#appr0vals by marketing_channel 
SELECT mc.source_channel, ls.status, COUNT(DISTINCT la.application_id) AS total_applications FROM marketing_channel mc
JOIN customers c ON mc.customer_id = c.customer_id JOIN loan_applications la ON c.customer_id = la.customer_id
JOIN loan_status ls ON la.application_id = ls.application_id
GROUP BY mc.source_channel, ls.status ORDER BY mc.source_channel, ls.status;

#Approval Rate by Segment
SELECT loan_type,COUNT(CASE WHEN ls.status='Approved' THEN 1 END)*100.0/COUNT(*) AS approval_rate
FROM loan_applications la JOIN loan_status ls ON la.application_id = ls.application_id GROUP BY loan_type;

#Customer Risk Analysis
SELECT c.credit_score,COUNT(*) AS total_applications,COUNT(CASE WHEN ls.status='Approved' THEN 1 END) AS approved
FROM customers c JOIN loan_applications la ON c.customer_id = la.customer_id JOIN loan_status ls ON la.application_id = ls.application_id
GROUP BY c.credit_score ORDER BY c.credit_score;

#Income vs Loan Amount
SELECT c.income,AVG(la.loan_amount) AS avg_loan FROM customers c
JOIN loan_applications la ON c.customer_id = la.customer_id GROUP BY c.income ORDER BY c.income;

#Marketing ROI
SELECT  mc.source_channel,SUM(mc.campaign_cost) AS total_cost,COUNT(CASE WHEN ls.status='Approved' THEN 1 END) AS approved_loans
FROM marketing_channel mc JOIN customers c ON mc.customer_id = c.customer_id JOIN loan_applications la ON c.customer_id = la.customer_id
JOIN loan_status ls ON la.application_id = ls.application_id GROUP BY mc.source_channel order by approved_loans desc;

#Marketing ROI %
SELECT mc.source_channel, COUNT(DISTINCT la.application_id) AS total_apps,COUNT(CASE WHEN ls.status = 'Approved' THEN 1 END) AS approved_apps,
COUNT(CASE WHEN ls.status = 'Approved' THEN 1 END) * 100.0 / COUNT(DISTINCT la.application_id) AS approval_rate
FROM marketing_channel mc JOIN customers c ON mc.customer_id = c.customer_id
JOIN loan_applications la ON c.customer_id = la.customer_id
JOIN loan_status ls ON la.application_id = ls.application_id
GROUP BY mc.source_channel ORDER BY approval_rate DESC;

#Processing Time Analysis
SELECT status,AVG(processing_days) AS avg_processing_time FROM loan_status GROUP BY status;

#Funnel Analysis
SELECT stage,COUNT(*) AS users FROM loan_status GROUP BY stage ORDER BY users DESC;

#Top 10 Customers
SELECT c.customer_id, SUM(la.loan_amount) AS total_loan FROM customers c
JOIN loan_applications la ON c.customer_id = la.customer_id GROUP BY c.customer_id
ORDER BY total_loan DESC LIMIT 10;

#Loan Distribution
SELECT loan_type,ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(),2) AS percentage
FROM loan_applications GROUP BY loan_type order by percentage desc;
