// Utility Functions
const showAlert = (message, type = 'success') => {
    const alert = document.createElement('div');
    alert.className = `alert ${type}`;
    alert.innerHTML = `
        <i class="fas fa-${type === 'success' ? 'check-circle' : 'exclamation-circle'}"></i>
        <span>${message}</span>
    `;

    const container = document.querySelector('.main-content');
    container.insertBefore(alert, container.firstChild);

    setTimeout(() => alert.remove(), 5000);
};

const formatDate = (dateString) => {
    if (!dateString) return '-';
    const date = new Date(dateString);
    return date.toLocaleDateString('tr-TR');
};

const formatDateTime = (dateString) => {
    if (!dateString) return '-';
    const date = new Date(dateString);
    return date.toLocaleString('tr-TR');
};

// Modal Functions
const openModal = (modalId) => {
    document.getElementById(modalId).classList.add('show');
};

const closeModal = (modalId) => {
    document.getElementById(modalId).classList.remove('show');
};

// Close modal when clicking outside
document.addEventListener('click', (e) => {
    if (e.target.classList.contains('modal')) {
        e.target.classList.remove('show');
    }
});

// ============================================
// PROJECTS PAGE FUNCTIONS
// ============================================
let currentProjectId = null;

const loadProjects = async () => {
    try {
        const response = await fetch('/api/projects');
        const data = await response.json();

        const tbody = document.getElementById('projectsTableBody');
        if (!data.projects || data.projects.length === 0) {
            tbody.innerHTML = '<tr><td colspan="7" class="empty-state"><i class="fas fa-folder-open"></i><h3>Henüz proje yok</h3><p>Yeni proje eklemek için yukarıdaki butona tıklayın</p></td></tr>';
            return;
        }

        tbody.innerHTML = data.projects.map(p => `
            <tr>
                <td><strong>${p.project_id}</strong></td>
                <td><strong>${p.project_name}</strong></td>
                <td>${p.description || '-'}</td>
                <td>${formatDate(p.start_date)}</td>
                <td>${formatDate(p.end_date)}</td>
                <td><span class="badge ${getStatusClass(p.status)}">${p.status}</span></td>
                <td>
                    <button class="btn-primary btn-sm" onclick="viewProjectDetails(${p.project_id})">
                        <i class="fas fa-eye"></i> Detay
                    </button>
                    <button class="btn-warning btn-sm" onclick="editProject(${p.project_id})">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn-danger btn-sm" onclick="deleteProject(${p.project_id})">
                        <i class="fas fa-trash"></i>
                    </button>
                </td>
            </tr>
        `).join('');
    } catch (error) {
        showAlert('Projeler yüklenirken hata oluştu', 'error');
    }
};

const getStatusClass = (status) => {
    const statusMap = {
        'Aktif': 'success',
        'Tamamlandı': 'primary',
        'Devam Ediyor': 'warning',
        'Planlandı': 'danger'
    };
    return statusMap[status] || 'primary';
};

const addProject = () => {
    document.getElementById('projectForm').reset();
    document.getElementById('projectId').value = '';
    document.getElementById('modalTitle').textContent = 'Yeni Proje Ekle';
    openModal('projectModal');
};

const editProject = async (id) => {
    currentProjectId = id;
    const response = await fetch(`/api/projects?id=${id}`);
    const data = await response.json();
    const project = data.project;

    document.getElementById('projectId').value = project.project_id;
    document.getElementById('projectName').value = project.project_name;
    document.getElementById('projectDescription').value = project.description || '';
    document.getElementById('projectStartDate').value = project.start_date.split('T')[0];
    document.getElementById('projectEndDate').value = project.end_date ? project.end_date.split('T')[0] : '';
    document.getElementById('projectStatus').value = project.status;

    document.getElementById('modalTitle').textContent = 'Proje Düzenle';
    openModal('projectModal');
};

const saveProject = async (e) => {
    e.preventDefault();

    const formData = new FormData(e.target);
    const data = {
        project_name: formData.get('project_name'),
        description: formData.get('description'),
        start_date: formData.get('start_date'),
        end_date: formData.get('end_date') || null,
        status: formData.get('status')
    };

    const projectId = document.getElementById('projectId').value;
    const method = projectId ? 'PUT' : 'POST';

    if (projectId) {
        data.project_id = projectId;
    }

    try {
        const response = await fetch('/api/projects', {
            method: method,
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });

        const result = await response.json();

        if (result.success) {
            showAlert(result.message);
            closeModal('projectModal');
            loadProjects();
        } else {
            showAlert(result.message || 'İşlem başarısız', 'error');
        }
    } catch (error) {
        showAlert('Bir hata oluştu', 'error');
    }
};

