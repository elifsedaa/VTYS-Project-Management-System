from flask import Flask, render_template, request, jsonify, redirect, url_for, session
from database import DatabaseManager
from datetime import datetime, timedelta
import json

app = Flask(__name__)
app.secret_key = 'your-secret-key-change-this-in-production'

# Veritabanı bağlantısı
# app.py dosyasındaki ilgili kısım:
db = DatabaseManager(
    server='localhost\\SQLEXPRESS',  # Eğer SSMS'de sunucu adın farklıysa onu yaz
    database='ProjectManagementDB2',
    username=None,  # 'sa' yerine None yapıyoruz
    password=None   # Şifre yerine None yapıyoruz
)


# ============================================
# ANA SAYFA - LOGIN
# ============================================
@app.route('/')
def index():
    if 'user_id' in session:
        return redirect(url_for('dashboard'))
    return render_template('login.html')


@app.route('/login', methods=['POST'])
def login():
    email = request.form.get('email')
    password = request.form.get('password')

    # Basit login kontrolü (gerçek projede hash'li şifre kullanın)
    query = "SELECT EmployeeID, FirstName, LastName FROM Employees WHERE Email = ?"
    result = db.execute_query(query, (email,))

    if result:
        session['user_id'] = result[0]['EmployeeID']
        session['user_name'] = f"{result[0]['FirstName']} {result[0]['LastName']}"
        return jsonify({'success': True, 'redirect': url_for('dashboard')})

    return jsonify({'success': False, 'message': 'Geçersiz email'})


@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('index'))


# ============================================
# DASHBOARD
# ============================================
@app.route('/dashboard')
def dashboard():
    if 'user_id' not in session:
        return redirect(url_for('index'))

    # İstatistikler
    stats = {
        'total_projects': db.execute_scalar("SELECT COUNT(*) FROM Projects"),
        'active_tasks': db.execute_scalar("SELECT COUNT(*) FROM Tasks WHERE status != 'Tamamlandı'"),
        'completed_tasks': db.execute_scalar("SELECT COUNT(*) FROM Tasks WHERE status = 'Tamamlandı'"),
        'total_employees': db.execute_scalar("SELECT COUNT(*) FROM Employees")
    }

    # Yaklaşan deadline'lar
    upcoming = db.execute_query("SELECT * FROM vw_UpcomingDeadlines ORDER BY DaysLeft")

    # Departman görev dağılımı
    dept_tasks = db.execute_query("SELECT * FROM vw_DepartmentTaskCount ORDER BY TotalTasks DESC")

    return render_template('dashboard.html',
                           user_name=session['user_name'],
                           stats=stats,
                           upcoming=upcoming,
                           dept_tasks=dept_tasks)


# ============================================
# PROJELER
# ============================================
@app.route('/projects')
def projects():
    if 'user_id' not in session:
        return redirect(url_for('index'))

    projects = db.execute_query("""
        SELECT p.*, 
               COUNT(DISTINCT pm.employee_id) as member_count,
               COUNT(DISTINCT t.task_id) as task_count
        FROM Projects p
        LEFT JOIN ProjectMembers pm ON p.project_id = pm.project_id
        LEFT JOIN Tasks t ON p.project_id = t.project_id
        GROUP BY p.project_id, p.project_name, p.description, p.start_date, p.end_date, p.status
        ORDER BY p.start_date DESC
    """)

    return render_template('projects.html',
                           user_name=session['user_name'],
                           projects=projects)


@app.route('/api/projects', methods=['GET', 'POST', 'PUT', 'DELETE'])
def api_projects():
    if request.method == 'GET':
        project_id = request.args.get('id')
        if project_id:
            project = db.execute_query("SELECT * FROM Projects WHERE project_id = ?", (project_id,))
            members = db.execute_query("SELECT * FROM vw_ProjectMembersDetails WHERE project_id = ?", (project_id,))
            tasks = db.execute_query("EXEC sp_GetProjectTasks ?", (project_id,))
            return jsonify({'project': project[0] if project else None, 'members': members, 'tasks': tasks})
        return jsonify({'projects': db.execute_query("SELECT * FROM Projects")})

    elif request.method == 'POST':
        data = request.json
        query = """
            INSERT INTO Projects (project_name, description, start_date, end_date, status)
            VALUES (?, ?, ?, ?, ?)
        """
        db.execute_update(query, (
            data['project_name'],
            data.get('description', ''),
            data['start_date'],
            data.get('end_date'),
            data.get('status', 'Aktif')
        ))
        return jsonify({'success': True, 'message': 'Proje başarıyla eklendi'})

    elif request.method == 'PUT':
        data = request.json
        query = """
            UPDATE Projects 
            SET project_name = ?, description = ?, start_date = ?, end_date = ?, status = ?
            WHERE project_id = ?
        """
        db.execute_update(query, (
            data['project_name'],
            data.get('description', ''),
            data['start_date'],
            data.get('end_date'),
            data.get('status', 'Aktif'),
            data['project_id']
        ))
        return jsonify({'success': True, 'message': 'Proje güncellendi'})

    elif request.method == 'DELETE':
        project_id = request.args.get('id')
        db.execute_update("DELETE FROM Projects WHERE project_id = ?", (project_id,))
        return jsonify({'success': True, 'message': 'Proje silindi'})


