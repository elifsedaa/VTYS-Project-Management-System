--- bu dosyada projeyi oluþtururken kullandýðýmýz tüm sorgular sýralý þekilde yer almaktadýr. 

CREATE DATABASE ProjectManagementDB2;
GO


USE ProjectManagementDB2;
GO

CREATE TABLE Departments (
    department_id INT IDENTITY(1,1) PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL
);



CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    DepartmentID INT NOT NULL,
    HireDate DATE NOT NULL,
    
    FOREIGN KEY (DepartmentID) REFERENCES Departments(department_id)
);


CREATE TABLE Projects (
    project_id INT IDENTITY(1,1) PRIMARY KEY,
    project_name NVARCHAR(100) NOT NULL,
    description NVARCHAR(255),
    start_date DATE NOT NULL,
    end_date DATE,
    status NVARCHAR(50) DEFAULT 'Aktif'
);



CREATE TABLE ProjectMembers (
    member_id INT IDENTITY(1,1) PRIMARY KEY,
    project_id INT NOT NULL,
    employee_id INT NOT NULL,
    role NVARCHAR(50) NOT NULL,   -- Projedeki rolü (Yönetici, Katýlýmcý, Gözlemci)
    
    FOREIGN KEY (project_id) REFERENCES Projects(project_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(EmployeeID)
);


CREATE TABLE Tasks (
    task_id INT IDENTITY(1,1) PRIMARY KEY,
    project_id INT NOT NULL,
    employee_id INT NOT NULL,         -- Görev hangi çalýþana atanmýþ
    task_title NVARCHAR(150) NOT NULL,
    task_description NVARCHAR(255),
    priority NVARCHAR(20) CHECK (priority IN ('Düþük', 'Orta', 'Yüksek')),
    status NVARCHAR(30) DEFAULT 'Atandý',
    start_date DATE NOT NULL,
    due_date DATE,
    
    FOREIGN KEY (project_id) REFERENCES Projects(project_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(EmployeeID)
);


CREATE TABLE TaskStatusHistory (
    history_id INT IDENTITY(1,1) PRIMARY KEY,
    task_id INT NOT NULL,
    old_status NVARCHAR(30),
    new_status NVARCHAR(30),
    changed_at DATETIME DEFAULT GETDATE(),
    changed_by INT NOT NULL,  -- Durumu kim deðiþtirdi (Employee ID)

    FOREIGN KEY (task_id) REFERENCES Tasks(task_id),
    FOREIGN KEY (changed_by) REFERENCES Employees(EmployeeID)
);


CREATE TABLE Notifications (
    notification_id INT IDENTITY(1,1) PRIMARY KEY,
    task_id INT NOT NULL,
    user_id INT NOT NULL,  -- Bildirimi alacak çalýþan (Employee)
    message NVARCHAR(255) NOT NULL,
    notification_type NVARCHAR(50) NOT NULL,  -- Deadline Yaklaþýyor, Gecikme, Görev Tamamlandý
    is_read BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),

    FOREIGN KEY (task_id) REFERENCES Tasks(task_id),
    FOREIGN KEY (user_id) REFERENCES Employees(EmployeeID)
);



INSERT INTO Departments (department_name)
VALUES
('Bilgi Teknolojileri'),
('Ýnsan Kaynaklarý'),
('Muhasebe'),
('Pazarlama'),
('Satýþ'),
('Ar-Ge'),
('Operasyon'),
('Yazýlým Geliþtirme'),
('Veri Analitiði'),
('Proje Yönetimi'),
('Donaným Destek'),
('Kalite Güvence');



INSERT INTO Employees (FirstName, LastName, Email, DepartmentID, HireDate)
VALUES
('Elif Seda', 'Demirhan', 'elif.demirhan@example.com', 1, '2022-03-01'),
('Selin', 'Tütüncü', 'selin.tutuncu@example.com', 2, '2023-01-15'),
('Sude Naz', 'Görmez', 'sudenaz.gormez@example.com', 3, '2024-05-22'),
('Merve', 'Pýnar', 'merve.pinar@example.com', 4, '2023-11-11'),
('John', 'Miller', 'john.miller@example.com', 5, '2021-09-10'),
('Emma', 'Wilson', 'emma.wilson@example.com', 1, '2020-02-12'),
('Oliver', 'Brown', 'oliver.brown@example.com', 2, '2022-07-19'),
('Sophia', 'Taylor', 'sophia.taylor@example.com', 6, '2023-02-01'),
('James', 'Anderson', 'james.anderson@example.com', 7, '2024-01-05'),
('Mia', 'Thompson', 'mia.thompson@example.com', 8, '2022-10-20'),
('Liam', 'Clark', 'liam.clark@example.com', 9, '2021-11-13'),
('Ava', 'White', 'ava.white@example.com', 10, '2024-03-18'),
('Noah', 'Hall', 'noah.hall@example.com', 3, '2023-07-07'),
('Isabella', 'Harris', 'isabella.harris@example.com', 4, '2020-08-08'),
('Lucas', 'Lewis', 'lucas.lewis@example.com', 11, '2022-06-15'),
('Amelia', 'Young', 'amelia.young@example.com', 12, '2023-09-09'),
('Daniel', 'King', 'daniel.king@example.com', 5, '2024-02-27'),
('Charlotte', 'Scott', 'charlotte.scott@example.com', 2, '2022-12-12'),
('Benjamin', 'Green', 'benjamin.green@example.com', 1, '2023-03-25'),
('Harper', 'Adams', 'harper.adams@example.com', 6, '2021-04-04'),
('Henry', 'Baker', 'henry.baker@example.com', 9, '2022-01-01'),
('Evelyn', 'Nelson', 'evelyn.nelson@example.com', 7, '2024-05-05'),
('Alexander', 'Carter', 'alex.carter@example.com', 8, '2023-10-14'),
('Grace', 'Mitchell', 'grace.mitchell@example.com', 10, '2021-12-30'),
('Samuel', 'Perez', 'samuel.perez@example.com', 11, '2024-04-21');



INSERT INTO Projects (project_name, description, start_date, end_date, status)
VALUES
('Kurumsal Web Sitesi Yenileme', 'Þirketin mevcut web sitesinin modern tasarýmla yenilenmesi', '2024-01-10', '2024-06-15', 'Aktif'),
('Mobil Uygulama Geliþtirme', 'Þirket için çok platformlu mobil uygulama geliþtirilmesi', '2024-03-01', NULL, 'Devam Ediyor'),
('CRM Sistem Entegrasyonu', 'CRM yazýlýmýnýn þirket süreçlerine entegrasyonu', '2023-09-15', '2024-02-28', 'Tamamlandý'),
('Pazarlama Otomasyon Sistemi', 'E-posta ve kampanya otomasyon yapýsýnýn kurulmasý', '2024-02-05', NULL, 'Aktif'),
('E-Ticaret Altyapý Geliþtirme', 'Yeni ürün satýþ platformunun backend + frontend geliþtirilmesi', '2024-05-12', NULL, 'Devam Ediyor'),
('Veri Ambarý Oluþturma', 'BI ve veri analizi süreçleri için veri ambarý kurulumu', '2023-11-20', NULL, 'Aktif'),
('Siber Güvenlik Testleri', 'Þirket sistemlerinde zafiyet taramasý ve güvenlik raporlamasý', '2024-04-04', NULL, 'Planlandý'),
('Personel Yönetim Sistemi', 'ÝK departmaný için personel yönetimi modülü geliþtirme', '2024-01-25', '2024-09-05', 'Tamamlandý'),
('Donaným Envanter Sistemi', 'Þirket donanýmlarýnýn takip edildiði sistem geliþtirme', '2024-06-01', NULL, 'Aktif'),
('Satýþ Performans Dashboard', 'Satýþ verilerinin analiz edildiði dashboard geliþtirilmesi', '2024-03-18', NULL, 'Devam Ediyor');



INSERT INTO ProjectMembers (project_id, employee_id, role)
VALUES
-- Proje 1
(1, 1, 'Yönetici'),
(1, 5, 'Geliþtirici'),
(1, 10, 'Tasarýmcý'),
(1, 18, 'Analist'),

-- Proje 2
(2, 2, 'Geliþtirici'),
(2, 6, 'Geliþtirici'),
(2, 12, 'Test Uzmaný'),
(2, 20, 'Analist'),
(2, 24, 'Proje Asistaný'),

-- Proje 3
(3, 3, 'Analist'),
(3, 7, 'Geliþtirici'),
(3, 14, 'Test Uzmaný'),
(3, 19, 'Destek Uzmaný'),

-- Proje 4
(4, 4, 'Pazarlama Uzmaný'),
(4, 8, 'Analist'),
(4, 11, 'Geliþtirici'),
(4, 17, 'Proje Yöneticisi'),
(4, 23, 'Veri Uzmaný'),

-- Proje 5
(5, 9, 'Geliþtirici'),
(5, 13, 'Analist'),
(5, 16, 'UI/UX'),
(5, 21, 'Test Uzmaný'),

-- Proje 6
(6, 1, 'Veri Uzmaný'),
(6, 6, 'Veri Mühendisi'),
(6, 15, 'Analist'),
(6, 22, 'Raporlama Uzmaný'),

-- Proje 7
(7, 7, 'Siber Güvenlik Uzmaný'),
(7, 11, 'Analist'),
(7, 20, 'Pentester'),

-- Proje 8
(8, 2, 'Geliþtirici'),
(8, 4, 'Analist'),
(8, 12, 'Destek Uzmaný'),

-- Proje 9
(9, 5, 'Destek Uzmaný'),
(9, 14, 'Teknik Uzman'),
(9, 18, 'Donaným Uzmaný'),
(9, 25, 'Destek Mühendisi'),

-- Proje 10
(10, 3, 'Analist'),
(10, 8, 'Veri Analisti'),
(10, 10, 'Dashboard Tasarýmcýsý'),
(10, 19, 'Geliþtirici');





ALTER TABLE Tasks
ADD assigned_role NVARCHAR(50);

ALTER TABLE Tasks
ADD assigned_date DATE;


ALTER TABLE ProjectMembers
ADD assigned_role NVARCHAR(50);

ALTER TABLE ProjectMembers
ADD assigned_date DATE;

ALTER TABLE ProjectMembers
ALTER COLUMN role NVARCHAR(50) NULL;

INSERT INTO Projects (project_name, description, start_date, status)
VALUES
('Proje 11', 'Açýklama', GETDATE(), 'Aktif'),
('Proje 12', 'Açýklama', GETDATE(), 'Aktif'),
('Proje 13', 'Açýklama', GETDATE(), 'Aktif'),
('Proje 14', 'Açýklama', GETDATE(), 'Aktif'),
('Proje 15', 'Açýklama', GETDATE(), 'Aktif');


INSERT INTO ProjectMembers (project_id, employee_id, assigned_role, assigned_date)
VALUES
(1, 1, 'Proje Yöneticisi', '2024-01-10'),
(1, 5, 'Geliþtirici', '2024-01-12'),
(1, 10, 'Analist', '2024-01-13'),
(2, 2, 'ÝK Sorumlusu', '2024-02-01'),
(2, 8, 'Destek Uzmaný', '2024-02-02'),
(3, 3, 'Muhasebe Uzmaný', '2024-03-05'),
(3, 14, 'Raporlama Analisti', '2024-03-07'),
(4, 4, 'Pazarlama Uzmaný', '2024-04-12'),
(4, 11, 'Veri Analisti', '2024-04-13'),
(5, 6, 'Kýdemli Geliþtirici', '2024-05-20'),
(5, 7, 'Stajyer Geliþtirici', '2024-05-21'),
(5, 9, 'DevOps Uzmaný', '2024-05-22'),
(6, 12, 'Proje Koordinatörü', '2024-06-10'),
(6, 18, 'Takým Lideri', '2024-06-12'),
(7, 13, 'Finans Analisti', '2024-07-01'),
(7, 17, 'Satýþ Temsilcisi', '2024-07-02'),
(8, 15, 'Donaným Uzmaný', '2024-08-15'),
(8, 16, 'Kalite Mühendisi', '2024-08-16'),
(9, 19, 'Veri Bilimci', '2024-09-01'),
(9, 20, 'Veri Analisti', '2024-09-02'),
(10, 21, 'Operasyon Uzmaný', '2024-10-05'),
(10, 22, 'Saha Sorumlusu', '2024-10-06'),
(11, 23, 'Backend Developer', '2024-11-01'),
(11, 24, 'Frontend Developer', '2024-11-02'),
(12, 25, 'Sistem Yöneticisi', '2024-12-10'),
(12, 1, 'Danýþman', '2024-12-11'),
(13, 7, 'AI Mühendisi', '2024-12-15'),
(13, 3, 'Veri Modelleyici', '2024-12-16'),
(14, 10, 'Araþtýrmacý', '2024-12-20'),
(14, 18, 'Test Uzmaný', '2024-12-21'),
(15, 5, 'Kýdemli Yazýlýmcý', '2024-12-25'),
(15, 14, 'Dokümantasyon Uzmaný', '2024-12-26');





INSERT INTO Tasks 
(project_id, employee_id, task_title, task_description, priority, status, start_date, due_date, assigned_role, assigned_date)
VALUES
-- 1
(1, 5, 'Frontend Arayüz Tasarýmý', 'Yeni web sitesi için ana sayfa tasarýmý', 'Yüksek', 'Atandý', '2024-01-15', '2024-01-25', 'Geliþtirici', '2024-01-15'),

-- 2
(1, 10, 'Logo Güncelleme', 'Kurumsal logo modernize edilecek', 'Orta', 'Atandý', '2024-01-16', '2024-01-22', 'Tasarýmcý', '2024-01-16'),

-- 3
(2, 2, 'Mobil API Baðlantýsý', 'Mobil uygulama için API endpoint entegrasyonu', 'Yüksek', 'Atandý', '2024-03-10', '2024-03-30', 'Geliþtirici', '2024-03-10'),

-- 4
(2, 6, 'Push Notification Modülü', 'Uygulama içi bildirim sisteminin geliþtirilmesi', 'Orta', 'Devam Ediyor', '2024-03-12', '2024-03-28', 'Geliþtirici', '2024-03-12'),

-- 5
(3, 14, 'Test Senaryosu Oluþturma', 'CRM entegrasyonu için test planý hazýrlanmasý', 'Düþük', 'Tamamlandý', '2023-12-10', '2024-01-05', 'Test Uzmaný', '2023-12-10'),

-- 6
(4, 4, 'E-posta Þablon Tasarýmý', 'Kampanya mail þablonlarýnýn hazýrlanmasý', 'Orta', 'Atandý', '2024-02-10', '2024-02-20', 'Pazarlama Uzmaný', '2024-02-10'),

-- 7
(4, 11, 'Otomasyon Modül Kodlama', 'Pazarlama otomasyon modülünün backend geliþtirmesi', 'Yüksek', 'Devam Ediyor', '2024-02-12', '2024-03-15', 'Geliþtirici', '2024-02-12'),

-- 8
(5, 9, 'Ürün Katalog Yapýsý', 'E-ticaret ürün sayfasý veri modellemesi', 'Yüksek', 'Atandý', '2024-05-20', '2024-06-01', 'Geliþtirici', '2024-05-20'),

-- 9
(5, 16, 'UX Revizyonu', 'Kullanýcý deneyimi iyileþtirme önerilerinin uygulanmasý', 'Orta', 'Atandý', '2024-05-22', '2024-06-05', 'UI/UX', '2024-05-22'),

-- 10
(6, 1, 'Veri Ambarý Þema Tasarýmý', 'BI süreçleri için temel þema planlanmasý', 'Yüksek', 'Devam Ediyor', '2023-11-25', '2024-01-15', 'Veri Uzmaný', '2023-11-25'),

-- 11
(6, 15, 'ETL Pipeline Hazýrlýðý', 'Veri ambarý için ETL süreçlerinin planlanmasý', 'Yüksek', 'Atandý', '2023-12-02', '2024-01-10', 'Analist', '2023-12-02'),

-- 12
(7, 7, 'Zafiyet Taramasý', 'Sistem güvenlik taramalarýnýn yapýlmasý', 'Yüksek', 'Atandý', '2024-04-05', '2024-04-18', 'Siber Güvenlik Uzmaný', '2024-04-05'),

-- 13
(7, 20, 'Penetrasyon Testi', 'Sisteme yönelik saldýrý simülasyonu', 'Yüksek', 'Atandý', '2024-04-08', '2024-04-22', 'Pentester', '2024-04-08'),

-- 14
(8, 12, 'Kullanýcý Rolleri Modülü', 'Personel yönetim sistemine rol yetkilendirme', 'Orta', 'Atandý', '2024-01-28', '2024-02-10', 'Destek Uzmaný', '2024-01-28'),

-- 15
(9, 18, 'Donaným Envanter Formu', 'Cihaz kayýt formunun geliþtirilmesi', 'Orta', 'Devam Ediyor', '2024-06-05', '2024-06-20', 'Donaným Uzmaný', '2024-06-05'),

-- 16
(9, 25, 'Envanter API Entegrasyonu', 'Donaným envanter API baðlanacak', 'Yüksek', 'Atandý', '2024-06-07', '2024-06-18', 'Destek Mühendisi', '2024-06-07'),

-- 17
(10, 3, 'Satýþ Dashboard KPI', 'KPI tanýmlarý çýkarýlacak', 'Orta', 'Atandý', '2024-03-19', '2024-04-05', 'Analist', '2024-03-19'),

-- 18
(10, 8, 'Veri Temizleme', 'Dashboard için veri seti düzenlenecek', 'Düþük', 'Devam Ediyor', '2024-03-20', '2024-04-10', 'Veri Analisti', '2024-03-20'),

-- 19
(10, 19, 'Grafik Modülü Geliþtirme', 'Dashboard grafik motoru kodlanacak', 'Yüksek', 'Atandý', '2024-03-22', '2024-04-15', 'Geliþtirici', '2024-03-22'),

-- 20
(2, 24, 'Test Otomasyonu', 'Mobil uygulama için otomasyon senaryolarý yazýlacak', 'Orta', 'Atandý', '2024-03-14', '2024-03-28', 'Proje Asistaný', '2024-03-14');





CREATE TRIGGER trg_TaskStatusHistory
ON Tasks
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO TaskStatusHistory (task_id, old_status, new_status, changed_by, changed_at)
    SELECT  
        i.task_id,
        d.status AS old_status,
        i.status AS new_status,
        i.employee_id AS changed_by,   -- görevi kim güncelledi varsayýmý
        GETDATE()
    FROM inserted i
    INNER JOIN deleted d ON i.task_id = d.task_id
    WHERE i.status <> d.status; -- sadece deðiþiklik varsa kayýt oluþsun
END;
GO




UPDATE Tasks
SET status = 'Devam Ediyor'
WHERE task_id = 1;



SELECT * FROM TaskStatusHistory;



CREATE TRIGGER trg_DeadlineApproaching
ON Tasks
AFTER INSERT, UPDATE
AS
BEGIN
    INSERT INTO Notifications (task_id, user_id, message, notification_type)
    SELECT 
        i.task_id,
        i.employee_id,
        CONCAT('Görev için deadline yaklaþýyor: ', i.task_title),
        'Deadline Yaklaþýyor'
    FROM inserted i
    WHERE i.due_date IS NOT NULL
      AND DATEDIFF(DAY, GETDATE(), i.due_date) = 3;
END;
GO



CREATE TRIGGER trg_TaskOverdue
ON Tasks
AFTER INSERT, UPDATE
AS
BEGIN
    INSERT INTO Notifications (task_id, user_id, message, notification_type)
    SELECT 
        i.task_id,
        i.employee_id,
        CONCAT('Görev gecikti: ', i.task_title),
        'Gecikme'
    FROM inserted i
    WHERE i.due_date < GETDATE()
      AND i.status <> 'Tamamlandý';
END;
GO



CREATE TRIGGER trg_TaskCompleted
ON Tasks
AFTER UPDATE
AS
BEGIN
    INSERT INTO Notifications(task_id, user_id, message, notification_type)
    SELECT 
        i.task_id,
        i.employee_id,
        CONCAT('Görev tamamlandý: ', i.task_title),
        'Görev Tamamlandý'
    FROM inserted i
    INNER JOIN deleted d ON i.task_id = d.task_id
    WHERE d.status <> 'Tamamlandý'
      AND i.status = 'Tamamlandý';
END;
GO



CREATE VIEW vw_TaskFullDetails AS
SELECT 
    t.task_id,
    t.task_title,
    t.task_description,
    t.priority,
    t.status,
    t.start_date,
    t.due_date,
    p.project_id,
    p.project_name,
    e.EmployeeID,
    CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeFullName,
    d.department_name,
    pm.assigned_role AS ProjectRole
FROM Tasks t
INNER JOIN Projects p ON t.project_id = p.project_id
INNER JOIN Employees e ON t.employee_id = e.EmployeeID
INNER JOIN Departments d ON e.DepartmentID = d.department_id
LEFT JOIN ProjectMembers pm 
    ON pm.project_id = p.project_id AND pm.employee_id = e.EmployeeID;



CREATE VIEW vw_UpcomingDeadlines AS
SELECT 
    t.task_id,
    t.task_title,
    t.due_date,
    DATEDIFF(DAY, GETDATE(), t.due_date) AS DaysLeft,
    e.FirstName + ' ' + e.LastName AS AssignedEmployee,
    p.project_name
FROM Tasks t
INNER JOIN Employees e ON t.employee_id = e.EmployeeID
INNER JOIN Projects p ON t.project_id = p.project_id
WHERE t.due_date IS NOT NULL
  AND DATEDIFF(DAY, GETDATE(), t.due_date) BETWEEN 1 AND 3
  AND t.status <> 'Tamamlandý';


CREATE VIEW vw_CompletedTasks AS
SELECT 
    t.task_id,
    t.task_title,
    t.task_description,
    t.start_date,
    t.due_date,
    t.assigned_date,
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    p.project_name
FROM Tasks t
INNER JOIN Employees e ON t.employee_id = e.EmployeeID
INNER JOIN Projects p ON t.project_id = p.project_id
WHERE t.status = 'Tamamlandý';



CREATE VIEW vw_ProjectMembersDetails AS
SELECT 
    pm.project_id,
    p.project_name,
    e.EmployeeID,
    e.FirstName + ' ' + e.LastName AS EmployeeFullName,
    d.department_name,
    pm.role AS ProjectRole,
    pm.assigned_role,
    pm.assigned_date
FROM ProjectMembers pm
INNER JOIN Employees e ON pm.employee_id = e.EmployeeID
INNER JOIN Projects p ON pm.project_id = p.project_id
INNER JOIN Departments d ON e.DepartmentID = d.department_id;


CREATE VIEW vw_DepartmentTaskCount AS
SELECT 
    d.department_name,
    COUNT(t.task_id) AS TotalTasks
FROM Departments d
LEFT JOIN Employees e ON d.department_id = e.DepartmentID
LEFT JOIN Tasks t ON e.EmployeeID = t.employee_id
GROUP BY d.department_name;


SELECT * FROM vw_TaskFullDetails

SELECT * FROM vw_UpcomingDeadlines

---vs...





CREATE VIEW V_TaskDetails AS
SELECT 
    t.task_id,
    t.task_title,
    t.task_description,
    t.priority,
    t.status,
    t.start_date,
    t.due_date,
    
    e.EmployeeID,
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    e.Email,
    
    p.project_id,
    p.project_name,
    p.status AS project_status
FROM Tasks t
INNER JOIN Employees e ON t.employee_id = e.EmployeeID
INNER JOIN Projects p ON t.project_id = p.project_id;




CREATE VIEW V_UpcomingDeadlines AS
SELECT 
    t.task_id,
    t.task_title,
    t.status,
    t.due_date,
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    p.project_name
FROM Tasks t
INNER JOIN Employees e ON t.employee_id = e.EmployeeID
INNER JOIN Projects p ON t.project_id = p.project_id
WHERE 
    t.due_date IS NOT NULL
    AND t.status NOT IN ('Tamamlandý')
    AND t.due_date <= DATEADD(DAY, 3, GETDATE())
    AND t.due_date >= GETDATE();


CREATE VIEW V_CompletedTasks AS
SELECT 
    t.task_id,
    t.task_title,
    t.due_date,
    t.start_date,
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    p.project_name
FROM Tasks t
INNER JOIN Employees e ON t.employee_id = e.EmployeeID
INNER JOIN Projects p ON t.project_id = p.project_id
WHERE t.status = 'Tamamlandý';



CREATE VIEW V_ProjectMembers AS
SELECT 
    pm.member_id,
    pm.role AS ProjectRole,
    p.project_id,
    p.project_name,
    e.EmployeeID,
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    d.department_name
FROM ProjectMembers pm
INNER JOIN Projects p ON pm.project_id = p.project_id
INNER JOIN Employees e ON pm.employee_id = e.EmployeeID
INNER JOIN Departments d ON e.DepartmentID = d.department_id;



CREATE VIEW V_DepartmentTaskCount AS
SELECT 
    d.department_name,
    COUNT(t.task_id) AS TotalTasks
FROM Tasks t
INNER JOIN Employees e ON t.employee_id = e.EmployeeID
INNER JOIN Departments d ON e.DepartmentID = d.department_id
GROUP BY d.department_name;







SELECT task_id, task_title, due_date, status,
       DATEDIFF(DAY, GETDATE(), due_date) AS KalanGun
FROM Tasks
ORDER BY due_date;



UPDATE Tasks
SET due_date = '2026-01-15'
WHERE task_id = 1;



SELECT * FROM vw_UpcomingDeadlines;


-- Bugünün tarihi
DECLARE @Today DATE = '2025-12-15';

-------------------------------
-- 1) TAMAMLANAN Görevler (geçmiþ 10 gün)
-------------------------------
UPDATE Tasks
SET due_date = DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 10, @Today)
WHERE status = 'Tamamlandý';