const deleteProject = async (id) => {
    if (!confirm('Bu projeyi silmek istediğinizden emin misiniz?')) return;

    try {
        const response = await fetch(`/api/projects?id=${id}`, {
            method: 'DELETE'
        });

        const result = await response.json();

        if (result.success) {
            showAlert(result.message);
            loadProjects();
        } else {
            showAlert(result.message || 'Silme işlemi başarısız', 'error');
        }
    } catch (error) {
        showAlert('Bir hata oluştu', 'error');
    }
};

// ============================================
// TASKS PAGE FUNCTIONS
// ============================================
const loadTasks = async (projectId = null) => {
    try {
        const url = projectId ? `/api/tasks?project_id=${projectId}` : '/api/tasks';
        const response = await fetch(url);
        const data = await response.json();

        const tbody = document.getElementById('tasksTableBody');
        const tasks = data.tasks || [];

        if (tasks.length === 0) {
            tbody.innerHTML = '<tr><td colspan="8" class="empty-state"><i class="fas fa-tasks"></i><h3>Henüz görev yok</h3><p>Yeni görev eklemek için yukarıdaki butona tıklayın</p></td></tr>';
            return;
        }

        tbody.innerHTML = tasks.map(t => `
            <tr>
                <td><strong>#${t.task_id}</strong></td>
                <td><strong>${t.task_title}</strong></td>
                <td>${t.project_name}</td>
                <td>${t.EmployeeName}</td>
                <td><span class="badge ${getPriorityClass(t.priority)}">${t.priority}</span></td>
                <td><span class="badge ${getStatusClass(t.status)}">${t.status}</span></td>
                <td>${formatDate(t.due_date)}</td>
                <td>
                    <button class="btn-success btn-sm" onclick="changeTaskStatus(${t.task_id}, 'Tamamlandı')">
                        <i class="fas fa-check"></i>
                    </button>
                    <button class="btn-warning btn-sm" onclick="editTask(${t.task_id})">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn-danger btn-sm" onclick="deleteTask(${t.task_id})">
                        <i class="fas fa-trash"></i>
                    </button>
                </td>
            </tr>
        `).join('');
    } catch (error) {
        showAlert('Görevler yüklenirken hata oluştu', 'error');
    }
};

const getPriorityClass = (priority) => {
    const priorityMap = {
        'Yüksek': 'danger',
        'Orta': 'warning',
        'Düşük': 'success'
    };
    return priorityMap[priority] || 'primary';
};

const addTask = () => {
    document.getElementById('taskForm').reset();
    document.getElementById('taskId').value = '';
    document.getElementById('taskModalTitle').textContent = 'Yeni Görev Ekle';
    openModal('taskModal');
};

const editTask = async (id) => {
    const response = await fetch(`/api/tasks?id=${id}`);
    const data = await response.json();
    const task = data.task;

    document.getElementById('taskId').value = task.task_id;
    document.getElementById('taskTitle').value = task.task_title;
    document.getElementById('taskDescription').value = task.task_description || '';
    document.getElementById('taskProject').value = task.project_id;
    document.getElementById('taskEmployee').value = task.EmployeeID;
    document.getElementById('taskPriority').value = task.priority;
    document.getElementById('taskStartDate').value = task.start_date.split('T')[0];
    document.getElementById('taskDueDate').value = task.due_date.split('T')[0];

    document.getElementById('taskModalTitle').textContent = 'Görev Düzenle';
    openModal('taskModal');
};

const saveTask = async (e) => {
    e.preventDefault();

    const formData = new FormData(e.target);
    const data = {
        project_id: parseInt(formData.get('project_id')),
        employee_id: parseInt(formData.get('employee_id')),
        task_title: formData.get('task_title'),
        task_description: formData.get('task_description'),
        priority: formData.get('priority'),
        start_date: formData.get('start_date'),
        due_date: formData.get('due_date')
    };

    const taskId = document.getElementById('taskId').value;
    const method = taskId ? 'PUT' : 'POST';

    if (taskId) {
        data.task_id = parseInt(taskId);
    }

    try {
        const response = await fetch('/api/tasks', {
            method: method,
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });

        const result = await response.json();

        if (result.success) {
            showAlert(result.message);
            closeModal('taskModal');
            loadTasks();
        } else {
            showAlert(result.message || 'İşlem başarısız', 'error');
        }
    } catch (error) {
        showAlert('Bir hata oluştu', 'error');
    }
};

const changeTaskStatus = async (taskId, newStatus) => {
    try {
        const response = await fetch('/api/tasks', {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ task_id: taskId, status: newStatus })
        });

        const result = await response.json();

        if (result.success) {
            showAlert(result.message);
            loadTasks();
        } else {
            showAlert(result.message || 'İşlem başarısız', 'error');
        }
    } catch (error) {
        showAlert('Bir hata oluştu', 'error');
    }
};

