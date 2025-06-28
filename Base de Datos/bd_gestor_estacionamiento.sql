-- Crear la base de datos si no existe
CREATE DATABASE bd_gestor_estacionamiento;
GO

-- Usar la base de datos recién creada
USE bd_gestor_estacionamiento;
GO

-- Tabla para almacenar los diferentes tipos de fracciones de tiempo para el estacionamiento.
-- Por ejemplo, por hora, por día, por mes.
CREATE TABLE [dbo].[ADM_TIPO_FRACCION](
	[CODIGO] [int] NOT NULL, -- Código único que identifica el tipo de fracción. Es la clave primaria.
	[DESCRIPCION] [varchar](100) NULL, -- Descripción del tipo de fracción (ej. "Por Hora", "Diario", "Mensual").
	[TIEMPO_ESTACIONAMIENTO] [time](7) NULL, -- Tiempo estándar de estacionamiento para esta fracción (ej. '01:00:00' para una hora).
	[TIEMPO_TOLERANCIA] [time](7) NULL, -- Tiempo de gracia o tolerancia permitido antes de aplicar la siguiente fracción o recargo.
	[ESTADO] [varchar](1) NULL, -- Estado del tipo de fracción ('A' para Activo, 'I' para Inactivo).
    CONSTRAINT [PKX_ADM_TIPO_FRACCION_01] PRIMARY KEY CLUSTERED
    (
	    [CODIGO] ASC -- Define CODIGO como la clave primaria agrupada.
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

-- Tabla para almacenar los diferentes tipos de vehículos que pueden estacionar.
-- Por ejemplo, carro, moto, camión.
CREATE TABLE [dbo].[ADM_TIPO_VEHICULO](
	[CODIGO] [int] NOT NULL, -- Código único que identifica el tipo de vehículo. Es la clave primaria.
	[DESCRIPCION] [varchar](100) NULL, -- Descripción del tipo de vehículo (ej. "Automóvil", "Motocicleta", "Camioneta").
	[ESTADO] [varchar](1) NULL, -- Estado del tipo de vehículo ('A' para Activo, 'I' para Inactivo).
    CONSTRAINT [PKX_ADM_TIPO_VEHICULO_01] PRIMARY KEY CLUSTERED
    (
	    [CODIGO] ASC -- Define CODIGO como la clave primaria agrupada.
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

-- Tabla para ADM_ESTADO (Agregada: Esta tabla es necesaria para que el procedimiento SP_S_VEN_ESTADIA_1 funcione correctamente)
-- Contiene descripciones de estados genéricos que pueden ser usados en otras tablas.
CREATE TABLE [dbo].[ADM_ESTADO](
	[ID] [varchar](1) NOT NULL, -- Identificador del estado (ej. 'A' para Activo, 'I' para Inactivo, 'C' para Cerrado). Es la clave primaria.
	[DESCRIPCION] [varchar](100) NULL, -- Descripción textual del estado (ej. "Activo", "Inactivo", "Cerrado").
    CONSTRAINT [PKX_ADM_ESTADO_01] PRIMARY KEY CLUSTERED
    (
	    [ID] ASC -- Define ID como la clave primaria agrupada.
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

-- Tabla para gestionar la información de los depósitos o espacios de estacionamiento.
CREATE TABLE [dbo].[INV_DEPOSITO](
	[CODIGO] [int] NOT NULL, -- Código único del depósito. Es la clave primaria.
	[DESCRIPCION] [varchar](100) NULL, -- Descripción del depósito (ej. "Zona A - Nivel 1").
	[ZONA] [int] NULL, -- Número de la zona donde se encuentra el depósito.
	[PASILLO] [varchar](100) NULL, -- Identificación del pasillo.
	[CARA] [varchar](100) NULL, -- Cara o lado del pasillo (ej. "Norte", "Sur").
	[ELEVACION] [int] NULL, -- Nivel o elevación del depósito.
	[ESTADO] [varchar](1) NULL, -- Estado del depósito ('A' para Activo, 'I' para Inactivo, 'O' para Ocupado).
    CONSTRAINT [PKX_INV_DEPOSITO_01] PRIMARY KEY CLUSTERED
    (
	    [CODIGO] ASC -- Define CODIGO como la clave primaria agrupada.
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

-- Tabla para definir las tarifas de estacionamiento.
CREATE TABLE [dbo].[VEN_TARIFA](
    [CODIGO] [int] NOT NULL, -- Código único de la tarifa. Es la clave primaria.
    [DESCRIPCION] [varchar](250) NULL, -- Descripción de la tarifa (ej. "Tarifa estándar por hora de auto").
    [TIPO_TARIFA] [int] NULL, -- Tipo de tarifa (puede ser un código a otra tabla de tipos de tarifa si existiera).
    [TIPO_VEHICULO] [int] NULL, -- Código del tipo de vehículo al que aplica esta tarifa (FK a ADM_TIPO_VEHICULO).
    [TIPO_FRACCION] [int] NULL, -- Código del tipo de fracción al que aplica esta tarifa (FK a ADM_TIPO_FRACCION).
    [PRECIO] [decimal](20, 5) NULL, -- Precio de la tarifa.
    [ESTADO] [varchar](1) NULL, -- Estado de la tarifa ('A' para Activo, 'I' para Inactivo).
    CONSTRAINT [PKX_VEN_TARIFA_01] PRIMARY KEY CLUSTERED
    (
        [CODIGO] ASC -- Define CODIGO como la clave primaria agrupada.
    )
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
    -- Claves foráneas para relacionar con las tablas correspondientes
    CONSTRAINT FK_TIPO_VEHICULO_TARIFA FOREIGN KEY (TIPO_VEHICULO) REFERENCES dbo.ADM_TIPO_VEHICULO(CODIGO), -- Relaciona con ADM_TIPO_VEHICULO.
    CONSTRAINT FK_TIPO_FRACCION_TARIFA FOREIGN KEY (TIPO_FRACCION) REFERENCES dbo.ADM_TIPO_FRACCION(CODIGO) -- Relaciona con ADM_TIPO_FRACCION.
) ON [PRIMARY]
GO

-- Tabla para almacenar la información de los vehículos.
CREATE TABLE [dbo].[VEN_VEHICULO](
	[CODIGO] [int] NOT NULL, -- Código único del vehículo. Es la clave primaria.
	[PLACA] [varchar](25) NULL, -- Número de placa del vehículo.
	[TIPO_VEHICULO] [int] NULL, -- Código del tipo de vehículo (FK a ADM_TIPO_VEHICULO).
	[MARCA] [varchar](100) NULL, -- Marca del vehículo.
	[MODELO] [varchar](100) NULL, -- Modelo del vehículo.
	[COLOR] [varchar](100) NULL, -- Color del vehículo.
	[EXONERADO] [bit] NULL, -- Indica si el vehículo está exonerado de pago (1 para sí, 0 para no).
	[ESTADO] [varchar](1) NULL, -- Estado del vehículo ('A' para Activo, 'I' para Inactivo).
    CONSTRAINT [PKX_VEN_VEHICULO_01] PRIMARY KEY CLUSTERED
    (
	    [CODIGO] ASC -- Define CODIGO como la clave primaria agrupada.
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	-- Clave foránea para relacionar con la tabla ADM_TIPO_VEHICULO
	CONSTRAINT FK_TIPO_VEHICULO_VEHICULO FOREIGN KEY (TIPO_VEHICULO) REFERENCES dbo.ADM_TIPO_VEHICULO(CODIGO) -- Relaciona con ADM_TIPO_VEHICULO.
) ON [PRIMARY]
GO

-- Tabla para almacenar la información de los clientes.
CREATE TABLE [dbo].[VEN_CLIENTE](
	[CODIGO] [varchar](8) NOT NULL, -- Código único del cliente. Es la clave primaria.
	[DOCUMENTO_IDENTIDAD] [int] NULL, -- Tipo de documento de identidad (ej. DNI, RUC).
	[DOCUMENTO_IDENTIDAD_NUMERO] [varchar](25) NULL, -- Número del documento de identidad.
	[RAZON_SOCIAL] [varchar](250) NULL, -- Nombre o razón social del cliente.
	[UBIGEO] [int] NULL, -- Código de ubicación geográfica.
	[DIRECCION] [varchar](250) NULL, -- Dirección del cliente.
	[TELEFONO] [varchar](50) NULL, -- Número de teléfono del cliente.
	[CLIENTE_ERP] [varchar](100) NULL, -- Identificador del cliente en un sistema ERP externo.
	[ESTADO] [varchar](1) NULL, -- Estado del cliente ('A' para Activo, 'I' para Inactivo).
    CONSTRAINT [PKX_VEN_CLIENTE_01] PRIMARY KEY CLUSTERED
    (
	    [CODIGO] ASC -- Define CODIGO como la clave primaria agrupada.
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

-- Tabla para registrar las estadías de los vehículos en el estacionamiento.
CREATE TABLE [dbo].[VEN_ESTADIA](
	[NUMERO] [varchar](25) NOT NULL, -- Número único de la estadía. Es la clave primaria.
	[VEHICULO] [int] NULL, -- Código del vehículo asociado a la estadía (FK a VEN_VEHICULO).
	[CLIENTE] [varchar](8) NULL, -- Código del cliente asociado a la estadía (FK a VEN_CLIENTE).
	[INGRESO] [bit] NULL, -- Indica si el vehículo ha ingresado (1 para sí, 0 para no).
	[FECHA_HORA_INGRESO] [datetime] NULL, -- Fecha y hora exactas de ingreso.
	[FECHA_INGRESO] [date] NULL, -- Solo la fecha de ingreso.
	[HORA_INGRESO] [time](7) NULL, -- Solo la hora de ingreso.
	[SALIDA] [bit] NULL, -- Indica si el vehículo ha salido (1 para sí, 0 para no).
	[FECHA_HORA_SALIDA] [datetime] NULL, -- Fecha y hora exactas de salida.
	[FECHA_SALIDA] [date] NULL, -- Solo la fecha de salida.
	[HORA_SALIDA] [time](7) NULL, -- Solo la hora de salida.
	[DEPOSITO] [int] NULL, -- Código del depósito donde el vehículo estuvo estacionado (FK a INV_DEPOSITO).
	[TARIFA] [int] NULL, -- Código de la tarifa aplicada a esta estadía (FK a VEN_TARIFA).
	[TIEMPO_ESTACIONAMIENTO] [varchar](8) NULL, -- Duración total del estacionamiento.
	[TIEMPO_TOLERANCIA] [varchar](8) NULL, -- Tiempo de tolerancia utilizado.
	[ABONADO] [bit] NULL, -- Indica si la estadía es de un abonado (1 para sí, 0 para no).
	[EXONERADO] [bit] NULL, -- Indica si la estadía fue exonerada de pago (1 para sí, 0 para no).
	[PRECIO] [decimal](20, 5) NULL, -- Precio unitario aplicado por la tarifa.
	[CANTIDAD] [decimal](20, 5) NULL, -- Cantidad de unidades de tiempo (ej. horas, días).
	[IMPORTE] [decimal](20, 5) NULL, -- Importe total a pagar por la estadía.
	[ESTADIA_ERP] [varchar](100) NULL, -- Identificador de la estadía en un sistema ERP externo.
	[ESTADIA_ERP_ITEM] [varchar](100) NULL, -- Ítem de la estadía en el ERP.
	[ESTADIA_ERP_NUMERO] [varchar](100) NULL, -- Número de la estadía en el ERP.
	[COMPROBANTE_ERP] [varchar](100) NULL, -- Tipo de comprobante asociado en el ERP.
	[COMPROBANTE_ERP_NUMERO] [varchar](100) NULL, -- Número del comprobante en el ERP.
	[COMENTARIO] [varchar](200) NULL, -- Comentarios adicionales sobre la estadía.
	[ESTADO] [varchar](1) NULL, -- Estado de la estadía ('A' para Activo, 'C' para Cerrado, 'P' para Pendiente de Pago).
    CONSTRAINT [PKX_VEN_ESTADIA_01] PRIMARY KEY CLUSTERED
    (
	    [NUMERO] ASC -- Define NUMERO como la clave primaria agrupada.
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	-- Claves foráneas para relacionar con las tablas correspondientes
	CONSTRAINT FK_VEHICULO_ESTADIA FOREIGN KEY (VEHICULO) REFERENCES dbo.VEN_VEHICULO(CODIGO), -- Relaciona con VEN_VEHICULO.
	CONSTRAINT FK_CLIENTE_ESTADIA FOREIGN KEY (CLIENTE) REFERENCES dbo.VEN_CLIENTE(CODIGO), -- Relaciona con VEN_CLIENTE.
	CONSTRAINT FK_DEPOSITO_ESTADIA FOREIGN KEY (DEPOSITO) REFERENCES dbo.INV_DEPOSITO(CODIGO), -- Relaciona con INV_DEPOSITO.
	CONSTRAINT FK_TARIFA_ESTADIA FOREIGN KEY (TARIFA) REFERENCES dbo.VEN_TARIFA(CODIGO) -- Relaciona con VEN_TARIFA.
) ON [PRIMARY]
GO

-- Tabla para gestionar los contratos de abonados.
CREATE TABLE [dbo].[VEN_ABONADO](
	[CODIGO] [int] NOT NULL, -- Código único del abonado. Es la clave primaria.
	[FECHA_EMISION] [date] NULL, -- Fecha de emisión del contrato de abonado.
	[CLIENTE] [varchar](8) NULL, -- Código del cliente abonado (FK a VEN_CLIENTE).
	[VEHICULO] [int] NULL, -- Código del vehículo del abonado (FK a VEN_VEHICULO).
	[FECHA_INICIO] [date] NULL, -- Fecha de inicio de la validez del abono.
	[FECHA_FINAL] [date] NULL, -- Fecha de finalización de la validez del abono.
	[TARIFA] [int] NULL, -- Código de la tarifa especial aplicada al abonado (FK a VEN_TARIFA).
	[IMPORTE] [decimal](20, 5) NULL, -- Importe del contrato de abonado.
	[ABONADO_ERP] [varchar](100) NULL, -- Identificador del abonado en un sistema ERP externo.
	[ESTADO] [varchar](1) NULL, -- Estado del abono ('A' para Activo, 'I' para Inactivo, 'V' para Vencido).
    CONSTRAINT [PKX_VEN_ABONADO_01] PRIMARY KEY CLUSTERED
    (
	    [CODIGO] ASC -- Define CODIGO como la clave primaria agrupada.
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	-- Claves foráneas para relacionar con las tablas correspondientes
	CONSTRAINT FK_VEHICULO_ABONADO FOREIGN KEY (VEHICULO) REFERENCES dbo.VEN_VEHICULO(CODIGO), -- Relaciona con VEN_VEHICULO.
	CONSTRAINT FK_CLIENTE_ABONADO FOREIGN KEY (CLIENTE) REFERENCES dbo.VEN_CLIENTE(CODIGO), -- Relaciona con VEN_CLIENTE.
	CONSTRAINT FK_TARIFA_ABONADO FOREIGN KEY (TARIFA) REFERENCES dbo.VEN_TARIFA(CODIGO) -- Relaciona con VEN_TARIFA.
) ON [PRIMARY]
GO


-- Procedimiento almacenado que lista todas las estadías de un cliente específico.
-- Este procedimiento toma el número de documento de identidad del cliente como entrada.
CREATE OR ALTER PROCEDURE sp_listar_Cli_x_estadias_codigo
    @COD_CLIENTE VARCHAR(15) -- Parámetro de entrada para el número de documento de identidad del cliente.
AS
BEGIN
    -- Inicia la consulta para obtener la información detallada de las estadías del cliente.
    SELECT
        dbo.VEN_ESTADIA.NUMERO,                     -- Número único de la estadía.
        dbo.VEN_CLIENTE.RAZON_SOCIAL,               -- Razón social (nombre) del cliente.
        dbo.VEN_CLIENTE.DOCUMENTO_IDENTIDAD_NUMERO, -- Número de documento de identidad del cliente.
        dbo.VEN_ESTADIA.CLIENTE,                    -- Código interno del cliente asociado a la estadía.
        dbo.VEN_ESTADIA.INGRESO,                    -- Bandera que indica si el vehículo ha ingresado (1 = sí, 0 = no).
        dbo.VEN_ESTADIA.FECHA_HORA_INGRESO,         -- Fecha y hora exactas del ingreso del vehículo.
        dbo.VEN_ESTADIA.FECHA_INGRESO,              -- Solo la fecha de ingreso.
        dbo.VEN_ESTADIA.HORA_INGRESO,               -- Solo la hora de ingreso.
        dbo.VEN_ESTADIA.SALIDA,                     -- Bandera que indica si el vehículo ha salido (1 = sí, 0 = no).
        ISNULL(dbo.VEN_ESTADIA.FECHA_HORA_SALIDA, NULL) AS FECHA_HORA_SALIDA, -- Fecha y hora exactas de salida; devuelve NULL si aún no ha salido.
        dbo.VEN_ESTADIA.FECHA_SALIDA,               -- Solo la fecha de salida.
        dbo.VEN_ESTADIA.HORA_SALIDA                 -- Solo la hora de salida.
    FROM dbo.VEN_ESTADIA
    INNER JOIN dbo.VEN_CLIENTE ON dbo.VEN_ESTADIA.CLIENTE = dbo.VEN_CLIENTE.CODIGO -- Une con la tabla de clientes para obtener la información del cliente.
    LEFT OUTER JOIN dbo.VEN_VEHICULO ON dbo.VEN_ESTADIA.VEHICULO = dbo.VEN_VEHICULO.CODIGO -- Une opcionalmente con la tabla de vehículos.
    WHERE dbo.VEN_CLIENTE.DOCUMENTO_IDENTIDAD_NUMERO = @COD_CLIENTE; -- Filtra los resultados por el número de documento de identidad del cliente proporcionado.
END
GO

-- Procedimiento que obtiene la información detallada de una estadía de un vehículo por su número.
CREATE OR ALTER PROCEDURE [dbo].[SP_R_VEN_ESTADIA_1]
(
    @NUMERO VARCHAR(25) -- Parámetro de entrada que representa el número único de la estadía a buscar.
)
AS
BEGIN
    -- Realizamos una consulta para obtener la información básica de la estadía.
    SELECT
        VEN_ESTADIA.NUMERO,                     -- Número de la estadía.
        VEN_VEHICULO.PLACA,                     -- Placa del vehículo asociado a esta estadía.
        VEN_ESTADIA.FECHA_INGRESO,              -- Fecha en que se registró el ingreso del vehículo.
        VEN_ESTADIA.HORA_INGRESO,               -- Hora en que se registró el ingreso del vehículo.
        VEN_ESTADIA.ESTADO                      -- Estado actual de la estadía (ej. 'A' para Activo, 'C' para Cerrado).
    FROM VEN_ESTADIA
    INNER JOIN VEN_VEHICULO ON VEN_ESTADIA.VEHICULO = VEN_VEHICULO.CODIGO -- Une con la tabla de vehículos para obtener la placa.
    WHERE VEN_ESTADIA.NUMERO = @NUMERO; -- Filtra las estadías por el número de estadía proporcionado.
END
GO

-- Procedimiento para obtener las estadías registradas dentro de un rango de fechas específico.
CREATE OR ALTER PROCEDURE [dbo].[SP_S_VEN_ESTADIA_1]
(
    @FECHA_INICIO DATE, -- Fecha de inicio del rango de búsqueda para las estadías.
    @FECHA_FINAL DATE   -- Fecha de finalización del rango de búsqueda para las estadías.
)
AS
BEGIN
    -- Consulta las estadías entre las dos fechas dadas, incluyendo información adicional sobre el vehículo, depósito y el estado.
    SELECT
        VEN_ESTADIA.NUMERO,                         -- Número de la estadía.
        VEN_VEHICULO.PLACA,                         -- Placa del vehículo (si está asociada a la estadía).
        INV_DEPOSITO.DESCRIPCION AS DEPOSITO_DESCRIPCION, -- Descripción del depósito donde el vehículo estuvo estacionado.
        VEN_ESTADIA.INGRESO,                        -- Bandera que indica si el vehículo ha ingresado.
        VEN_ESTADIA.FECHA_INGRESO,                  -- Fecha de ingreso del vehículo.
        VEN_ESTADIA.HORA_INGRESO,                   -- Hora de ingreso del vehículo.
        VEN_ESTADIA.SALIDA,                         -- Bandera que indica si el vehículo ha salido.
        VEN_ESTADIA.FECHA_SALIDA,                   -- Fecha de salida del vehículo.
        VEN_ESTADIA.HORA_SALIDA,                    -- Hora de salida del vehículo.
        VEN_ESTADIA.TIEMPO_ESTACIONAMIENTO,         -- Tiempo total que el vehículo estuvo estacionado.
        VEN_ESTADIA.PRECIO,                         -- Precio unitario aplicado a la estadía.
        VEN_ESTADIA.CANTIDAD,                       -- Cantidad de unidades de tiempo (ej. horas) de la estadía.
        VEN_ESTADIA.IMPORTE,                        -- Importe total a pagar por la estadía.
        VEN_ESTADIA.ESTADIA_ERP,                    -- Identificador de la estadía en el sistema ERP.
        VEN_ESTADIA.ESTADIA_ERP_NUMERO,             -- Número de la estadía en el sistema ERP.
        VEN_ESTADIA.COMPROBANTE_ERP,                -- Tipo de comprobante asociado en el sistema ERP.
        VEN_ESTADIA.COMPROBANTE_ERP_NUMERO,         -- Número del comprobante en el sistema ERP.
        VEN_ESTADIA.COMENTARIO,                     -- Comentarios adicionales sobre la estadía.
        ADM_ESTADO.DESCRIPCION AS ESTADO_DESCRIPCION -- Descripción del estado de la estadía (ej. "Activo", "Cerrado").
    FROM VEN_ESTADIA
    LEFT JOIN VEN_VEHICULO ON VEN_ESTADIA.VEHICULO = VEN_VEHICULO.CODIGO -- Une opcionalmente con la tabla de vehículos.
    LEFT JOIN INV_DEPOSITO ON VEN_ESTADIA.DEPOSITO = INV_DEPOSITO.CODIGO -- Une opcionalmente con la tabla de depósitos.
    INNER JOIN ADM_ESTADO ON VEN_ESTADIA.ESTADO = ADM_ESTADO.ID -- Une con la tabla de estados para obtener la descripción del estado.
    WHERE
        VEN_ESTADIA.FECHA_INGRESO >= @FECHA_INICIO AND -- Filtra por la fecha de inicio del rango.
        VEN_ESTADIA.FECHA_INGRESO <= @FECHA_FINAL      -- Filtra por la fecha de fin del rango.
    ORDER BY CONVERT(NUMERIC, VEN_ESTADIA.NUMERO) DESC; -- Ordena los resultados por el número de estadía en orden descendente.
END
GO

-- Procedimiento para obtener las tarifas filtradas por tipo de tarifa, tipo de vehículo y tipo de fracción.
CREATE OR ALTER PROCEDURE [dbo].[SP_S_VEN_TARIFA_4]
(
    @TIPO_TARIFA INT,    -- Parámetro para filtrar por el tipo de tarifa.
    @TIPO_VEHICULO INT,  -- Parámetro para filtrar por el tipo de vehículo.
    @TIPO_FRACCION INT   -- Parámetro para filtrar por el tipo de fracción.
)
AS
BEGIN
    -- Consulta las tarifas que coinciden con los filtros proporcionados.
    SELECT
        VEN_TARIFA.CODIGO,                          -- Código único de la tarifa.
        VEN_TARIFA.DESCRIPCION,                     -- Descripción de la tarifa.
        VEN_TARIFA.TIPO_TARIFA,                     -- Tipo de tarifa.
        VEN_TARIFA.TIPO_VEHICULO,                   -- Código del tipo de vehículo al que aplica la tarifa.
        ADM_TIPO_VEHICULO.DESCRIPCION AS 'TipoVehiculo', -- Descripción del tipo de vehículo.
        VEN_TARIFA.TIPO_FRACCION,                   -- Código del tipo de fracción al que aplica la tarifa.
        ADM_TIPO_FRACCION.DESCRIPCION AS 'TipoFraccion', -- Descripción del tipo de fracción.
        ADM_TIPO_FRACCION.TIEMPO_TOLERANCIA,        -- Tiempo de tolerancia asociado a la fracción de la tarifa.
        VEN_TARIFA.PRECIO,                          -- Precio de la tarifa.
        VEN_TARIFA.ESTADO                           -- Estado de la tarifa.
    FROM VEN_TARIFA
    LEFT JOIN ADM_TIPO_VEHICULO ON VEN_TARIFA.TIPO_VEHICULO = ADM_TIPO_VEHICULO.CODIGO -- Une con la tabla de tipos de vehículo.
    LEFT JOIN ADM_TIPO_FRACCION ON VEN_TARIFA.TIPO_FRACCION = ADM_TIPO_FRACCION.CODIGO -- Une con la tabla de tipos de fracción.
    WHERE
        VEN_TARIFA.TIPO_TARIFA = @TIPO_TARIFA AND -- Filtra por el tipo de tarifa.
        VEN_TARIFA.TIPO_VEHICULO = @TIPO_VEHICULO AND -- Filtra por el tipo de vehículo.
        VEN_TARIFA.TIPO_FRACCION = @TIPO_FRACCION; -- Filtra por el tipo de fracción.
END
GO

-- Procedimiento para insertar un nuevo cliente en la tabla VEN_CLIENTE.
CREATE OR ALTER PROCEDURE sp_InsertarClientes
(
    @CODIGO VARCHAR(8),  -- Código único del cliente (clave primaria).
    @DOCUMENTO_IDENTIDAD INT,  -- Tipo de documento de identidad (ej. 1 para DNI, 2 para RUC).
    @DOCUMENTO_IDENTIDAD_NUMERO VARCHAR(25),  -- Número del documento de identidad.
    @RAZON_SOCIAL VARCHAR(250)  -- Nombre o razón social del cliente.
)
AS
BEGIN
    -- Inserta un nuevo registro de cliente en la tabla VEN_CLIENTE.
    -- Se añade el campo ESTADO con un valor por defecto 'A' (Activo).
    INSERT INTO dbo.VEN_CLIENTE(CODIGO, DOCUMENTO_IDENTIDAD, DOCUMENTO_IDENTIDAD_NUMERO, RAZON_SOCIAL, ESTADO)
    VALUES (@CODIGO, @DOCUMENTO_IDENTIDAD, @DOCUMENTO_IDENTIDAD_NUMERO, @RAZON_SOCIAL, 'A'); -- 'A' de Activo como estado por defecto.
END
GO

-- Procedimiento para actualizar los datos de un cliente existente en la tabla VEN_CLIENTE.
CREATE OR ALTER PROCEDURE sp_ActualizarClientes
(
    @CODIGO VARCHAR(8),  -- Código del cliente que se va a actualizar (es la clave primaria).
    @DOCUMENTO_IDENTIDAD INT,  -- Nuevo tipo de documento de identidad.
    @DOCUMENTO_IDENTIDAD_NUMERO VARCHAR(25),  -- Nuevo número del documento de identidad.
    @RAZON_SOCIAL VARCHAR(250)  -- Nueva razón social del cliente.
)
AS
BEGIN
    -- Actualiza los campos especificados para el cliente cuyo CODIGO coincide.
    UPDATE dbo.VEN_CLIENTE
    SET
        DOCUMENTO_IDENTIDAD = @DOCUMENTO_IDENTIDAD, -- Actualiza el tipo de documento.
        DOCUMENTO_IDENTIDAD_NUMERO = @DOCUMENTO_IDENTIDAD_NUMERO, -- Actualiza el número de documento.
        RAZON_SOCIAL = @RAZON_SOCIAL -- Actualiza la razón social.
    WHERE CODIGO = @CODIGO; -- La condición de WHERE usa el CODIGO como clave primaria para identificar el registro.
END
GO

-- Procedimiento para eliminar un cliente de la tabla VEN_CLIENTE.
CREATE OR ALTER PROCEDURE sp_EliminarClientes
(
    @CODIGO VARCHAR(8)  -- Código del cliente que se va a eliminar (es la clave primaria).
)
AS
BEGIN
    -- Elimina el registro del cliente de la tabla VEN_CLIENTE.
    DELETE FROM dbo.VEN_CLIENTE
    WHERE CODIGO = @CODIGO; -- La condición de WHERE usa el CODIGO como clave primaria para identificar el registro.
END
GO
