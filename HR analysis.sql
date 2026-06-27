USE enterprise_analytics;

Select * from Employees;
select * from Departments;
Select * from Addresses;
Select * from projects;
select * from project_tasks;
select * from salaries;
select * from emails;

											#1)How many employees work in each department?
select d.department_id,d.department_name,count(e.employee_id) as Employee
from departments d
inner join employees e
on d.department_id = e.department_id
group by d.department_id,d.department_name;

																#2)Which department has the highest payroll cost?
select d.department_id,d.department_name,count(e.employee_id) as Employee,sum(s.salary)as payroll_cost
from departments d
inner join employees e
on d.department_id = e.department_id
inner join salaries s
on e.employee_id = s.employee_id
group by d.department_id,d.department_name
order by payroll_cost desc;

														#3)Which department has the highest average salary?
                                                        
select d.department_id,d.department_name,count(e.employee_id) as Employee,
		sum(s.salary)as payroll_cost,
        round(avg(s.salary),2) as Avg_salary
from departments d
inner join employees e
on d.department_id = e.department_id
inner join salaries s
on e.employee_id = s.employee_id
group by d.department_id,d.department_name
order by Avg_salary desc;

														#4)Which employees earn above their department's average salary?

with Department_avg_salary as (
select e.employee_id,concat(e.first_name," ",e.last_name) as employee_name,d.department_name,s.salary,
	round(avg(s.salary) over(partition by d.department_id),2) as dept_avg_salary
    from departments d
inner join employees e
on d.department_id = e.department_id
inner join salaries s
on e.employee_id = s.employee_id)

select * from Department_avg_salary
where salary>=dept_avg_salary;

																	#5)Which employees earn above their department's average salary?

with Department_avg_salary as (
select e.employee_id,concat(e.first_name," ",e.last_name) as employee_name,d.department_name,s.salary,
	dense_rank() over(partition by d.department_id
				order by s.salary Desc) as SalaryRank
    from departments d
inner join employees e
on d.department_id = e.department_id
inner join salaries s
on e.employee_id = s.employee_id)

select * from Department_avg_salary
where salaryRank<=3;

																

Select * from Employees;
select * from Departments;
Select * from Addresses;
Select * from projects;
select * from project_tasks;
select * from salaries;
select * from emails;

																	#6)Which employees are assigned to multiple projects?
select e.employee_id,concat(e.first_name," ",e.last_name) as employee_name,
		count(distinct p.Project_id) as Assigned_Project
        from Employees e
        Left Join project_tasks P
        on e.employee_id = p.employee_id
        group by e.employee_id,employee_name
        order by assigned_project Desc;
        
																	#7)Which projects have the highest number of pending tasks?

Select p.project_id,p.project_name,
Count(case when pt.status = 'pending' then 1 end) as Pending_Task
        from projects p
        left Join project_tasks pt
        on p.project_id = pt.project_id
        group by p.project_id,p.project_name
        order by Pending_task Desc;
        
																#8)Which employees have the highest number of pending tasks?

select e.employee_id,concat(e.first_name," ",e.last_name) as Employee_name,
		count(case when pt.status = "pending" then 1 end) as pending_tasks
        from employees e 
        left join project_tasks pt
        on e.employee_id = pt.employee_id
        group by e.employee_id,Employee_name
        order by pending_tasks Desc;

																	#9)What is the average project duration by department?
                                                                    
select d.department_id,d.department_name, 
			avg(case 
				when p.status = "completed" then datediff(p.end_date,p.start_date)
                when p.status = "Pending" then datediff(curdate(),p.start_date) 
                end)as avg_tat
from employees e
inner join departments d
on e.department_id = d.department_id
inner join project_tasks p
on e.employee_id = p.employee_id
group by d.department_id,d.department_name
order by avg_tat Desc;



CREATE VIEW v_employee_department_salary AS
SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS Employee_Name,
    d.department_id,
    d.department_name,
    s.salary
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id
INNER JOIN salaries s ON e.employee_id = s.employee_id;

SELECT * FROM v_employee_department_salary;

CREATE VIEW v_project_task_summary AS
SELECT 
    p.project_id,
    p.project_name,
    pt.status AS Project_Status,
    p.start_date,
    p.end_date,
    pt.employee_id,
    pt.status AS Task_Status
FROM projects p
LEFT JOIN project_tasks pt ON p.project_id = pt.project_id;

CREATE VIEW v_employee_project_summary AS
SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS Employee_Name,
    d.department_name,
    p.project_id,
    p.project_name,
    pt.status AS Task_Status,
    p.start_date,
    p.end_date
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id
LEFT JOIN project_tasks pt ON e.employee_id = pt.employee_id
LEFT JOIN projects p ON pt.project_id = p.project_id;

##--- view list

SELECT * FROM v_employee_department_salary;
SELECT * FROM v_project_task_summary;
SELECT * FROM v_employee_project_summary;