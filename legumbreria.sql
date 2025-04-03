-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 03-04-2025 a las 05:23:54
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `legumbreria`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `desbloquear_usuario` (IN `p_usuario_id` INT, IN `p_admin_id` INT)   BEGIN
    DECLARE v_rol_admin INT;
    
    -- Verificar que el que ejecuta es administrador
    SELECT rol_id INTO v_rol_admin FROM usuarios WHERE usuario_id = p_admin_id;
    
    IF v_rol_admin = (SELECT rol_id FROM roles WHERE nombre_rol = 'administrador') THEN
        UPDATE usuarios 
        SET cuenta_bloqueada = FALSE,
            intentos_fallidos = 0,
            fecha_bloqueo = NULL,
            fecha_desbloqueo = NULL,
            actualizado_en = CURRENT_TIMESTAMP
        WHERE usuario_id = p_usuario_id;
        
        -- Registrar en auditoría
        INSERT INTO auditoria (usuario_id, tabla_afectada, accion, registro_id, datos_anteriores, ip_address)
        VALUES (p_admin_id, 'usuarios', 'DESBLOQUEO', p_usuario_id, 
                JSON_OBJECT('admin_id', p_admin_id), NULL);
        
        SELECT 1 AS success, 'Cuenta desbloqueada exitosamente' AS message;
    ELSE
        SELECT 0 AS success, 'No tienes permisos para desbloquear cuentas' AS message;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registrar_intento_fallido` (IN `p_usuario_id` INT)   BEGIN
    DECLARE v_intentos INT;
    DECLARE v_bloqueado BOOLEAN;
    
    UPDATE usuarios 
    SET intentos_fallidos = intentos_fallidos + 1,
        actualizado_en = CURRENT_TIMESTAMP
    WHERE usuario_id = p_usuario_id;
    
    SELECT intentos_fallidos, cuenta_bloqueada INTO v_intentos, v_bloqueado
    FROM usuarios 
    WHERE usuario_id = p_usuario_id;
    
    -- Bloquear cuenta si supera 4 intentos fallidos
    IF v_intentos >= 4 AND v_bloqueado = FALSE THEN
        UPDATE usuarios 
        SET cuenta_bloqueada = TRUE,
            fecha_bloqueo = CURRENT_TIMESTAMP,
            fecha_desbloqueo = DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 30 MINUTE)
        WHERE usuario_id = p_usuario_id;
        
        -- Registrar en auditoría
        INSERT INTO auditoria (usuario_id, tabla_afectada, accion, registro_id, datos_anteriores, ip_address)
        VALUES (p_usuario_id, 'usuarios', 'BLOQUEO', p_usuario_id, 
                JSON_OBJECT('intentos_fallidos', v_intentos), NULL);
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `verificar_bloqueos_automaticos` ()   BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_usuario_id INT;
    DECLARE v_fecha_desbloqueo TIMESTAMP;
    
    -- Cursor para usuarios bloqueados con fecha de desbloqueo expirada
    DECLARE cur CURSOR FOR 
        SELECT usuario_id, fecha_desbloqueo 
        FROM usuarios 
        WHERE cuenta_bloqueada = TRUE 
        AND fecha_desbloqueo <= CURRENT_TIMESTAMP;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_usuario_id, v_fecha_desbloqueo;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Desbloquear usuario
        UPDATE usuarios 
        SET cuenta_bloqueada = FALSE,
            intentos_fallidos = 0,
            fecha_bloqueo = NULL,
            fecha_desbloqueo = NULL,
            actualizado_en = CURRENT_TIMESTAMP
        WHERE usuario_id = v_usuario_id;
        
        -- Registrar en auditoría
        INSERT INTO auditoria (tabla_afectada, accion, registro_id, datos_anteriores, ip_address)
        VALUES ('usuarios', 'DESBLOQUEO_AUTO', v_usuario_id, 
                JSON_OBJECT('fecha_desbloqueo', v_fecha_desbloqueo), NULL);
    END LOOP;
    
    CLOSE cur;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auditoria`
--