const deleteTask = async (id) => {
    if (!confirm('Bu görevi silmek istediğinizden emin misiniz?')) return;

    try {
        const response = await fetch(`/api/tasks?id=${id}`, {
            method: 'DELETE'
        });

        const result = await response.json();

        if (result.success) {
            showAlert(result.message);
            loadTasks();
        } else {
            showAlert(result.message || 'Silme işlemi başarısız', 'error');
        }
    } catch (error) {
        showAlert('Bir hata oluştu', 'error');
    }
};

// ============================================
// EMPLOYEES PAGE FUNCTIONS
// ============================================
const loadEmployees = async () => {
    try {
        const response = await fetch('/api/employees');
        const data = await response.json();

        const tbody = document.getElementById('employeesTableBody');
        const employees = data.employees || [];

        if (employees.length === 0) {
            tbody.innerHTML = '<tr><td colspan="7" class="empty-state"><i class="fas fa-users"></i><h3>Henüz çalışan yok</h3></td></tr>';
            return;
        }

        tbody.innerHTML = employees.map(e => `
            <tr>
                <td><strong>#${e.EmployeeID}</strong></td>
                <td><strong>${e.FirstName} ${e.LastName}</strong></td>
                <td>${e.Email}</td>
                <td>${e.department_name || '-'}</td>
                <td>${formatDate(e.HireDate)}</td>
                <td>
                    <span class="badge primary">${e.project_count || 0} Proje</span>
                    <span class="badge warning">${e.task_count || 0} Görev</span>
                </td>
                <td>
                    <button class="btn-primary btn-sm" onclick="viewEmployeeDetails(${e.EmployeeID})">
                        <i class="fas fa-eye"></i>
                    </button>
                    <button class="btn-warning btn-sm" onclick="editEmployee(${e.EmployeeID})">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn-danger btn-sm" onclick="deleteEmployee(${e.EmployeeID})">
                        <i class="fas fa-trash"></i>
                    </button>
                </td>
            </tr>
        `).join('');
    } catch (error) {
        showAlert('Çalışanlar yüklenirken hata oluştu', 'error');
    }
};

const addEmployee = () => {
    document.getElementById('employeeForm').reset();
    document.getElementById('employeeId').value = '';
    document.getElementById('employeeModalTitle').textContent = 'Yeni Çalışan Ekle';
    openModal('employeeModal');
};

const editEmployee = async (id) => {
    const response = await fetch(`/api/employees?id=${id}`);
    const data = await response.json();
    const employee = data.employee;

    document.getElementById('employeeId').value = employee.EmployeeID;
    document.getElementById('employeeFirstName').value = employee.FirstName;
    document.getElementById('employeeLastName').value = employee.LastName;
    document.getElementById('employeeEmail').value = employee.Email;
    document.getElementById('employeeDepartment').value = employee.DepartmentID;

    document.getElementById('employeeModalTitle').textContent = 'Çalışan Düzenle';
    openModal('employeeModal');
};

const saveEmployee = async (e) => {
    e.preventDefault();

    const formData = new FormData(e.target);
    const data = {
        FirstName: formData.get('FirstName'),
        LastName: formData.get('LastName'),
        Email: formData.get('Email'),
        DepartmentID: parseInt(formData.get('DepartmentID'))
    };

    const employeeId = document.getElementById('employeeId').value;
    const method = employeeId ? 'PUT' : 'POST';

    if (employeeId) {
        data.EmployeeID = parseInt(employeeId);
    }

    try {
        const response = await fetch('/api/employees', {
            method: method,
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });

        const result = await response.json();

        if (result.success) {
            showAlert(result.message);
            closeModal('employeeModal');
            loadEmployees();
        } else {
            showAlert(result.message || 'İşlem başarısız', 'error');
        }
    } catch (error) {
        showAlert('Bir hata oluştu', 'error');
    }
};

const deleteEmployee = async (id) => {
    if (!confirm('Bu çalışanı silmek istediğinizden emin misiniz?')) return;

    try {
        const response = await fetch(`/api/employees?id=${id}`, {
            method: 'DELETE'
        });

        const result = await response.json();

        if (result.success) {
            showAlert(result.message);
            loadEmployees();
        } else {
            showAlert(result.message || 'Silme işlemi başarısız', 'error');
        }
    } catch (error) {
        showAlert('Bir hata oluştu', 'error');
    }
};

// Filter function
const filterTable = (inputId, tableId) => {
    const input = document.getElementById(inputId);
    const filter = input.value.toUpperCase();
    const table = document.getElementById(tableId);
    const tr = table.getElementsByTagName('tr');

    for (let i = 0; i < tr.length; i++) {
        const td = tr[i].getElementsByTagName('td');
        let found = false;

        for (let j = 0; j < td.length; j++) {
            if (td[j]) {
                const txtValue = td[j].textContent || td[j].innerText;
                if (txtValue.toUpperCase().indexOf(filter) > -1) {
                    found = true;
                    break;
                }
            }
        }

        tr[i].style.display = found ? '' : 'none';
    }
};