-------------------------------
-- 2) DEVAM EDÝYOR görevler (15–30 gün sonrasý)
-------------------------------
UPDATE Tasks
SET due_date = DATEADD(DAY, (ABS(CHECKSUM(NEWID())) % 16) + 15, @Today)
WHERE status = 'Devam Ediyor';

-------------------------------
-- 3) ATANDI görevler (5–20 gün sonrasý)
-------------------------------
UPDATE Tasks
SET due_date = DATEADD(DAY, (ABS(CHECKSUM(NEWID())) % 16) + 5, @Today)
WHERE status = 'Atandý';

-------------------------------
-- 4) YAKLAÞAN DEADLINE göstermek için 
-- bazý ATANDI görevleri 2–7 gün sonrasý yapýlýr
-------------------------------
UPDATE Tasks
SET due_date = DATEADD(DAY, (ABS(CHECKSUM(NEWID())) % 6) + 2, @Today)
WHERE status = 'Atandý'
  AND task_id % 3 = 0;   -- her 3 görevden biri yakýn deadline



SELECT task_id, task_title, status, due_date,
       DATEDIFF(DAY, GETDATE(), due_date) AS KalanGun
FROM Tasks
ORDER BY due_date;



SELECT * FROM vw_UpcomingDeadlines;



CREATE PROCEDURE sp_AddTask
(
    @project_id INT,
    @employee_id INT,
    @task_title NVARCHAR(150),
    @task_description NVARCHAR(255),
    @priority NVARCHAR(20),
    @start_date DATE,
    @due_date DATE,
    @assigned_role NVARCHAR(50),
    @assigned_date DATE
)
AS
BEGIN
    INSERT INTO Tasks 
    (project_id, employee_id, task_title, task_description, priority, status, 
     start_date, due_date, assigned_role, assigned_date)
    VALUES
    (@project_id, @employee_id, @task_title, @task_description, @priority,
     'Atandý', @start_date, @due_date, @assigned_role, @assigned_date);

    SELECT SCOPE_IDENTITY() AS NewTaskID;
