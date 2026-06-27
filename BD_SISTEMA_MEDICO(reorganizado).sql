-- ====================================================================
-- 1. CREACIÓN DE TABLAS (ORDENADAS POR DEPENDENCIAS)
-- ====================================================================

-- TABLA TIPO DOCUMENTO
CREATE TABLE tipo_documento ( 
    id_tipo_doc SERIAL PRIMARY KEY, 
    abreviatura VARCHAR(10) NOT NULL, 
    nombre_completo VARCHAR(50) NOT NULL 
); 

-- TABLA DEPARTAMENTO
CREATE TABLE departamento ( 
    id_departamento SERIAL PRIMARY KEY, 
    nombre_departamento VARCHAR(100) NOT NULL 
); 

-- TABLA CARGO
CREATE TABLE cargo ( 
    id_cargo SERIAL PRIMARY KEY, 
    id_departamento INT NOT NULL, 
    nombre_cargo VARCHAR(100) NOT NULL, 
    sueldo_base DECIMAL(10,2), 
    CONSTRAINT fk_cargo_depto FOREIGN KEY (id_departamento) REFERENCES departamento(id_departamento) 
); 

-- TABLA EMPLEADO
CREATE TABLE empleado (
    id_empleado SERIAL PRIMARY KEY,
    id_tipo_doc INT NOT NULL,
    numero_doc VARCHAR(20) UNIQUE NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    fecha_contratacion DATE DEFAULT CURRENT_DATE,
    id_cargo INT NOT NULL,

    FOREIGN KEY (id_tipo_doc) REFERENCES tipo_documento(id_tipo_doc)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (id_cargo) REFERENCES cargo(id_cargo)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- TABLE TURNO
CREATE TABLE turno (
    id_turno SERIAL PRIMARY KEY,
    nombre_turno VARCHAR(50) NOT NULL, -- Mañana, Tarde, Noche
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    CHECK (hora_inicio < hora_fin)
);

-- TABLE ASISTENCIA
CREATE TABLE asistencia (
    id_asistencia SERIAL PRIMARY KEY,
    id_empleado INT NOT NULL,
    fecha DATE NOT NULL,
    hora_entrada TIME,
    hora_salida TIME,

    CONSTRAINT fk_asist_emp 
    FOREIGN KEY (id_empleado) 
    REFERENCES empleado(id_empleado)
);

-- TABLE ROL SISTEMA
CREATE TABLE rol_sistema (
    id_rol SERIAL PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL
);

-- TABLA USUARIO
CREATE TABLE usuario (
    id_usuario SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    id_empleado INT NOT NULL,
    id_rol INT NOT NULL,
    estado VARCHAR(20) DEFAULT 'Activo',

    CONSTRAINT fk_user_emp 
    FOREIGN KEY (id_empleado) 
    REFERENCES empleado(id_empleado),

    CONSTRAINT fk_user_rol 
    FOREIGN KEY (id_rol) 
    REFERENCES rol_sistema(id_rol),

    CONSTRAINT chk_estado_usuario
    CHECK (estado IN ('Activo','Inactivo'))
);

-- TABLA MODULO SISTEMA
CREATE TABLE modulo_sistema (
    id_modulo SERIAL PRIMARY KEY,
    nombre_modulo VARCHAR(100) NOT NULL
);

-- TABLA PERMISOS
CREATE TABLE permiso_rol (
    id_permiso SERIAL PRIMARY KEY,
    id_rol INT NOT NULL,
    id_modulo INT NOT NULL,
    puede_leer BOOLEAN DEFAULT FALSE,
    puede_escribir BOOLEAN DEFAULT FALSE,
    puede_eliminar BOOLEAN DEFAULT FALSE,

    CONSTRAINT fk_permiso_rol 
    FOREIGN KEY (id_rol) 
    REFERENCES rol_sistema(id_rol),

    CONSTRAINT fk_permiso_mod 
    FOREIGN KEY (id_modulo) 
    REFERENCES modulo_sistema(id_modulo),

    CONSTRAINT uk_permiso UNIQUE (id_rol, id_modulo)
);

-- TABLA PACIENTE
CREATE TABLE paciente (
    id_paciente SERIAL PRIMARY KEY,
    dni VARCHAR(8) UNIQUE NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    genero CHAR(1) NOT NULL,
    ubigeo VARCHAR(6) NULL
);

-- TABLA ASEGURADORA
CREATE TABLE aseguradora (
    id_aseguradora SERIAL PRIMARY KEY,
    nro_ruc VARCHAR(11) UNIQUE NOT NULL,
    razon_social VARCHAR(150) NOT NULL,
    telefono VARCHAR(15) NULL
);

-- TABLA PLAN_SEGURO
CREATE TABLE plan_seguro (
    id_plan SERIAL PRIMARY KEY,
    id_aseguradora INT NOT NULL,
    nombre_plan VARCHAR(100) NOT NULL,
    cobertura DECIMAL(5,2) NOT NULL,

    FOREIGN KEY (id_aseguradora) REFERENCES aseguradora(id_aseguradora)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

-- TABLA ESPECIALIDAD
CREATE TABLE especialidad (
    id_especialidad SERIAL PRIMARY KEY,
    especialidad VARCHAR(100) UNIQUE NOT NULL,
    descripcion TEXT NULL
);

-- TABLA MEDICO
CREATE TABLE medico (
    id_medico SERIAL PRIMARY KEY,
    id_empleado INT NOT NULL, 
    cmp VARCHAR(10) UNIQUE NOT NULL,
    id_especialidad INT NOT NULL,
    correo VARCHAR(100) NOT NULL,

    FOREIGN KEY (id_especialidad) REFERENCES especialidad(id_especialidad)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
    FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

-- TABLA CONSULTORIO
CREATE TABLE consultorio (
    id_consultorio SERIAL PRIMARY KEY,
    nro_consultorio VARCHAR(10) NOT NULL,
    nro_piso INT NOT NULL,
    sede VARCHAR(50) NOT NULL
);

-- TABLA ESTADO_CITA
CREATE TABLE estado_cita (
    id_estado SERIAL PRIMARY KEY,
    descripcion VARCHAR(50) UNIQUE NOT NULL
);

-- TABLA CITA
CREATE TABLE cita (
    id_cita SERIAL PRIMARY KEY,
    id_paciente INT NOT NULL,
    id_medico INT NOT NULL,
    id_consultorio INT NOT NULL,
    id_estado INT NOT NULL,
    fecha_cita DATE NOT NULL,
    hora_cita TIME NOT NULL,

    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
    FOREIGN KEY (id_medico) REFERENCES medico(id_medico)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
    FOREIGN KEY (id_consultorio) REFERENCES consultorio(id_consultorio)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
    FOREIGN KEY (id_estado) REFERENCES estado_cita(id_estado)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

-- TABLA DISPONIBILIDAD_MEDICA
CREATE TABLE disponibilidad_medica (
    id_disponibilidad SERIAL PRIMARY KEY,
    id_medico INT NOT NULL,
    dia_semana VARCHAR(15) NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,

    FOREIGN KEY (id_medico) REFERENCES medico(id_medico)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

-- TABLA RESERVA_ONLINE
CREATE TABLE reserva_online (
    id_reserva SERIAL PRIMARY KEY,
    id_cita INT NOT NULL,
    token VARCHAR(255) NOT NULL,
    fecha_expiracion TIMESTAMP NOT NULL,

    FOREIGN KEY (id_cita) REFERENCES cita(id_cita)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

-- TABLA PABELLON
CREATE TABLE pabellon (
    id_pabellon SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    sector VARCHAR(50) NOT NULL,
    numero_pisos INT NOT NULL DEFAULT 1 CHECK (numero_pisos > 0)
);

-- TABLA HABITACION
CREATE TABLE habitacion (
    id_habitacion SERIAL PRIMARY KEY,
    id_pabellon INT NOT NULL,
    numero_habitacion VARCHAR(10) NOT NULL,
    tipo VARCHAR(20) NOT NULL DEFAULT 'Compartida',
    UNIQUE (id_pabellon, numero_habitacion),
    FOREIGN KEY (id_pabellon) REFERENCES pabellon(id_pabellon),
    CHECK (tipo IN ('Privada','Compartida'))
);

-- TABLA TIPO CAMA
CREATE TABLE tipo_cama (
    id_tipo SERIAL PRIMARY KEY,
    descripcion VARCHAR(50) NOT NULL UNIQUE,
    costo_dia DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (costo_dia >= 0)
);

-- TABLA ESTADO CAMA
CREATE TABLE estado_cama (
    id_estado SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

-- TABLA CAMA
CREATE TABLE cama (
    id_cama SERIAL PRIMARY KEY,
    id_habitacion INT NOT NULL,
    id_tipo INT NOT NULL,
    id_estado INT NOT NULL,
    codigo_cama VARCHAR(20) NOT NULL UNIQUE,
    FOREIGN KEY (id_habitacion) REFERENCES habitacion(id_habitacion),
    FOREIGN KEY (id_tipo) REFERENCES tipo_cama(id_tipo),
    FOREIGN KEY (id_estado) REFERENCES estado_cama(id_estado)
);

-- TABLA ADMISION
CREATE TABLE admision (
    id_admision SERIAL PRIMARY KEY,
    id_paciente INT NOT NULL,
    fecha_ingreso TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    motivo_ingreso TEXT NOT NULL,
    id_medico_responsable INT NOT NULL,
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente),
    FOREIGN KEY (id_medico_responsable) REFERENCES medico(id_medico)
);

-- TABLA HOSPITALIZACION
CREATE TABLE hospitalizacion (
    id_hospitalizacion SERIAL PRIMARY KEY,
    id_admision INT NOT NULL UNIQUE,
    id_cama INT NOT NULL,
    fecha_asignacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_liberacion TIMESTAMP,
    FOREIGN KEY (id_admision) REFERENCES admision(id_admision),
    FOREIGN KEY (id_cama) REFERENCES cama(id_cama)
);

-- TABLA VISITA MEDICA DIARIA
CREATE TABLE visita_medica_diaria (
    id_visita SERIAL PRIMARY KEY,
    id_hospitalizacion INT NOT NULL,
    id_medico INT NOT NULL,
    fecha_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    evolucion TEXT NOT NULL,
    FOREIGN KEY (id_hospitalizacion) REFERENCES hospitalizacion(id_hospitalizacion),
    FOREIGN KEY (id_medico) REFERENCES medico(id_medico)
);

-- TABLA ALTA MEDICA
CREATE TABLE alta_medica (
    id_alta SERIAL PRIMARY KEY,
    id_hospitalizacion INT NOT NULL UNIQUE,
    fecha_alta TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diagnostico_final TEXT NOT NULL,
    indicaciones TEXT,
    FOREIGN KEY (id_hospitalizacion) REFERENCES hospitalizacion(id_hospitalizacion)
);

-- TABLA TRASLADO CAMA
CREATE TABLE traslado_cama (
    id_traslado SERIAL PRIMARY KEY,
    id_hospitalizacion INT NOT NULL,
    id_cama_origen INT NOT NULL,
    id_cama_destino INT NOT NULL,
    motivo TEXT NOT NULL,
    fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_hospitalizacion) REFERENCES hospitalizacion(id_hospitalizacion),
    FOREIGN KEY (id_cama_origen) REFERENCES cama(id_cama),
    FOREIGN KEY (id_cama_destino) REFERENCES cama(id_cama),
    CHECK (id_cama_origen <> id_cama_destino)
);

-- TABLA CATEGORIA MEDICAMENTO
CREATE TABLE categoria_medicamento (
    id_categoria SERIAL PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    descripcion TEXT NULL
);

-- TABLA PRESENTACION
CREATE TABLE presentacion (
    id_presentacion SERIAL PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL
);

-- TABLA MEDICAMENTO
CREATE TABLE medicamento (
    id_medicamento SERIAL PRIMARY KEY,
    id_categoria INT NOT NULL,
    id_presentacion INT NOT NULL,
    nombre_generico VARCHAR(100) NOT NULL,
    nombre_comercial VARCHAR(100) NULL,

    FOREIGN KEY (id_categoria) REFERENCES categoria_medicamento(id_categoria)
    ON UPDATE CASCADE
    ON DELETE CASCADE,

    FOREIGN KEY (id_presentacion) REFERENCES presentacion(id_presentacion)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

-- TABLA PROVEEDOR
CREATE TABLE proveedor (
    id_proveedor SERIAL PRIMARY KEY,
    ruc VARCHAR(11) UNIQUE NOT NULL,
    razon_social VARCHAR(150) NOT NULL,
    direccion VARCHAR(200) NULL,
    telefono VARCHAR(20) NULL
);

-- TABLA LOTE
CREATE TABLE lote (
    id_lote SERIAL PRIMARY KEY,
    id_medicamento INT NOT NULL,
    id_proveedor INT NOT NULL,
    fecha_fabricacion DATE NOT NULL,
    fecha_vencimiento DATE NOT NULL,

    FOREIGN KEY (id_medicamento) REFERENCES medicamento(id_medicamento)
    ON UPDATE CASCADE
    ON DELETE CASCADE,

    FOREIGN KEY (id_proveedor) REFERENCES proveedor(id_proveedor)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

-- TABLA ALMACEN
CREATE TABLE almacen (
    id_almacen SERIAL PRIMARY KEY,
    nombre_almacen VARCHAR(100) NOT NULL,
    ubicacion VARCHAR(150) NULL
);

-- TABLA INVENTARIO
CREATE TABLE inventario (
    id_inventario SERIAL PRIMARY KEY,
    id_lote INT NOT NULL,
    id_almacen INT NOT NULL,
    cantidad_stock INT NOT NULL CHECK (cantidad_stock >= 0),
    stock_minimo INT NOT NULL CHECK (stock_minimo >= 0),

    FOREIGN KEY (id_lote) REFERENCES lote(id_lote)
    ON UPDATE CASCADE
    ON DELETE CASCADE,

    FOREIGN KEY (id_almacen) REFERENCES almacen(id_almacen)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

-- TABLA RECETA MEDICA (Corregido con FK formal)
CREATE TABLE receta_medica (
    id_receta SERIAL PRIMARY KEY,
    id_cita INT NOT NULL,
    id_medico INT NOT NULL,
    fecha_emision TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    instrucciones_generales TEXT NULL,
    
    FOREIGN KEY (id_cita) REFERENCES cita(id_cita) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_medico) REFERENCES medico(id_medico) ON UPDATE CASCADE ON DELETE CASCADE
);

-- TABLA DETALLE RECETA
CREATE TABLE detalle_receta (
    id_detalle_receta SERIAL PRIMARY KEY,
    id_receta INT NOT NULL,
    id_medicamento INT NOT NULL,
    dosis VARCHAR(50) NOT NULL,
    frecuencia VARCHAR(50) NOT NULL,
    duracion VARCHAR(50) NOT NULL,

    FOREIGN KEY (id_receta) REFERENCES receta_medica(id_receta)
    ON UPDATE CASCADE
    ON DELETE CASCADE,

    FOREIGN KEY (id_medicamento) REFERENCES medicamento(id_medicamento)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

-- TABLA ENTREGA MEDICAMENTO
CREATE TABLE entrega_medicamento (
    id_entrega SERIAL PRIMARY KEY,
    id_detalle_receta INT NOT NULL,
    cantidad_entregada INT NOT NULL CHECK (cantidad_entregada > 0),
    fecha_entrega TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (id_detalle_receta) REFERENCES detalle_receta(id_detalle_receta)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

---TABLA TIPO_EXAMEN
CREATE TABLE tipo_examen (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    preparacion_previa TEXT
);

--TABLA EXAMEN
CREATE TABLE examen (
    id SERIAL PRIMARY KEY,
    id_tipo INT NOT NULL,
    codigo_examen VARCHAR(20) UNIQUE NOT NULL,
    costo_base DECIMAL(10,2) NOT NULL,
    
    FOREIGN KEY (id_tipo) REFERENCES tipo_examen(id)
);

--TABLA ORDEN_LABORATORIO
CREATE TABLE orden_laboratorio (
    id SERIAL PRIMARY KEY,
    id_paciente INT NOT NULL,
    id_medico INT NOT NULL,
    fecha_orden TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    prioridad VARCHAR(20) CHECK (prioridad IN ('Normal', 'Urgente'))
);

--TABLA DETALLE_ORDEN
CREATE TABLE detalle_orden (
    id SERIAL PRIMARY KEY,
    id_orden INT NOT NULL,
    id_examen INT NOT NULL,
    estado VARCHAR(20) CHECK (estado IN ('Pendiente', 'Procesando', 'Completado')),
    
    FOREIGN KEY (id_orden) REFERENCES orden_laboratorio(id),
    FOREIGN KEY (id_examen) REFERENCES examen(id)
);

--TABLA TIPO_MUESTRA
CREATE TABLE tipo_muestra (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

--TABLA MUESTRA
CREATE TABLE muestra (
    id SERIAL PRIMARY KEY,
    id_detalle_orden INT NOT NULL,
    id_tipo_muestra INT NOT NULL,
    codigo_barras VARCHAR(50) UNIQUE,
    fecha_toma TIMESTAMP,
    
    FOREIGN KEY (id_detalle_orden) REFERENCES detalle_orden(id),
    FOREIGN KEY (id_tipo_muestra) REFERENCES tipo_muestra(id)
);

--TABLA TECNOLOGO_MEDICO
CREATE TABLE tecnologo_medico (
    id SERIAL PRIMARY KEY,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    nro_licencia VARCHAR(50) UNIQUE NOT NULL
);

--TABLA EQUIPO_MEDICO
CREATE TABLE equipo_medico (
    id SERIAL PRIMARY KEY,
    nombre_equipo VARCHAR(100) NOT NULL,
    marca VARCHAR(100),
    modelo VARCHAR(100),
    fecha_ultimo_mantenimiento DATE
);

--TABLA RESULTADO
CREATE TABLE resultado (
    id SERIAL PRIMARY KEY,
    id_detalle_orden INT NOT NULL,
    id_tecnologo INT NOT NULL,
    id_equipo INT NOT NULL,
    fecha_resultado TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valores_obtenidos TEXT NOT NULL,
    
    FOREIGN KEY (id_detalle_orden) REFERENCES detalle_orden(id),
    FOREIGN KEY (id_tecnologo) REFERENCES tecnologo_medico(id),
    FOREIGN KEY (id_equipo) REFERENCES equipo_medico(id)
);

--TABLA PARAMETRO_REFERENCIA
CREATE TABLE parametro_referencia (
    id SERIAL PRIMARY KEY,
    id_examen INT NOT NULL,
    genero_aplica VARCHAR(20),
    rango_minimo DECIMAL(10,2),
    rango_maximo DECIMAL(10,2),
    
    FOREIGN KEY (id_examen) REFERENCES examen(id)
);

-- TABLA SERVICIO HOSPITALARIO
CREATE TABLE servicio_hospitalario (
    id_servicio SERIAL PRIMARY KEY,
    nombre_servicio VARCHAR(150) NOT NULL UNIQUE,
    costo_sin_seguro DECIMAL(10,2) NOT NULL CHECK (costo_sin_seguro >= 0)
);

-- TABLA TARIFARIO
CREATE TABLE tarifario (
    id_tarifario SERIAL PRIMARY KEY,
    id_servicio INT NOT NULL,
    id_aseguradora INT NOT NULL,
    costo_con_seguro DECIMAL(10,2) NOT NULL CHECK (costo_con_seguro >= 0),

    FOREIGN KEY (id_servicio) REFERENCES servicio_hospitalario(id_servicio),
    FOREIGN KEY (id_aseguradora) REFERENCES aseguradora(id_aseguradora),

    UNIQUE (id_servicio, id_aseguradora)
);

-- TABLA CAJA
CREATE TABLE caja (
    id_caja SERIAL PRIMARY KEY,
    nombre_caja VARCHAR(100) NOT NULL,
    nro_terminal VARCHAR(20) UNIQUE NOT NULL
);

-- TABLA CAJERO
CREATE TABLE cajero (
    id_cajero SERIAL PRIMARY KEY,
    id_empleado INT NOT NULL,
    id_turno INT NOT NULL,

    FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado),
    FOREIGN KEY (id_turno) REFERENCES turno(id_turno)
);

-- TABLA APERTURA CAJA
CREATE TABLE apertura_caja (
    id_apertura SERIAL PRIMARY KEY,
    id_caja INT NOT NULL,
    id_cajero INT NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    monto_inicial DECIMAL(10,2) NOT NULL CHECK (monto_inicial >= 0),

    FOREIGN KEY (id_caja) REFERENCES caja(id_caja),
    FOREIGN KEY (id_cajero) REFERENCES cajero(id_cajero)
);

-- TABLA COMPROBANTE
CREATE TABLE comprobante_pago (
    id_comprobante SERIAL PRIMARY KEY,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('Boleta','Factura')),
    serie VARCHAR(10) NOT NULL,
    correlativo VARCHAR(20) NOT NULL,

    UNIQUE (serie, correlativo)
);

-- TABLA METODO DE PAGO
CREATE TABLE metodo_pago (
    id_metodo SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

-- TABLA FACTURACION
CREATE TABLE facturacion (
    id_facturacion SERIAL PRIMARY KEY,
    id_paciente INT NOT NULL,
    id_comprobante INT NOT NULL,
    fecha_emision TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    subtotal DECIMAL(10,2) NOT NULL,
    igv DECIMAL(10,2) NOT NULL,
    total DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente),
    FOREIGN KEY (id_comprobante) REFERENCES comprobante_pago(id_comprobante)
);

-- TABLA DETALLE FACTURACION
CREATE TABLE detalle_facturacion (
    id_detalle SERIAL PRIMARY KEY,
    id_facturacion INT NOT NULL,
    id_servicio INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(10,2) NOT NULL,
    descuento_seguro DECIMAL(10,2) DEFAULT 0,

    FOREIGN KEY (id_facturacion) REFERENCES facturacion(id_facturacion),
    FOREIGN KEY (id_servicio) REFERENCES servicio_hospitalario(id_servicio)
);

-- TABLA PAGO
CREATE TABLE pago (
    id_pago SERIAL PRIMARY KEY,
    id_facturacion INT NOT NULL,
    id_metodo INT NOT NULL,
    monto_pagado DECIMAL(10,2) NOT NULL CHECK (monto_pagado > 0),
    fecha_pago TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (id_facturacion) REFERENCES facturacion(id_facturacion),
    FOREIGN KEY (id_metodo) REFERENCES metodo_pago(id_metodo)
);


-- ====================================================================
-- 2. INSERCIÓN DE DATOS (ORDENADOS CRONOLÓGICAMENTE)
-- ====================================================================

-- TABLA TIPO DOCUMENTO
INSERT INTO tipo_documento (abreviatura, nombre_completo) VALUES
('DNI', 'Documento Nacional de Identidad'),
('CE', 'Carnet de Extranjería');

-- TABLA DEPARTAMENTO
INSERT INTO departamento (nombre_departamento) VALUES
('Medicina Externa'),
('Recursos Humanos'),
('Finanzas e Infraestructura');

-- TABLA CARGO
INSERT INTO cargo (id_departamento, nombre_cargo, sueldo_base) VALUES
(1, 'Médico Especialista', 6500.00),
(3, 'Cajero Operativo', 1500.00);

-- TABLA EMPLEADO (Datos requeridos para que funcione la tabla MEDICO)
INSERT INTO empleado (id_tipo_doc, numero_doc, nombres, apellidos, id_cargo) VALUES
(1, '70000001', 'Carlos', 'Augusto', 1),
(1, '70000002', 'Beatriz', 'Luna', 1),
(1, '70000003', 'Daniel', 'Gamarra', 1),
(1, '70000004', 'Elena', 'Paredes', 1),
(1, '70000005', 'Felipe', 'Tello', 1),
(1, '70000006', 'Gabriela', 'Solís', 1),
(1, '70000007', 'Héctor', 'Milla', 1),
(1, '70000008', 'Irene', 'Benavides', 1),
(1, '70000009', 'Julio', 'Chávez', 1),
(1, '70000010', 'Katia', 'Zegarra', 1);

-- TABLA TURNO
INSERT INTO turno (nombre_turno, hora_inicio, hora_fin) VALUES
('Mañana', '07:00:00', '13:00:00'),
('Tarde', '13:00:00', '19:00:00');

-- TABLA PACIENTE
INSERT INTO paciente (dni, nombres, apellidos, fecha_nacimiento, genero, ubigeo) VALUES
('12345678', 'Juan Carlos', 'Perez Silva', '1985-04-12', 'M', '150101'),
('87654321', 'Maria Elena', 'Gomez Ruiz', '1990-08-25', 'F', '150102'),
('11223344', 'Luis Fernando', 'Lopez Vega', '1978-11-05', 'M', '150103'),
('55667788', 'Ana Luisa', 'Torres Rios', '2000-02-14', 'F', NULL),
('99887766', 'Carlos Raul', 'Mendoza Diaz', '1995-09-30', 'M', '150105'),
('22334455', 'Lucia', 'Fernandez Ramos', '1988-06-18', 'F', '150106'),
('66778899', 'Miguel Angel', 'Cruz Vargas', '1982-12-01', 'M', '150107'),
('33445566', 'Rosa Maria', 'Salazar Castro', '1975-03-22', 'F', NULL),
('77889900', 'Jorge', 'Navarro Ortiz', '1992-07-10', 'M', '150109'),
('44556677', 'Carmen', 'Ibanez Soto', '1989-05-28', 'F', '150110');

SELECT * FROM paciente;

-- TABLA ASEGURADORA
INSERT INTO aseguradora (nro_ruc, razon_social, telefono) VALUES
('20100047211', 'Rimac Seguros y Reaseguros', '014111111'),
('20332970411', 'Pacifico Seguros', '015135000'),
('20432395011', 'Mapfre Peru', '012133333'),
('20501103211', 'Sanitas Peru EPS', '016100000'),
('20112233441', 'Essalud EPS', '012345678'),
('20445566771', 'La Positiva Seguros', '015555555'),
('20778899001', 'Qualitas Seguros', '013333333'),
('20123123121', 'Chubb Peru Seguros', '014444444'),
('20987654321', 'Interseguro Cia de Seguros', '016666666'),
('20456456451', 'Seguros Sura', NULL);

SELECT * FROM aseguradora;

-- TABLA PLAN_SEGURO
INSERT INTO plan_seguro (id_aseguradora, nombre_plan, cobertura) VALUES
(1, 'Plan Base Salud', 70.00),
(1, 'Plan Premium', 90.00),
(2, 'Salud Oro', 85.00),
(2, 'Salud Platino', 100.00),
(3, 'Mapfre Completo', 80.00),
(4, 'Sanitas Total', 90.00),
(5, 'Cobertura Regular', 100.00),
(6, 'Positiva EPS', 75.00),
(1, 'Plan Red Medica', 60.00),
(3, 'Mapfre Basico', 50.00);

SELECT * FROM plan_seguro;

-- TABLA ESPECIALIDAD
INSERT INTO especialidad (especialidad, descripcion) VALUES
('Medicina General', 'Atencion primaria y diagnostico inicial.'),
('Pediatria', 'Atencion medica para bebes, ninos y adolescentes.'),
('Cardiologia', 'Enfermedades del corazon y sistema circulatorio.'),
('Dermatologia', 'Cuidado y enfermedades de la piel.'),
('Ginecologia', 'Salud del sistema reproductor femenino.'),
('Neurologia', 'Trastornos del sistema nervioso.'),
('Traumatologia', 'Lesiones del sistema locomotor.'),
('Oftalmologia', 'Cuidado y enfermedades de los ojos.'),
('Gastroenterologia', 'Enfermedades del sistema digestivo.'),
('Odontologia', 'Cuidado de los dientes y salud bucal.');

SELECT * FROM especialidad;

-- TABLA MEDICO
INSERT INTO medico (id_empleado, cmp, id_especialidad, correo) VALUES
(1, 'CMP10001', 1, 'm.general1@clinica.com'),
(2, 'CMP10002', 2, 'pediatra1@clinica.com'),
(3, 'CMP10003', 3, 'cardiologo1@clinica.com'),
(4, 'CMP10004', 4, 'dermatologia@clinica.com'),
(5, 'CMP10005', 5, 'ginecologa1@clinica.com'),
(6, 'CMP10006', 6, 'neurologo1@clinica.com'),
(7, 'CMP10007', 7, 'traumatologo1@clinica.com'),
(8, 'CMP10008', 8, 'oftalmologo1@clinica.com'),
(9, 'CMP10009', 9, 'gastroenterologia@clinica.com'),
(10, 'CMP10010', 10, 'odontologo1@clinica.com');

SELECT * FROM medico;

-- TABLA CONSULTORIO
INSERT INTO consultorio (nro_consultorio, nro_piso, sede) VALUES
('101A', 1, 'Sede Central'),
('102B', 1, 'Sede Central'),
('201A', 2, 'Sede Central'),
('202B', 2, 'Sede Central'),
('301A', 3, 'Sede Central'),
('101C', 1, 'Sede Norte'),
('102C', 1, 'Sede Norte'),
('201C', 2, 'Sede Norte'),
('101D', 1, 'Sede Sur'),
('102D', 1, 'Sede Sur');

SELECT * FROM consultorio;

-- TABLA ESTADO_CITA
INSERT INTO estado_cita (descripcion) VALUES
('PROGRAMADA'),
('ATENDIDA'),
('CANCELADA'),
('REPROGRAMADA'),
('EN SALA DE ESPERA'),
('NO ASISTIO'),
('POR CONFIRMAR');

SELECT * FROM estado_cita;

-- TABLA CITA
INSERT INTO cita (id_paciente, id_medico, id_consultorio, id_estado, fecha_cita, hora_cita) VALUES
(1, 1, 1, 1, '2026-05-15', '08:00:00'),
(2, 2, 2, 2, '2026-05-08', '09:30:00'),
(3, 3, 3, 3, '2026-05-16', '10:00:00'),
(4, 4, 4, 1, '2026-05-20', '11:15:00'),
(5, 5, 5, 2, '2026-05-09', '15:00:00'),
(6, 6, 6, 4, '2026-05-22', '16:30:00'),
(7, 7, 7, 5, '2026-05-09', '08:15:00'),
(8, 8, 8, 6, '2026-05-05', '14:00:00'),
(9, 9, 9, 7, '2026-05-25', '10:45:00'),
(10, 10, 10, 1, '2026-05-28', '12:00:00');

SELECT * FROM cita;

-- TABLA DISPONIBILIDAD_MEDICA
INSERT INTO disponibilidad_medica (id_medico, dia_semana, hora_inicio, hora_fin) VALUES
(1, 'LUNES', '08:00:00', '14:00:00'),
(2, 'MARTES', '09:00:00', '13:00:00'),
(3, 'MIERCOLES', '10:00:00', '16:00:00'),
(4, 'JUEVES', '08:00:00', '12:00:00'),
(5, 'VIERNES', '14:00:00', '18:00:00'),
(6, 'SABADO', '08:00:00', '12:00:00'),
(7, 'LUNES', '15:00:00', '19:00:00'),
(8, 'MARTES', '14:00:00', '20:00:00'),
(9, 'MIERCOLES', '08:00:00', '14:00:00'),
(10, 'JUEVES', '16:00:00', '21:00:00');

SELECT * FROM disponibilidad_medica;

-- TABLA RESERVA_ONLINE
INSERT INTO reserva_online (id_cita, token, fecha_expiracion) VALUES
(1, 'abc123token_seguro', '2026-05-14 08:00:00'),
(3, 'xyz987token_cancel', '2026-05-15 10:00:00'),
(4, 'qwe456token_web', '2026-05-19 11:15:00'),
(6, 'rty789token_reprog', '2026-05-21 16:30:00'),
(9, 'uio111token_conf', '2026-05-24 10:45:00'),
(10, 'pas222token_web', '2026-05-27 12:00:00'),
(2, 'dfg333token_old', '2026-05-07 09:30:00'),
(5, 'hjk444token_old', '2026-05-08 15:00:00'),
(7, 'lzx555token_hoy', '2026-05-09 08:00:00'),
(8, 'cvb666token_miss', '2026-05-04 14:00:00');

SELECT * FROM reserva_online;