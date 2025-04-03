<?php
require_once '../includes/config.php';

// Verificar rol de vendedor
if (!isset($_SESSION['user_id']) || $_SESSION['rol'] !== getRolId('vendedor')) {
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
    <title>Vendedor Dashboard - <?= APP_NAME ?></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="../assets/css/styles.css" rel="stylesheet">
</head>
<body>
    <?php include '../includes/navbar.php'; ?>
    
    <div class="container-fluid">
        <div class="row">
            <?php include '../includes/sidebar.php'; ?>
            
            <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">Panel de Vendedor</h1>
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <a href="nueva_venta.php" class="btn btn-success">
                            <i class="bi bi-cart-plus"></i> Nueva Venta
                        </a>
                    </div>
                </div>
                
                <div class="row">
                    <div class="col-md-4 mb-4">
                        <div class="card text-white bg-primary">
                            <div class="card-body">
                                <h5 class="card-title">Ventas Hoy</h5>
                                <?php
                                $stmt = $pdo->prepare("SELECT COUNT(*) FROM ventas 
                                                      WHERE DATE(fecha_venta) = CURDATE() 
                                                      AND usuario_id = :user_id
                                                      AND estado = 'completada'");
                                $stmt->bindParam(':user_id', $_SESSION['user_id']);
                                $stmt->execute();
                                $count = $stmt->fetchColumn();
                                ?>
                                <p class="card-text display-4"><?= $count ?></p>
                                <a href="ventas.php" class="text-white">Ver más <i class="bi bi-arrow-right"></i></a>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-4 mb-4">
                        <div class="card text-white bg-success">
                            <div class="card-body">
                                <h5 class="card-title">Total Vendido Hoy</h5>
                                <?php
                                $stmt = $pdo->prepare("SELECT SUM(total) FROM ventas 
                                                      WHERE DATE(fecha_venta) = CURDATE() 
                                                      AND usuario_id = :user_id
                                                      AND estado = 'completada'");
                                $stmt->bindParam(':user_id', $_SESSION['user_id']);
                                $stmt->execute();
                                $total = $stmt->fetchColumn();
                                ?>
                                <p class="card-text display-4">$<?= number_format($total, 2) ?></p>
                                <a href="ventas.php" class="text-white">Ver más <i class="bi bi-arrow-right"></i></a>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-4 mb-4">
                        <div class="card text-white bg-info">
                            <div class="card-body">
                                <h5 class="card-title">Productos en Stock</h5>
                                <?php
                                $stmt = $pdo->query("SELECT COUNT(*) FROM productos WHERE activo = 1 AND stock > 0");
                                $count = $stmt->fetchColumn();
                                ?>
                                <p class="card-text display-4"><?= $count ?></p>
                                <a href="productos.php" class="text-white">Ver más <i class="bi bi-arrow-right"></i></a>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="row">
                    <div class="col-md-12">
                        <div class="card">
                            <div class="card-header">
                                <h5>Mis Últimas Ventas</h5>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-striped table-sm">
                                        <thead>
                                            <tr>
                                                <th>ID</th>
                                                <th>Fecha</th>
                                                <th>Cliente</th>
                                                <th>Total</th>
                                                <th>Estado</th>
                                                <th>Acciones</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <?php
                                            $stmt = $pdo->prepare("SELECT v.venta_id, v.fecha_venta, v.total, v.estado, u.nombre, u.apellido 
                                                                 FROM ventas v
                                                                 LEFT JOIN usuarios u ON v.cliente_id = u.usuario_id
                                                                 WHERE v.usuario_id = :user_id
                                                                 ORDER BY v.fecha_venta DESC 
                                                                 LIMIT 10");
                                            $stmt->bindParam(':user_id', $_SESSION['user_id']);
                                            $stmt->execute();
                                            
                                            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                                                $cliente = $row['nombre'] ? "{$row['nombre']} {$row['apellido']}" : "Consumidor Final";
                                                echo "<tr>
                                                    <td>{$row['venta_id']}</td>
                                                    <td>" . date('d/m/Y H:i', strtotime($row['fecha_venta'])) . "</td>
                                                    <td>{$cliente}</td>
                                                    <td>\${$row['total']}</td>
                                                    <td><span class='badge bg-" . ($row['estado'] == 'completada' ? 'success' : 'warning') . "'>{$row['estado']}</span></td>
                                                    <td>
                                                        <a href='ventas/detalle.php?id={$row['venta_id']}' class='btn btn-sm btn-primary'>Ver</a>
                                                    </td>
                                                </tr>";
                                            }
                                            ?>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="../assets/js/vendedor.js"></script>
</body>
</html>