END;
GO


---test
ALTER PROCEDURE sp_AddTask
    @project_id INT,
    @employee_id INT,
    @task_title NVARCHAR(150),
    @task_description NVARCHAR(255),
    @priority NVARCHAR(20),
    @start_date DATE,
    @due_date DATE,
    @assigned_role NVARCHAR(50),
    @assigned_date DATE
AS
BEGIN
    SET NOCOUNT ON;

    ------------------------------------------------
    -- 1) Duplicate Task Kontrolü 
    ------------------------------------------------
    IF EXISTS (
        SELECT 1 FROM Tasks 
        WHERE task_title = @task_title
          AND employee_id = @employee_id
    )
    BEGIN
        RAISERROR('Bu çalýþan için ayný task zaten var!', 16, 1);
        RETURN;
    END

    ------------------------------------------------
    -- 2) Task Ekleme
    ------------------------------------------------
    INSERT INTO Tasks (project_id, employee_id, task_title, task_description, priority, status,
                       start_date, due_date, assigned_role, assigned_date)
    VALUES (
        @project_id, @employee_id, @task_title, @task_description, @priority,
        'Atandý', @start_date, @due_date, @assigned_role, @assigned_date
    );

    DECLARE @newTaskId INT = SCOPE_IDENTITY();

    ------------------------------------------------
    -- 3) Ýlk Log Kaydý (Tarihçe)
    ------------------------------------------------
    INSERT INTO TaskStatusHistory (task_id, old_status, new_status, changed_by)
    VALUES (@newTaskId, NULL, 'Atandý', @employee_id);

    ------------------------------------------------
    -- 4) Task ID'yi geri döndür
    ------------------------------------------------
    SELECT @newTaskId AS NewTaskID;
