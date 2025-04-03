<?php
require_once '../includes/config.php';

// Verificar rol de cliente
if (!isset($_SESSION['user_id']) || $_SESSION['rol'] !== getRolId('cliente')) {
    header('Location: ../login.php');
    exit();
}

// Obtener nombre del rol
$rol = getRolNombre($_SESSION['rol']);
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mi Cuenta - <?= APP_NAME ?></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="../assets/css/styles.css" rel="stylesheet">
</head>
<body>
    <?php include '../includes/navbar.php'; ?>
    
    <div class="container">
        <div class="row">
            <div class="col-md-3">
                <div class="card mb-4">
                    <div class="card-header bg-primary text-white">
                        <h5 class="card-title mb-0">Mi Cuenta</h5>
                    </div>
                    <div class="list-group list-group-flush">
                        <a href="dashboard.php" class="list-group-item list-group-item-action active">Resumen</a>
                        <a href="perfil.php" class="list-group-item list-group-item-action">Mi Perfil</a>
                        <a href="pedidos.php" class="list-group-item list-group-item-action">Mis Compras</a>
                        <a href="../change_password.php" class="list-group-item list-group-item-action">Cambiar Contraseña</a>
                        <a href="../logout.php" class="list-group-item list-group-item-action text-danger">Cerrar Sesión</a>
                    </div>
                </div>
            </div>
            
            <div class="col-md-9">
                <div class="card mb-4">
                    <div class="card-header">
                        <h5 class="mb-0">Bienvenido, <?= htmlspecialchars($_SESSION['nombre']) ?></h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6 mb-4">
                                <div class="card bg-light">
                                    <div class="card-body">
                                        <h6 class="card-title">Información de Contacto</h6>
                                        <?php
                                        $stmt = $pdo->prepare("SELECT email, telefono, direccion FROM usuarios WHERE usuario_id = ?");
                                        $stmt->execute([$_SESSION['user_id']]);
                                        $user = $stmt->fetch(PDO::FETCH_ASSOC);
                                        ?>
                                        <p class="card-text">
                                            <strong>Email:</strong> <?= htmlspecialchars($user['email']) ?><br>
                                            <strong>Teléfono:</strong> <?= htmlspecialchars($user['telefono'] ?? 'No registrado') ?><br>
                                            <strong>Dirección:</strong> <?= htmlspecialchars($user['direccion'] ?? 'No registrada') ?>
                                        </p>
                                        <a href="perfil.php" class="btn btn-sm btn-primary">Editar Perfil</a>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="col-md-6 mb-4">
                                <div class="card bg-light">
                                    <div class="card-body">
                                        <h6 class="card-title">Mis Últimas Compras</h6>
                                        <?php
                                        $stmt = $pdo->prepare("SELECT COUNT(*) FROM ventas WHERE cliente_id = ?");
                                        $stmt->execute([$_SESSION['user_id']]);
                                        $total_compras = $stmt->fetchColumn();
                                        ?>
                                        <p class="card-text">
                                            <strong>Total de compras:</strong> <?= $total_compras ?>
                                        </p>
                                        <a href="pedidos.php" class="btn btn-sm btn-primary">Ver Historial</a>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="card">
                            <div class="card-header">
                                <h6 class="mb-0">Últimas Compras</h6>
                            </div>
                            <div class="card-body">
                                <?php
                                $stmt = $pdo->prepare("SELECT v.venta_id, v.fecha_venta, v.total, v.estado 
                                                      FROM ventas v 
                                                      WHERE v.cliente_id = ? 
                                                      ORDER BY v.fecha_venta DESC 
                                                      LIMIT 5");
                                $stmt->execute([$_SESSION['user_id']]);
                                
                                if ($stmt->rowCount() > 0) {
                                    echo '<div class="table-responsive">
                                        <table class="table table-sm">
                                            <thead>
                                                <tr>
                                                    <th>Pedido #</th>
                                                    <th>Fecha</th>
                                                    <th>Total</th>
                                                    <th>Estado</th>
                                                    <th>Acciones</th>
                                                </tr>
                                            </thead>
                                            <tbody>';
                                    
                                    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                                        echo "<tr>
                                            <td>{$row['venta_id']}</td>
                                            <td>" . date('d/m/Y', strtotime($row['fecha_venta'])) . "</td>
                                            <td>\${$row['total']}</td>
                                            <td><span class='badge bg-" . ($row['estado'] == 'completada' ? 'success' : 'warning') . "'>{$row['estado']}</span></td>
                                            <td><a href='pedidos/detalle.php?id={$row['venta_id']}' class='btn btn-sm btn-outline-primary'>Ver</a></td>
                                        </tr>";
                                    }
                                    
                                    echo '</tbody>
                                        </table>
                                    </div>';
                                } else {
                                    echo '<div class="alert alert-info">No has realizado ninguna compra aún.</div>';
                                }
                                ?>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="../assets/js/cliente.js"></script>
</body>
</html>