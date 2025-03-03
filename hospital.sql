-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 03-03-2025 a las 19:53:31
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
-- Base de datos: `hospital_eps`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `MostrarTodasLasVistas` ()   BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE vista_nombre VARCHAR(255);
    DECLARE cur CURSOR FOR 
        SELECT TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS 
        WHERE TABLE_SCHEMA = 'hospital_eps';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    leer_vistas: LOOP
        FETCH cur INTO vista_nombre;
        IF done THEN
            LEAVE leer_vistas;
        END IF;
        
        SET @query = CONCAT('SELECT * FROM ', vista_nombre);
        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP;

    CLOSE cur;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ObtenerCitasMedicas` (IN `p_ID_Doctor` INT, IN `p_ID_Paciente` INT, IN `p_Fecha_Inicio` DATE, IN `p_Fecha_Fin` DATE, IN `p_Estado` VARCHAR(50))   BEGIN
    SELECT 
        c.ID AS ID_Cita, 
        c.Fecha, 
        c.Hora, 
        d.Nombre AS Nombre_Doctor, 
        d.Apellido AS Apellido_Doctor,
        p.Nombre AS Nombre_Paciente, 
        p.Apellido AS Apellido_Paciente,
        c.Estado
    FROM Citas c
    JOIN Doctores d ON c.ID_Doctor = d.ID
    JOIN Pacientes p ON c.ID_Paciente = p.ID
    WHERE 
        (p_ID_Doctor IS NULL OR c.ID_Doctor = p_ID_Doctor) AND
        (p_ID_Paciente IS NULL OR c.ID_Paciente = p_ID_Paciente) AND
        (p_Fecha_Inicio IS NULL OR c.Fecha >= p_Fecha_Inicio) AND
        (p_Fecha_Fin IS NULL OR c.Fecha <= p_Fecha_Fin) AND
        (p_Estado IS NULL OR c.Estado = p_Estado)
    ORDER BY c.Fecha DESC, c.Hora DESC;
    
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cirugias`
--

