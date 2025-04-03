<?php
require_once 'includes/config.php';

// Redirigir si no está logueado
if (!isset($_SESSION['user_id'])) {
    header('Location: login.php');
    exit();
}

$error = '';
$success = '';

// Procesar cambio de contraseña
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $current_password = $_POST['current_password'];
    $new_password = $_POST['new_password'];
    $confirm_password = $_POST['confirm_password'];
    
    // Validaciones
    if (empty($current_password) || empty($new_password) || empty($confirm_password)) {
        $error = 'Todos los campos son obligatorios.';
    } elseif ($new_password !== $confirm_password) {
        $error = 'Las nuevas contraseñas no coinciden.';
    } elseif (strlen($new_password) < 8) {
        $error = 'La nueva contraseña debe tener al menos 8 caracteres.';
    } else {
        // Cambiar contraseña
        $result = changePassword($_SESSION['user_id'], $current_password, $new_password);
        
        if ($result['success']) {
            $success = $result['message'];
        } else {
            $error = $result['message'];
        }
    }
}
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cambiar Contraseña - <?= APP_NAME ?></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="assets/css/styles.css" rel="stylesheet">
</head>
<body>
    <div class="container">
        <div class="row justify-content-center mt-5">
            <div class="col-md-6 col-lg-4">
                <div class="card shadow">
                    <div class="card-header bg-primary text-white">
                        <h4 class="text-center">Cambiar Contraseña</h4>
                    </div>
                    <div class="card-body">
                        <?php if ($error): ?>
                            <div class="alert alert-danger"><?= htmlspecialchars($error) ?></div>
                        <?php endif; ?>
                        
                        <?php if ($success): ?>
                            <div class="alert alert-success"><?= htmlspecialchars($success) ?></div>
                        <?php endif; ?>
                        
                        <form action="change_password.php" method="post">
                            <div class="mb-3">
                                <label for="current_password" class="form-label">Contraseña Actual</label>
                                <input type="password" class="form-control" id="current_password" name="current_password" required>
                            </div>
                            <div class="mb-3">
                                <label for="new_password" class="form-label">Nueva Contraseña</label>
                                <input type="password" class="form-control" id="new_password" name="new_password" required>
                                <small class="text-muted">Mínimo 8 caracteres</small>
                            </div>
                            <div class="mb-3">
                                <label for="confirm_password" class="form-label">Confirmar Nueva Contraseña</label>
                                <input type="password" class="form-control" id="confirm_password" name="confirm_password" required>
                            </div>
                            <div class="d-grid gap-2">
                                <button type="submit" class="btn btn-primary">Cambiar Contraseña</button>
                                <a href="index.php" class="btn btn-secondary">Cancelar</a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="assets/js/auth.js"></script>
</body>
</html>