END
GO



EXEC sp_AddTask
    @project_id = 1,
    @employee_id = 5,
    @task_title = 'Raporlama Modülü Testi',
    @task_description = 'Yeni eklenen SP için test',
    @priority = 'Orta',
    @start_date = '2025-12-15',
    @due_date = '2025-12-20',
    @assigned_role = 'Geliþtirici',
    @assigned_date = '2025-12-15';



SELECT task_id, task_title, employee_id
FROM Tasks
WHERE task_title = 'Raporlama Modülü Testi'
  AND employee_id = 5;




DELETE FROM Tasks
WHERE task_id BETWEEN 21 AND 28;


SELECT task_id, task_title
FROM Tasks
ORDER BY task_id;



CREATE OR ALTER PROCEDURE sp_UpdateTaskStatus
    @task_id INT,
    @new_status NVARCHAR(50),
    @changed_by INT
AS
BEGIN
    SET NOCOUNT ON;

    ----------------------------------------------------
    -- 1) Task var mý?
    ----------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM Tasks WHERE task_id = @task_id)
    BEGIN
        RAISERROR('Belirtilen Task bulunamadý!', 16, 1);
        RETURN;
    END

    DECLARE @old_status NVARCHAR(50);
    SELECT @old_status = status FROM Tasks WHERE task_id = @task_id;

    ----------------------------------------------------
    -- 2) Ayný statüye güncellemeyi engelle
    ----------------------------------------------------
    IF @old_status = @new_status
    BEGIN
        RAISERROR('Zaten bu statüde!', 16, 1);
        RETURN;
    END

    ----------------------------------------------------
    -- 3) Durumu Güncelle
    ----------------------------------------------------
    UPDATE Tasks
    SET status = @new_status
    WHERE task_id = @task_id;

    ----------------------------------------------------
    -- 4) Log Kaydý (NOT: Trigger zaten log atýyor ama biz manuel log da ekliyoruz)
    ----------------------------------------------------
    INSERT INTO TaskStatusHistory (task_id, old_status, new_status, changed_by)
    VALUES (@task_id, @old_status, @new_status, @changed_by);

    ----------------------------------------------------
    -- 5) Yeni statüyü geri döndür 
    ----------------------------------------------------
    SELECT 
        @task_id AS TaskID,
        @old_status AS OldStatus,
        @new_status AS NewStatus,
        @changed_by AS ChangedBy,
        GETDATE() AS ChangedAt;