CREATE TABLE `cirugias` (
  `ID` int(11) NOT NULL,
  `ID_Paciente` int(11) DEFAULT NULL,
  `ID_Doctor` int(11) DEFAULT NULL,
  `Fecha` date NOT NULL,
  `Tipo` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `cirugias`
--

INSERT INTO `cirugias` (`ID`, `ID_Paciente`, `ID_Doctor`, `Fecha`, `Tipo`) VALUES
(1, 1, 1, '2025-04-10', 'Bypass Coronario'),
(2, 2, 2, '2025-05-15', 'Apendicectomía'),
(3, 3, 3, '2025-06-20', 'Resección de tumor cerebral');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `citas`
--

CREATE TABLE `citas` (
  `ID` int(11) NOT NULL,
  `ID_Paciente` int(11) DEFAULT NULL,
  `ID_Doctor` int(11) DEFAULT NULL,
  `Fecha` date NOT NULL,
  `Hora` time NOT NULL,
  `Estado` enum('Pendiente','Completada','Cancelada') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `citas`
--

INSERT INTO `citas` (`ID`, `ID_Paciente`, `ID_Doctor`, `Fecha`, `Hora`, `Estado`) VALUES
(1, 1, 1, '2025-03-01', '10:00:00', 'Pendiente'),
(2, 2, 2, '2025-03-02', '11:30:00', 'Pendiente'),
(3, 3, 3, '2025-03-03', '15:00:00', 'Pendiente');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `doctores`
--

CREATE TABLE `doctores` (
  `ID` int(11) NOT NULL,
  `Nombre` varchar(100) NOT NULL,
  `Apellido` varchar(100) NOT NULL,
  `Especialidad` varchar(100) NOT NULL,
  `Teléfono` varchar(20) NOT NULL,
  `Correo` varchar(100) NOT NULL,
  `ID_EPS` int(11) DEFAULT NULL,
  `Años_Experiencia` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `doctores`
--

INSERT INTO `doctores` (`ID`, `Nombre`, `Apellido`, `Especialidad`, `Teléfono`, `Correo`, `ID_EPS`, `Años_Experiencia`) VALUES
(1, 'Ana', 'Ramírez', 'Cardiología', '3154321876', 'ana.ramirez@mail.com', 1, 10),
(2, 'Luis', 'Martínez', 'Pediatría', '3106543219', 'luis.martinez@mail.com', 1, 7),
(3, 'Elena', 'Fernández', 'Neurología', '3056784321', 'elena.fernandez@mail.com', 1, 3);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `enfermeros`
--

CREATE TABLE `enfermeros` (
  `ID` int(11) NOT NULL,
  `Nombre` varchar(100) NOT NULL,
  `Apellido` varchar(100) NOT NULL,
  `Teléfono` varchar(20) NOT NULL,
  `Correo` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `enfermeros`
--

INSERT INTO `enfermeros` (`ID`, `Nombre`, `Apellido`, `Teléfono`, `Correo`) VALUES
(1, 'Pedro', 'López', '3123456789', 'pedro.lopez@mail.com'),
(2, 'Lucía', 'García', '3229876543', 'lucia.garcia@mail.com'),
(3, 'Fernando', 'Díaz', '3007654321', 'fernando.diaz@mail.com');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `eps`
--

CREATE TABLE `eps` (
  `ID` int(11) NOT NULL,
  `Nombre` varchar(100) NOT NULL,
  `Dirección` varchar(255) NOT NULL,
  `Teléfono` varchar(20) NOT NULL,
  `Correo` varchar(100) NOT NULL,
  `Ciudad` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `eps`
--

INSERT INTO `eps` (`ID`, `Nombre`, `Dirección`, `Teléfono`, `Correo`, `Ciudad`) VALUES
(1, 'NUEVA EPS', 'Calle 123, Bogotá', '3001234567', 'contacto@nuevaeps.com', 'Bogotá');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `facturacion`
--

CREATE TABLE `facturacion` (
  `ID` int(11) NOT NULL,
  `ID_Paciente` int(11) DEFAULT NULL,
  `Monto` decimal(10,2) NOT NULL,
  `Fecha` date NOT NULL,
  `Estado` enum('Pagado','Pendiente') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `facturacion`
--

INSERT INTO `facturacion` (`ID`, `ID_Paciente`, `Monto`, `Fecha`, `Estado`) VALUES
(1, 1, 150000.00, '2025-02-25', 'Pagado'),
(2, 2, 200000.00, '2025-02-26', 'Pendiente'),
(3, 3, 175000.00, '2025-02-27', 'Pagado');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `habitaciones`
--

CREATE TABLE `habitaciones` (
  `ID` int(11) NOT NULL,
  `Numero` varchar(10) NOT NULL,
  `Tipo` enum('General','Privada','UCI') NOT NULL,
  `Estado` enum('Disponible','Ocupada','Mantenimiento') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `habitaciones`
--

INSERT INTO `habitaciones` (`ID`, `Numero`, `Tipo`, `Estado`) VALUES
(1, '101', 'General', 'Disponible'),
(2, '202', 'Privada', 'Ocupada'),
(3, '303', 'UCI', 'Mantenimiento');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `historias_clinicas`
--

CREATE TABLE `historias_clinicas` (
  `ID` int(11) NOT NULL,
  `ID_Paciente` int(11) DEFAULT NULL,
  `Diagnóstico` text NOT NULL,
  `Tratamiento` text NOT NULL,
  `Fecha` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `historias_clinicas`
--

INSERT INTO `historias_clinicas` (`ID`, `ID_Paciente`, `Diagnóstico`, `Tratamiento`, `Fecha`) VALUES
(1, 1, 'Hipertensión arterial', 'Dieta baja en sodio y medicamento Losartán', '2025-02-20'),
(2, 2, 'Asma', 'Inhalador de Salbutamol y control anual', '2025-02-18'),
(3, 3, 'Migraña crónica', 'Analgésicos y cambio de hábitos de sueño', '2025-02-22');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `hospitalizaciones`
--

CREATE TABLE `hospitalizaciones` (
  `ID` int(11) NOT NULL,
  `ID_Paciente` int(11) NOT NULL,
  `Fecha_Ingreso` date NOT NULL,
  `Fecha_Egreso` date NOT NULL,
  `Dias_Hospitalizacion` int(11) GENERATED ALWAYS AS (to_days(`Fecha_Egreso`) - to_days(`Fecha_Ingreso`)) STORED,
  `ID_Doctor` int(11) NOT NULL,
  `Habitacion` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `hospitalizaciones`
--

INSERT INTO `hospitalizaciones` (`ID`, `ID_Paciente`, `Fecha_Ingreso`, `Fecha_Egreso`, `ID_Doctor`, `Habitacion`) VALUES
(1, 1, '2025-02-10', '2025-02-15', 1, ''),
(2, 2, '2025-02-12', '2025-02-18', 2, ''),
(3, 3, '2025-02-15', '2025-02-20', 2, ''),
(4, 1, '2025-01-05', '2025-01-10', 3, ''),
(5, 2, '2025-01-20', '2025-01-25', 1, '');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `medicamentos`
--

CREATE TABLE `medicamentos` (
  `ID` int(11) NOT NULL,
  `Nombre` varchar(100) NOT NULL,
  `Descripción` text NOT NULL,
  `Dosis` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `medicamentos`
--

INSERT INTO `medicamentos` (`ID`, `Nombre`, `Descripción`, `Dosis`) VALUES
(1, 'Paracetamol', 'Analgésico y antipirético', '500mg cada 8 horas'),
(2, 'Ibuprofeno', 'Antiinflamatorio y analgésico', '400mg cada 6 horas'),
(3, 'Amoxicilina', 'Antibiótico de amplio espectro', '500mg cada 12 horas');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pacientes`
--

CREATE TABLE `pacientes` (
  `ID` int(11) NOT NULL,
  `Nombre` varchar(100) NOT NULL,
  `Apellido` varchar(100) NOT NULL,
  `FechaNacimiento` date NOT NULL,
  `Género` enum('Masculino','Femenino','Otro') NOT NULL,
  `Dirección` varchar(255) NOT NULL,
  `Teléfono` varchar(20) NOT NULL,
  `Correo` varchar(100) NOT NULL,
  `TipoSangre` varchar(5) NOT NULL,
  `ID_EPS` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `pacientes`
--

INSERT INTO `pacientes` (`ID`, `Nombre`, `Apellido`, `FechaNacimiento`, `Género`, `Dirección`, `Teléfono`, `Correo`, `TipoSangre`, `ID_EPS`) VALUES
(1, 'Juan', 'Pérez', '1985-06-15', 'Masculino', 'Calle 45, Bogotá', '3112345678', 'juan.perez@mail.com', 'O+', 1),
(2, 'María', 'Gómez', '1990-08-21', 'Femenino', 'Carrera 12, Medellín', '3208765432', 'maria.gomez@mail.com', 'A-', 1),
(3, 'Carlos', 'Rodríguez', '1978-02-10', 'Masculino', 'Avenida 9, Cali', '3009876543', 'carlos.rod@mail.com', 'B+', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `prescripciones`
--

CREATE TABLE `prescripciones` (
  `ID` int(11) NOT NULL,
  `ID_Paciente` int(11) NOT NULL,
  `ID_Doctor` int(11) NOT NULL,
  `ID_Medicamento` int(11) NOT NULL,
  `Dosis` varchar(50) NOT NULL,
  `Fecha_Prescripcion` date NOT NULL,
  `Fecha` date NOT NULL DEFAULT '2025-01-01'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `prescripciones`
--

INSERT INTO `prescripciones` (`ID`, `ID_Paciente`, `ID_Doctor`, `ID_Medicamento`, `Dosis`, `Fecha_Prescripcion`, `Fecha`) VALUES
(1, 1, 1, 1, '500mg cada 8 horas', '2025-02-10', '2025-01-01'),
(2, 2, 2, 2, '400mg cada 6 horas', '2025-02-12', '2025-01-01'),
(3, 3, 3, 3, '500mg cada 12 horas', '2025-02-14', '2025-01-01'),
(4, 1, 1, 2, '400mg cada 6 horas', '2025-02-15', '2025-01-01'),
(5, 2, 2, 1, '500mg cada 8 horas', '2025-02-16', '2025-01-01');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `procedimientos`
--

CREATE TABLE `procedimientos` (
  `ID` int(11) NOT NULL,
  `Nombre` varchar(100) NOT NULL,
  `Descripción` text NOT NULL,
  `Costo` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `procedimientos`
--

INSERT INTO `procedimientos` (`ID`, `Nombre`, `Descripción`, `Costo`) VALUES
(1, 'Radiografía de Tórax', 'Imagen para evaluar pulmones y corazón', 50000.00),
(2, 'Electrocardiograma', 'Registro de la actividad eléctrica del corazón', 70000.00),
(3, 'Resonancia Magnética', 'Exploración detallada de tejidos y órganos', 250000.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `procedimientos_realizados`
--

CREATE TABLE `procedimientos_realizados` (
  `ID` int(11) NOT NULL,
  `ID_Enfermero` int(11) NOT NULL,
  `ID_Procedimiento` int(11) NOT NULL,
  `ID_Paciente` int(11) NOT NULL,
  `Fecha` date NOT NULL,
  `ID_Doctor` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `procedimientos_realizados`
--

INSERT INTO `procedimientos_realizados` (`ID`, `ID_Enfermero`, `ID_Procedimiento`, `ID_Paciente`, `Fecha`, `ID_Doctor`) VALUES
(1, 1, 1, 1, '2025-02-15', 1),
(2, 2, 2, 2, '2025-02-16', 1),
(3, 3, 3, 3, '2025-02-17', 1),
(4, 1, 2, 1, '2025-02-18', 1),
(5, 2, 3, 2, '2025-02-19', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos`
--

CREATE TABLE `productos` (
  `ID` int(11) NOT NULL,
  `Nombre` varchar(100) NOT NULL,
  `Descripción` text NOT NULL,
  `Precio` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `productos`
--

INSERT INTO `productos` (`ID`, `Nombre`, `Descripción`, `Precio`) VALUES
(1, 'Paracetamol', 'Analgésico y antipirético', 5000.00),
(2, 'Ibuprofeno', 'Antiinflamatorio no esteroideo', 8000.00),
(3, 'Amoxicilina', 'Antibiótico de amplio espectro', 12000.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedores`
--

CREATE TABLE `proveedores` (
  `ID` int(11) NOT NULL,
  `Nombre` varchar(100) NOT NULL,
  `Contacto` varchar(100) NOT NULL,
  `Teléfono` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `proveedores`
--

INSERT INTO `proveedores` (`ID`, `Nombre`, `Contacto`, `Teléfono`) VALUES
(1, 'Distribuidora Salud', 'Carlos Méndez', '3145678901'),
(2, 'Medicamentos Vital', 'Ana Torres', '3209876543'),
(3, 'Suministros Hospitalarios', 'Roberto Pérez', '3012345678');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `recetas`
--

CREATE TABLE `recetas` (
  `ID` int(11) NOT NULL,
  `ID_Historia` int(11) DEFAULT NULL,
  `ID_Medicamento` int(11) DEFAULT NULL,
  `Cantidad` int(11) NOT NULL,
  `Indicaciones` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `recetas`
--

INSERT INTO `recetas` (`ID`, `ID_Historia`, `ID_Medicamento`, `Cantidad`, `Indicaciones`) VALUES
(1, 1, 1, 10, 'Tomar cada 8 horas después de las comidas'),
(2, 2, 2, 15, 'Tomar cada 6 horas con abundante agua'),
(3, 3, 3, 7, 'Tomar cada 12 horas hasta terminar el tratamiento');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `suministros`
--

CREATE TABLE `suministros` (
  `ID` int(11) NOT NULL,
  `ID_Proveedor` int(11) NOT NULL,
  `ID_Producto` int(11) NOT NULL,
  `Cantidad` int(11) NOT NULL,
  `Fecha_Suministro` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `suministros`
--

INSERT INTO `suministros` (`ID`, `ID_Proveedor`, `ID_Producto`, `Cantidad`, `Fecha_Suministro`) VALUES
(1, 1, 1, 50, '2025-02-15'),
(2, 1, 2, 30, '2025-02-20'),
(3, 2, 3, 20, '2025-02-10'),
(4, 3, 1, 40, '2025-02-18'),
(5, 3, 2, 60, '2025-02-25');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `turnos`
--

CREATE TABLE `turnos` (
  `ID` int(11) NOT NULL,
  `ID_Enfermero` int(11) DEFAULT NULL,
  `Fecha` date NOT NULL,
  `HoraInicio` time NOT NULL,
  `HoraFin` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `turnos`
--

INSERT INTO `turnos` (`ID`, `ID_Enfermero`, `Fecha`, `HoraInicio`, `HoraFin`) VALUES
(1, 1, '2025-02-27', '07:00:00', '15:00:00'),
(2, 2, '2025-02-28', '15:00:00', '23:00:00'),
(3, 3, '2025-03-01', '23:00:00', '07:00:00');

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_cantidad_enfermeros`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_cantidad_enfermeros` (
`Total_Enfermeros` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_cirugias_programadas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_cirugias_programadas` (
`ID` int(11)
,`Paciente` varchar(100)
,`Doctor` varchar(100)
,`Fecha` date
,`Tipo` varchar(100)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_cirugias_recientes`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_cirugias_recientes` (
`ID` int(11)
,`Paciente` varchar(100)
,`Doctor` varchar(100)
,`Fecha` date
,`Tipo` varchar(100)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_citas_canceladas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_citas_canceladas` (
`ID` int(11)
,`Paciente` varchar(100)
,`Doctor` varchar(100)
,`Fecha` date
,`Hora` time
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_citas_canceladas_pacientes`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_citas_canceladas_pacientes` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
,`Total_Citas_Canceladas` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_citas_completadas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_citas_completadas` (
`ID` int(11)
,`Paciente` varchar(100)
,`Doctor` varchar(100)
,`Fecha` date
,`Hora` time
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_citas_completadas_por_doctor`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_citas_completadas_por_doctor` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
,`Total_Citas_Completadas` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_citas_mes_actual`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_citas_mes_actual` (
`ID` int(11)
,`Paciente` varchar(100)
,`Doctor` varchar(100)
,`Fecha` date
,`Hora` time
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_citas_pendientes`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_citas_pendientes` (
`ID` int(11)
,`Paciente` varchar(100)
,`Doctor` varchar(100)
,`Fecha` date
,`Hora` time
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_citas_por_dia_semana`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_citas_por_dia_semana` (
`Dia_Semana` varchar(9)
,`Total_Citas` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_citas_por_especialidad`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_citas_por_especialidad` (
`Especialidad` varchar(100)
,`Total_Citas` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_citas_por_mes_ultimo_año`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_citas_por_mes_ultimo_año` (
`Año` int(4)
,`Mes` int(2)
,`Total_Citas` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_citas_proxima_semana`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_citas_proxima_semana` (
`ID` int(11)
,`Paciente` varchar(100)
,`Doctor` varchar(100)
,`Fecha` date
,`Hora` time
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_doctores_con_cirugias`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_doctores_con_cirugias` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
,`Especialidad` varchar(100)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_doctores_con_citas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_doctores_con_citas` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
,`Total_Citas` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_doctores_con_experiencia`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_doctores_con_experiencia` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
,`Especialidad` varchar(100)
,`Años_Experiencia` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_doctores_especialidad`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_doctores_especialidad` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
,`Especialidad` varchar(100)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_doctores_mas_citas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_doctores_mas_citas` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
,`Total_Citas` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_doctores_mas_pacientes`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_doctores_mas_pacientes` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
,`Total_Pacientes_Atendidos` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_doctores_mayor_atencion`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_doctores_mayor_atencion` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
,`Total_Citas` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_doctores_mayor_procedimientos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_doctores_mayor_procedimientos` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
,`Total_Procedimientos` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_doctores_sin_citas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_doctores_sin_citas` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
,`Especialidad` varchar(100)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_enfermeros_mas_procedimientos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_enfermeros_mas_procedimientos` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
,`Total_Procedimientos` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_enfermeros_mas_turnos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_enfermeros_mas_turnos` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
,`Total_Turnos` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_eps_enfermedades_cronicas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_eps_enfermedades_cronicas` (
`EPS` varchar(100)
,`Total_Pacientes_Cronicos` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_especialidades_populares`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_especialidades_populares` (
`Especialidad` varchar(100)
,`Total_Citas` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_facturacion_mensual`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_facturacion_mensual` (
`Mes` varchar(7)
,`Total_Facturado_COP` varchar(14)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_facturacion_pendiente`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_facturacion_pendiente` (
`ID` int(11)
,`Paciente` varchar(100)
,`Monto_COP` varchar(14)
,`Fecha` date
,`Estado` enum('Pagado','Pendiente')
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_facturacion_por_eps`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_facturacion_por_eps` (
`EPS` varchar(100)
,`Facturacion_Total_COP` varchar(43)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_facturacion_promedio_paciente`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_facturacion_promedio_paciente` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
,`Facturacion_Promedio` decimal(14,6)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_facturacion_total`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_facturacion_total` (
`Total_Facturado` decimal(32,2)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_habitaciones_disponibles`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_habitaciones_disponibles` (
`ID` int(11)
,`Numero` varchar(10)
,`Tipo` enum('General','Privada','UCI')
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_habitaciones_ocupadas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_habitaciones_ocupadas` (
`ID` int(11)
,`Numero` varchar(10)
,`Tipo` enum('General','Privada','UCI')
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_historial_medicamentos_paciente`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_historial_medicamentos_paciente` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
,`Medicamento` varchar(100)
,`Fecha_Receta` date
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_historias_diagnostico`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_historias_diagnostico` (
`ID` int(11)
,`Paciente` varchar(100)
,`Diagnóstico` text
,`Tratamiento` text
,`Fecha` date
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_hospitalizaciones_activas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_hospitalizaciones_activas` (
`ID` int(11)
,`Paciente` varchar(100)
,`Doctor` varchar(100)
,`Fecha_Ingreso` date
,`Habitacion` varchar(10)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_ingresos_por_especialidad`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_ingresos_por_especialidad` (
`Especialidad` varchar(100)
,`Total_Ingresos` decimal(32,2)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_ingresos_por_mes`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_ingresos_por_mes` (
`Mes` varchar(7)
,`Total_Ingresos` decimal(32,2)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_medicamentos_descripcion_corta`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_medicamentos_descripcion_corta` (
`ID` int(11)
,`Nombre` varchar(100)
,`Descripcion_Corta` varchar(50)
,`Dosis` varchar(50)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_medicamentos_dosis`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_medicamentos_dosis` (
`ID` int(11)
,`Nombre` varchar(100)
,`Descripción` text
,`Dosis` varchar(50)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_medicamentos_mas_prescritos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_medicamentos_mas_prescritos` (
`Nombre` varchar(100)
,`Total_Recetas` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_medicamentos_mas_recetados`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_medicamentos_mas_recetados` (
`Nombre` varchar(100)
,`Total_Recetas` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_medicamentos_mas_usados`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_medicamentos_mas_usados` (
`ID` int(11)
,`Nombre` varchar(100)
,`Veces_Recetado` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_medicamentos_ultimo_mes`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_medicamentos_ultimo_mes` (
`ID` int(11)
,`Nombre` varchar(100)
,`Descripción` text
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_medicos_con_pacientes_recurrentes`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_medicos_con_pacientes_recurrentes` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
,`ID_Paciente` int(11)
,`Paciente` varchar(100)
,`Total_Citas` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_medicos_mayor_facturacion`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_medicos_mayor_facturacion` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
,`Total_Facturado` decimal(32,2)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_pacientes_atendidos_recientes`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_pacientes_atendidos_recientes` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_pacientes_atendidos_ultimo_mes`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_pacientes_atendidos_ultimo_mes` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_pacientes_con_cirugias`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_pacientes_con_cirugias` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_pacientes_enfermedades_cronicas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_pacientes_enfermedades_cronicas` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
,`Diagnóstico` text
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_pacientes_eps`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_pacientes_eps` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
,`EPS` varchar(100)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_pacientes_frecuentes`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_pacientes_frecuentes` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
,`Total_Citas` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_pacientes_hospitalizados_recientemente`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_pacientes_hospitalizados_recientemente` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
,`Fecha_Ingreso` date
,`Fecha_Egreso` date
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_pacientes_mayor_facturacion`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_pacientes_mayor_facturacion` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
,`Total_Facturado` decimal(32,2)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_pacientes_multiples_cirugias`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_pacientes_multiples_cirugias` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
,`Total_Cirugias` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_pacientes_multiples_enfermedades`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_pacientes_multiples_enfermedades` (
`ID_Paciente` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
,`Total_Enfermedades` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_pacientes_multiples_hospitalizaciones`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_pacientes_multiples_hospitalizaciones` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
,`Total_Hospitalizaciones` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_pacientes_por_doctor`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_pacientes_por_doctor` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
,`Total_Pacientes_Atendidos` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_pacientes_por_eps`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_pacientes_por_eps` (
`EPS` varchar(100)
,`Total_Pacientes` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_pacientes_por_tipo_sangre`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_pacientes_por_tipo_sangre` (
`TipoSangre` varchar(5)
,`Total_Pacientes` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_pacientes_repetidos_procedimientos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_pacientes_repetidos_procedimientos` (
`ID_Paciente` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
,`Total_Procedimientos` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_pacientes_sin_citas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_pacientes_sin_citas` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_procedimientos_caros`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_procedimientos_caros` (
`ID` int(11)
,`Nombre` varchar(100)
,`Costo` decimal(10,2)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_procedimientos_costo`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_procedimientos_costo` (
`ID` int(11)
,`Nombre` varchar(100)
,`Descripción` text
,`Costo` decimal(10,2)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_procedimientos_hospitalizacion`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_procedimientos_hospitalizacion` (
`ID_Hospitalizacion` int(11)
,`Paciente` varchar(100)
,`Procedimiento` varchar(100)
,`Fecha` date
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_procedimientos_mas_costosos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_procedimientos_mas_costosos` (
`Nombre` varchar(100)
,`Descripción` text
,`Costo` decimal(10,2)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_procedimientos_mas_realizados`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_procedimientos_mas_realizados` (
`Nombre` varchar(100)
,`Total_Realizados` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_promedio_citas_doctor`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_promedio_citas_doctor` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
,`Promedio_Citas` decimal(24,4)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_promedio_citas_paciente`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_promedio_citas_paciente` (
`Promedio_Citas_Paciente` decimal(24,4)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_promedio_costo_procedimientos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_promedio_costo_procedimientos` (
`Promedio_Costo_Procedimientos` decimal(14,6)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_promedio_dias_hospitalizacion`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_promedio_dias_hospitalizacion` (
`ID_Paciente` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
,`Promedio_Dias` decimal(10,4)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_promedio_edad_por_enfermedad`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_promedio_edad_por_enfermedad` (
`Diagnóstico` text
,`Promedio_Edad` decimal(8,4)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_promedio_edad_por_especialidad`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_promedio_edad_por_especialidad` (
`Especialidad` varchar(100)
,`Promedio_Edad` decimal(8,4)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_promedio_edad_por_genero`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_promedio_edad_por_genero` (
`Género` enum('Masculino','Femenino','Otro')
,`Promedio_Edad` decimal(24,4)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_promedio_facturacion_paciente`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_promedio_facturacion_paciente` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
,`Promedio_Facturacion` decimal(14,6)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_promedio_hospitalizacion`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_promedio_hospitalizacion` (
`Diagnóstico` text
,`Promedio_Dias` decimal(14,4)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_promedio_hospitalizacion_especialidad`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_promedio_hospitalizacion_especialidad` (
`Especialidad` varchar(100)
,`Promedio_Dias_Hospitalizacion` decimal(10,4)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_proveedores_contacto`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_proveedores_contacto` (
`ID` int(11)
,`Nombre` varchar(100)
,`Contacto` varchar(100)
,`Teléfono` varchar(20)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_proveedores_mayor_suministro`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_proveedores_mayor_suministro` (
`ID` int(11)
,`Nombre` varchar(100)
,`Total_Suministros` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_proveedores_multiples_productos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_proveedores_multiples_productos` (
`ID` int(11)
,`Nombre` varchar(100)
,`Total_Productos` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_total_citas_por_doctor`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_total_citas_por_doctor` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
,`Total_Citas` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_total_citas_por_especialidad`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_total_citas_por_especialidad` (
`Especialidad` varchar(100)
,`Total_Citas` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_total_facturacion_pacientes`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_total_facturacion_pacientes` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
,`Total_Facturado` decimal(32,2)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_total_pacientes_por_eps`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_total_pacientes_por_eps` (
`EPS` varchar(100)
,`Total_Pacientes` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_turnos_enfermeros`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_turnos_enfermeros` (
`ID` int(11)
,`Enfermero` varchar(100)
,`Fecha` date
,`HoraInicio` time
,`HoraFin` time
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_ultimo_procedimiento_paciente`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_ultimo_procedimiento_paciente` (
`ID` int(11)
,`Nombre` varchar(100)
,`Apellido` varchar(100)
,`Ultimo_Procedimiento` varchar(100)
,`Fecha_Ultimo_Procedimiento` date
);

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_cantidad_enfermeros`
--
DROP TABLE IF EXISTS `vista_cantidad_enfermeros`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_cantidad_enfermeros`  AS SELECT count(0) AS `Total_Enfermeros` FROM `enfermeros` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_cirugias_programadas`
--
DROP TABLE IF EXISTS `vista_cirugias_programadas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_cirugias_programadas`  AS SELECT `c`.`ID` AS `ID`, `p`.`Nombre` AS `Paciente`, `d`.`Nombre` AS `Doctor`, `c`.`Fecha` AS `Fecha`, `c`.`Tipo` AS `Tipo` FROM ((`cirugias` `c` join `pacientes` `p` on(`c`.`ID_Paciente` = `p`.`ID`)) join `doctores` `d` on(`c`.`ID_Doctor` = `d`.`ID`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_cirugias_recientes`
--
DROP TABLE IF EXISTS `vista_cirugias_recientes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_cirugias_recientes`  AS SELECT `c`.`ID` AS `ID`, `p`.`Nombre` AS `Paciente`, `d`.`Nombre` AS `Doctor`, `c`.`Fecha` AS `Fecha`, `c`.`Tipo` AS `Tipo` FROM ((`cirugias` `c` join `pacientes` `p` on(`c`.`ID_Paciente` = `p`.`ID`)) join `doctores` `d` on(`c`.`ID_Doctor` = `d`.`ID`)) WHERE `c`.`Fecha` >= curdate() - interval 6 month ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_citas_canceladas`
--
DROP TABLE IF EXISTS `vista_citas_canceladas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_citas_canceladas`  AS SELECT `c`.`ID` AS `ID`, `p`.`Nombre` AS `Paciente`, `d`.`Nombre` AS `Doctor`, `c`.`Fecha` AS `Fecha`, `c`.`Hora` AS `Hora` FROM ((`citas` `c` join `pacientes` `p` on(`c`.`ID_Paciente` = `p`.`ID`)) join `doctores` `d` on(`c`.`ID_Doctor` = `d`.`ID`)) WHERE `c`.`Estado` = 'Cancelada' AND `c`.`Fecha` >= curdate() - interval 3 month ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_citas_canceladas_pacientes`
--
DROP TABLE IF EXISTS `vista_citas_canceladas_pacientes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_citas_canceladas_pacientes`  AS SELECT `p`.`ID` AS `ID`, `p`.`Nombre` AS `Nombre`, `p`.`Apellido` AS `Apellido`, count(`c`.`ID`) AS `Total_Citas_Canceladas` FROM (`pacientes` `p` join `citas` `c` on(`p`.`ID` = `c`.`ID_Paciente`)) WHERE `c`.`Estado` = 'Cancelada' GROUP BY `p`.`ID`, `p`.`Nombre`, `p`.`Apellido` ORDER BY count(`c`.`ID`) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_citas_completadas`
--
DROP TABLE IF EXISTS `vista_citas_completadas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_citas_completadas`  AS SELECT `c`.`ID` AS `ID`, `p`.`Nombre` AS `Paciente`, `d`.`Nombre` AS `Doctor`, `c`.`Fecha` AS `Fecha`, `c`.`Hora` AS `Hora` FROM ((`citas` `c` join `pacientes` `p` on(`c`.`ID_Paciente` = `p`.`ID`)) join `doctores` `d` on(`c`.`ID_Doctor` = `d`.`ID`)) WHERE `c`.`Estado` = 'Completada' ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_citas_completadas_por_doctor`
--
DROP TABLE IF EXISTS `vista_citas_completadas_por_doctor`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_citas_completadas_por_doctor`  AS SELECT `d`.`ID` AS `ID`, `d`.`Nombre` AS `Nombre`, `d`.`Apellido` AS `Apellido`, count(`c`.`ID`) AS `Total_Citas_Completadas` FROM (`doctores` `d` join `citas` `c` on(`d`.`ID` = `c`.`ID_Doctor`)) WHERE `c`.`Estado` = 'Completada' GROUP BY `d`.`ID`, `d`.`Nombre`, `d`.`Apellido` ORDER BY count(`c`.`ID`) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_citas_mes_actual`
--
DROP TABLE IF EXISTS `vista_citas_mes_actual`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_citas_mes_actual`  AS SELECT `c`.`ID` AS `ID`, `p`.`Nombre` AS `Paciente`, `d`.`Nombre` AS `Doctor`, `c`.`Fecha` AS `Fecha`, `c`.`Hora` AS `Hora` FROM ((`citas` `c` join `pacientes` `p` on(`c`.`ID_Paciente` = `p`.`ID`)) join `doctores` `d` on(`c`.`ID_Doctor` = `d`.`ID`)) WHERE month(`c`.`Fecha`) = month(curdate()) AND year(`c`.`Fecha`) = year(curdate()) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_citas_pendientes`
--
DROP TABLE IF EXISTS `vista_citas_pendientes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_citas_pendientes`  AS SELECT `c`.`ID` AS `ID`, `p`.`Nombre` AS `Paciente`, `d`.`Nombre` AS `Doctor`, `c`.`Fecha` AS `Fecha`, `c`.`Hora` AS `Hora` FROM ((`citas` `c` join `pacientes` `p` on(`c`.`ID_Paciente` = `p`.`ID`)) join `doctores` `d` on(`c`.`ID_Doctor` = `d`.`ID`)) WHERE `c`.`Estado` = 'Pendiente' ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_citas_por_dia_semana`
--
DROP TABLE IF EXISTS `vista_citas_por_dia_semana`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_citas_por_dia_semana`  AS SELECT CASE END FROM `citas` GROUP BY CASE ENDdayname(`citas`.`Fecha`) END ORDER BY field(`Dia_Semana`,'Lunes','Martes','Miércoles','Jueves','Viernes','Sábado','Domingo') ASC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_citas_por_especialidad`
--
DROP TABLE IF EXISTS `vista_citas_por_especialidad`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_citas_por_especialidad`  AS SELECT `d`.`Especialidad` AS `Especialidad`, count(`c`.`ID`) AS `Total_Citas` FROM (`doctores` `d` join `citas` `c` on(`d`.`ID` = `c`.`ID_Doctor`)) GROUP BY `d`.`Especialidad` ORDER BY count(`c`.`ID`) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_citas_por_mes_ultimo_año`
--
DROP TABLE IF EXISTS `vista_citas_por_mes_ultimo_año`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_citas_por_mes_ultimo_año`  AS SELECT year(`citas`.`Fecha`) AS `Año`, month(`citas`.`Fecha`) AS `Mes`, count(`citas`.`ID`) AS `Total_Citas` FROM `citas` WHERE `citas`.`Fecha` >= curdate() - interval 1 year GROUP BY year(`citas`.`Fecha`), month(`citas`.`Fecha`) ORDER BY year(`citas`.`Fecha`) DESC, month(`citas`.`Fecha`) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_citas_proxima_semana`
--
DROP TABLE IF EXISTS `vista_citas_proxima_semana`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_citas_proxima_semana`  AS SELECT `c`.`ID` AS `ID`, `p`.`Nombre` AS `Paciente`, `d`.`Nombre` AS `Doctor`, `c`.`Fecha` AS `Fecha`, `c`.`Hora` AS `Hora` FROM ((`citas` `c` join `pacientes` `p` on(`c`.`ID_Paciente` = `p`.`ID`)) join `doctores` `d` on(`c`.`ID_Doctor` = `d`.`ID`)) WHERE `c`.`Fecha` between curdate() and curdate() + interval 7 day ORDER BY `c`.`Fecha` ASC, `c`.`Hora` ASC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_doctores_con_cirugias`
--
DROP TABLE IF EXISTS `vista_doctores_con_cirugias`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_doctores_con_cirugias`  AS SELECT DISTINCT `d`.`ID` AS `ID`, `d`.`Nombre` AS `Nombre`, `d`.`Apellido` AS `Apellido`, `d`.`Especialidad` AS `Especialidad` FROM (`doctores` `d` join `cirugias` `c` on(`d`.`ID` = `c`.`ID_Doctor`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_doctores_con_citas`
--
DROP TABLE IF EXISTS `vista_doctores_con_citas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_doctores_con_citas`  AS SELECT `d`.`ID` AS `ID`, `d`.`Nombre` AS `Nombre`, `d`.`Apellido` AS `Apellido`, count(`c`.`ID`) AS `Total_Citas` FROM (`doctores` `d` left join `citas` `c` on(`d`.`ID` = `c`.`ID_Doctor`)) GROUP BY `d`.`ID`, `d`.`Nombre`, `d`.`Apellido` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_doctores_con_experiencia`
--
DROP TABLE IF EXISTS `vista_doctores_con_experiencia`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_doctores_con_experiencia`  AS SELECT `doctores`.`ID` AS `ID`, `doctores`.`Nombre` AS `Nombre`, `doctores`.`Apellido` AS `Apellido`, `doctores`.`Especialidad` AS `Especialidad`, `doctores`.`Años_Experiencia` AS `Años_Experiencia` FROM `doctores` WHERE `doctores`.`Años_Experiencia` > 5 ORDER BY `doctores`.`Años_Experiencia` DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_doctores_especialidad`
--
DROP TABLE IF EXISTS `vista_doctores_especialidad`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_doctores_especialidad`  AS SELECT `doctores`.`ID` AS `ID`, `doctores`.`Nombre` AS `Nombre`, `doctores`.`Apellido` AS `Apellido`, `doctores`.`Especialidad` AS `Especialidad` FROM `doctores` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_doctores_mas_citas`
--
DROP TABLE IF EXISTS `vista_doctores_mas_citas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_doctores_mas_citas`  AS SELECT `d`.`ID` AS `ID`, `d`.`Nombre` AS `Nombre`, `d`.`Apellido` AS `Apellido`, count(`c`.`ID`) AS `Total_Citas` FROM (`doctores` `d` join `citas` `c` on(`d`.`ID` = `c`.`ID_Doctor`)) GROUP BY `d`.`ID`, `d`.`Nombre`, `d`.`Apellido` HAVING count(`c`.`ID`) > 5 ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_doctores_mas_pacientes`
--
DROP TABLE IF EXISTS `vista_doctores_mas_pacientes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_doctores_mas_pacientes`  AS SELECT `d`.`ID` AS `ID`, `d`.`Nombre` AS `Nombre`, `d`.`Apellido` AS `Apellido`, count(distinct `c`.`ID_Paciente`) AS `Total_Pacientes_Atendidos` FROM (`doctores` `d` join `citas` `c` on(`d`.`ID` = `c`.`ID_Doctor`)) GROUP BY `d`.`ID`, `d`.`Nombre`, `d`.`Apellido` ORDER BY count(distinct `c`.`ID_Paciente`) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_doctores_mayor_atencion`
--
DROP TABLE IF EXISTS `vista_doctores_mayor_atencion`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_doctores_mayor_atencion`  AS SELECT `d`.`ID` AS `ID`, `d`.`Nombre` AS `Nombre`, `d`.`Apellido` AS `Apellido`, count(`c`.`ID`) AS `Total_Citas` FROM (`doctores` `d` join `citas` `c` on(`d`.`ID` = `c`.`ID_Doctor`)) WHERE `c`.`Estado` = 'Completada' GROUP BY `d`.`ID`, `d`.`Nombre`, `d`.`Apellido` HAVING count(`c`.`ID`) > 10 ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_doctores_mayor_procedimientos`
--
DROP TABLE IF EXISTS `vista_doctores_mayor_procedimientos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_doctores_mayor_procedimientos`  AS SELECT `d`.`ID` AS `ID`, `d`.`Nombre` AS `Nombre`, `d`.`Apellido` AS `Apellido`, count(`prr`.`ID`) AS `Total_Procedimientos` FROM (`doctores` `d` join `procedimientos_realizados` `prr` on(`d`.`ID` = `prr`.`ID_Doctor`)) GROUP BY `d`.`ID`, `d`.`Nombre`, `d`.`Apellido` ORDER BY count(`prr`.`ID`) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_doctores_sin_citas`
--
DROP TABLE IF EXISTS `vista_doctores_sin_citas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_doctores_sin_citas`  AS SELECT `d`.`ID` AS `ID`, `d`.`Nombre` AS `Nombre`, `d`.`Apellido` AS `Apellido`, `d`.`Especialidad` AS `Especialidad` FROM (`doctores` `d` left join `citas` `c` on(`d`.`ID` = `c`.`ID_Doctor`)) WHERE `c`.`ID` is null ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_enfermeros_mas_procedimientos`
--
DROP TABLE IF EXISTS `vista_enfermeros_mas_procedimientos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_enfermeros_mas_procedimientos`  AS SELECT `e`.`ID` AS `ID`, `e`.`Nombre` AS `Nombre`, `e`.`Apellido` AS `Apellido`, count(`p`.`ID`) AS `Total_Procedimientos` FROM ((`enfermeros` `e` join `procedimientos_realizados` `pr` on(`e`.`ID` = `pr`.`ID_Enfermero`)) join `procedimientos` `p` on(`pr`.`ID_Procedimiento` = `p`.`ID`)) GROUP BY `e`.`ID`, `e`.`Nombre`, `e`.`Apellido` ORDER BY count(`p`.`ID`) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_enfermeros_mas_turnos`
--
DROP TABLE IF EXISTS `vista_enfermeros_mas_turnos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_enfermeros_mas_turnos`  AS SELECT `e`.`ID` AS `ID`, `e`.`Nombre` AS `Nombre`, `e`.`Apellido` AS `Apellido`, count(`t`.`ID`) AS `Total_Turnos` FROM (`enfermeros` `e` join `turnos` `t` on(`e`.`ID` = `t`.`ID_Enfermero`)) GROUP BY `e`.`ID`, `e`.`Nombre`, `e`.`Apellido` ORDER BY count(`t`.`ID`) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_eps_enfermedades_cronicas`
--
DROP TABLE IF EXISTS `vista_eps_enfermedades_cronicas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_eps_enfermedades_cronicas`  AS SELECT `e`.`Nombre` AS `EPS`, count(distinct `hc`.`ID_Paciente`) AS `Total_Pacientes_Cronicos` FROM ((`eps` `e` join `pacientes` `p` on(`e`.`ID` = `p`.`ID_EPS`)) join `historias_clinicas` `hc` on(`p`.`ID` = `hc`.`ID_Paciente`)) WHERE `hc`.`Diagnóstico` like '%crónico%' GROUP BY `e`.`Nombre` ORDER BY count(distinct `hc`.`ID_Paciente`) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_especialidades_populares`
--
DROP TABLE IF EXISTS `vista_especialidades_populares`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_especialidades_populares`  AS SELECT `d`.`Especialidad` AS `Especialidad`, count(`c`.`ID`) AS `Total_Citas` FROM (`doctores` `d` join `citas` `c` on(`d`.`ID` = `c`.`ID_Doctor`)) GROUP BY `d`.`Especialidad` ORDER BY count(`c`.`ID`) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_facturacion_mensual`
--
DROP TABLE IF EXISTS `vista_facturacion_mensual`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_facturacion_mensual`  AS SELECT date_format(`facturacion`.`Fecha`,'%Y-%m') AS `Mes`, concat('$',format(`facturacion`.`Monto`,0,'es_CO')) AS `Total_Facturado_COP` FROM `facturacion` GROUP BY date_format(`facturacion`.`Fecha`,'%Y-%m') ORDER BY date_format(`facturacion`.`Fecha`,'%Y-%m') DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_facturacion_pendiente`
--
DROP TABLE IF EXISTS `vista_facturacion_pendiente`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_facturacion_pendiente`  AS SELECT `f`.`ID` AS `ID`, `p`.`Nombre` AS `Paciente`, concat('$',format(`f`.`Monto`,0,'es_CO')) AS `Monto_COP`, `f`.`Fecha` AS `Fecha`, `f`.`Estado` AS `Estado` FROM (`facturacion` `f` join `pacientes` `p` on(`f`.`ID_Paciente` = `p`.`ID`)) WHERE `f`.`Estado` = 'Pendiente' ORDER BY `f`.`Fecha` DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_facturacion_por_eps`
--
DROP TABLE IF EXISTS `vista_facturacion_por_eps`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_facturacion_por_eps`  AS SELECT `e`.`Nombre` AS `EPS`, concat('$',format(sum(`f`.`Monto`),0,'es_CO')) AS `Facturacion_Total_COP` FROM ((`facturacion` `f` join `pacientes` `p` on(`f`.`ID_Paciente` = `p`.`ID`)) join `eps` `e` on(`p`.`ID_EPS` = `e`.`ID`)) GROUP BY `e`.`Nombre` ORDER BY sum(`f`.`Monto`) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_facturacion_promedio_paciente`
--
DROP TABLE IF EXISTS `vista_facturacion_promedio_paciente`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_facturacion_promedio_paciente`  AS SELECT `p`.`ID` AS `ID`, `p`.`Nombre` AS `Nombre`, `p`.`Apellido` AS `Apellido`, avg(`f`.`Monto`) AS `Facturacion_Promedio` FROM (`pacientes` `p` join `facturacion` `f` on(`p`.`ID` = `f`.`ID_Paciente`)) GROUP BY `p`.`ID`, `p`.`Nombre`, `p`.`Apellido` ORDER BY avg(`f`.`Monto`) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_facturacion_total`
--
DROP TABLE IF EXISTS `vista_facturacion_total`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_facturacion_total`  AS SELECT sum(`facturacion`.`Monto`) AS `Total_Facturado` FROM `facturacion` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_habitaciones_disponibles`
--
DROP TABLE IF EXISTS `vista_habitaciones_disponibles`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_habitaciones_disponibles`  AS SELECT `habitaciones`.`ID` AS `ID`, `habitaciones`.`Numero` AS `Numero`, `habitaciones`.`Tipo` AS `Tipo` FROM `habitaciones` WHERE `habitaciones`.`Estado` = 'Disponible' ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_habitaciones_ocupadas`
--
DROP TABLE IF EXISTS `vista_habitaciones_ocupadas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_habitaciones_ocupadas`  AS SELECT `habitaciones`.`ID` AS `ID`, `habitaciones`.`Numero` AS `Numero`, `habitaciones`.`Tipo` AS `Tipo` FROM `habitaciones` WHERE `habitaciones`.`Estado` = 'Ocupada' ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_historial_medicamentos_paciente`
--
DROP TABLE IF EXISTS `vista_historial_medicamentos_paciente`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_historial_medicamentos_paciente`  AS SELECT `p`.`ID` AS `ID`, `p`.`Nombre` AS `Nombre`, `p`.`Apellido` AS `Apellido`, `m`.`Nombre` AS `Medicamento`, `pr`.`Fecha` AS `Fecha_Receta` FROM ((`pacientes` `p` join `prescripciones` `pr` on(`p`.`ID` = `pr`.`ID_Paciente`)) join `medicamentos` `m` on(`pr`.`ID_Medicamento` = `m`.`ID`)) ORDER BY `pr`.`Fecha` DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_historias_diagnostico`
--
DROP TABLE IF EXISTS `vista_historias_diagnostico`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_historias_diagnostico`  AS SELECT `hc`.`ID` AS `ID`, `p`.`Nombre` AS `Paciente`, `hc`.`Diagnóstico` AS `Diagnóstico`, `hc`.`Tratamiento` AS `Tratamiento`, `hc`.`Fecha` AS `Fecha` FROM (`historias_clinicas` `hc` join `pacientes` `p` on(`hc`.`ID_Paciente` = `p`.`ID`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_hospitalizaciones_activas`
--
DROP TABLE IF EXISTS `vista_hospitalizaciones_activas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_hospitalizaciones_activas`  AS SELECT `h`.`ID` AS `ID`, `p`.`Nombre` AS `Paciente`, `d`.`Nombre` AS `Doctor`, `h`.`Fecha_Ingreso` AS `Fecha_Ingreso`, `h`.`Habitacion` AS `Habitacion` FROM ((`hospitalizaciones` `h` join `pacientes` `p` on(`h`.`ID_Paciente` = `p`.`ID`)) join `doctores` `d` on(`h`.`ID_Doctor` = `d`.`ID`)) WHERE `h`.`Fecha_Egreso` is null ORDER BY `h`.`Fecha_Ingreso` DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_ingresos_por_especialidad`
--
DROP TABLE IF EXISTS `vista_ingresos_por_especialidad`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_ingresos_por_especialidad`  AS SELECT `d`.`Especialidad` AS `Especialidad`, sum(`f`.`Monto`) AS `Total_Ingresos` FROM ((`doctores` `d` join `citas` `c` on(`d`.`ID` = `c`.`ID_Doctor`)) join `facturacion` `f` on(`c`.`ID_Paciente` = `f`.`ID_Paciente`)) GROUP BY `d`.`Especialidad` ORDER BY sum(`f`.`Monto`) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_ingresos_por_mes`
--
DROP TABLE IF EXISTS `vista_ingresos_por_mes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_ingresos_por_mes`  AS SELECT date_format(`facturacion`.`Fecha`,'%Y-%m') AS `Mes`, sum(`facturacion`.`Monto`) AS `Total_Ingresos` FROM `facturacion` GROUP BY date_format(`facturacion`.`Fecha`,'%Y-%m') ORDER BY date_format(`facturacion`.`Fecha`,'%Y-%m') DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_medicamentos_descripcion_corta`
--
DROP TABLE IF EXISTS `vista_medicamentos_descripcion_corta`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_medicamentos_descripcion_corta`  AS SELECT `medicamentos`.`ID` AS `ID`, `medicamentos`.`Nombre` AS `Nombre`, substr(`medicamentos`.`Descripción`,1,50) AS `Descripcion_Corta`, `medicamentos`.`Dosis` AS `Dosis` FROM `medicamentos` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_medicamentos_dosis`
--
DROP TABLE IF EXISTS `vista_medicamentos_dosis`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_medicamentos_dosis`  AS SELECT `medicamentos`.`ID` AS `ID`, `medicamentos`.`Nombre` AS `Nombre`, `medicamentos`.`Descripción` AS `Descripción`, `medicamentos`.`Dosis` AS `Dosis` FROM `medicamentos` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_medicamentos_mas_prescritos`
--
DROP TABLE IF EXISTS `vista_medicamentos_mas_prescritos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_medicamentos_mas_prescritos`  AS SELECT `m`.`Nombre` AS `Nombre`, count(`hc`.`ID`) AS `Total_Recetas` FROM (`medicamentos` `m` join `historias_clinicas` `hc` on(`hc`.`Tratamiento` like concat('%',`m`.`Nombre`,'%'))) GROUP BY `m`.`Nombre` ORDER BY count(`hc`.`ID`) DESC LIMIT 0, 5 ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_medicamentos_mas_recetados`
--
DROP TABLE IF EXISTS `vista_medicamentos_mas_recetados`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_medicamentos_mas_recetados`  AS SELECT `m`.`Nombre` AS `Nombre`, count(`pr`.`ID`) AS `Total_Recetas` FROM (`medicamentos` `m` join `prescripciones` `pr` on(`m`.`ID` = `pr`.`ID_Medicamento`)) GROUP BY `m`.`Nombre` ORDER BY count(`pr`.`ID`) DESC LIMIT 0, 5 ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_medicamentos_mas_usados`
--
DROP TABLE IF EXISTS `vista_medicamentos_mas_usados`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_medicamentos_mas_usados`  AS SELECT `m`.`ID` AS `ID`, `m`.`Nombre` AS `Nombre`, count(`hc`.`ID`) AS `Veces_Recetado` FROM (`medicamentos` `m` join `historias_clinicas` `hc` on(`hc`.`Tratamiento` like concat('%',`m`.`Nombre`,'%'))) GROUP BY `m`.`ID`, `m`.`Nombre` ORDER BY count(`hc`.`ID`) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_medicamentos_ultimo_mes`
--
DROP TABLE IF EXISTS `vista_medicamentos_ultimo_mes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_medicamentos_ultimo_mes`  AS SELECT DISTINCT `m`.`ID` AS `ID`, `m`.`Nombre` AS `Nombre`, `m`.`Descripción` AS `Descripción` FROM (`medicamentos` `m` join `historias_clinicas` `hc` on(`hc`.`Tratamiento` like concat('%',`m`.`Nombre`,'%'))) WHERE `hc`.`Fecha` >= curdate() - interval 1 month ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_medicos_con_pacientes_recurrentes`
--
DROP TABLE IF EXISTS `vista_medicos_con_pacientes_recurrentes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_medicos_con_pacientes_recurrentes`  AS SELECT `d`.`ID` AS `ID`, `d`.`Nombre` AS `Nombre`, `d`.`Apellido` AS `Apellido`, `p`.`ID` AS `ID_Paciente`, `p`.`Nombre` AS `Paciente`, count(`c`.`ID`) AS `Total_Citas` FROM ((`doctores` `d` join `citas` `c` on(`d`.`ID` = `c`.`ID_Doctor`)) join `pacientes` `p` on(`c`.`ID_Paciente` = `p`.`ID`)) GROUP BY `d`.`ID`, `d`.`Nombre`, `d`.`Apellido`, `p`.`ID`, `p`.`Nombre` HAVING count(`c`.`ID`) > 3 ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_medicos_mayor_facturacion`
--
DROP TABLE IF EXISTS `vista_medicos_mayor_facturacion`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_medicos_mayor_facturacion`  AS SELECT `d`.`ID` AS `ID`, `d`.`Nombre` AS `Nombre`, `d`.`Apellido` AS `Apellido`, sum(`f`.`Monto`) AS `Total_Facturado` FROM ((`doctores` `d` join `citas` `c` on(`d`.`ID` = `c`.`ID_Doctor`)) join `facturacion` `f` on(`c`.`ID_Paciente` = `f`.`ID_Paciente`)) GROUP BY `d`.`ID`, `d`.`Nombre`, `d`.`Apellido` ORDER BY sum(`f`.`Monto`) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_pacientes_atendidos_recientes`
--
DROP TABLE IF EXISTS `vista_pacientes_atendidos_recientes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_pacientes_atendidos_recientes`  AS SELECT DISTINCT `p`.`ID` AS `ID`, `p`.`Nombre` AS `Nombre`, `p`.`Apellido` AS `Apellido` FROM (`pacientes` `p` join `citas` `c` on(`p`.`ID` = `c`.`ID_Paciente`)) WHERE `c`.`Fecha` >= curdate() - interval 3 month ORDER BY `c`.`Fecha` DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_pacientes_atendidos_ultimo_mes`
--
DROP TABLE IF EXISTS `vista_pacientes_atendidos_ultimo_mes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_pacientes_atendidos_ultimo_mes`  AS SELECT DISTINCT `p`.`ID` AS `ID`, `p`.`Nombre` AS `Nombre`, `p`.`Apellido` AS `Apellido` FROM (`pacientes` `p` join `citas` `c` on(`p`.`ID` = `c`.`ID_Paciente`)) WHERE `c`.`Fecha` >= curdate() - interval 1 month ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_pacientes_con_cirugias`
--
DROP TABLE IF EXISTS `vista_pacientes_con_cirugias`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_pacientes_con_cirugias`  AS SELECT DISTINCT `p`.`ID` AS `ID`, `p`.`Nombre` AS `Nombre`, `p`.`Apellido` AS `Apellido` FROM (`pacientes` `p` join `cirugias` `c` on(`p`.`ID` = `c`.`ID_Paciente`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_pacientes_enfermedades_cronicas`
--
DROP TABLE IF EXISTS `vista_pacientes_enfermedades_cronicas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_pacientes_enfermedades_cronicas`  AS SELECT DISTINCT `p`.`ID` AS `ID`, `p`.`Nombre` AS `Nombre`, `p`.`Apellido` AS `Apellido`, `hc`.`Diagnóstico` AS `Diagnóstico` FROM (`pacientes` `p` join `historias_clinicas` `hc` on(`p`.`ID` = `hc`.`ID_Paciente`)) WHERE `hc`.`Diagnóstico` like '%crónica%' OR `hc`.`Diagnóstico` like '%diabetes%' OR `hc`.`Diagnóstico` like '%hipertensión%' ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_pacientes_eps`
--
DROP TABLE IF EXISTS `vista_pacientes_eps`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_pacientes_eps`  AS SELECT `p`.`ID` AS `ID`, `p`.`Nombre` AS `Nombre`, `p`.`Apellido` AS `Apellido`, `e`.`Nombre` AS `EPS` FROM (`pacientes` `p` join `eps` `e` on(`p`.`ID_EPS` = `e`.`ID`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_pacientes_frecuentes`
--
DROP TABLE IF EXISTS `vista_pacientes_frecuentes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_pacientes_frecuentes`  AS SELECT `p`.`ID` AS `ID`, `p`.`Nombre` AS `Nombre`, `p`.`Apellido` AS `Apellido`, count(`c`.`ID`) AS `Total_Citas` FROM (`pacientes` `p` join `citas` `c` on(`p`.`ID` = `c`.`ID_Paciente`)) WHERE `c`.`Fecha` >= curdate() - interval 1 year GROUP BY `p`.`ID`, `p`.`Nombre`, `p`.`Apellido` HAVING `Total_Citas` > 5 ORDER BY count(`c`.`ID`) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_pacientes_hospitalizados_recientemente`
--
DROP TABLE IF EXISTS `vista_pacientes_hospitalizados_recientemente`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_pacientes_hospitalizados_recientemente`  AS SELECT `p`.`ID` AS `ID`, `p`.`Nombre` AS `Nombre`, `p`.`Apellido` AS `Apellido`, `h`.`Fecha_Ingreso` AS `Fecha_Ingreso`, `h`.`Fecha_Egreso` AS `Fecha_Egreso` FROM (`pacientes` `p` join `hospitalizaciones` `h` on(`p`.`ID` = `h`.`ID_Paciente`)) WHERE `h`.`Fecha_Ingreso` >= curdate() - interval 1 month ORDER BY `h`.`Fecha_Ingreso` DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_pacientes_mayor_facturacion`
--
DROP TABLE IF EXISTS `vista_pacientes_mayor_facturacion`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_pacientes_mayor_facturacion`  AS SELECT `p`.`ID` AS `ID`, `p`.`Nombre` AS `Nombre`, `p`.`Apellido` AS `Apellido`, sum(`f`.`Monto`) AS `Total_Facturado` FROM (`pacientes` `p` join `facturacion` `f` on(`p`.`ID` = `f`.`ID_Paciente`)) GROUP BY `p`.`ID`, `p`.`Nombre`, `p`.`Apellido` ORDER BY sum(`f`.`Monto`) DESC LIMIT 0, 5 ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_pacientes_multiples_cirugias`
--
DROP TABLE IF EXISTS `vista_pacientes_multiples_cirugias`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_pacientes_multiples_cirugias`  AS SELECT `p`.`ID` AS `ID`, `p`.`Nombre` AS `Nombre`, `p`.`Apellido` AS `Apellido`, count(`c`.`ID`) AS `Total_Cirugias` FROM (`pacientes` `p` join `cirugias` `c` on(`p`.`ID` = `c`.`ID_Paciente`)) GROUP BY `p`.`ID`, `p`.`Nombre`, `p`.`Apellido` HAVING count(`c`.`ID`) > 1 ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_pacientes_multiples_enfermedades`
--
DROP TABLE IF EXISTS `vista_pacientes_multiples_enfermedades`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_pacientes_multiples_enfermedades`  AS SELECT `hc`.`ID_Paciente` AS `ID_Paciente`, `p`.`Nombre` AS `Nombre`, `p`.`Apellido` AS `Apellido`, count(`hc`.`ID`) AS `Total_Enfermedades` FROM (`historias_clinicas` `hc` join `pacientes` `p` on(`hc`.`ID_Paciente` = `p`.`ID`)) GROUP BY `hc`.`ID_Paciente`, `p`.`Nombre`, `p`.`Apellido` HAVING count(`hc`.`ID`) > 1 ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_pacientes_multiples_hospitalizaciones`
--
DROP TABLE IF EXISTS `vista_pacientes_multiples_hospitalizaciones`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_pacientes_multiples_hospitalizaciones`  AS SELECT `p`.`ID` AS `ID`, `p`.`Nombre` AS `Nombre`, `p`.`Apellido` AS `Apellido`, count(`h`.`ID`) AS `Total_Hospitalizaciones` FROM (`pacientes` `p` join `hospitalizaciones` `h` on(`p`.`ID` = `h`.`ID_Paciente`)) GROUP BY `p`.`ID`, `p`.`Nombre`, `p`.`Apellido` HAVING count(`h`.`ID`) > 1 ORDER BY count(`h`.`ID`) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_pacientes_por_doctor`
--
DROP TABLE IF EXISTS `vista_pacientes_por_doctor`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_pacientes_por_doctor`  AS SELECT `d`.`ID` AS `ID`, `d`.`Nombre` AS `Nombre`, `d`.`Apellido` AS `Apellido`, count(`c`.`ID_Paciente`) AS `Total_Pacientes_Atendidos` FROM (`doctores` `d` join `citas` `c` on(`d`.`ID` = `c`.`ID_Doctor`)) GROUP BY `d`.`ID`, `d`.`Nombre`, `d`.`Apellido` ORDER BY count(`c`.`ID_Paciente`) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_pacientes_por_eps`
--
DROP TABLE IF EXISTS `vista_pacientes_por_eps`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_pacientes_por_eps`  AS SELECT `e`.`Nombre` AS `EPS`, count(`p`.`ID`) AS `Total_Pacientes` FROM (`eps` `e` join `pacientes` `p` on(`e`.`ID` = `p`.`ID_EPS`)) GROUP BY `e`.`Nombre` ORDER BY count(`p`.`ID`) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_pacientes_por_tipo_sangre`
--
DROP TABLE IF EXISTS `vista_pacientes_por_tipo_sangre`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_pacientes_por_tipo_sangre`  AS SELECT `pacientes`.`TipoSangre` AS `TipoSangre`, count(`pacientes`.`ID`) AS `Total_Pacientes` FROM `pacientes` GROUP BY `pacientes`.`TipoSangre` ORDER BY count(`pacientes`.`ID`) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_pacientes_repetidos_procedimientos`
--
DROP TABLE IF EXISTS `vista_pacientes_repetidos_procedimientos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_pacientes_repetidos_procedimientos`  AS SELECT `pr`.`ID_Paciente` AS `ID_Paciente`, `p`.`Nombre` AS `Nombre`, `p`.`Apellido` AS `Apellido`, count(`pr`.`ID_Procedimiento`) AS `Total_Procedimientos` FROM (`procedimientos_realizados` `pr` join `pacientes` `p` on(`pr`.`ID_Paciente` = `p`.`ID`)) GROUP BY `pr`.`ID_Paciente`, `p`.`Nombre`, `p`.`Apellido` HAVING count(`pr`.`ID_Procedimiento`) > 1 ORDER BY count(`pr`.`ID_Procedimiento`) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_pacientes_sin_citas`
--
DROP TABLE IF EXISTS `vista_pacientes_sin_citas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_pacientes_sin_citas`  AS SELECT `p`.`ID` AS `ID`, `p`.`Nombre` AS `Nombre`, `p`.`Apellido` AS `Apellido` FROM (`pacientes` `p` left join `citas` `c` on(`p`.`ID` = `c`.`ID_Paciente`)) WHERE `c`.`ID` is null ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_procedimientos_caros`
--
DROP TABLE IF EXISTS `vista_procedimientos_caros`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_procedimientos_caros`  AS SELECT `procedimientos`.`ID` AS `ID`, `procedimientos`.`Nombre` AS `Nombre`, `procedimientos`.`Costo` AS `Costo` FROM `procedimientos` ORDER BY `procedimientos`.`Costo` DESC LIMIT 0, 5 ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_procedimientos_costo`
--
DROP TABLE IF EXISTS `vista_procedimientos_costo`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_procedimientos_costo`  AS SELECT `procedimientos`.`ID` AS `ID`, `procedimientos`.`Nombre` AS `Nombre`, `procedimientos`.`Descripción` AS `Descripción`, `procedimientos`.`Costo` AS `Costo` FROM `procedimientos` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_procedimientos_hospitalizacion`
--
DROP TABLE IF EXISTS `vista_procedimientos_hospitalizacion`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_procedimientos_hospitalizacion`  AS SELECT `h`.`ID` AS `ID_Hospitalizacion`, `p`.`Nombre` AS `Paciente`, `pr`.`Nombre` AS `Procedimiento`, `prr`.`Fecha` AS `Fecha` FROM (((`hospitalizaciones` `h` join `pacientes` `p` on(`h`.`ID_Paciente` = `p`.`ID`)) join `procedimientos_realizados` `prr` on(`p`.`ID` = `prr`.`ID_Paciente`)) join `procedimientos` `pr` on(`prr`.`ID_Procedimiento` = `pr`.`ID`)) ORDER BY `h`.`ID` ASC, `prr`.`Fecha` DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_procedimientos_mas_costosos`
--
DROP TABLE IF EXISTS `vista_procedimientos_mas_costosos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_procedimientos_mas_costosos`  AS SELECT `procedimientos`.`Nombre` AS `Nombre`, `procedimientos`.`Descripción` AS `Descripción`, `procedimientos`.`Costo` AS `Costo` FROM `procedimientos` ORDER BY `procedimientos`.`Costo` DESC LIMIT 0, 5 ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_procedimientos_mas_realizados`
--
DROP TABLE IF EXISTS `vista_procedimientos_mas_realizados`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_procedimientos_mas_realizados`  AS SELECT `p`.`Nombre` AS `Nombre`, count(`pr`.`ID`) AS `Total_Realizados` FROM (`procedimientos` `p` join `procedimientos_realizados` `pr` on(`p`.`ID` = `pr`.`ID_Procedimiento`)) GROUP BY `p`.`Nombre` ORDER BY count(`pr`.`ID`) DESC LIMIT 0, 5 ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_promedio_citas_doctor`
--
DROP TABLE IF EXISTS `vista_promedio_citas_doctor`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_promedio_citas_doctor`  AS SELECT `d`.`ID` AS `ID`, `d`.`Nombre` AS `Nombre`, `d`.`Apellido` AS `Apellido`, count(`c`.`ID`) / (select count(0) from `doctores`) AS `Promedio_Citas` FROM (`doctores` `d` left join `citas` `c` on(`d`.`ID` = `c`.`ID_Doctor`)) GROUP BY `d`.`ID`, `d`.`Nombre`, `d`.`Apellido` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_promedio_citas_paciente`
--
DROP TABLE IF EXISTS `vista_promedio_citas_paciente`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_promedio_citas_paciente`  AS SELECT count(`c`.`ID`) / count(distinct `c`.`ID_Paciente`) AS `Promedio_Citas_Paciente` FROM `citas` AS `c` WHERE `c`.`Fecha` >= curdate() - interval 1 year ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_promedio_costo_procedimientos`
--
DROP TABLE IF EXISTS `vista_promedio_costo_procedimientos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_promedio_costo_procedimientos`  AS SELECT avg(`procedimientos`.`Costo`) AS `Promedio_Costo_Procedimientos` FROM `procedimientos` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_promedio_dias_hospitalizacion`
--
DROP TABLE IF EXISTS `vista_promedio_dias_hospitalizacion`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_promedio_dias_hospitalizacion`  AS SELECT `h`.`ID_Paciente` AS `ID_Paciente`, `p`.`Nombre` AS `Nombre`, `p`.`Apellido` AS `Apellido`, avg(to_days(`h`.`Fecha_Egreso`) - to_days(`h`.`Fecha_Ingreso`)) AS `Promedio_Dias` FROM (`hospitalizaciones` `h` join `pacientes` `p` on(`h`.`ID_Paciente` = `p`.`ID`)) GROUP BY `h`.`ID_Paciente`, `p`.`Nombre`, `p`.`Apellido` ORDER BY avg(to_days(`h`.`Fecha_Egreso`) - to_days(`h`.`Fecha_Ingreso`)) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_promedio_edad_por_enfermedad`
--
DROP TABLE IF EXISTS `vista_promedio_edad_por_enfermedad`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_promedio_edad_por_enfermedad`  AS SELECT `hc`.`Diagnóstico` AS `Diagnóstico`, avg(year(curdate()) - year(`p`.`FechaNacimiento`)) AS `Promedio_Edad` FROM (`historias_clinicas` `hc` join `pacientes` `p` on(`hc`.`ID_Paciente` = `p`.`ID`)) GROUP BY `hc`.`Diagnóstico` ORDER BY avg(year(curdate()) - year(`p`.`FechaNacimiento`)) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_promedio_edad_por_especialidad`
--
DROP TABLE IF EXISTS `vista_promedio_edad_por_especialidad`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_promedio_edad_por_especialidad`  AS SELECT `d`.`Especialidad` AS `Especialidad`, avg(year(curdate()) - year(`p`.`FechaNacimiento`)) AS `Promedio_Edad` FROM ((`doctores` `d` join `citas` `c` on(`d`.`ID` = `c`.`ID_Doctor`)) join `pacientes` `p` on(`c`.`ID_Paciente` = `p`.`ID`)) GROUP BY `d`.`Especialidad` ORDER BY avg(year(curdate()) - year(`p`.`FechaNacimiento`)) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_promedio_edad_por_genero`
--
DROP TABLE IF EXISTS `vista_promedio_edad_por_genero`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_promedio_edad_por_genero`  AS SELECT `pacientes`.`Género` AS `Género`, avg(timestampdiff(YEAR,`pacientes`.`FechaNacimiento`,curdate())) AS `Promedio_Edad` FROM `pacientes` GROUP BY `pacientes`.`Género` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_promedio_facturacion_paciente`
--
DROP TABLE IF EXISTS `vista_promedio_facturacion_paciente`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_promedio_facturacion_paciente`  AS SELECT `p`.`ID` AS `ID`, `p`.`Nombre` AS `Nombre`, `p`.`Apellido` AS `Apellido`, avg(`f`.`Monto`) AS `Promedio_Facturacion` FROM (`pacientes` `p` join `facturacion` `f` on(`p`.`ID` = `f`.`ID_Paciente`)) GROUP BY `p`.`ID`, `p`.`Nombre`, `p`.`Apellido` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_promedio_hospitalizacion`
--
DROP TABLE IF EXISTS `vista_promedio_hospitalizacion`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_promedio_hospitalizacion`  AS SELECT `hc`.`Diagnóstico` AS `Diagnóstico`, avg(`h`.`Dias_Hospitalizacion`) AS `Promedio_Dias` FROM (`historias_clinicas` `hc` join `hospitalizaciones` `h` on(`hc`.`ID_Paciente` = `h`.`ID_Paciente`)) GROUP BY `hc`.`Diagnóstico` ORDER BY avg(`h`.`Dias_Hospitalizacion`) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_promedio_hospitalizacion_especialidad`
--
DROP TABLE IF EXISTS `vista_promedio_hospitalizacion_especialidad`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_promedio_hospitalizacion_especialidad`  AS SELECT `d`.`Especialidad` AS `Especialidad`, avg(to_days(`h`.`Fecha_Egreso`) - to_days(`h`.`Fecha_Ingreso`)) AS `Promedio_Dias_Hospitalizacion` FROM (`hospitalizaciones` `h` join `doctores` `d` on(`h`.`ID_Doctor` = `d`.`ID`)) GROUP BY `d`.`Especialidad` ORDER BY avg(to_days(`h`.`Fecha_Egreso`) - to_days(`h`.`Fecha_Ingreso`)) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_proveedores_contacto`
--
DROP TABLE IF EXISTS `vista_proveedores_contacto`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_proveedores_contacto`  AS SELECT `proveedores`.`ID` AS `ID`, `proveedores`.`Nombre` AS `Nombre`, `proveedores`.`Contacto` AS `Contacto`, `proveedores`.`Teléfono` AS `Teléfono` FROM `proveedores` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_proveedores_mayor_suministro`
--
DROP TABLE IF EXISTS `vista_proveedores_mayor_suministro`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_proveedores_mayor_suministro`  AS SELECT `pr`.`ID` AS `ID`, `pr`.`Nombre` AS `Nombre`, count(`s`.`ID`) AS `Total_Suministros` FROM (`proveedores` `pr` join `suministros` `s` on(`pr`.`ID` = `s`.`ID_Proveedor`)) GROUP BY `pr`.`ID`, `pr`.`Nombre` ORDER BY count(`s`.`ID`) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_proveedores_multiples_productos`
--
DROP TABLE IF EXISTS `vista_proveedores_multiples_productos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_proveedores_multiples_productos`  AS SELECT `pr`.`ID` AS `ID`, `pr`.`Nombre` AS `Nombre`, count(distinct `s`.`ID_Producto`) AS `Total_Productos` FROM (`proveedores` `pr` join `suministros` `s` on(`pr`.`ID` = `s`.`ID_Proveedor`)) GROUP BY `pr`.`ID`, `pr`.`Nombre` HAVING count(distinct `s`.`ID_Producto`) > 1 ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_total_citas_por_doctor`
--
DROP TABLE IF EXISTS `vista_total_citas_por_doctor`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_total_citas_por_doctor`  AS SELECT `d`.`ID` AS `ID`, `d`.`Nombre` AS `Nombre`, `d`.`Apellido` AS `Apellido`, count(`c`.`ID`) AS `Total_Citas` FROM (`doctores` `d` left join `citas` `c` on(`d`.`ID` = `c`.`ID_Doctor`)) GROUP BY `d`.`ID`, `d`.`Nombre`, `d`.`Apellido` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_total_citas_por_especialidad`
--
DROP TABLE IF EXISTS `vista_total_citas_por_especialidad`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_total_citas_por_especialidad`  AS SELECT `d`.`Especialidad` AS `Especialidad`, count(`c`.`ID`) AS `Total_Citas` FROM (`doctores` `d` join `citas` `c` on(`d`.`ID` = `c`.`ID_Doctor`)) GROUP BY `d`.`Especialidad` ORDER BY count(`c`.`ID`) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_total_facturacion_pacientes`
--
DROP TABLE IF EXISTS `vista_total_facturacion_pacientes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_total_facturacion_pacientes`  AS SELECT `p`.`ID` AS `ID`, `p`.`Nombre` AS `Nombre`, `p`.`Apellido` AS `Apellido`, sum(`f`.`Monto`) AS `Total_Facturado` FROM (`pacientes` `p` join `facturacion` `f` on(`p`.`ID` = `f`.`ID_Paciente`)) GROUP BY `p`.`ID`, `p`.`Nombre`, `p`.`Apellido` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_total_pacientes_por_eps`
--
DROP TABLE IF EXISTS `vista_total_pacientes_por_eps`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_total_pacientes_por_eps`  AS SELECT `e`.`Nombre` AS `EPS`, count(`p`.`ID`) AS `Total_Pacientes` FROM (`pacientes` `p` join `eps` `e` on(`p`.`ID_EPS` = `e`.`ID`)) GROUP BY `e`.`Nombre` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_turnos_enfermeros`
--
DROP TABLE IF EXISTS `vista_turnos_enfermeros`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_turnos_enfermeros`  AS SELECT `t`.`ID` AS `ID`, `e`.`Nombre` AS `Enfermero`, `t`.`Fecha` AS `Fecha`, `t`.`HoraInicio` AS `HoraInicio`, `t`.`HoraFin` AS `HoraFin` FROM (`turnos` `t` join `enfermeros` `e` on(`t`.`ID_Enfermero` = `e`.`ID`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_ultimo_procedimiento_paciente`
--
DROP TABLE IF EXISTS `vista_ultimo_procedimiento_paciente`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_ultimo_procedimiento_paciente`  AS SELECT `p`.`ID` AS `ID`, `p`.`Nombre` AS `Nombre`, `p`.`Apellido` AS `Apellido`, `pr`.`Nombre` AS `Ultimo_Procedimiento`, max(`prr`.`Fecha`) AS `Fecha_Ultimo_Procedimiento` FROM ((`pacientes` `p` join `procedimientos_realizados` `prr` on(`p`.`ID` = `prr`.`ID_Paciente`)) join `procedimientos` `pr` on(`prr`.`ID_Procedimiento` = `pr`.`ID`)) GROUP BY `p`.`ID`, `p`.`Nombre`, `p`.`Apellido`, `pr`.`Nombre` ORDER BY max(`prr`.`Fecha`) DESC ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `cirugias`
--
ALTER TABLE `cirugias`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `ID_Paciente` (`ID_Paciente`),
  ADD KEY `ID_Doctor` (`ID_Doctor`);

--
-- Indices de la tabla `citas`
--
ALTER TABLE `citas`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `ID_Paciente` (`ID_Paciente`),
  ADD KEY `ID_Doctor` (`ID_Doctor`);

--
-- Indices de la tabla `doctores`
--
ALTER TABLE `doctores`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `ID_EPS` (`ID_EPS`);

--
-- Indices de la tabla `enfermeros`
--
ALTER TABLE `enfermeros`
  ADD PRIMARY KEY (`ID`);

--
-- Indices de la tabla `eps`
--
ALTER TABLE `eps`
  ADD PRIMARY KEY (`ID`);

--
-- Indices de la tabla `facturacion`
--
ALTER TABLE `facturacion`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `ID_Paciente` (`ID_Paciente`);

--
-- Indices de la tabla `habitaciones`
--
ALTER TABLE `habitaciones`
  ADD PRIMARY KEY (`ID`);

--
-- Indices de la tabla `historias_clinicas`
--
ALTER TABLE `historias_clinicas`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `ID_Paciente` (`ID_Paciente`);

--
-- Indices de la tabla `hospitalizaciones`
--
ALTER TABLE `hospitalizaciones`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `ID_Paciente` (`ID_Paciente`),
  ADD KEY `ID_Doctor` (`ID_Doctor`);

--
-- Indices de la tabla `medicamentos`
--
ALTER TABLE `medicamentos`
  ADD PRIMARY KEY (`ID`);

--
-- Indices de la tabla `pacientes`
--
ALTER TABLE `pacientes`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `ID_EPS` (`ID_EPS`);

--
-- Indices de la tabla `prescripciones`
--
ALTER TABLE `prescripciones`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `ID_Paciente` (`ID_Paciente`),
  ADD KEY `ID_Doctor` (`ID_Doctor`),
  ADD KEY `ID_Medicamento` (`ID_Medicamento`);

--
-- Indices de la tabla `procedimientos`
--
ALTER TABLE `procedimientos`
  ADD PRIMARY KEY (`ID`);

--
-- Indices de la tabla `procedimientos_realizados`
--
ALTER TABLE `procedimientos_realizados`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `ID_Enfermero` (`ID_Enfermero`),
  ADD KEY `ID_Procedimiento` (`ID_Procedimiento`),
  ADD KEY `ID_Paciente` (`ID_Paciente`),
  ADD KEY `ID_Doctor` (`ID_Doctor`);

--
-- Indices de la tabla `productos`
--
ALTER TABLE `productos`
  ADD PRIMARY KEY (`ID`);

--
-- Indices de la tabla `proveedores`
--
ALTER TABLE `proveedores`
  ADD PRIMARY KEY (`ID`);

--
-- Indices de la tabla `recetas`
--
ALTER TABLE `recetas`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `ID_Historia` (`ID_Historia`),
  ADD KEY `ID_Medicamento` (`ID_Medicamento`);

--
-- Indices de la tabla `suministros`
--
ALTER TABLE `suministros`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `ID_Proveedor` (`ID_Proveedor`),
  ADD KEY `ID_Producto` (`ID_Producto`);

--
-- Indices de la tabla `turnos`
--
ALTER TABLE `turnos`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `ID_Enfermero` (`ID_Enfermero`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `cirugias`
--
ALTER TABLE `cirugias`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `citas`
--
ALTER TABLE `citas`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `doctores`
--
ALTER TABLE `doctores`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `enfermeros`
--
ALTER TABLE `enfermeros`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `eps`
--
ALTER TABLE `eps`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `facturacion`
--
ALTER TABLE `facturacion`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `habitaciones`
--
ALTER TABLE `habitaciones`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `historias_clinicas`
--
ALTER TABLE `historias_clinicas`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `hospitalizaciones`
--
ALTER TABLE `hospitalizaciones`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `medicamentos`
--
ALTER TABLE `medicamentos`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `pacientes`
--
ALTER TABLE `pacientes`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `prescripciones`
--
ALTER TABLE `prescripciones`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `procedimientos`
--
ALTER TABLE `procedimientos`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `procedimientos_realizados`
--
ALTER TABLE `procedimientos_realizados`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `productos`
--
ALTER TABLE `productos`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `proveedores`
--
ALTER TABLE `proveedores`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `recetas`
--
ALTER TABLE `recetas`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `suministros`
--
ALTER TABLE `suministros`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `turnos`
--
ALTER TABLE `turnos`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `cirugias`
--
ALTER TABLE `cirugias`
  ADD CONSTRAINT `cirugias_ibfk_1` FOREIGN KEY (`ID_Paciente`) REFERENCES `pacientes` (`ID`),
  ADD CONSTRAINT `cirugias_ibfk_2` FOREIGN KEY (`ID_Doctor`) REFERENCES `doctores` (`ID`);

--
-- Filtros para la tabla `citas`
--
ALTER TABLE `citas`
  ADD CONSTRAINT `citas_ibfk_1` FOREIGN KEY (`ID_Paciente`) REFERENCES `pacientes` (`ID`),
  ADD CONSTRAINT `citas_ibfk_2` FOREIGN KEY (`ID_Doctor`) REFERENCES `doctores` (`ID`);

--
-- Filtros para la tabla `doctores`
--
ALTER TABLE `doctores`
  ADD CONSTRAINT `doctores_ibfk_1` FOREIGN KEY (`ID_EPS`) REFERENCES `eps` (`ID`);

--
-- Filtros para la tabla `facturacion`
--
ALTER TABLE `facturacion`
  ADD CONSTRAINT `facturacion_ibfk_1` FOREIGN KEY (`ID_Paciente`) REFERENCES `pacientes` (`ID`);

--
-- Filtros para la tabla `historias_clinicas`
--
ALTER TABLE `historias_clinicas`
  ADD CONSTRAINT `historias_clinicas_ibfk_1` FOREIGN KEY (`ID_Paciente`) REFERENCES `pacientes` (`ID`);

--
-- Filtros para la tabla `hospitalizaciones`
--
ALTER TABLE `hospitalizaciones`
  ADD CONSTRAINT `hospitalizaciones_ibfk_1` FOREIGN KEY (`ID_Paciente`) REFERENCES `pacientes` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `hospitalizaciones_ibfk_2` FOREIGN KEY (`ID_Doctor`) REFERENCES `doctores` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `pacientes`
--
ALTER TABLE `pacientes`
  ADD CONSTRAINT `pacientes_ibfk_1` FOREIGN KEY (`ID_EPS`) REFERENCES `eps` (`ID`);

--
-- Filtros para la tabla `prescripciones`
--
ALTER TABLE `prescripciones`
  ADD CONSTRAINT `prescripciones_ibfk_1` FOREIGN KEY (`ID_Paciente`) REFERENCES `pacientes` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `prescripciones_ibfk_2` FOREIGN KEY (`ID_Doctor`) REFERENCES `doctores` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `prescripciones_ibfk_3` FOREIGN KEY (`ID_Medicamento`) REFERENCES `medicamentos` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `procedimientos_realizados`
--
ALTER TABLE `procedimientos_realizados`
  ADD CONSTRAINT `procedimientos_realizados_ibfk_1` FOREIGN KEY (`ID_Enfermero`) REFERENCES `enfermeros` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `procedimientos_realizados_ibfk_2` FOREIGN KEY (`ID_Procedimiento`) REFERENCES `procedimientos` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `procedimientos_realizados_ibfk_3` FOREIGN KEY (`ID_Paciente`) REFERENCES `pacientes` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `procedimientos_realizados_ibfk_4` FOREIGN KEY (`ID_Doctor`) REFERENCES `doctores` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `recetas`
--
ALTER TABLE `recetas`
  ADD CONSTRAINT `recetas_ibfk_1` FOREIGN KEY (`ID_Historia`) REFERENCES `historias_clinicas` (`ID`),
  ADD CONSTRAINT `recetas_ibfk_2` FOREIGN KEY (`ID_Medicamento`) REFERENCES `medicamentos` (`ID`);

--
-- Filtros para la tabla `suministros`
--
ALTER TABLE `suministros`
  ADD CONSTRAINT `suministros_ibfk_1` FOREIGN KEY (`ID_Proveedor`) REFERENCES `proveedores` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `suministros_ibfk_2` FOREIGN KEY (`ID_Producto`) REFERENCES `productos` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `turnos`
--
ALTER TABLE `turnos`
  ADD CONSTRAINT `turnos_ibfk_1` FOREIGN KEY (`ID_Enfermero`) REFERENCES `enfermeros` (`ID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
