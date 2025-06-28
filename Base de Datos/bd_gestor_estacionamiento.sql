-- Crear la base de datos si no existe
CREATE DATABASE bd_gestor_estacionamiento;
GO

-- Usar la base de datos reci�n creada
USE bd_gestor_estacionamiento;
GO

-- Tabla para almacenar los diferentes tipos de fracciones de tiempo para el estacionamiento.
-- Por ejemplo, por hora, por d�a, por mes.
CREATE TABLE [dbo].[ADM_TIPO_FRACCION](
	[CODIGO] [int] NOT NULL, -- C�digo �nico que identifica el tipo de fracci�n. Es la clave primaria.
	[DESCRIPCION] [varchar](100) NULL, -- Descripci�n del tipo de fracci�n (ej. "Por Hora", "Diario", "Mensual").
	[TIEMPO_ESTACIONAMIENTO] [time](7) NULL, -- Tiempo est�ndar de estacionamiento para esta fracci�n (ej. '01:00:00' para una hora).
	[TIEMPO_TOLERANCIA] [time](7) NULL, -- Tiempo de gracia o tolerancia permitido antes de aplicar la siguiente fracci�n o recargo.
	[ESTADO] [varchar](1) NULL, -- Estado del tipo de fracci�n ('A' para Activo, 'I' para Inactivo).
    CONSTRAINT [PKX_ADM_TIPO_FRACCION_01] PRIMARY KEY CLUSTERED
    (
	    [CODIGO] ASC -- Define CODIGO como la clave primaria agrupada.
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

-- Tabla para almacenar los diferentes tipos de veh�culos que pueden estacionar.
-- Por ejemplo, carro, moto, cami�n.
CREATE TABLE [dbo].[ADM_TIPO_VEHICULO](
	[CODIGO] [int] NOT NULL, -- C�digo �nico que identifica el tipo de veh�culo. Es la clave primaria.
	[DESCRIPCION] [varchar](100) NULL, -- Descripci�n del tipo de veh�culo (ej. "Autom�vil", "Motocicleta", "Camioneta").
	[ESTADO] [varchar](1) NULL, -- Estado del tipo de veh�culo ('A' para Activo, 'I' para Inactivo).
    CONSTRAINT [PKX_ADM_TIPO_VEHICULO_01] PRIMARY KEY CLUSTERED
    (
	    [CODIGO] ASC -- Define CODIGO como la clave primaria agrupada.
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

-- Tabla para ADM_ESTADO (Agregada: Esta tabla es necesaria para que el procedimiento SP_S_VEN_ESTADIA_1 funcione correctamente)
-- Contiene descripciones de estados gen�ricos que pueden ser usados en otras tablas.
CREATE TABLE [dbo].[ADM_ESTADO](
	[ID] [varchar](1) NOT NULL, -- Identificador del estado (ej. 'A' para Activo, 'I' para Inactivo, 'C' para Cerrado). Es la clave primaria.
	[DESCRIPCION] [varchar](100) NULL, -- Descripci�n textual del estado (ej. "Activo", "Inactivo", "Cerrado").
    CONSTRAINT [PKX_ADM_ESTADO_01] PRIMARY KEY CLUSTERED
    (
	    [ID] ASC -- Define ID como la clave primaria agrupada.
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

-- Tabla para gestionar la informaci�n de los dep�sitos o espacios de estacionamiento.
CREATE TABLE [dbo].[INV_DEPOSITO](
	[CODIGO] [int] NOT NULL, -- C�digo �nico del dep�sito. Es la clave primaria.
	[DESCRIPCION] [varchar](100) NULL, -- Descripci�n del dep�sito (ej. "Zona A - Nivel 1").
	[ZONA] [int] NULL, -- N�mero de la zona donde se encuentra el dep�sito.
	[PASILLO] [varchar](100) NULL, -- Identificaci�n del pasillo.
	[CARA] [varchar](100) NULL, -- Cara o lado del pasillo (ej. "Norte", "Sur").
	[ELEVACION] [int] NULL, -- Nivel o elevaci�n del dep�sito.
	[ESTADO] [varchar](1) NULL, -- Estado del dep�sito ('A' para Activo, 'I' para Inactivo, 'O' para Ocupado).
    CONSTRAINT [PKX_INV_DEPOSITO_01] PRIMARY KEY CLUSTERED
    (
	    [CODIGO] ASC -- Define CODIGO como la clave primaria agrupada.
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

-- Tabla para definir las tarifas de estacionamiento.
CREATE TABLE [dbo].[VEN_TARIFA](
    [CODIGO] [int] NOT NULL, -- C�digo �nico de la tarifa. Es la clave primaria.
    [DESCRIPCION] [varchar](250) NULL, -- Descripci�n de la tarifa (ej. "Tarifa est�ndar por hora de auto").
    [TIPO_TARIFA] [int] NULL, -- Tipo de tarifa (puede ser un c�digo a otra tabla de tipos de tarifa si existiera).
    [TIPO_VEHICULO] [int] NULL, -- C�digo del tipo de veh�culo al que aplica esta tarifa (FK a ADM_TIPO_VEHICULO).
    [TIPO_FRACCION] [int] NULL, -- C�digo del tipo de fracci�n al que aplica esta tarifa (FK a ADM_TIPO_FRACCION).
    [PRECIO] [decimal](20, 5) NULL, -- Precio de la tarifa.
    [ESTADO] [varchar](1) NULL, -- Estado de la tarifa ('A' para Activo, 'I' para Inactivo).
    CONSTRAINT [PKX_VEN_TARIFA_01] PRIMARY KEY CLUSTERED
    (
        [CODIGO] ASC -- Define CODIGO como la clave primaria agrupada.
    )
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
    -- Claves for�neas para relacionar con las tablas correspondientes
    CONSTRAINT FK_TIPO_VEHICULO_TARIFA FOREIGN KEY (TIPO_VEHICULO) REFERENCES dbo.ADM_TIPO_VEHICULO(CODIGO), -- Relaciona con ADM_TIPO_VEHICULO.
    CONSTRAINT FK_TIPO_FRACCION_TARIFA FOREIGN KEY (TIPO_FRACCION) REFERENCES dbo.ADM_TIPO_FRACCION(CODIGO) -- Relaciona con ADM_TIPO_FRACCION.
) ON [PRIMARY]
GO

-- Tabla para almacenar la informaci�n de los veh�culos.
CREATE TABLE [dbo].[VEN_VEHICULO](
	[CODIGO] [int] NOT NULL, -- C�digo �nico del veh�culo. Es la clave primaria.
	[PLACA] [varchar](25) NULL, -- N�mero de placa del veh�culo.
	[TIPO_VEHICULO] [int] NULL, -- C�digo del tipo de veh�culo (FK a ADM_TIPO_VEHICULO).
	[MARCA] [varchar](100) NULL, -- Marca del veh�culo.
	[MODELO] [varchar](100) NULL, -- Modelo del veh�culo.
	[COLOR] [varchar](100) NULL, -- Color del veh�culo.
	[EXONERADO] [bit] NULL, -- Indica si el veh�culo est� exonerado de pago (1 para s�, 0 para no).
	[ESTADO] [varchar](1) NULL, -- Estado del veh�culo ('A' para Activo, 'I' para Inactivo).
    CONSTRAINT [PKX_VEN_VEHICULO_01] PRIMARY KEY CLUSTERED
    (
	    [CODIGO] ASC -- Define CODIGO como la clave primaria agrupada.
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	-- Clave for�nea para relacionar con la tabla ADM_TIPO_VEHICULO
	CONSTRAINT FK_TIPO_VEHICULO_VEHICULO FOREIGN KEY (TIPO_VEHICULO) REFERENCES dbo.ADM_TIPO_VEHICULO(CODIGO) -- Relaciona con ADM_TIPO_VEHICULO.
) ON [PRIMARY]
GO

-- Tabla para almacenar la informaci�n de los clientes.
CREATE TABLE [dbo].[VEN_CLIENTE](
	[CODIGO] [varchar](8) NOT NULL, -- C�digo �nico del cliente. Es la clave primaria.
	[DOCUMENTO_IDENTIDAD] [int] NULL, -- Tipo de documento de identidad (ej. DNI, RUC).
	[DOCUMENTO_IDENTIDAD_NUMERO] [varchar](25) NULL, -- N�mero del documento de identidad.
	[RAZON_SOCIAL] [varchar](250) NULL, -- Nombre o raz�n social del cliente.
	[UBIGEO] [int] NULL, -- C�digo de ubicaci�n geogr�fica.
	[DIRECCION] [varchar](250) NULL, -- Direcci�n del cliente.
	[TELEFONO] [varchar](50) NULL, -- N�mero de tel�fono del cliente.
	[CLIENTE_ERP] [varchar](100) NULL, -- Identificador del cliente en un sistema ERP externo.
	[ESTADO] [varchar](1) NULL, -- Estado del cliente ('A' para Activo, 'I' para Inactivo).
    CONSTRAINT [PKX_VEN_CLIENTE_01] PRIMARY KEY CLUSTERED
    (
	    [CODIGO] ASC -- Define CODIGO como la clave primaria agrupada.
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

-- Tabla para registrar las estad�as de los veh�culos en el estacionamiento.
CREATE TABLE [dbo].[VEN_ESTADIA](
	[NUMERO] [varchar](25) NOT NULL, -- N�mero �nico de la estad�a. Es la clave primaria.
	[VEHICULO] [int] NULL, -- C�digo del veh�culo asociado a la estad�a (FK a VEN_VEHICULO).
	[CLIENTE] [varchar](8) NULL, -- C�digo del cliente asociado a la estad�a (FK a VEN_CLIENTE).
	[INGRESO] [bit] NULL, -- Indica si el veh�culo ha ingresado (1 para s�, 0 para no).
	[FECHA_HORA_INGRESO] [datetime] NULL, -- Fecha y hora exactas de ingreso.
	[FECHA_INGRESO] [date] NULL, -- Solo la fecha de ingreso.
	[HORA_INGRESO] [time](7) NULL, -- Solo la hora de ingreso.
	[SALIDA] [bit] NULL, -- Indica si el veh�culo ha salido (1 para s�, 0 para no).
	[FECHA_HORA_SALIDA] [datetime] NULL, -- Fecha y hora exactas de salida.
	[FECHA_SALIDA] [date] NULL, -- Solo la fecha de salida.
	[HORA_SALIDA] [time](7) NULL, -- Solo la hora de salida.
	[DEPOSITO] [int] NULL, -- C�digo del dep�sito donde el veh�culo estuvo estacionado (FK a INV_DEPOSITO).
	[TARIFA] [int] NULL, -- C�digo de la tarifa aplicada a esta estad�a (FK a VEN_TARIFA).
	[TIEMPO_ESTACIONAMIENTO] [varchar](8) NULL, -- Duraci�n total del estacionamiento.
	[TIEMPO_TOLERANCIA] [varchar](8) NULL, -- Tiempo de tolerancia utilizado.
	[ABONADO] [bit] NULL, -- Indica si la estad�a es de un abonado (1 para s�, 0 para no).
	[EXONERADO] [bit] NULL, -- Indica si la estad�a fue exonerada de pago (1 para s�, 0 para no).
	[PRECIO] [decimal](20, 5) NULL, -- Precio unitario aplicado por la tarifa.
	[CANTIDAD] [decimal](20, 5) NULL, -- Cantidad de unidades de tiempo (ej. horas, d�as).
	[IMPORTE] [decimal](20, 5) NULL, -- Importe total a pagar por la estad�a.
	[ESTADIA_ERP] [varchar](100) NULL, -- Identificador de la estad�a en un sistema ERP externo.
	[ESTADIA_ERP_ITEM] [varchar](100) NULL, -- �tem de la estad�a en el ERP.
	[ESTADIA_ERP_NUMERO] [varchar](100) NULL, -- N�mero de la estad�a en el ERP.
	[COMPROBANTE_ERP] [varchar](100) NULL, -- Tipo de comprobante asociado en el ERP.
	[COMPROBANTE_ERP_NUMERO] [varchar](100) NULL, -- N�mero del comprobante en el ERP.
	[COMENTARIO] [varchar](200) NULL, -- Comentarios adicionales sobre la estad�a.
	[ESTADO] [varchar](1) NULL, -- Estado de la estad�a ('A' para Activo, 'C' para Cerrado, 'P' para Pendiente de Pago).
    CONSTRAINT [PKX_VEN_ESTADIA_01] PRIMARY KEY CLUSTERED
    (
	    [NUMERO] ASC -- Define NUMERO como la clave primaria agrupada.
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	-- Claves for�neas para relacionar con las tablas correspondientes
	CONSTRAINT FK_VEHICULO_ESTADIA FOREIGN KEY (VEHICULO) REFERENCES dbo.VEN_VEHICULO(CODIGO), -- Relaciona con VEN_VEHICULO.
	CONSTRAINT FK_CLIENTE_ESTADIA FOREIGN KEY (CLIENTE) REFERENCES dbo.VEN_CLIENTE(CODIGO), -- Relaciona con VEN_CLIENTE.
	CONSTRAINT FK_DEPOSITO_ESTADIA FOREIGN KEY (DEPOSITO) REFERENCES dbo.INV_DEPOSITO(CODIGO), -- Relaciona con INV_DEPOSITO.
	CONSTRAINT FK_TARIFA_ESTADIA FOREIGN KEY (TARIFA) REFERENCES dbo.VEN_TARIFA(CODIGO) -- Relaciona con VEN_TARIFA.
) ON [PRIMARY]
GO

-- Tabla para gestionar los contratos de abonados.
CREATE TABLE [dbo].[VEN_ABONADO](
	[CODIGO] [int] NOT NULL, -- C�digo �nico del abonado. Es la clave primaria.
	[FECHA_EMISION] [date] NULL, -- Fecha de emisi�n del contrato de abonado.
	[CLIENTE] [varchar](8) NULL, -- C�digo del cliente abonado (FK a VEN_CLIENTE).
	[VEHICULO] [int] NULL, -- C�digo del veh�culo del abonado (FK a VEN_VEHICULO).
	[FECHA_INICIO] [date] NULL, -- Fecha de inicio de la validez del abono.
	[FECHA_FINAL] [date] NULL, -- Fecha de finalizaci�n de la validez del abono.
	[TARIFA] [int] NULL, -- C�digo de la tarifa especial aplicada al abonado (FK a VEN_TARIFA).
	[IMPORTE] [decimal](20, 5) NULL, -- Importe del contrato de abonado.
	[ABONADO_ERP] [varchar](100) NULL, -- Identificador del abonado en un sistema ERP externo.
	[ESTADO] [varchar](1) NULL, -- Estado del abono ('A' para Activo, 'I' para Inactivo, 'V' para Vencido).
    CONSTRAINT [PKX_VEN_ABONADO_01] PRIMARY KEY CLUSTERED
    (
	    [CODIGO] ASC -- Define CODIGO como la clave primaria agrupada.
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	-- Claves for�neas para relacionar con las tablas correspondientes
	CONSTRAINT FK_VEHICULO_ABONADO FOREIGN KEY (VEHICULO) REFERENCES dbo.VEN_VEHICULO(CODIGO), -- Relaciona con VEN_VEHICULO.
	CONSTRAINT FK_CLIENTE_ABONADO FOREIGN KEY (CLIENTE) REFERENCES dbo.VEN_CLIENTE(CODIGO), -- Relaciona con VEN_CLIENTE.
	CONSTRAINT FK_TARIFA_ABONADO FOREIGN KEY (TARIFA) REFERENCES dbo.VEN_TARIFA(CODIGO) -- Relaciona con VEN_TARIFA.
) ON [PRIMARY]
GO


-- Procedimiento almacenado que lista todas las estad�as de un cliente espec�fico.
-- Este procedimiento toma el n�mero de documento de identidad del cliente como entrada.
CREATE OR ALTER PROCEDURE sp_listar_Cli_x_estadias_codigo
    @COD_CLIENTE VARCHAR(15) -- Par�metro de entrada para el n�mero de documento de identidad del cliente.
AS
BEGIN
    -- Inicia la consulta para obtener la informaci�n detallada de las estad�as del cliente.
    SELECT
        dbo.VEN_ESTADIA.NUMERO,                     -- N�mero �nico de la estad�a.
        dbo.VEN_CLIENTE.RAZON_SOCIAL,               -- Raz�n social (nombre) del cliente.
        dbo.VEN_CLIENTE.DOCUMENTO_IDENTIDAD_NUMERO, -- N�mero de documento de identidad del cliente.
        dbo.VEN_ESTADIA.CLIENTE,                    -- C�digo interno del cliente asociado a la estad�a.
        dbo.VEN_ESTADIA.INGRESO,                    -- Bandera que indica si el veh�culo ha ingresado (1 = s�, 0 = no).
        dbo.VEN_ESTADIA.FECHA_HORA_INGRESO,         -- Fecha y hora exactas del ingreso del veh�culo.
        dbo.VEN_ESTADIA.FECHA_INGRESO,              -- Solo la fecha de ingreso.
        dbo.VEN_ESTADIA.HORA_INGRESO,               -- Solo la hora de ingreso.
        dbo.VEN_ESTADIA.SALIDA,                     -- Bandera que indica si el veh�culo ha salido (1 = s�, 0 = no).
        ISNULL(dbo.VEN_ESTADIA.FECHA_HORA_SALIDA, NULL) AS FECHA_HORA_SALIDA, -- Fecha y hora exactas de salida; devuelve NULL si a�n no ha salido.
        dbo.VEN_ESTADIA.FECHA_SALIDA,               -- Solo la fecha de salida.
        dbo.VEN_ESTADIA.HORA_SALIDA                 -- Solo la hora de salida.
    FROM dbo.VEN_ESTADIA
    INNER JOIN dbo.VEN_CLIENTE ON dbo.VEN_ESTADIA.CLIENTE = dbo.VEN_CLIENTE.CODIGO -- Une con la tabla de clientes para obtener la informaci�n del cliente.
    LEFT OUTER JOIN dbo.VEN_VEHICULO ON dbo.VEN_ESTADIA.VEHICULO = dbo.VEN_VEHICULO.CODIGO -- Une opcionalmente con la tabla de veh�culos.
    WHERE dbo.VEN_CLIENTE.DOCUMENTO_IDENTIDAD_NUMERO = @COD_CLIENTE; -- Filtra los resultados por el n�mero de documento de identidad del cliente proporcionado.
END
GO

-- Procedimiento que obtiene la informaci�n detallada de una estad�a de un veh�culo por su n�mero.
CREATE OR ALTER PROCEDURE [dbo].[SP_R_VEN_ESTADIA_1]
(
    @NUMERO VARCHAR(25) -- Par�metro de entrada que representa el n�mero �nico de la estad�a a buscar.
)
AS
BEGIN
    -- Realizamos una consulta para obtener la informaci�n b�sica de la estad�a.
    SELECT
        VEN_ESTADIA.NUMERO,                     -- N�mero de la estad�a.
        VEN_VEHICULO.PLACA,                     -- Placa del veh�culo asociado a esta estad�a.
        VEN_ESTADIA.FECHA_INGRESO,              -- Fecha en que se registr� el ingreso del veh�culo.
        VEN_ESTADIA.HORA_INGRESO,               -- Hora en que se registr� el ingreso del veh�culo.
        VEN_ESTADIA.ESTADO                      -- Estado actual de la estad�a (ej. 'A' para Activo, 'C' para Cerrado).
    FROM VEN_ESTADIA
    INNER JOIN VEN_VEHICULO ON VEN_ESTADIA.VEHICULO = VEN_VEHICULO.CODIGO -- Une con la tabla de veh�culos para obtener la placa.
    WHERE VEN_ESTADIA.NUMERO = @NUMERO; -- Filtra las estad�as por el n�mero de estad�a proporcionado.
END
GO

-- Procedimiento para obtener las estad�as registradas dentro de un rango de fechas espec�fico.
CREATE OR ALTER PROCEDURE [dbo].[SP_S_VEN_ESTADIA_1]
(
    @FECHA_INICIO DATE, -- Fecha de inicio del rango de b�squeda para las estad�as.
    @FECHA_FINAL DATE   -- Fecha de finalizaci�n del rango de b�squeda para las estad�as.
)
AS
BEGIN
    -- Consulta las estad�as entre las dos fechas dadas, incluyendo informaci�n adicional sobre el veh�culo, dep�sito y el estado.
    SELECT
        VEN_ESTADIA.NUMERO,                         -- N�mero de la estad�a.
        VEN_VEHICULO.PLACA,                         -- Placa del veh�culo (si est� asociada a la estad�a).
        INV_DEPOSITO.DESCRIPCION AS DEPOSITO_DESCRIPCION, -- Descripci�n del dep�sito donde el veh�culo estuvo estacionado.
        VEN_ESTADIA.INGRESO,                        -- Bandera que indica si el veh�culo ha ingresado.
        VEN_ESTADIA.FECHA_INGRESO,                  -- Fecha de ingreso del veh�culo.
        VEN_ESTADIA.HORA_INGRESO,                   -- Hora de ingreso del veh�culo.
        VEN_ESTADIA.SALIDA,                         -- Bandera que indica si el veh�culo ha salido.
        VEN_ESTADIA.FECHA_SALIDA,                   -- Fecha de salida del veh�culo.
        VEN_ESTADIA.HORA_SALIDA,                    -- Hora de salida del veh�culo.
        VEN_ESTADIA.TIEMPO_ESTACIONAMIENTO,         -- Tiempo total que el veh�culo estuvo estacionado.
        VEN_ESTADIA.PRECIO,                         -- Precio unitario aplicado a la estad�a.
        VEN_ESTADIA.CANTIDAD,                       -- Cantidad de unidades de tiempo (ej. horas) de la estad�a.
        VEN_ESTADIA.IMPORTE,                        -- Importe total a pagar por la estad�a.
        VEN_ESTADIA.ESTADIA_ERP,                    -- Identificador de la estad�a en el sistema ERP.
        VEN_ESTADIA.ESTADIA_ERP_NUMERO,             -- N�mero de la estad�a en el sistema ERP.
        VEN_ESTADIA.COMPROBANTE_ERP,                -- Tipo de comprobante asociado en el sistema ERP.
        VEN_ESTADIA.COMPROBANTE_ERP_NUMERO,         -- N�mero del comprobante en el sistema ERP.
        VEN_ESTADIA.COMENTARIO,                     -- Comentarios adicionales sobre la estad�a.
        ADM_ESTADO.DESCRIPCION AS ESTADO_DESCRIPCION -- Descripci�n del estado de la estad�a (ej. "Activo", "Cerrado").
    FROM VEN_ESTADIA
    LEFT JOIN VEN_VEHICULO ON VEN_ESTADIA.VEHICULO = VEN_VEHICULO.CODIGO -- Une opcionalmente con la tabla de veh�culos.
    LEFT JOIN INV_DEPOSITO ON VEN_ESTADIA.DEPOSITO = INV_DEPOSITO.CODIGO -- Une opcionalmente con la tabla de dep�sitos.
    INNER JOIN ADM_ESTADO ON VEN_ESTADIA.ESTADO = ADM_ESTADO.ID -- Une con la tabla de estados para obtener la descripci�n del estado.
    WHERE
        VEN_ESTADIA.FECHA_INGRESO >= @FECHA_INICIO AND -- Filtra por la fecha de inicio del rango.
        VEN_ESTADIA.FECHA_INGRESO <= @FECHA_FINAL      -- Filtra por la fecha de fin del rango.
    ORDER BY CONVERT(NUMERIC, VEN_ESTADIA.NUMERO) DESC; -- Ordena los resultados por el n�mero de estad�a en orden descendente.
END
GO

-- Procedimiento para obtener las tarifas filtradas por tipo de tarifa, tipo de veh�culo y tipo de fracci�n.
CREATE OR ALTER PROCEDURE [dbo].[SP_S_VEN_TARIFA_4]
(
    @TIPO_TARIFA INT,    -- Par�metro para filtrar por el tipo de tarifa.
    @TIPO_VEHICULO INT,  -- Par�metro para filtrar por el tipo de veh�culo.
    @TIPO_FRACCION INT   -- Par�metro para filtrar por el tipo de fracci�n.
)
AS
BEGIN
    -- Consulta las tarifas que coinciden con los filtros proporcionados.
    SELECT
        VEN_TARIFA.CODIGO,                          -- C�digo �nico de la tarifa.
        VEN_TARIFA.DESCRIPCION,                     -- Descripci�n de la tarifa.
        VEN_TARIFA.TIPO_TARIFA,                     -- Tipo de tarifa.
        VEN_TARIFA.TIPO_VEHICULO,                   -- C�digo del tipo de veh�culo al que aplica la tarifa.
        ADM_TIPO_VEHICULO.DESCRIPCION AS 'TipoVehiculo', -- Descripci�n del tipo de veh�culo.
        VEN_TARIFA.TIPO_FRACCION,                   -- C�digo del tipo de fracci�n al que aplica la tarifa.
        ADM_TIPO_FRACCION.DESCRIPCION AS 'TipoFraccion', -- Descripci�n del tipo de fracci�n.
        ADM_TIPO_FRACCION.TIEMPO_TOLERANCIA,        -- Tiempo de tolerancia asociado a la fracci�n de la tarifa.
        VEN_TARIFA.PRECIO,                          -- Precio de la tarifa.
        VEN_TARIFA.ESTADO                           -- Estado de la tarifa.
    FROM VEN_TARIFA
    LEFT JOIN ADM_TIPO_VEHICULO ON VEN_TARIFA.TIPO_VEHICULO = ADM_TIPO_VEHICULO.CODIGO -- Une con la tabla de tipos de veh�culo.
    LEFT JOIN ADM_TIPO_FRACCION ON VEN_TARIFA.TIPO_FRACCION = ADM_TIPO_FRACCION.CODIGO -- Une con la tabla de tipos de fracci�n.
    WHERE
        VEN_TARIFA.TIPO_TARIFA = @TIPO_TARIFA AND -- Filtra por el tipo de tarifa.
        VEN_TARIFA.TIPO_VEHICULO = @TIPO_VEHICULO AND -- Filtra por el tipo de veh�culo.
        VEN_TARIFA.TIPO_FRACCION = @TIPO_FRACCION; -- Filtra por el tipo de fracci�n.
END
GO

-- Procedimiento para insertar un nuevo cliente en la tabla VEN_CLIENTE.
CREATE OR ALTER PROCEDURE sp_InsertarClientes
(
    @CODIGO VARCHAR(8),  -- C�digo �nico del cliente (clave primaria).
    @DOCUMENTO_IDENTIDAD INT,  -- Tipo de documento de identidad (ej. 1 para DNI, 2 para RUC).
    @DOCUMENTO_IDENTIDAD_NUMERO VARCHAR(25),  -- N�mero del documento de identidad.
    @RAZON_SOCIAL VARCHAR(250)  -- Nombre o raz�n social del cliente.
)
AS
BEGIN
    -- Inserta un nuevo registro de cliente en la tabla VEN_CLIENTE.
    -- Se a�ade el campo ESTADO con un valor por defecto 'A' (Activo).
    INSERT INTO dbo.VEN_CLIENTE(CODIGO, DOCUMENTO_IDENTIDAD, DOCUMENTO_IDENTIDAD_NUMERO, RAZON_SOCIAL, ESTADO)
    VALUES (@CODIGO, @DOCUMENTO_IDENTIDAD, @DOCUMENTO_IDENTIDAD_NUMERO, @RAZON_SOCIAL, 'A'); -- 'A' de Activo como estado por defecto.
END
GO

-- Procedimiento para actualizar los datos de un cliente existente en la tabla VEN_CLIENTE.
CREATE OR ALTER PROCEDURE sp_ActualizarClientes
(
    @CODIGO VARCHAR(8),  -- C�digo del cliente que se va a actualizar (es la clave primaria).
    @DOCUMENTO_IDENTIDAD INT,  -- Nuevo tipo de documento de identidad.
    @DOCUMENTO_IDENTIDAD_NUMERO VARCHAR(25),  -- Nuevo n�mero del documento de identidad.
    @RAZON_SOCIAL VARCHAR(250)  -- Nueva raz�n social del cliente.
)
AS
BEGIN
    -- Actualiza los campos especificados para el cliente cuyo CODIGO coincide.
    UPDATE dbo.VEN_CLIENTE
    SET
        DOCUMENTO_IDENTIDAD = @DOCUMENTO_IDENTIDAD, -- Actualiza el tipo de documento.
        DOCUMENTO_IDENTIDAD_NUMERO = @DOCUMENTO_IDENTIDAD_NUMERO, -- Actualiza el n�mero de documento.
        RAZON_SOCIAL = @RAZON_SOCIAL -- Actualiza la raz�n social.
    WHERE CODIGO = @CODIGO; -- La condici�n de WHERE usa el CODIGO como clave primaria para identificar el registro.
END
GO

-- Procedimiento para eliminar un cliente de la tabla VEN_CLIENTE.
CREATE OR ALTER PROCEDURE sp_EliminarClientes
(
    @CODIGO VARCHAR(8)  -- C�digo del cliente que se va a eliminar (es la clave primaria).
)
AS
BEGIN
    -- Elimina el registro del cliente de la tabla VEN_CLIENTE.
    DELETE FROM dbo.VEN_CLIENTE
    WHERE CODIGO = @CODIGO; -- La condici�n de WHERE usa el CODIGO como clave primaria para identificar el registro.
END
GO
