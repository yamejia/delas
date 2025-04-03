<?php
// Función para obtener nombre del rol
function getRolNombre($rol_id) {
    global $pdo;
    $stmt = $pdo->prepare("SELECT nombre_rol FROM roles WHERE rol_id = ?");
    $stmt->execute([$rol_id]);
    $rol = $stmt->fetch(PDO::FETCH_ASSOC);
    return $rol ? $rol['nombre_rol'] : 'Desconocido';
}

// Función para obtener ID del rol
function getRolId($nombre_rol) {
    global $pdo;
    $stmt = $pdo->prepare("SELECT rol_id FROM roles WHERE nombre_rol = ?");
    $stmt->execute([$nombre_rol]);
    $rol = $stmt->fetch(PDO::FETCH_ASSOC);
    return $rol ? $rol['rol_id'] : null;
}
?>

<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container-fluid">
        <a class="navbar-brand" href="../index.php"><?= APP_NAME ?></a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav me-auto">
                <?php if (isset($_SESSION['user_id'])): ?>
                    <li class="nav-item">
                        <a class="nav-link" href="<?= getDashboardPath($_SESSION['rol']) ?>">Inicio</a>
                    </li>
                    
                    <?php if ($_SESSION['rol'] === getRolId('administrador')): ?>
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#" id="adminDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                Administración
                            </a>
                            <ul class="dropdown-menu" aria-labelledby="adminDropdown">
                                <li><a class="dropdown-item" href="../admin/usuarios.php">Usuarios</a></li>
                                <li><a class="dropdown-item" href="../admin/productos.php">Productos</a></li>
                                <li><a class="dropdown-item" href="../admin/ventas.php">Ventas</a></li>
                                <li><a class="dropdown-item" href="../admin/compras.php">Compras</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item" href="../admin/reportes.php">Reportes</a></li>
                            </ul>
                        </li>
                    <?php elseif ($_SESSION['rol'] === getRolId('vendedor')): ?>
                        <li class="nav-item">
                            <a class="nav-link" href="../vendedor/ventas.php">Ventas</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="../vendedor/productos.php">Productos</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="../vendedor/clientes.php">Clientes</a>
                        </li>
                    <?php elseif ($_SESSION['rol'] === getRolId('cliente')): ?>
                        <li class="nav-item">
                            <a class="nav-link" href="../cliente/productos.php">Productos</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="../cliente/pedidos.php">Mis Compras</a>
                        </li>
                    <?php endif; ?>
                <?php else: ?>
                    <li class="nav-item">
                        <a class="nav-link" href="../index.php">Inicio</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="../login.php">Iniciar Sesión</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="../register.php">Registrarse</a>
                    </li>
                <?php endif; ?>
            </ul>
            
            <?php if (isset($_SESSION['user_id'])): ?>
                <ul class="navbar-nav">
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="userDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            <?= htmlspecialchars($_SESSION['nombre']) ?> (<?= getRolNombre($_SESSION['rol']) ?>)
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="userDropdown">
                            <li><a class="dropdown-item" href="<?= getProfilePath($_SESSION['rol']) ?>">Mi Perfil</a></li>
                            <li><a class="dropdown-item" href="../change_password.php">Cambiar Contraseña</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item" href="../logout.php">Cerrar Sesión</a></li>
                        </ul>
                    </li>
                </ul>
            <?php endif; ?>
        </div>
    </div>
</nav>

<?php
// Función para obtener ruta al dashboard según rol
function getDashboardPath($rol_id) {
    $rol = getRolNombre($rol_id);
    switch ($rol) {
        case 'administrador': return '../admin/dashboard.php';
        case 'vendedor': return '../vendedor/dashboard.php';
        case 'cliente': return '../cliente/dashboard.php';
        default: return '../index.php';
    }
}

// Función para obtener ruta al perfil según rol
function getProfilePath($rol_id) {
    $rol = getRolNombre($rol_id);
    switch ($rol) {
        case 'administrador': return '../admin/perfil.php';
        case 'vendedor': return '../vendedor/perfil.php';
        case 'cliente': return '../cliente/perfil.php';
        default: return '../index.php';
    }
}
?>