END
GO


EXEC sp_UpdateTaskStatus
    @task_id = 29,
    @new_status = 'Devam Ediyor',
    @changed_by = 5;


ALTER TABLE ProjectMembers
ADD role_in_project NVARCHAR(100);



CREATE PROCEDURE sp_AssignEmployeeToProject
    @project_id INT,
    @employee_id INT,
    @role_in_project NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    ---------------------------------------------------------
    -- 1) Ayný çalýþan zaten projeye atanmýþ mý? (KORUMA)
    ---------------------------------------------------------
    IF EXISTS (
        SELECT 1 FROM ProjectMembers
        WHERE project_id = @project_id
          AND employee_id = @employee_id
    )
    BEGIN
        RAISERROR('Bu çalýþan zaten bu projeye atanmýþ!', 16, 1);
        RETURN;
    END

    ---------------------------------------------------------
    -- 2) Proje Görevlendirmeyi Ekle
    ---------------------------------------------------------
    INSERT INTO ProjectMembers (project_id, employee_id, role_in_project, assigned_date)
    VALUES (@project_id, @employee_id, @role_in_project, GETDATE());

    ---------------------------------------------------------
    -- 3) Bilgi mesajý olarak eklenen ID’yi döndür
    ---------------------------------------------------------
    DECLARE @NewAssignmentID INT = SCOPE_IDENTITY();
    SELECT @NewAssignmentID AS NewAssignmentID;