# ============================================
# GÖREVLER
# ============================================
@app.route('/tasks')
def tasks():
    if 'user_id' not in session:
        return redirect(url_for('index'))

    # Tüm görevleri view'dan çek
    all_tasks = db.execute_query("SELECT * FROM V_TaskDetails ORDER BY due_date")

    # Proje listesi (dropdown için)
    projects = db.execute_query("SELECT project_id, project_name FROM Projects ORDER BY project_name")

    # Çalışan listesi (dropdown için)
    employees = db.execute_query("SELECT EmployeeID, FirstName, LastName FROM Employees ORDER BY FirstName")

    return render_template('tasks.html',
                           user_name=session['user_name'],
                           tasks=all_tasks,
                           projects=projects,
                           employees=employees)


@app.route('/api/tasks', methods=['GET', 'POST', 'PUT', 'DELETE'])
def api_tasks():
    if request.method == 'GET':
        task_id = request.args.get('id')
        if task_id:
            task = db.execute_query("SELECT * FROM V_TaskDetails WHERE task_id = ?", (task_id,))
            return jsonify({'task': task[0] if task else None})

        project_id = request.args.get('project_id')
        if project_id:
            tasks = db.execute_query("EXEC sp_GetProjectTasks ?", (project_id,))
            return jsonify({'tasks': tasks})

        return jsonify({'tasks': db.execute_query("SELECT * FROM V_TaskDetails")})


    # app.py içindeki api_tasks fonksiyonu POST metodu

    elif request.method == 'POST':
        try:
            data = request.json
            print("Gelen Veri:", data)  # Terminalden veriyi kontrol etmek için

            # 1. Tarihleri SQL'in anlayacağı YYYY-MM-DD formatına zorla
            def format_date(date_str):
                if not date_str or date_str == "":
                    return datetime.now().strftime('%Y-%m-%d')
                return date_str

            start_dt = format_date(data.get('start_date'))
            due_dt = format_date(data.get('due_date'))
            assigned_dt = datetime.now().strftime('%Y-%m-%d')

            # 2. Parametreleri tam olarak prosedürün beklediği sırayla hazırla
            # Prosedür sırası: project_id, employee_id, title, desc, priority, start, due, role, assigned_date
            params = (
                int(data['project_id']),
                int(data['employee_id']),
                str(data['task_title']),
                str(data.get('task_description', '')),
                str(data['priority']),
                start_dt,
                due_dt,
                str(data.get('assigned_role', 'Ekip Üyesi')),
                assigned_dt
            )

            # 3. Prosedürü çalıştır
            db.execute_procedure('sp_AddTask', params)

            return jsonify({'success': True, 'message': 'Görev başarıyla eklendi!'})

        except Exception as e:
            print(f"HATA OLUŞTU: {str(e)}")
            return jsonify({'success': False, 'message': f"Hata: {str(e)}"})

    elif request.method == 'PUT':
        data = request.json
        if 'status' in data and len(data) == 2:  # Sadece status güncellemesi
            db.execute_procedure('sp_UpdateTaskStatus', (
                data['task_id'],
                data['status'],
                session['user_id']
            ))
            return jsonify({'success': True, 'message': 'Görev durumu güncellendi'})
        else:
            query = """
                UPDATE Tasks 
                SET task_title = ?, task_description = ?, priority = ?, 
                    start_date = ?, due_date = ?, employee_id = ?
                WHERE task_id = ?
            """
            db.execute_update(query, (
                data['task_title'],
                data.get('task_description', ''),
                data['priority'],
                data['start_date'],
                data['due_date'],
                data['employee_id'],
                data['task_id']
            ))
            return jsonify({'success': True, 'message': 'Görev güncellendi'})

    elif request.method == 'DELETE':
        task_id = request.args.get('id')
        db.execute_update("DELETE FROM Tasks WHERE task_id = ?", (task_id,))
        return jsonify({'success': True, 'message': 'Görev silindi'})


