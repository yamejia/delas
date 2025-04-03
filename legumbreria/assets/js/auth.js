// Validación de formularios
document.addEventListener('DOMContentLoaded', function() {
    // Validación de registro
    const registerForm = document.querySelector('form[action="register.php"]');
    if (registerForm) {
        registerForm.addEventListener('submit', function(e) {
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirm_password').value;
            
            if (password.length < 8) {
                alert('La contraseña debe tener al menos 8 caracteres.');
                e.preventDefault();
                return false;
            }
            
            if (password !== confirmPassword) {
                alert('Las contraseñas no coinciden.');
                e.preventDefault();
                return false;
            }
            
            return true;
        });
    }
    
    // Validación de cambio de contraseña
    const changePasswordForm = document.querySelector('form[action="change_password.php"]');
    if (changePasswordForm) {
        changePasswordForm.addEventListener('submit', function(e) {
            const newPassword = document.getElementById('new_password').value;
            const confirmPassword = document.getElementById('confirm_password').value;
            
            if (newPassword.length < 8) {
                alert('La nueva contraseña debe tener al menos 8 caracteres.');
                e.preventDefault();
                return false;
            }
            
            if (newPassword !== confirmPassword) {
                alert('Las nuevas contraseñas no coinciden.');
                e.preventDefault();
                return false;
            }
            
            return true;
        });
    }
    
    // Mostrar/ocultar contraseña
    const togglePasswordButtons = document.querySelectorAll('.toggle-password');
    togglePasswordButtons.forEach(button => {
        button.addEventListener('click', function() {
            const input = this.previousElementSibling;
            const icon = this.querySelector('i');
            
            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.remove('bi-eye');
                icon.classList.add('bi-eye-slash');
            } else {
                input.type = 'password';
                icon.classList.remove('bi-eye-slash');
                icon.classList.add('bi-eye');
            }
        });
    });
    
    // Auto-ocultar mensajes de alerta después de 5 segundos
    const alerts = document.querySelectorAll('.alert');
    alerts.forEach(alert => {
        setTimeout(() => {
            alert.style.transition = 'opacity 0.5s ease';
            alert.style.opacity = '0';
            setTimeout(() => alert.remove(), 500);
        }, 5000);
    });
    
    // Manejar modal de cuenta bloqueada
    const lockedModal = document.getElementById('lockedModal');
    if (lockedModal) {
        const modal = new bootstrap.Modal(lockedModal);
        modal.show();
        
        lockedModal.addEventListener('hidden.bs.modal', function () {
            window.location.href = 'login.php';
        });
    }
});