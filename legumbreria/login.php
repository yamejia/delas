<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
require_once 'includes/config.php';

// Redirigir si ya está logueado
if (isset($_SESSION['user_id'])) {
    redirectByRole($_SESSION['rol']);
}

$error = '';
$locked = false;

// Procesar formulario de login
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = trim($_POST['username']);
    $password = $_POST['password'];
    
    $result = verifyCredentials($username, $password);
    
    if ($result['success']) {
        // Iniciar sesión
        $_SESSION['user_id'] = $result['user']['usuario_id'];
        $_SESSION['username'] = $result['user']['username'];
        $_SESSION['rol'] = $result['user']['rol_id'];
        $_SESSION['nombre'] = $result['user']['nombre'];
        
        // Redirigir según rol
        redirectByRole($result['user']['rol_id']);
    } else {
        $error = $result['message'];
        if (isset($result['locked']) && $result['locked']) {
            $locked = true;
        }
    }
}

// Función para redirigir según rol
function redirectByRole($rol_id) {
    global $pdo;
    
    $stmt = $pdo->prepare("SELECT nombre_rol FROM roles WHERE rol_id = ?");
    $stmt->execute([$rol_id]);
    $rol = $stmt->fetch(PDO::FETCH_ASSOC);
    
    switch ($rol['nombre_rol']) {
        case 'administrador':
            header('Location: admin/dashboard.php');
            break;
        case 'vendedor':
            header('Location: vendedor/dashboard.php');
            break;
        case 'cliente':
            header('Location: cliente/dashboard.php');
            break;
        default:
            header('Location: index.php');
    }
    exit();
}
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - <?= APP_NAME ?></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="assets/css/styles.css" rel="stylesheet">
</head>
<body>
    <div class="container">
        <div class="row justify-content-center mt-5">
            <div class="col-md-6 col-lg-4">
                <div class="card shadow">
                    <div class="card-header bg-primary text-white">
                        <h4 class="text-center">Iniciar Sesión</h4>
                    </div>
                    <div class="card-body">
                        <?php if ($error): ?>
                            <div class="alert alert-danger"><?= htmlspecialchars($error) ?></div>
                        <?php endif; ?>
                        
                        <form action="login.php" method="post">
                            <div class="mb-3">
                                <label for="username" class="form-label">Usuario o Email</label>
                                <input type="text" class="form-control" id="username" name="username" required>
                            </div>
                            <div class="mb-3">
                                <label for="password" class="form-label">Contraseña</label>
                                <input type="password" class="form-control" id="password" name="password" required>
                            </div>
                            <div class="d-grid gap-2">
                                <button type="submit" class="btn btn-primary">Ingresar</button>
                            </div>
                        </form>
                        
                        <div class="mt-3 text-center">
                            <a href="register.php">Crear una cuenta</a> | 
                            <a href="change_password.php">Cambiar contraseña</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal para cuenta bloqueada -->
    <?php if ($locked): ?>
    <div class="modal fade show" id="lockedModal" tabindex="-1" style="display: block; background-color: rgba(0,0,0,0.5);">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header bg-danger text-white">
                    <h5 class="modal-title">Cuenta Bloqueada</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p>Su cuenta ha sido bloqueada temporalmente debido a múltiples intentos fallidos de inicio de sesión.</p>
                    <p>Por seguridad, deberá esperar 30 minutos antes de intentar nuevamente.</p>
                    <p>Si cree que esto es un error, por favor contacte al administrador del sistema.</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Entendido</button>
                </div>
            </div>
        </div>
    </div>

    <?php
// Debug de conexión
try {
    $test = $pdo->query("SELECT 1")->fetch();
    echo "<p style='color:green'>✓ Conexión a DB funcionando</p>";
} catch (PDOException $e) {
    echo "<p style='color:red'>✗ Error de conexión: " . $e->getMessage() . "</p>";
}

// Debug de hash
$hash = '$2y$10$ZKGXW.zWY5bJZ7W9v6n8.e5UOj7hN.8qk3VcKzLm1RtD2TQxvL1aK';
echo "<p>Verificación de hash: " . 
    (password_verify('Yeison0023', $hash) ? "✓ Correcto" : "✗ Incorrecto") . 
    "</p>";

// Debug de tabla
try {
    $stmt = $pdo->query("DESCRIBE usuarios");
    $columns = $stmt->fetchAll(PDO::FETCH_COLUMN);
    echo "<p>Columnas en 'usuarios': " . implode(", ", $columns) . "</p>";
} catch (PDOException $e) {
    echo "<p style='color:red'>✗ Error al verificar tabla: " . $e->getMessage() . "</p>";
}
?>
    
    <script>
        // Mostrar modal automáticamente
        document.addEventListener('DOMContentLoaded', function() {
            var modal = new bootstrap.Modal(document.getElementById('lockedModal'));
            modal.show();
        });
    </script>
    <?php endif; ?>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="assets/js/auth.js"></script>
</body>
</html>