# ============================================
# ÇALIŞANLAR
# ============================================
@app.route('/employees')
def employees():
    if 'user_id' not in session:
        return redirect(url_for('index'))

    employees = db.execute_query("""
        SELECT e.*, d.department_name,
               COUNT(DISTINCT pm.project_id) as project_count,
               COUNT(DISTINCT t.task_id) as task_count
        FROM Employees e
        LEFT JOIN Departments d ON e.DepartmentID = d.department_id
        LEFT JOIN ProjectMembers pm ON e.EmployeeID = pm.employee_id
        LEFT JOIN Tasks t ON e.EmployeeID = t.employee_id
        GROUP BY e.EmployeeID, e.FirstName, e.LastName, e.Email, e.DepartmentID, e.HireDate, d.department_name
        ORDER BY e.FirstName
    """)

    departments = db.execute_query("SELECT * FROM Departments ORDER BY department_name")

    return render_template('employees.html',
                           user_name=session['user_name'],
                           employees=employees,
                           departments=departments)


@app.route('/api/employees', methods=['GET', 'POST', 'PUT', 'DELETE'])
def api_employees():
    if request.method == 'GET':
        employee_id = request.args.get('id')
        if employee_id:
            employee = db.execute_query("SELECT * FROM Employees WHERE EmployeeID = ?", (employee_id,))
            tasks = db.execute_query("EXEC sp_GetEmployeeTaskSummary ?", (employee_id,))
            return jsonify({'employee': employee[0] if employee else None, 'tasks': tasks})
        return jsonify({'employees': db.execute_query("SELECT * FROM Employees")})

    elif request.method == 'POST':
        data = request.json
        query = """
            INSERT INTO Employees (FirstName, LastName, Email, DepartmentID, HireDate)
            VALUES (?, ?, ?, ?, ?)
        """
        db.execute_update(query, (
            data['FirstName'],
            data['LastName'],
            data['Email'],
            data['DepartmentID'],
            data.get('HireDate', datetime.now().strftime('%Y-%m-%d'))
        ))
        return jsonify({'success': True, 'message': 'Çalışan başarıyla eklendi'})

    elif request.method == 'PUT':
        data = request.json
        query = """
            UPDATE Employees 
            SET FirstName = ?, LastName = ?, Email = ?, DepartmentID = ?
            WHERE EmployeeID = ?
        """
        db.execute_update(query, (
            data['FirstName'],
            data['LastName'],
            data['Email'],
            data['DepartmentID'],
            data['EmployeeID']
        ))
        return jsonify({'success': True, 'message': 'Çalışan güncellendi'})

    elif request.method == 'DELETE':
        employee_id = request.args.get('id')
        db.execute_update("DELETE FROM Employees WHERE EmployeeID = ?", (employee_id,))
        return jsonify({'success': True, 'message': 'Çalışan silindi'})


# ============================================
# RAPORLAR
# ============================================
@app.route('/reports')
def reports():
    if 'user_id' not in session:
        return redirect(url_for('index'))

    # Tamamlanan görevler
    completed = db.execute_query("SELECT * FROM V_CompletedTasks ORDER BY due_date DESC")

    # Görev durum geçmişi
    history = db.execute_query("""
        SELECT tsh.*, t.task_title, e.FirstName + ' ' + e.LastName as changed_by_name
        FROM TaskStatusHistory tsh
        INNER JOIN Tasks t ON tsh.task_id = t.task_id
        INNER JOIN Employees e ON tsh.changed_by = e.EmployeeID
        ORDER BY tsh.changed_at DESC
    """)

    # Bildirimler
    notifications = db.execute_query("""
        SELECT n.*, t.task_title, e.FirstName + ' ' + e.LastName as user_name
        FROM Notifications n
        INNER JOIN Tasks t ON n.task_id = t.task_id
        INNER JOIN Employees e ON n.user_id = e.EmployeeID
        ORDER BY n.created_at DESC
    """)

    return render_template('reports.html',
                           user_name=session['user_name'],
                           completed=completed,
                           history=history,
                           notifications=notifications)


# ============================================
# ÇALIŞTIR
# ============================================
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)