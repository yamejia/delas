<?php
// Configuración básica
session_start();
date_default_timezone_set('America/Guayaquil');

// Configuración de la aplicación
define('APP_NAME', 'Legumbreria Don Pepe');
define('MAX_LOGIN_ATTEMPTS', 4);
define('LOCKOUT_TIME', 30 * 60); // 30 minutos en segundos

// Incluir archivo de conexión a la base de datos
require_once 'database.php';

// Incluir funciones de autenticación
require_once 'auth_functions.php';
?>