CREATE TABLE `auditoria` (
  `auditoria_id` int(11) NOT NULL,
  `usuario_id` int(11) DEFAULT NULL,
  `tabla_afectada` varchar(50) NOT NULL,
  `accion` varchar(20) NOT NULL,
  `registro_id` int(11) DEFAULT NULL,
  `datos_anteriores` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`datos_anteriores`)),
  `datos_nuevos` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`datos_nuevos`)),
  `fecha_accion` timestamp NOT NULL DEFAULT current_timestamp(),
  `ip_address` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `auditoria`
--

INSERT INTO `auditoria` (`auditoria_id`, `usuario_id`, `tabla_afectada`, `accion`, `registro_id`, `datos_anteriores`, `datos_nuevos`, `fecha_accion`, `ip_address`) VALUES
(1, NULL, 'usuarios', 'UPDATE', 1, '{\"nombre\": \"Administrador\", \"apellido\": \"Principal\", \"email\": \"admin@legumbreria.com\", \"telefono\": \"0999999999\", \"direccion\": \"Dirección principal\", \"activo\": 1}', '{\"nombre\": \"Administrador\", \"apellido\": \"Principal\", \"email\": \"yamejiaa@icloud.com\", \"telefono\": \"0999999999\", \"direccion\": \"Dirección principal\", \"activo\": 1}', '2025-04-03 03:11:33', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categorias`
--

CREATE TABLE `categorias` (
  `categoria_id` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `imagen_url` varchar(255) DEFAULT NULL,
  `activa` tinyint(1) DEFAULT 1,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `compras`
--

CREATE TABLE `compras` (
  `compra_id` int(11) NOT NULL,
  `proveedor_id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `fecha_compra` timestamp NOT NULL DEFAULT current_timestamp(),
  `subtotal` decimal(10,2) NOT NULL,
  `iva` decimal(10,3) NOT NULL,
  `total` decimal(10,3) NOT NULL,
  `estado` enum('pendiente','recibida','cancelada') DEFAULT 'recibida',
  `observaciones` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_compra`
--

CREATE TABLE `detalle_compra` (
  `detalle_id` int(11) NOT NULL,
  `compra_id` int(11) NOT NULL,
  `producto_id` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_unitario` decimal(10,3) NOT NULL,
  `subtotal` decimal(10,3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_venta`
--

CREATE TABLE `detalle_venta` (
  `detalle_id` int(11) NOT NULL,
  `venta_id` int(11) NOT NULL,
  `producto_id` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_unitario` decimal(10,2) NOT NULL,
  `descuento` decimal(5,3) DEFAULT 0.000,
  `subtotal` decimal(10,3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `historial_passwords`
--

CREATE TABLE `historial_passwords` (
  `historial_id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `historial_passwords`
--

INSERT INTO `historial_passwords` (`historial_id`, `usuario_id`, `password_hash`, `creado_en`) VALUES
(1, 1, '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '2025-04-03 03:11:33');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `historial_precios`
--

CREATE TABLE `historial_precios` (
  `historial_id` int(11) NOT NULL,
  `producto_id` int(11) NOT NULL,
  `precio_anterior` decimal(10,3) NOT NULL,
  `precio_nuevo` decimal(10,3) NOT NULL,
  `fecha_cambio` timestamp NOT NULL DEFAULT current_timestamp(),
  `usuario_id` int(11) NOT NULL,
  `motivo` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `permisos`
--

CREATE TABLE `permisos` (
  `permiso_id` int(11) NOT NULL,
  `nombre_permiso` varchar(100) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `modulo` varchar(50) NOT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `permisos`
--

INSERT INTO `permisos` (`permiso_id`, `nombre_permiso`, `descripcion`, `modulo`, `creado_en`, `actualizado_en`) VALUES
(1, 'login', 'Iniciar sesión en el sistema', 'autenticacion', '2025-04-03 02:47:01', '2025-04-03 02:47:01'),
(2, 'logout', 'Cerrar sesión', 'autenticacion', '2025-04-03 02:47:01', '2025-04-03 02:47:01'),
(3, 'cambiar_password', 'Cambiar contraseña propia', 'autenticacion', '2025-04-03 02:47:01', '2025-04-03 02:47:01'),
(4, 'ver_usuarios', 'Ver lista de usuarios', 'usuarios', '2025-04-03 02:47:01', '2025-04-03 02:47:01'),
(5, 'crear_usuarios', 'Crear nuevos usuarios', 'usuarios', '2025-04-03 02:47:01', '2025-04-03 02:47:01'),
(6, 'editar_usuarios', 'Editar usuarios existentes', 'usuarios', '2025-04-03 02:47:01', '2025-04-03 02:47:01'),
(7, 'desactivar_usuarios', 'Desactivar usuarios', 'usuarios', '2025-04-03 02:47:01', '2025-04-03 02:47:01'),
(8, 'resetear_password', 'Resetear contraseña de otros', 'usuarios', '2025-04-03 02:47:01', '2025-04-03 02:47:01'),
(9, 'desbloquear_usuarios', 'Desbloquear cuentas bloqueadas', 'usuarios', '2025-04-03 02:47:01', '2025-04-03 02:47:01'),
(10, 'ver_productos', 'Ver lista de productos', 'productos', '2025-04-03 02:47:01', '2025-04-03 02:47:01'),
(11, 'crear_productos', 'Crear nuevos productos', 'productos', '2025-04-03 02:47:01', '2025-04-03 02:47:01'),
(12, 'editar_productos', 'Editar productos existentes', 'productos', '2025-04-03 02:47:01', '2025-04-03 02:47:01'),
(13, 'ajustar_inventario', 'Ajustar cantidades de inventario', 'productos', '2025-04-03 02:47:01', '2025-04-03 02:47:01'),
(14, 'ver_historial_precios', 'Ver historial de precios', 'productos', '2025-04-03 02:47:01', '2025-04-03 02:47:01'),
(15, 'realizar_ventas', 'Realizar nuevas ventas', 'ventas', '2025-04-03 02:47:01', '2025-04-03 02:47:01'),
(16, 'anular_ventas', 'Anular ventas', 'ventas', '2025-04-03 02:47:01', '2025-04-03 02:47:01'),
(17, 'ver_ventas', 'Ver historial de ventas', 'ventas', '2025-04-03 02:47:01', '2025-04-03 02:47:01'),
(18, 'generar_reportes_ventas', 'Generar reportes de ventas', 'ventas', '2025-04-03 02:47:01', '2025-04-03 02:47:01'),
(19, 'realizar_compras', 'Realizar nuevas compras', 'compras', '2025-04-03 02:47:01', '2025-04-03 02:47:01'),
(20, 'ver_compras', 'Ver historial de compras', 'compras', '2025-04-03 02:47:01', '2025-04-03 02:47:01'),
(21, 'ver_clientes', 'Ver lista de clientes', 'clientes', '2025-04-03 02:47:01', '2025-04-03 02:47:01'),
(22, 'editar_clientes', 'Editar información de clientes', 'clientes', '2025-04-03 02:47:01', '2025-04-03 02:47:01'),
(23, 'crear_promociones', 'Crear promociones', 'promociones', '2025-04-03 02:47:01', '2025-04-03 02:47:01'),
(24, 'editar_promociones', 'Editar promociones', 'promociones', '2025-04-03 02:47:01', '2025-04-03 02:47:01');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos`
--

CREATE TABLE `productos` (
  `producto_id` int(11) NOT NULL,
  `categoria_id` int(11) NOT NULL,
  `proveedor_id` int(11) NOT NULL,
  `codigo_barras` varchar(50) DEFAULT NULL,
  `nombre` varchar(100) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `precio_compra` decimal(10,3) NOT NULL,
  `precio_venta` decimal(10,3) NOT NULL,
  `stock` int(11) NOT NULL DEFAULT 0,
  `stock_minimo` int(11) DEFAULT 10,
  `imagen_url` varchar(255) DEFAULT NULL,
  `es_perecero` tinyint(1) DEFAULT 0,
  `fecha_vencimiento` date DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Disparadores `productos`
--
DELIMITER $$
CREATE TRIGGER `after_producto_update` AFTER UPDATE ON `productos` FOR EACH ROW BEGIN
    IF NEW.precio_venta <> OLD.precio_venta THEN
        -- Registrar cambio de precio en historial
        INSERT INTO historial_precios (producto_id, precio_anterior, precio_nuevo, usuario_id, motivo)
        VALUES (
            NEW.producto_id, 
            OLD.precio_venta, 
            NEW.precio_venta, 
            IFNULL(@current_user_id, 1), 
            'Actualización de precio'
        );
    END IF;
    
    -- Registrar otros cambios en auditoría
    IF NEW.nombre <> OLD.nombre OR NEW.descripcion <> OLD.descripcion OR 
       NEW.precio_compra <> OLD.precio_compra OR NEW.stock <> OLD.stock OR 
       NEW.activo <> OLD.activo THEN
        
        INSERT INTO auditoria (usuario_id, tabla_afectada, accion, registro_id, datos_anteriores, datos_nuevos)
        VALUES (
            IFNULL(@current_user_id, NULL), 
            'productos', 
            'UPDATE', 
            NEW.producto_id,
            JSON_OBJECT(
                'nombre', OLD.nombre,
                'descripcion', OLD.descripcion,
                'precio_compra', OLD.precio_compra,
                'precio_venta', OLD.precio_venta,
                'stock', OLD.stock,
                'activo', OLD.activo
            ),
            JSON_OBJECT(
                'nombre', NEW.nombre,
                'descripcion', NEW.descripcion,
                'precio_compra', NEW.precio_compra,
                'precio_venta', NEW.precio_venta,
                'stock', NEW.stock,
                'activo', NEW.activo
            )
        );
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `promociones`
--

CREATE TABLE `promociones` (
  `promocion_id` int(11) NOT NULL,
  `producto_id` int(11) NOT NULL,
  `descuento` decimal(5,3) NOT NULL,
  `fecha_inicio` date NOT NULL,
  `fecha_fin` date NOT NULL,
  `descripcion` text DEFAULT NULL,
  `activa` tinyint(1) DEFAULT 1,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedores`
--

CREATE TABLE `proveedores` (
  `proveedor_id` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `contacto` varchar(100) NOT NULL,
  `telefono` varchar(20) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `direccion` text DEFAULT NULL,
  `ruc` varchar(20) DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `roles`
--

CREATE TABLE `roles` (
  `rol_id` int(11) NOT NULL,
  `nombre_rol` varchar(50) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `roles`
--

INSERT INTO `roles` (`rol_id`, `nombre_rol`, `descripcion`, `creado_en`, `actualizado_en`) VALUES
(1, 'administrador', 'Tiene acceso completo al sistema', '2025-04-03 02:47:00', '2025-04-03 02:47:00'),
(2, 'vendedor', 'Puede realizar ventas y consultar inventario', '2025-04-03 02:47:00', '2025-04-03 02:47:00'),
(3, 'cliente', 'Puede comprar productos y ver su historial', '2025-04-03 02:47:00', '2025-04-03 02:47:00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `roles_permisos`
--

CREATE TABLE `roles_permisos` (
  `rol_permiso_id` int(11) NOT NULL,
  `rol_id` int(11) NOT NULL,
  `permiso_id` int(11) NOT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `roles_permisos`
--

INSERT INTO `roles_permisos` (`rol_permiso_id`, `rol_id`, `permiso_id`, `creado_en`) VALUES
(1, 1, 13, '2025-04-03 02:47:01'),
(2, 1, 16, '2025-04-03 02:47:01'),
(3, 1, 3, '2025-04-03 02:47:01'),
(4, 1, 11, '2025-04-03 02:47:01'),
(5, 1, 23, '2025-04-03 02:47:01'),
(6, 1, 5, '2025-04-03 02:47:01'),
(7, 1, 7, '2025-04-03 02:47:01'),
(8, 1, 9, '2025-04-03 02:47:01'),
(9, 1, 22, '2025-04-03 02:47:01'),
(10, 1, 12, '2025-04-03 02:47:01'),
(11, 1, 24, '2025-04-03 02:47:01'),
(12, 1, 6, '2025-04-03 02:47:01'),
(13, 1, 18, '2025-04-03 02:47:01'),
(14, 1, 1, '2025-04-03 02:47:01'),
(15, 1, 2, '2025-04-03 02:47:01'),
(16, 1, 19, '2025-04-03 02:47:01'),
(17, 1, 15, '2025-04-03 02:47:01'),
(18, 1, 8, '2025-04-03 02:47:01'),
(19, 1, 21, '2025-04-03 02:47:01'),
(20, 1, 20, '2025-04-03 02:47:01'),
(21, 1, 14, '2025-04-03 02:47:01'),
(22, 1, 10, '2025-04-03 02:47:01'),
(23, 1, 4, '2025-04-03 02:47:01'),
(24, 1, 17, '2025-04-03 02:47:01'),
(32, 2, 3, '2025-04-03 02:47:01'),
(33, 2, 22, '2025-04-03 02:47:01'),
(34, 2, 1, '2025-04-03 02:47:01'),
(35, 2, 2, '2025-04-03 02:47:01'),
(36, 2, 15, '2025-04-03 02:47:01'),
(37, 2, 21, '2025-04-03 02:47:01'),
(38, 2, 10, '2025-04-03 02:47:01'),
(39, 2, 17, '2025-04-03 02:47:01'),
(47, 3, 3, '2025-04-03 02:47:01'),
(48, 3, 1, '2025-04-03 02:47:01'),
(49, 3, 2, '2025-04-03 02:47:01'),
(50, 3, 10, '2025-04-03 02:47:01'),
(51, 3, 17, '2025-04-03 02:47:01');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `usuario_id` int(11) NOT NULL,
  `rol_id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(100) NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `direccion` text DEFAULT NULL,
  `intentos_fallidos` int(11) DEFAULT 0,
  `cuenta_bloqueada` tinyint(1) DEFAULT 0,
  `fecha_bloqueo` timestamp NULL DEFAULT NULL,
  `fecha_desbloqueo` timestamp NULL DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`usuario_id`, `rol_id`, `username`, `email`, `password_hash`, `nombre`, `apellido`, `telefono`, `direccion`, `intentos_fallidos`, `cuenta_bloqueada`, `fecha_bloqueo`, `fecha_desbloqueo`, `activo`, `creado_en`, `actualizado_en`) VALUES
(1, 1, 'admin', 'yamejiaa@icloud.com', '$2y$10$ZKGXW.zWY5bJZ7W9v6n8.e5UOj7hN.8qk3VcKzLm1RtD2TQxvL1aK', 'Administrador', 'Principal', '0999999999', 'Dirección principal', 0, 0, NULL, NULL, 1, '2025-04-03 02:47:01', '2025-04-03 03:11:33'),
(2, 3, 'myshelm11', 'myshelandreamoreno4@gmail.com', '$2y$10$vK3I6m3nySKGPOgQDLJ0wOza5rebcJGh/VKQKbdeE4/sb6wHF56cC', 'Myshel', 'Moreno', '3207654512', 'Cascorba cabi', 0, 0, NULL, NULL, 1, '2025-04-03 03:07:00', '2025-04-03 03:07:00');

--
-- Disparadores `usuarios`
--
DELIMITER $$
CREATE TRIGGER `after_usuario_password_update` AFTER UPDATE ON `usuarios` FOR EACH ROW BEGIN
    IF NEW.password_hash <> OLD.password_hash THEN
        INSERT INTO historial_passwords (usuario_id, password_hash)
        VALUES (OLD.usuario_id, OLD.password_hash);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_usuario_update` AFTER UPDATE ON `usuarios` FOR EACH ROW BEGIN
    IF NEW.nombre <> OLD.nombre OR NEW.apellido <> OLD.apellido OR NEW.email <> OLD.email OR 
       NEW.telefono <> OLD.telefono OR NEW.direccion <> OLD.direccion OR NEW.activo <> OLD.activo THEN
        
        INSERT INTO auditoria (usuario_id, tabla_afectada, accion, registro_id, datos_anteriores, datos_nuevos)
        VALUES (
            IFNULL(@current_user_id, NULL), 
            'usuarios', 
            'UPDATE', 
            NEW.usuario_id,
            JSON_OBJECT(
                'nombre', OLD.nombre,
                'apellido', OLD.apellido,
                'email', OLD.email,
                'telefono', OLD.telefono,
                'direccion', OLD.direccion,
                'activo', OLD.activo
            ),
            JSON_OBJECT(
                'nombre', NEW.nombre,
                'apellido', NEW.apellido,
                'email', NEW.email,
                'telefono', NEW.telefono,
                'direccion', NEW.direccion,
                'activo', NEW.activo
            )
        );
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_usuario_insert` BEFORE INSERT ON `usuarios` FOR EACH ROW BEGIN
    -- En un sistema real, deberías usar una función de hash adecuada como password_hash()
    -- Esto es solo un ejemplo
    IF NEW.password_hash NOT LIKE '$2y$%' THEN
        SET NEW.password_hash = CONCAT('$2y$10$', SHA2(CONCAT(NEW.password_hash, 'salt_secreta'), 256));
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ventas`
--

CREATE TABLE `ventas` (
  `venta_id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `cliente_id` int(11) DEFAULT NULL,
  `fecha_venta` timestamp NOT NULL DEFAULT current_timestamp(),
  `subtotal` decimal(10,3) NOT NULL,
  `iva` decimal(10,3) NOT NULL,
  `total` decimal(10,3) NOT NULL,
  `metodo_pago` enum('efectivo','tarjeta','transferencia') NOT NULL,
  `estado` enum('pendiente','completada','cancelada') DEFAULT 'completada',
  `observaciones` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_inventario_bajo`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_inventario_bajo` (
`producto_id` int(11)
,`nombre` varchar(100)
,`stock` int(11)
,`stock_minimo` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_productos_mas_vendidos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_productos_mas_vendidos` (
`producto_id` int(11)
,`nombre` varchar(100)
,`codigo_barras` varchar(50)
,`unidades_vendidas` decimal(32,0)
,`ingresos_generados` decimal(32,3)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_ventas_diarias`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_ventas_diarias` (
`fecha` date
,`total_ventas` bigint(21)
,`ingresos_totales` decimal(32,3)
,`promedio_venta` decimal(14,7)
);

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_inventario_bajo`
--
DROP TABLE IF EXISTS `vista_inventario_bajo`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_inventario_bajo`  AS SELECT `productos`.`producto_id` AS `producto_id`, `productos`.`nombre` AS `nombre`, `productos`.`stock` AS `stock`, `productos`.`stock_minimo` AS `stock_minimo` FROM `productos` WHERE `productos`.`stock` <= `productos`.`stock_minimo` AND `productos`.`activo` = 1 ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_productos_mas_vendidos`
--
DROP TABLE IF EXISTS `vista_productos_mas_vendidos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_productos_mas_vendidos`  AS SELECT `p`.`producto_id` AS `producto_id`, `p`.`nombre` AS `nombre`, `p`.`codigo_barras` AS `codigo_barras`, sum(`dv`.`cantidad`) AS `unidades_vendidas`, sum(`dv`.`subtotal`) AS `ingresos_generados` FROM ((`productos` `p` join `detalle_venta` `dv` on(`p`.`producto_id` = `dv`.`producto_id`)) join `ventas` `v` on(`dv`.`venta_id` = `v`.`venta_id`)) WHERE `v`.`estado` = 'completada' GROUP BY `p`.`producto_id`, `p`.`nombre`, `p`.`codigo_barras` ORDER BY sum(`dv`.`cantidad`) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_ventas_diarias`
--
DROP TABLE IF EXISTS `vista_ventas_diarias`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_ventas_diarias`  AS SELECT cast(`ventas`.`fecha_venta` as date) AS `fecha`, count(0) AS `total_ventas`, sum(`ventas`.`total`) AS `ingresos_totales`, avg(`ventas`.`total`) AS `promedio_venta` FROM `ventas` WHERE `ventas`.`estado` = 'completada' GROUP BY cast(`ventas`.`fecha_venta` as date) ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `auditoria`
--
ALTER TABLE `auditoria`
  ADD PRIMARY KEY (`auditoria_id`),
  ADD KEY `usuario_id` (`usuario_id`),
  ADD KEY `idx_tabla` (`tabla_afectada`),
  ADD KEY `idx_fecha` (`fecha_accion`);

--
-- Indices de la tabla `categorias`
--
ALTER TABLE `categorias`
  ADD PRIMARY KEY (`categoria_id`),
  ADD UNIQUE KEY `nombre` (`nombre`);

--
-- Indices de la tabla `compras`
--
ALTER TABLE `compras`
  ADD PRIMARY KEY (`compra_id`),
  ADD KEY `proveedor_id` (`proveedor_id`),
  ADD KEY `usuario_id` (`usuario_id`),
  ADD KEY `idx_fecha_compra` (`fecha_compra`);

--
-- Indices de la tabla `detalle_compra`
--
ALTER TABLE `detalle_compra`
  ADD PRIMARY KEY (`detalle_id`),
  ADD KEY `compra_id` (`compra_id`),
  ADD KEY `producto_id` (`producto_id`);

--
-- Indices de la tabla `detalle_venta`
--
ALTER TABLE `detalle_venta`
  ADD PRIMARY KEY (`detalle_id`),
  ADD KEY `producto_id` (`producto_id`),
  ADD KEY `idx_venta` (`venta_id`);

--
-- Indices de la tabla `historial_passwords`
--
ALTER TABLE `historial_passwords`
  ADD PRIMARY KEY (`historial_id`),
  ADD KEY `usuario_id` (`usuario_id`);

--
-- Indices de la tabla `historial_precios`
--
ALTER TABLE `historial_precios`
  ADD PRIMARY KEY (`historial_id`),
  ADD KEY `usuario_id` (`usuario_id`),
  ADD KEY `idx_producto` (`producto_id`),
  ADD KEY `idx_fecha` (`fecha_cambio`);

--
-- Indices de la tabla `permisos`
--
ALTER TABLE `permisos`
  ADD PRIMARY KEY (`permiso_id`),
  ADD UNIQUE KEY `nombre_permiso` (`nombre_permiso`);

--
-- Indices de la tabla `productos`
--
ALTER TABLE `productos`
  ADD PRIMARY KEY (`producto_id`),
  ADD UNIQUE KEY `codigo_barras` (`codigo_barras`),
  ADD KEY `idx_nombre` (`nombre`),
  ADD KEY `idx_categoria` (`categoria_id`),
  ADD KEY `idx_proveedor` (`proveedor_id`);

--
-- Indices de la tabla `promociones`
--
ALTER TABLE `promociones`
  ADD PRIMARY KEY (`promocion_id`),
  ADD KEY `producto_id` (`producto_id`),
  ADD KEY `idx_fechas` (`fecha_inicio`,`fecha_fin`);

--
-- Indices de la tabla `proveedores`
--
ALTER TABLE `proveedores`
  ADD PRIMARY KEY (`proveedor_id`);

--
-- Indices de la tabla `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`rol_id`),
  ADD UNIQUE KEY `nombre_rol` (`nombre_rol`);

--
-- Indices de la tabla `roles_permisos`
--
ALTER TABLE `roles_permisos`
  ADD PRIMARY KEY (`rol_permiso_id`),
  ADD UNIQUE KEY `rol_id` (`rol_id`,`permiso_id`),
  ADD KEY `permiso_id` (`permiso_id`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`usuario_id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `rol_id` (`rol_id`);

--
-- Indices de la tabla `ventas`
--
ALTER TABLE `ventas`
  ADD PRIMARY KEY (`venta_id`),
  ADD KEY `cliente_id` (`cliente_id`),
  ADD KEY `idx_fecha_venta` (`fecha_venta`),
  ADD KEY `idx_usuario` (`usuario_id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `auditoria`
--
ALTER TABLE `auditoria`
  MODIFY `auditoria_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `categorias`
--
ALTER TABLE `categorias`
  MODIFY `categoria_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `compras`
--
ALTER TABLE `compras`
  MODIFY `compra_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `detalle_compra`
--
ALTER TABLE `detalle_compra`
  MODIFY `detalle_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `detalle_venta`
--
ALTER TABLE `detalle_venta`
  MODIFY `detalle_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `historial_passwords`
--
ALTER TABLE `historial_passwords`
  MODIFY `historial_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `historial_precios`
--
ALTER TABLE `historial_precios`
  MODIFY `historial_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `permisos`
--
ALTER TABLE `permisos`
  MODIFY `permiso_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT de la tabla `productos`
--
ALTER TABLE `productos`
  MODIFY `producto_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `promociones`
--
ALTER TABLE `promociones`
  MODIFY `promocion_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `proveedores`
--
ALTER TABLE `proveedores`
  MODIFY `proveedor_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `roles`
--
ALTER TABLE `roles`
  MODIFY `rol_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `roles_permisos`
--
ALTER TABLE `roles_permisos`
  MODIFY `rol_permiso_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=54;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `usuario_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `ventas`
--
ALTER TABLE `ventas`
  MODIFY `venta_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `auditoria`
--
ALTER TABLE `auditoria`
  ADD CONSTRAINT `auditoria_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`usuario_id`);

--
-- Filtros para la tabla `compras`
--
ALTER TABLE `compras`
  ADD CONSTRAINT `compras_ibfk_1` FOREIGN KEY (`proveedor_id`) REFERENCES `proveedores` (`proveedor_id`),
  ADD CONSTRAINT `compras_ibfk_2` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`usuario_id`);

--
-- Filtros para la tabla `detalle_compra`
--
ALTER TABLE `detalle_compra`
  ADD CONSTRAINT `detalle_compra_ibfk_1` FOREIGN KEY (`compra_id`) REFERENCES `compras` (`compra_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `detalle_compra_ibfk_2` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`producto_id`);

--
-- Filtros para la tabla `detalle_venta`
--
ALTER TABLE `detalle_venta`
  ADD CONSTRAINT `detalle_venta_ibfk_1` FOREIGN KEY (`venta_id`) REFERENCES `ventas` (`venta_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `detalle_venta_ibfk_2` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`producto_id`);

--
-- Filtros para la tabla `historial_passwords`
--
ALTER TABLE `historial_passwords`
  ADD CONSTRAINT `historial_passwords_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`usuario_id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `historial_precios`
--
ALTER TABLE `historial_precios`
  ADD CONSTRAINT `historial_precios_ibfk_1` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`producto_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `historial_precios_ibfk_2` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`usuario_id`);

--
-- Filtros para la tabla `productos`
--
ALTER TABLE `productos`
  ADD CONSTRAINT `productos_ibfk_1` FOREIGN KEY (`categoria_id`) REFERENCES `categorias` (`categoria_id`),
  ADD CONSTRAINT `productos_ibfk_2` FOREIGN KEY (`proveedor_id`) REFERENCES `proveedores` (`proveedor_id`);

--
-- Filtros para la tabla `promociones`
--
ALTER TABLE `promociones`
  ADD CONSTRAINT `promociones_ibfk_1` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`producto_id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `roles_permisos`
--
ALTER TABLE `roles_permisos`
  ADD CONSTRAINT `roles_permisos_ibfk_1` FOREIGN KEY (`rol_id`) REFERENCES `roles` (`rol_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `roles_permisos_ibfk_2` FOREIGN KEY (`permiso_id`) REFERENCES `permisos` (`permiso_id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD CONSTRAINT `usuarios_ibfk_1` FOREIGN KEY (`rol_id`) REFERENCES `roles` (`rol_id`);

--
-- Filtros para la tabla `ventas`
--
ALTER TABLE `ventas`
  ADD CONSTRAINT `ventas_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`usuario_id`),
  ADD CONSTRAINT `ventas_ibfk_2` FOREIGN KEY (`cliente_id`) REFERENCES `usuarios` (`usuario_id`);

DELIMITER $$
--
-- Eventos
--
CREATE DEFINER=`root`@`localhost` EVENT `evento_desbloqueo_automatico` ON SCHEDULE EVERY 5 MINUTE STARTS '2025-04-02 21:47:52' ON COMPLETION NOT PRESERVE ENABLE DO CALL verificar_bloqueos_automaticos()$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
