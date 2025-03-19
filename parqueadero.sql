-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 19-03-2025 a las 21:39:44
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
-- Base de datos: `parkin`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizar_estado_vehiculo` (IN `p_vehiculo_id` INT, IN `p_estado` ENUM('Bueno','Regular','Malo'))   BEGIN
    UPDATE estado_vehiculo SET estado = p_estado WHERE vehiculo_id = p_vehiculo_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `agregar_usuario` (IN `p_nombre` VARCHAR(100), IN `p_correo` VARCHAR(100), IN `p_telefono` VARCHAR(15))   BEGIN
    INSERT INTO usuarios (nombre, correo, telefono) VALUES (p_nombre, p_correo, p_telefono);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `obtener_factura` (IN `p_usuario_id` INT)   BEGIN
    SELECT f.id, u.nombre, r.placa, f.monto, f.fecha
    FROM facturacion f
    JOIN usuarios u ON f.usuario_id = u.id
    JOIN registro_vehiculo r ON f.vehiculo_id = r.id
    WHERE f.usuario_id = p_usuario_id;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estado_vehiculo`
--

CREATE TABLE `estado_vehiculo` (
  `id` int(11) NOT NULL,
  `vehiculo_id` int(11) DEFAULT NULL,
  `estado` enum('Bueno','Regular','Malo') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `estado_vehiculo`
--

INSERT INTO `estado_vehiculo` (`id`, `vehiculo_id`, `estado`) VALUES
(1, 1, 'Bueno'),
(2, 2, 'Regular'),
(3, 3, 'Malo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `facturacion`
--

CREATE TABLE `facturacion` (
  `id` int(11) NOT NULL,
  `usuario_id` int(11) DEFAULT NULL,
  `vehiculo_id` int(11) DEFAULT NULL,
  `monto` decimal(10,3) DEFAULT NULL,
  `fecha` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `facturacion`
--

INSERT INTO `facturacion` (`id`, `usuario_id`, `vehiculo_id`, `monto`, `fecha`) VALUES
(1, 1, 1, 250.500, '2024-03-19 12:00:00'),
(2, 2, 2, 180.750, '2024-03-19 13:00:00'),
(3, 3, 3, 300.250, '2024-03-19 14:00:00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `puesto_vehiculo`
--

CREATE TABLE `puesto_vehiculo` (
  `id` int(11) NOT NULL,
  `numero` int(11) DEFAULT NULL,
  `estado` enum('Disponible','Ocupado') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `puesto_vehiculo`
--

INSERT INTO `puesto_vehiculo` (`id`, `numero`, `estado`) VALUES
(1, 1, 'Disponible'),
(2, 2, 'Ocupado'),
(3, 3, 'Disponible');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `registro_vehiculo`
--

CREATE TABLE `registro_vehiculo` (
  `id` int(11) NOT NULL,
  `placa` varchar(10) DEFAULT NULL,
  `marca` varchar(50) DEFAULT NULL,
  `modelo` varchar(50) DEFAULT NULL,
  `usuario_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `registro_vehiculo`
--

INSERT INTO `registro_vehiculo` (`id`, `placa`, `marca`, `modelo`, `usuario_id`) VALUES
(1, 'ABC123', 'Toyota', 'Corolla', 1),
(2, 'XYZ789', 'Honda', 'Civic', 2),
(3, 'LMN456', 'Ford', 'Focus', 3);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `servicio_lavado`
--

CREATE TABLE `servicio_lavado` (
  `id` int(11) NOT NULL,
  `vehiculo_id` int(11) DEFAULT NULL,
  `tipo` enum('Básico','Completo','Premium') DEFAULT NULL,
  `fecha` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `servicio_lavado`
--

INSERT INTO `servicio_lavado` (`id`, `vehiculo_id`, `tipo`, `fecha`) VALUES
(1, 1, 'Básico', '2024-03-19 10:00:00'),
(2, 2, 'Completo', '2024-03-19 11:00:00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id` int(11) NOT NULL,
  `nombre` varchar(100) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `telefono` varchar(15) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id`, `nombre`, `correo`, `telefono`) VALUES
(1, 'Juan Pérez', 'juan.perez@email.com', '1234567890'),
(2, 'María López', 'maria.lopez@email.com', '0987654321'),
(3, 'Carlos Ruiz', 'carlos.ruiz@email.com', '1122334455');

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_facturacion`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_facturacion` (
`id` int(11)
,`nombre` varchar(100)
,`placa` varchar(10)
,`monto` decimal(10,3)
,`fecha` datetime
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_usuarios`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_usuarios` (
`id` int(11)
,`nombre` varchar(100)
,`correo` varchar(100)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_vehiculos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_vehiculos` (
`placa` varchar(10)
,`marca` varchar(50)
,`modelo` varchar(50)
,`estado` enum('Bueno','Regular','Malo')
);

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_facturacion`
--
DROP TABLE IF EXISTS `vista_facturacion`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_facturacion`  AS SELECT `f`.`id` AS `id`, `u`.`nombre` AS `nombre`, `r`.`placa` AS `placa`, `f`.`monto` AS `monto`, `f`.`fecha` AS `fecha` FROM ((`facturacion` `f` join `usuarios` `u` on(`f`.`usuario_id` = `u`.`id`)) join `registro_vehiculo` `r` on(`f`.`vehiculo_id` = `r`.`id`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_usuarios`
--
DROP TABLE IF EXISTS `vista_usuarios`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_usuarios`  AS SELECT `usuarios`.`id` AS `id`, `usuarios`.`nombre` AS `nombre`, `usuarios`.`correo` AS `correo` FROM `usuarios` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_vehiculos`
--
DROP TABLE IF EXISTS `vista_vehiculos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_vehiculos`  AS SELECT `r`.`placa` AS `placa`, `r`.`marca` AS `marca`, `r`.`modelo` AS `modelo`, `e`.`estado` AS `estado` FROM (`registro_vehiculo` `r` join `estado_vehiculo` `e` on(`r`.`id` = `e`.`vehiculo_id`)) ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `estado_vehiculo`
--
ALTER TABLE `estado_vehiculo`
  ADD PRIMARY KEY (`id`),
  ADD KEY `vehiculo_id` (`vehiculo_id`);

--
-- Indices de la tabla `facturacion`
--
ALTER TABLE `facturacion`
  ADD PRIMARY KEY (`id`),
  ADD KEY `usuario_id` (`usuario_id`),
  ADD KEY `vehiculo_id` (`vehiculo_id`);

--
-- Indices de la tabla `puesto_vehiculo`
--
ALTER TABLE `puesto_vehiculo`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `numero` (`numero`);

--
-- Indices de la tabla `registro_vehiculo`
--
ALTER TABLE `registro_vehiculo`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `placa` (`placa`),
  ADD KEY `usuario_id` (`usuario_id`);

--
-- Indices de la tabla `servicio_lavado`
--
ALTER TABLE `servicio_lavado`
  ADD PRIMARY KEY (`id`),
  ADD KEY `vehiculo_id` (`vehiculo_id`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `correo` (`correo`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `estado_vehiculo`
--
ALTER TABLE `estado_vehiculo`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `facturacion`
--
ALTER TABLE `facturacion`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `puesto_vehiculo`
--
ALTER TABLE `puesto_vehiculo`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `registro_vehiculo`
--
ALTER TABLE `registro_vehiculo`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `servicio_lavado`
--
ALTER TABLE `servicio_lavado`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `estado_vehiculo`
--
ALTER TABLE `estado_vehiculo`
  ADD CONSTRAINT `estado_vehiculo_ibfk_1` FOREIGN KEY (`vehiculo_id`) REFERENCES `registro_vehiculo` (`id`);

--
-- Filtros para la tabla `facturacion`
--
ALTER TABLE `facturacion`
  ADD CONSTRAINT `facturacion_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`),
  ADD CONSTRAINT `facturacion_ibfk_2` FOREIGN KEY (`vehiculo_id`) REFERENCES `registro_vehiculo` (`id`);

--
-- Filtros para la tabla `registro_vehiculo`
--
ALTER TABLE `registro_vehiculo`
  ADD CONSTRAINT `registro_vehiculo_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`);

--
-- Filtros para la tabla `servicio_lavado`
--
ALTER TABLE `servicio_lavado`
  ADD CONSTRAINT `servicio_lavado_ibfk_1` FOREIGN KEY (`vehiculo_id`) REFERENCES `registro_vehiculo` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
