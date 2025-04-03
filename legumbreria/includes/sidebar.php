<?php if (isset($_SESSION['user_id']) && in_array(getRolNombre($_SESSION['rol']), ['administrador', 'vendedor'])): ?>
<div class="col-md-3 col-lg-2 d-md-block bg-light sidebar collapse">
    <div class="position-sticky pt-3">
        <ul class="nav flex-column">
            <li class="nav-item">
                <a class="nav-link active" href="<?= getDashboardPath($_SESSION['rol']) ?>">
                    <i class="bi bi-speedometer2"></i> Dashboard
                </a>
            </li>
            
            <?php if ($_SESSION['rol'] === getRolId('administrador')): ?>
                <li class="nav-item">
                    <a class="nav-link" href="../admin/usuarios.php">
                        <i class="bi bi-people"></i> Usuarios
                    </a>
                </li>
            <?php endif; ?>
            
            <li class="nav-item">
                <a class="nav-link" href="<?= $_SESSION['rol'] === getRolId('administrador') ? '../admin/productos.php' : '../vendedor/productos.php' ?>">
                    <i class="bi bi-box-seam"></i> Productos
                </a>
            </li>
            
            <li class="nav-item">
                <a class="nav-link" href="<?= $_SESSION['rol'] === getRolId('administrador') ? '../admin/ventas.php' : '../vendedor/ventas.php' ?>">
                    <i class="bi bi-cart-check"></i> Ventas
                </a>
            </li>
            
            <?php if ($_SESSION['rol'] === getRolId('administrador')): ?>
                <li class="nav-item">
                    <a class="nav-link" href="../admin/compras.php">
                        <i class="bi bi-truck"></i> Compras
                    </a>
                </li>
            <?php endif; ?>
            
            <li class="nav-item">
                <a class="nav-link" href="<?= $_SESSION['rol'] === getRolId('administrador') ? '../admin/clientes.php' : '../vendedor/clientes.php' ?>">
                    <i class="bi bi-person-lines-fill"></i> Clientes
                </a>
            </li>
            
            <?php if ($_SESSION['rol'] === getRolId('administrador')): ?>
                <li class="nav-item">
                    <a class="nav-link" href="../admin/reportes.php">
                        <i class="bi bi-graph-up"></i> Reportes
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="../admin/configuracion.php">
                        <i class="bi bi-gear"></i> Configuración
                    </a>
                </li>
            <?php endif; ?>
        </ul>
        
        <h6 class="sidebar-heading d-flex justify-content-between align-items-center px-3 mt-4 mb-1 text-muted">
            <span>Mi Cuenta</span>
        </h6>
        <ul class="nav flex-column mb-2">
            <li class="nav-item">
                <a class="nav-link" href="<?= getProfilePath($_SESSION['rol']) ?>">
                    <i class="bi bi-person"></i> Perfil
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="../change_password.php">
                    <i class="bi bi-key"></i> Cambiar Contraseña
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link text-danger" href="../logout.php">
                    <i class="bi bi-box-arrow-right"></i> Cerrar Sesión
                </a>
            </li>
        </ul>
    </div>
</div>
<?php endif; ?>