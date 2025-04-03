<?php
function verifyCredentials($username, $password) {
    global $pdo;
    
    // Validación básica
    if (empty($username) || empty($password)) {
        return ['success' => false, 'message' => 'Usuario y contraseña son requeridos'];
    }

    try {
        // Consulta optimizada
        $stmt = $pdo->prepare("SELECT 
            usuario_id, 
            username, 
            password_hash,
            cuenta_bloqueada,
            fecha_desbloqueo,
            intentos_fallidos
            FROM usuarios 
            WHERE username = ? OR email = ?");
        
        $stmt->execute([$username, $username]);
        $user = $stmt->fetch();

        if (!$user) {
            return ['success' => false, 'message' => 'Usuario no encontrado'];
        }

        // Verificar bloqueo
        if ($user['cuenta_bloqueada'] && 
            strtotime($user['fecha_desbloqueo']) > time()) {
            return [
                'success' => false,
                'message' => 'Cuenta bloqueada temporalmente'
            ];
        }

        // Verificar contraseña
        if (!password_verify($password, $user['password_hash'])) {
            // Registrar intento fallido
            $pdo->prepare("UPDATE usuarios SET 
                intentos_fallidos = intentos_fallidos + 1 
                WHERE usuario_id = ?")
               ->execute([$user['usuario_id']]);
            
            return ['success' => false, 'message' => 'Contraseña incorrecta'];
        }

        // Login exitoso - Resetear intentos
        $pdo->prepare("UPDATE usuarios SET 
            intentos_fallidos = 0,
            cuenta_bloqueada = 0
            WHERE usuario_id = ?")
           ->execute([$user['usuario_id']]);

        return ['success' => true, 'user' => $user];

    } catch (PDOException $e) {
        // Registrar error en logs
        error_log("Error en login: " . $e->getMessage());
        return [
            'success' => false,
            'message' => 'Error técnico. Contacte al administrador',
            'debug' => $e->getMessage() // Solo en desarrollo
        ];
    }
}
// Función para registrar intento fallido
function registerFailedAttempt($user_id) {
    global $pdo;
    
    try {
        $stmt = $pdo->prepare("UPDATE usuarios SET intentos_fallidos = intentos_fallidos + 1 WHERE usuario_id = :user_id");
        $stmt->bindParam(':user_id', $user_id);
        $stmt->execute();
        
        // Verificar si se debe bloquear la cuenta
        $stmt = $pdo->prepare("SELECT intentos_fallidos FROM usuarios WHERE usuario_id = :user_id");
        $stmt->bindParam(':user_id', $user_id);
        $stmt->execute();
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($result && $result['intentos_fallidos'] >= MAX_LOGIN_ATTEMPTS) {
            lockAccount($user_id);
        }
        
        return true;
    } catch (PDOException $e) {
        return false;
    }
}

// Función para bloquear cuenta
function lockAccount($user_id) {
    global $pdo;
    
    try {
        $unlock_time = date('Y-m-d H:i:s', time() + LOCKOUT_TIME);
        
        $stmt = $pdo->prepare("UPDATE usuarios 
                              SET cuenta_bloqueada = 1, 
                                  fecha_bloqueo = NOW(), 
                                  fecha_desbloqueo = :unlock_time 
                              WHERE usuario_id = :user_id");
        $stmt->bindParam(':user_id', $user_id);
        $stmt->bindParam(':unlock_time', $unlock_time);
        return $stmt->execute();
    } catch (PDOException $e) {
        return false;
    }
}

// Función para desbloquear cuenta
function unlockAccount($user_id) {
    global $pdo;
    
    try {
        $stmt = $pdo->prepare("UPDATE usuarios 
                              SET cuenta_bloqueada = 0, 
                                  intentos_fallidos = 0, 
                                  fecha_bloqueo = NULL, 
                                  fecha_desbloqueo = NULL 
                              WHERE usuario_id = :user_id");
        $stmt->bindParam(':user_id', $user_id);
        return $stmt->execute();
    } catch (PDOException $e) {
        return false;
    }
}

// Función para restablecer intentos fallidos
function resetFailedAttempts($user_id) {
    global $pdo;
    
    try {
        $stmt = $pdo->prepare("UPDATE usuarios SET intentos_fallidos = 0 WHERE usuario_id = :user_id");
        $stmt->bindParam(':user_id', $user_id);
        return $stmt->execute();
    } catch (PDOException $e) {
        return false;
    }
}

// Función para registrar un nuevo usuario
function registerUser($username, $email, $password, $nombre, $apellido, $telefono = null, $direccion = null) {
    global $pdo;
    
    try {
        // Verificar si el usuario o email ya existen
        $stmt = $pdo->prepare("SELECT usuario_id FROM usuarios WHERE username = :username OR email = :email");
        $stmt->bindParam(':username', $username);
        $stmt->bindParam(':email', $email);
        $stmt->execute();
        
        if ($stmt->rowCount() > 0) {
            return [
                'success' => false,
                'message' => 'El nombre de usuario o correo electrónico ya está en uso.'
            ];
        }
        
        // Hash de la contraseña
        $password_hash = password_hash($password, PASSWORD_BCRYPT);
        
        // Obtener ID del rol de cliente
        $stmt = $pdo->prepare("SELECT rol_id FROM roles WHERE nombre_rol = 'cliente'");
        $stmt->execute();
        $rol = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$rol) {
            return [
                'success' => false,
                'message' => 'Error al asignar rol de usuario.'
            ];
        }
        
        // Insertar nuevo usuario
        $stmt = $pdo->prepare("INSERT INTO usuarios (rol_id, username, email, password_hash, nombre, apellido, telefono, direccion) 
                              VALUES (:rol_id, :username, :email, :password_hash, :nombre, :apellido, :telefono, :direccion)");
        $stmt->bindParam(':rol_id', $rol['rol_id']);
        $stmt->bindParam(':username', $username);
        $stmt->bindParam(':email', $email);
        $stmt->bindParam(':password_hash', $password_hash);
        $stmt->bindParam(':nombre', $nombre);
        $stmt->bindParam(':apellido', $apellido);
        $stmt->bindParam(':telefono', $telefono);
        $stmt->bindParam(':direccion', $direccion);
        
        if ($stmt->execute()) {
            return [
                'success' => true,
                'user_id' => $pdo->lastInsertId()
            ];
        } else {
            return [
                'success' => false,
                'message' => 'Error al registrar el usuario.'
            ];
        }
    } catch (PDOException $e) {
        return [
            'success' => false,
            'message' => 'Error en la base de datos: '.$e->getMessage()
        ];
    }
}

// Función para cambiar contraseña
function changePassword($user_id, $current_password, $new_password) {
    global $pdo;
    
    try {
        // Obtener hash actual
        $stmt = $pdo->prepare("SELECT password_hash FROM usuarios WHERE usuario_id = :user_id");
        $stmt->bindParam(':user_id', $user_id);
        $stmt->execute();
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$user) {
            return [
                'success' => false,
                'message' => 'Usuario no encontrado.'
            ];
        }
        
        // Verificar contraseña actual
        if (!password_verify($current_password, $user['password_hash'])) {
            return [
                'success' => false,
                'message' => 'La contraseña actual es incorrecta.'
            ];
        }
        
        // Actualizar contraseña
        $new_password_hash = password_hash($new_password, PASSWORD_BCRYPT);
        
        $stmt = $pdo->prepare("UPDATE usuarios 
                              SET password_hash = :new_password_hash 
                              WHERE usuario_id = :user_id");
        $stmt->bindParam(':new_password_hash', $new_password_hash);
        $stmt->bindParam(':user_id', $user_id);
        
        if ($stmt->execute()) {
            // Registrar en historial de contraseñas
            $stmt = $pdo->prepare("INSERT INTO historial_passwords (usuario_id, password_hash) 
                                  VALUES (:user_id, :old_password_hash)");
            $stmt->bindParam(':user_id', $user_id);
            $stmt->bindParam(':old_password_hash', $user['password_hash']);
            $stmt->execute();
            
            return [
                'success' => true,
                'message' => 'Contraseña cambiada exitosamente.'
            ];
        } else {
            return [
                'success' => false,
                'message' => 'Error al actualizar la contraseña.'
            ];
        }
    } catch (PDOException $e) {
        return [
            'success' => false,
            'message' => 'Error en la base de datos: '.$e->getMessage()
        ];
    }
}
?>