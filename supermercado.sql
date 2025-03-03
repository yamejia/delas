-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 03-03-2025 a las 19:52:52
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
-- Base de datos: `supermercadodb`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categorias`
--

CREATE TABLE `categorias` (
  `id_categoria` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `categorias`
--

INSERT INTO `categorias` (`id_categoria`, `nombre`) VALUES
(1, 'Lácteos'),
(2, 'Bebidas'),
(3, 'Carnes');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clientes`
--

CREATE TABLE `clientes` (
  `id_cliente` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `telefono` varchar(15) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `clientes`
--

INSERT INTO `clientes` (`id_cliente`, `nombre`, `telefono`, `email`) VALUES
(1, 'Juan Pérez', '111222333', 'juanperez@email.com'),
(2, 'María Gómez', '444555666', 'mariagomez@email.com'),
(3, 'Carlos Ramírez', '777888999', 'carlosramirez@email.com');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `compras`
--

CREATE TABLE `compras` (
  `id_compra` int(11) NOT NULL,
  `id_proveedor` int(11) NOT NULL,
  `fecha` date NOT NULL,
  `total` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `compras`
--

INSERT INTO `compras` (`id_compra`, `id_proveedor`, `fecha`, `total`) VALUES
(1, 1, '2024-03-01', 150.00),
(2, 2, '2024-03-02', 230.00),
(3, 3, '2024-03-03', 90.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detallecompras`
--

CREATE TABLE `detallecompras` (
  `id_detalle` int(11) NOT NULL,
  `id_compra` int(11) NOT NULL,
  `id_producto` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_compra` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `detallecompras`
--

INSERT INTO `detallecompras` (`id_detalle`, `id_compra`, `id_producto`, `cantidad`, `precio_compra`) VALUES
(1, 1, 1, 50, 1.20),
(2, 2, 2, 20, 2.00),
(3, 3, 3, 10, 7.50);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalleventas`
--

CREATE TABLE `detalleventas` (
  `id_detalle` int(11) NOT NULL,
  `id_venta` int(11) NOT NULL,
  `id_producto` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_venta` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `detalleventas`
--

INSERT INTO `detalleventas` (`id_detalle`, `id_venta`, `id_producto`, `cantidad`, `precio_venta`) VALUES
(1, 1, 1, 5, 1.50),
(2, 2, 2, 10, 2.30),
(3, 3, 3, 1, 8.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empleados`
--

CREATE TABLE `empleados` (
  `id_empleado` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `cargo` varchar(50) DEFAULT NULL,
  `telefono` varchar(15) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `empleados`
--

INSERT INTO `empleados` (`id_empleado`, `nombre`, `cargo`, `telefono`) VALUES
(1, 'Pedro López', 'Cajero', '321654987'),
(2, 'Ana Torres', 'Gerente', '987321654'),
(3, 'Luis Herrera', 'Repartidor', '456789123');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `metodospago`
--

CREATE TABLE `metodospago` (
  `id_metodo` int(11) NOT NULL,
  `tipo` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `metodospago`
--

INSERT INTO `metodospago` (`id_metodo`, `tipo`) VALUES
(1, 'Efectivo'),
(2, 'Tarjeta de Crédito'),
(3, 'Transferencia Bancaria');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos`
--

CREATE TABLE `productos` (
  `id_producto` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `stock` int(11) NOT NULL,
  `id_categoria` int(11) NOT NULL,
  `id_proveedor` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `productos`
--

INSERT INTO `productos` (`id_producto`, `nombre`, `precio`, `stock`, `id_categoria`, `id_proveedor`) VALUES
(1, 'Leche Entera', 1.50, 100, 1, 1),
(2, 'Coca-Cola 2L', 2.30, 50, 2, 2),
(3, 'Carne de Res', 8.00, 30, 3, 3);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedores`
--

CREATE TABLE `proveedores` (
  `id_proveedor` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `telefono` varchar(15) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `direccion` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `proveedores`
--

INSERT INTO `proveedores` (`id_proveedor`, `nombre`, `telefono`, `email`, `direccion`) VALUES
(1, 'Distribuidora A', '123456789', 'contacto@distA.com', 'Calle 1, Ciudad'),
(2, 'Distribuidora B', '987654321', 'contacto@distB.com', 'Calle 2, Ciudad'),
(3, 'Distribuidora C', '456123789', 'contacto@distC.com', 'Calle 3, Ciudad');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ventas`
--

CREATE TABLE `ventas` (
  `id_venta` int(11) NOT NULL,
  `id_cliente` int(11) NOT NULL,
  `id_empleado` int(11) NOT NULL,
  `id_metodo` int(11) NOT NULL,
  `fecha` date NOT NULL,
  `total` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `ventas`
--

INSERT INTO `ventas` (`id_venta`, `id_cliente`, `id_empleado`, `id_metodo`, `fecha`, `total`) VALUES
(1, 1, 1, 1, '2024-03-05', 15.00),
(2, 2, 2, 2, '2024-03-06', 23.00),
(3, 3, 3, 3, '2024-03-07', 8.00);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_clientes_compras`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_clientes_compras` (
`id_cliente` int(11)
,`nombre` varchar(100)
,`cantidad_compras` bigint(21)
,`total_gastado` decimal(32,2)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_compras`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_compras` (
`id_compra` int(11)
,`proveedor` varchar(100)
,`fecha` date
,`total` decimal(10,2)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_detallecompras`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_detallecompras` (
`id_detalle` int(11)
,`id_compra` int(11)
,`producto` varchar(100)
,`cantidad` int(11)
,`precio_compra` decimal(10,2)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_detalleventas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_detalleventas` (
`id_detalle` int(11)
,`id_venta` int(11)
,`producto` varchar(100)
,`cantidad` int(11)
,`precio_venta` decimal(10,2)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_empleados_ventas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_empleados_ventas` (
`id_empleado` int(11)
,`nombre` varchar(100)
,`cargo` varchar(50)
,`ventas_realizadas` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_productos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_productos` (
`id_producto` int(11)
,`producto` varchar(100)
,`precio` decimal(10,2)
,`stock` int(11)
,`categoria` varchar(100)
,`proveedor` varchar(100)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_productos_bajostock`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_productos_bajostock` (
`id_producto` int(11)
,`nombre` varchar(100)
,`stock` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_ventas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_ventas` (
`id_venta` int(11)
,`cliente` varchar(100)
,`empleado` varchar(100)
,`metodo_pago` varchar(50)
,`fecha` date
,`total` decimal(10,2)
);

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_clientes_compras`
--
DROP TABLE IF EXISTS `vista_clientes_compras`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_clientes_compras`  AS SELECT `c`.`id_cliente` AS `id_cliente`, `c`.`nombre` AS `nombre`, count(`v`.`id_venta`) AS `cantidad_compras`, sum(`v`.`total`) AS `total_gastado` FROM (`clientes` `c` left join `ventas` `v` on(`c`.`id_cliente` = `v`.`id_cliente`)) GROUP BY `c`.`id_cliente`, `c`.`nombre` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_compras`
--
DROP TABLE IF EXISTS `vista_compras`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_compras`  AS SELECT `c`.`id_compra` AS `id_compra`, `p`.`nombre` AS `proveedor`, `c`.`fecha` AS `fecha`, `c`.`total` AS `total` FROM (`compras` `c` join `proveedores` `p` on(`c`.`id_proveedor` = `p`.`id_proveedor`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_detallecompras`
--
DROP TABLE IF EXISTS `vista_detallecompras`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_detallecompras`  AS SELECT `dc`.`id_detalle` AS `id_detalle`, `c`.`id_compra` AS `id_compra`, `p`.`nombre` AS `producto`, `dc`.`cantidad` AS `cantidad`, `dc`.`precio_compra` AS `precio_compra` FROM ((`detallecompras` `dc` join `compras` `c` on(`dc`.`id_compra` = `c`.`id_compra`)) join `productos` `p` on(`dc`.`id_producto` = `p`.`id_producto`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_detalleventas`
--
DROP TABLE IF EXISTS `vista_detalleventas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_detalleventas`  AS SELECT `dv`.`id_detalle` AS `id_detalle`, `v`.`id_venta` AS `id_venta`, `p`.`nombre` AS `producto`, `dv`.`cantidad` AS `cantidad`, `dv`.`precio_venta` AS `precio_venta` FROM ((`detalleventas` `dv` join `ventas` `v` on(`dv`.`id_venta` = `v`.`id_venta`)) join `productos` `p` on(`dv`.`id_producto` = `p`.`id_producto`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_empleados_ventas`
--
DROP TABLE IF EXISTS `vista_empleados_ventas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_empleados_ventas`  AS SELECT `e`.`id_empleado` AS `id_empleado`, `e`.`nombre` AS `nombre`, `e`.`cargo` AS `cargo`, count(`v`.`id_venta`) AS `ventas_realizadas` FROM (`empleados` `e` left join `ventas` `v` on(`e`.`id_empleado` = `v`.`id_empleado`)) GROUP BY `e`.`id_empleado`, `e`.`nombre`, `e`.`cargo` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_productos`
--
DROP TABLE IF EXISTS `vista_productos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_productos`  AS SELECT `p`.`id_producto` AS `id_producto`, `p`.`nombre` AS `producto`, `p`.`precio` AS `precio`, `p`.`stock` AS `stock`, `c`.`nombre` AS `categoria`, `prov`.`nombre` AS `proveedor` FROM ((`productos` `p` join `categorias` `c` on(`p`.`id_categoria` = `c`.`id_categoria`)) join `proveedores` `prov` on(`p`.`id_proveedor` = `prov`.`id_proveedor`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_productos_bajostock`
--
DROP TABLE IF EXISTS `vista_productos_bajostock`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_productos_bajostock`  AS SELECT `productos`.`id_producto` AS `id_producto`, `productos`.`nombre` AS `nombre`, `productos`.`stock` AS `stock` FROM `productos` WHERE `productos`.`stock` < 10 ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_ventas`
--
DROP TABLE IF EXISTS `vista_ventas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_ventas`  AS SELECT `v`.`id_venta` AS `id_venta`, `c`.`nombre` AS `cliente`, `e`.`nombre` AS `empleado`, `mp`.`tipo` AS `metodo_pago`, `v`.`fecha` AS `fecha`, `v`.`total` AS `total` FROM (((`ventas` `v` join `clientes` `c` on(`v`.`id_cliente` = `c`.`id_cliente`)) join `empleados` `e` on(`v`.`id_empleado` = `e`.`id_empleado`)) join `metodospago` `mp` on(`v`.`id_metodo` = `mp`.`id_metodo`)) ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `categorias`
--
ALTER TABLE `categorias`
  ADD PRIMARY KEY (`id_categoria`);

--
-- Indices de la tabla `clientes`
--
ALTER TABLE `clientes`
  ADD PRIMARY KEY (`id_cliente`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indices de la tabla `compras`
--
ALTER TABLE `compras`
  ADD PRIMARY KEY (`id_compra`),
  ADD KEY `id_proveedor` (`id_proveedor`);

--
-- Indices de la tabla `detallecompras`
--
ALTER TABLE `detallecompras`
  ADD PRIMARY KEY (`id_detalle`),
  ADD KEY `id_compra` (`id_compra`),
  ADD KEY `id_producto` (`id_producto`);

--
-- Indices de la tabla `detalleventas`
--
ALTER TABLE `detalleventas`
  ADD PRIMARY KEY (`id_detalle`),
  ADD KEY `id_venta` (`id_venta`),
  ADD KEY `id_producto` (`id_producto`);

--
-- Indices de la tabla `empleados`
--
ALTER TABLE `empleados`
  ADD PRIMARY KEY (`id_empleado`);

--
-- Indices de la tabla `metodospago`
--
ALTER TABLE `metodospago`
  ADD PRIMARY KEY (`id_metodo`),
  ADD UNIQUE KEY `tipo` (`tipo`);

--
-- Indices de la tabla `productos`
--
ALTER TABLE `productos`
  ADD PRIMARY KEY (`id_producto`),
  ADD KEY `id_categoria` (`id_categoria`),
  ADD KEY `id_proveedor` (`id_proveedor`);

--
-- Indices de la tabla `proveedores`
--
ALTER TABLE `proveedores`
  ADD PRIMARY KEY (`id_proveedor`);

--
-- Indices de la tabla `ventas`
--
ALTER TABLE `ventas`
  ADD PRIMARY KEY (`id_venta`),
  ADD KEY `id_cliente` (`id_cliente`),
  ADD KEY `id_empleado` (`id_empleado`),
  ADD KEY `id_metodo` (`id_metodo`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `categorias`
--
ALTER TABLE `categorias`
  MODIFY `id_categoria` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `clientes`
--
ALTER TABLE `clientes`
  MODIFY `id_cliente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `compras`
--
ALTER TABLE `compras`
  MODIFY `id_compra` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `detallecompras`
--
ALTER TABLE `detallecompras`
  MODIFY `id_detalle` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `detalleventas`
--
ALTER TABLE `detalleventas`
  MODIFY `id_detalle` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `empleados`
--
ALTER TABLE `empleados`
  MODIFY `id_empleado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `metodospago`
--
ALTER TABLE `metodospago`
  MODIFY `id_metodo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `productos`
--
ALTER TABLE `productos`
  MODIFY `id_producto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `proveedores`
--
ALTER TABLE `proveedores`
  MODIFY `id_proveedor` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `ventas`
--
ALTER TABLE `ventas`
  MODIFY `id_venta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `compras`
--
ALTER TABLE `compras`
  ADD CONSTRAINT `compras_ibfk_1` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedores` (`id_proveedor`);

--
-- Filtros para la tabla `detallecompras`
--
ALTER TABLE `detallecompras`
  ADD CONSTRAINT `detallecompras_ibfk_1` FOREIGN KEY (`id_compra`) REFERENCES `compras` (`id_compra`),
  ADD CONSTRAINT `detallecompras_ibfk_2` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`);

--
-- Filtros para la tabla `detalleventas`
--
ALTER TABLE `detalleventas`
  ADD CONSTRAINT `detalleventas_ibfk_1` FOREIGN KEY (`id_venta`) REFERENCES `ventas` (`id_venta`),
  ADD CONSTRAINT `detalleventas_ibfk_2` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`);

--
-- Filtros para la tabla `productos`
--
ALTER TABLE `productos`
  ADD CONSTRAINT `productos_ibfk_1` FOREIGN KEY (`id_categoria`) REFERENCES `categorias` (`id_categoria`),
  ADD CONSTRAINT `productos_ibfk_2` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedores` (`id_proveedor`);

--
-- Filtros para la tabla `ventas`
--
ALTER TABLE `ventas`
  ADD CONSTRAINT `ventas_ibfk_1` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`),
  ADD CONSTRAINT `ventas_ibfk_2` FOREIGN KEY (`id_empleado`) REFERENCES `empleados` (`id_empleado`),
  ADD CONSTRAINT `ventas_ibfk_3` FOREIGN KEY (`id_metodo`) REFERENCES `metodospago` (`id_metodo`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