END
GO


EXEC sp_help 'Employees';




SELECT name, type_desc
FROM sys.objects
WHERE name = 'sp_GetProjectTasks';


SELECT name, type_desc
FROM sys.objects
WHERE type = 'P'
ORDER BY name;





EXEC sp_columns Employees;


SELECT TABLE_NAME, COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Tasks';

---

DROP PROCEDURE IF EXISTS sp_GetProjectTasks;
GO

CREATE PROCEDURE sp_GetProjectTasks
    @project_id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        t.task_id,
        t.task_title,
        t.status,
        t.employee_id,
        (e.FirstName + ' ' + e.LastName) AS employee_name,
        t.start_date,
        t.due_date
    FROM Tasks t
    LEFT JOIN Employees e 
        ON t.employee_id = e.EmployeeID
    WHERE t.project_id = @project_id;
END
GO



EXEC sp_GetProjectTasks @project_id = 1;





CREATE PROCEDURE sp_GetEmployeeTaskSummary
    @employee_id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        t.task_id,
        t.task_title,
        p.project_name,
        t.status,
        t.priority,
        t.start_date,
        t.due_date,

        -- Kalan gün hesabý
        DATEDIFF(DAY, GETDATE(), t.due_date) AS DaysLeft,

        -- Gecikmiþ mi?
        CASE 
            WHEN t.due_date < GETDATE() AND t.status <> 'Tamamlandý' 
                THEN 'Evet'
            ELSE 'Hayýr'
        END AS IsOverdue

    FROM Tasks t
    INNER JOIN Projects p ON t.project_id = p.project_id
    WHERE t.employee_id = @employee_id
    ORDER BY t.due_date ASC;
