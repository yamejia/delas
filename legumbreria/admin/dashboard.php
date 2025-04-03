<?php
require_once '../includes/config.php';

// Verificar rol de administrador
if (!isset($_SESSION['user_id']) || $_SESSION['rol'] !== getRolId('administrador')) {
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
    <title>Admin Dashboard - <?= APP_NAME ?></title>
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
                    <h1 class="h2">Panel de Administración</h1>
                </div>
                
                <div class="row">
                    <div class="col-md-4 mb-4">
                        <div class="card text-white bg-primary">
                            <div class="card-body">
                                <h5 class="card-title">Usuarios Registrados</h5>
                                <?php
                                $stmt = $pdo->query("SELECT COUNT(*) FROM usuarios");
                                $count = $stmt->fetchColumn();
                                ?>
                                <p class="card-text display-4"><?= $count ?></p>
                                <a href="usuarios.php" class="text-white">Ver más <i class="bi bi-arrow-right"></i></a>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-4 mb-4">
                        <div class="card text-white bg-success">
                            <div class="card-body">
                                <h5 class="card-title">Productos en Inventario</h5>
                                <?php
                                $stmt = $pdo->query("SELECT COUNT(*) FROM productos WHERE activo = 1");
                                $count = $stmt->fetchColumn();
                                ?>
                                <p class="card-text display-4"><?= $count ?></p>
                                <a href="productos.php" class="text-white">Ver más <i class="bi bi-arrow-right"></i></a>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-4 mb-4">
                        <div class="card text-white bg-info">
                            <div class="card-body">
                                <h5 class="card-title">Ventas Hoy</h5>
                                <?php
                                $stmt = $pdo->prepare("SELECT COUNT(*) FROM ventas 
                                                      WHERE DATE(fecha_venta) = CURDATE() 
                                                      AND estado = 'completada'");
                                $stmt->execute();
                                $count = $stmt->fetchColumn();
                                ?>
                                <p class="card-text display-4"><?= $count ?></p>
                                <a href="ventas.php" class="text-white">Ver más <i class="bi bi-arrow-right"></i></a>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="row">
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header">
                                <h5>Últimas Ventas</h5>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-striped table-sm">
                                        <thead>
                                            <tr>
                                                <th>ID</th>
                                                <th>Fecha</th>
                                                <th>Total</th>
                                                <th>Estado</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <?php
                                            $stmt = $pdo->query("SELECT v.venta_id, v.fecha_venta, v.total, v.estado 
                                                               FROM ventas v 
                                                               ORDER BY v.fecha_venta DESC 
                                                               LIMIT 5");
                                            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                                                echo "<tr>
                                                    <td>{$row['venta_id']}</td>
                                                    <td>" . date('d/m/Y H:i', strtotime($row['fecha_venta'])) . "</td>
                                                    <td>\${$row['total']}</td>
                                                    <td><span class='badge bg-" . ($row['estado'] == 'completada' ? 'success' : 'warning') . "'>{$row['estado']}</span></td>
                                                </tr>";
                                            }
                                            ?>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header">
                                <h5>Productos con Stock Bajo</h5>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-striped table-sm">
                                        <thead>
                                            <tr>
                                                <th>Producto</th>
                                                <th>Stock</th>
                                                <th>Mínimo</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <?php
                                            $stmt = $pdo->query("SELECT p.nombre, p.stock, p.stock_minimo 
                                                               FROM productos p 
                                                               WHERE p.stock <= p.stock_minimo 
                                                               AND p.activo = 1 
                                                               ORDER BY p.stock ASC 
                                                               LIMIT 5");
                                            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                                                echo "<tr>
                                                    <td>{$row['nombre']}</td>
                                                    <td class='" . ($row['stock'] == 0 ? 'text-danger fw-bold' : 'text-warning') . "'>{$row['stock']}</td>
                                                    <td>{$row['stock_minimo']}</td>
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
    <script src="../assets/js/admin.js"></script>
</body>
</html>