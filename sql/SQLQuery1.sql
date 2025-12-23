select * from Employees


SELECT * FROM Projects ORDER BY project_id DESC


SELECT t.task_id, t.task_title, p.project_name, e.FirstName + ' ' + e.LastName as AssignedTo
FROM Tasks t
LEFT JOIN Projects p ON t.project_id = p.project_id
LEFT JOIN Employees e ON t.employee_id = e.EmployeeID


SELECT * FROM Tasks WHERE project_id = 16


-- Prosedür içeriðini görmek için
EXEC sp_helptext 'sp_AddTask'


SELECT * FROM Tasks WHERE task_title = 'elifseda'


SELECT TOP 5 * FROM Tasks ORDER BY task_id DESC;


SELECT * FROM Tasks ORDER BY task_id DESC;