END
GO




EXEC sp_GetEmployeeTaskSummary @employee_id = 5;




EXEC sp_AddTask
    @project_id = 1,
    @employee_id = 5,
    @task_title = 'CRUD Insert Testi',
    @task_description = 'Insert test kaydý',
    @priority = 'Orta',
    @start_date = '2025-12-15',
    @due_date = '2025-12-22',
    @assigned_role = 'Geliþtirici',
    @assigned_date = '2025-12-15';



EXEC sp_UpdateTaskStatus
    @task_id = 30,
    @new_status = 'Tamamlandý',
    @changed_by = 5;



ALTER TABLE TaskStatusHistory
DROP CONSTRAINT FK__TaskStatu__task___6477ECF3;

ALTER TABLE TaskStatusHistory
ADD CONSTRAINT FK__TaskStatusHistory_Tasks
    FOREIGN KEY (task_id) REFERENCES Tasks(task_id)
    ON DELETE CASCADE;


DELETE FROM Tasks WHERE task_id = 30;



ALTER TABLE Notifications
DROP CONSTRAINT FK__Notificat__task___6A30C649;



ALTER TABLE Notifications
ADD CONSTRAINT FK_Notifications_Tasks
    FOREIGN KEY (task_id) REFERENCES Tasks(task_id)
    ON DELETE CASCADE;


DELETE FROM Tasks WHERE task_id = 30;





UPDATE Tasks
SET 
    task_title = 'CRUD Update Testi - Güncellendi',
    task_description = 'Bu kayýt update testi için güncellendi',
    priority = 'Yüksek',
    due_date = '2025-12-30'
WHERE task_title = 'CRUD Insert Testi';




SELECT * FROM Tasks
WHERE task_title LIKE '%Update Testi%';



SELECT * FROM Tasks;


SELECT * FROM Tasks
WHERE employee_id = 5;


SELECT * FROM Tasks
WHERE project_id = 1;


SELECT * FROM Tasks
WHERE due_date BETWEEN GETDATE() AND DATEADD(day, 7, GETDATE());




CREATE PROCEDURE sp_AddTask_WithTransaction
    @task_title NVARCHAR(100),
    @project_id INT,
    @employee_id INT,
    @due_date DATE
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Görev ekleme
        INSERT INTO Tasks (task_title, project_id, employee_id, status, due_date)
        VALUES (@task_title, @project_id, @employee_id, 'Yeni', @due_date);

        DECLARE @newTaskId INT = SCOPE_IDENTITY();

        -- 2. Görev durum geçmiþine kayýt
        INSERT INTO TaskStatusHistory (task_id, old_status, new_status, change_date)
        VALUES (@newTaskId, NULL, 'Yeni', GETDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
