-- USE BBDD

GO

/* 
 * Creado por: Nahuel Gómez - 30/05/2019.
 *
 * Genera automaticamente todos los script de alter que se le indique.
 * Para que funcione correctamente se deben insertar nombres de SP, VW o FN en la tabla @SP
 * ESTE SCRIPT NO FUNCIONA PARA CREACION DE TABLAS... Todav�a.
 */

BEGIN
	-- Le seteo el set no count ON porque sino me muestra un monton de giladas
	SET NOCOUNT ON;

	DECLARE @CURRENT_USER VARCHAR(100)
	select @CURRENT_USER = REPLACE(USER_NAME(),'TERNIUM\','')
	
	-- Declaro la tabla que va a tener las cosas que tengo que visualizar.
	DECLARE @SPs TABLE (idx int identity (1,1), nombres varchar(MAX), cambios VARCHAR(MAX))
	DECLARE @SPs_Inexistentes TABLE (obj_inexistente varchar(max))
	DECLARE @ACTUAL INT = 1


	--insert into @sps select name from sys.objects where name like '%%' and type = 'p'
	--select 
	--'insert into @sps values ('''+name+''',''Prueba'')'
	--from sys.objects
	--where name like '%%'
	--and type in ('P','TF','FR','V')

	insert into @sps values ('Stored Procedure','Comentario')
	
	-- Cuento cuantos tengo
	DECLARE @MAX INT = (SELECT COUNT(1) FROM @SPs)
	
	-- Declaro las variables a utilizar
	DECLARE @TEXT TABLE (texto VARCHAR(MAX))
	DECLARE @TXTPRE VARCHAR(MAX)
	DECLARE @SQL VARCHAR(MAX)
	DECLARE @PREEXEC VARCHAR(MAX)
	DECLARE @SPActual VARCHAR(MAX)
	DECLARE @CAMBIO VARCHAR(MAX)
	DECLARE @EXISTE INT = 0
	DECLARE @TIPO_OBJ VARCHAR(10)
	
	DECLARE @BBDD VARCHAR(800)
	set @BBDD = 'master'
	-- Seteo en que BBDD voy a usar el script
	SET @SQL = 'USE '+@BBDD+CHAR(13)+'GO' + char(13)
	SET @TXTPRE = 'USE '+@BBDD+CHAR(13)+'GO'+ char(13)

	-- Con este WHILE voy armando el script para los alters
	WHILE @ACTUAL <= @MAX
	BEGIN
		SELECT	@SPActual	= Nombres
			, @CAMBIO = ISNULL(cambios,'')
		FROM	@sps
		WHERE	IDX			= @Actual
	
		DELETE @TEXT

		IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE NAME = @SPActual)
		BEGIN
			SELECT @TIPO_OBJ = [type] 
			FROM SYS.OBJECTS
			WHERE NAME = @SPActual
					
			IF @tipo_obj not in ('U')
				INSERT INTO @TEXT (texto)
				EXEC sp_helptext @SPActual

			
			-- P  = Stored Procedure
			IF @TIPO_OBJ = 'P'
			BEGIN
				SET @TXTPRE = @TXTPRE + 'GO' +char(13)
				SET @TXTPRE = @TXTPRE + 'DECLARE @SQL VARCHAR(MAX)' +char(13)
				SET @TXTPRE = @TXTPRE + 'IF NOT EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE NAME = '''+@SPActual+''') ' +char(13)
				SET @TXTPRE = @TXTPRE + 'BEGIN' +char(13)
				SET @TXTPRE = @TXTPRE + '	SET @SQL = ''CREATE PROCEDURE dbo.'+UPPER(@SPActual)+' as BEGIN SELECT 1 Resultado END''' +char(13)
				SET @TXTPRE = @TXTPRE + '	EXEC(@SQL)' +char(13)
				SET @TXTPRE = @TXTPRE + '	PRINT(''Script: Se cre� el stored: '+@SPActual+''')' +char(13)
				SET @TXTPRE = @TXTPRE + 'END ELSE BEGIN' +char(13)
				SET @TXTPRE = @TXTPRE + '	PRINT(''Script: Ya existe el SP: '+@SPActual+''')' +char(13)
				SET @TXTPRE = @TXTPRE + 'END' +char(13)
				
				SET @TXTPRE = @TXTPRE + 'GO' +char(13)
			END
			
			-- TF = Funcion Tabla
			IF @TIPO_OBJ = 'TF'
			BEGIN
				SET @TXTPRE = @TXTPRE + 'GO' +char(13)
				SET @TXTPRE = @TXTPRE + 'DECLARE @SQL VARCHAR(MAX)' +char(13)
				SET @TXTPRE = @TXTPRE + 'IF NOT EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE NAME = '''+@SPActual+''') ' +char(13)
				SET @TXTPRE = @TXTPRE + 'BEGIN' +char(13)
				SET @TXTPRE = @TXTPRE + '	SET @SQL = ''CREATE FUNCTION dbo.'+@SPActual+'() RETURNS TABLE AS RETURN (SELECT 0 IDX)''' +char(13)
				SET @TXTPRE = @TXTPRE + '	EXEC(@SQL)' +char(13)
				SET @TXTPRE = @TXTPRE + '	PRINT(''Script: Se cre� la funci�n tabla: '+@SPActual+''')' +char(13)
				SET @TXTPRE = @TXTPRE + 'END ELSE BEGIN' +char(13)
				SET @TXTPRE = @TXTPRE + '	PRINT(''Script: Ya existe la funci�n tabla: '+@SPActual+''')' +char(13)
				SET @TXTPRE = @TXTPRE + 'END' +char(13)
				SET @TXTPRE = @TXTPRE + 'GO' + CHAR(13)
			END
			
			-- FN = Funcion Scala
			IF @TIPO_OBJ = 'FN'
			BEGIN
				SET @TXTPRE = @TXTPRE + 'GO' +char(13)
				SET @TXTPRE = @TXTPRE + 'DECLARE @SQL VARCHAR(MAX)' +char(13)
				SET @TXTPRE = @TXTPRE + 'IF NOT EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE NAME = '''+@SPActual+''') ' +char(13)
				SET @TXTPRE = @TXTPRE + 'BEGIN' +char(13)
				SET @TXTPRE = @TXTPRE + '	SET @SQL = ''CREATE FUNCTION dbo.'+@SPActual+'() RETURNS INT AS BEGIN RETURN 1 END''' +char(13)
				SET @TXTPRE = @TXTPRE + '	EXEC(@SQL)' +char(13)
				SET @TXTPRE = @TXTPRE + '	PRINT(''Script: Se cre� la Funcion Scala: '+@SPActual+''')' +char(13)
				SET @TXTPRE = @TXTPRE + 'END ELSE BEGIN' +char(13)
				SET @TXTPRE = @TXTPRE + '	PRINT(''Script: Ya existe la Funcion Scala: '+@SPActual+''')' +char(13)
				SET @TXTPRE = @TXTPRE + 'END' +char(13)
				SET @TXTPRE = @TXTPRE + 'GO' + CHAR(13)
			END
			
			-- V  = View
			IF @TIPO_OBJ = 'V'
			BEGIN
				SET @TXTPRE = @TXTPRE + 'GO' +char(13)
				SET @TXTPRE = @TXTPRE + 'DECLARE @SQL VARCHAR(MAX)' +char(13)
				SET @TXTPRE = @TXTPRE + 'IF NOT EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE NAME = '''+@SPActual+''') ' +char(13)
				SET @TXTPRE = @TXTPRE + 'BEGIN' +char(13)
				SET @TXTPRE = @TXTPRE + '	SET @SQL = ''CREATE VIEW dbo.'+@SPActual+' AS SELECT 1 AS BMW''' +char(13)
				SET @TXTPRE = @TXTPRE + '	EXEC(@SQL)' +char(13)
				SET @TXTPRE = @TXTPRE + '	PRINT(''Script: Se cre� la View: '+@SPActual+''')' +char(13)
				SET @TXTPRE = @TXTPRE + 'END ELSE BEGIN' +char(13)
				SET @TXTPRE = @TXTPRE + '	PRINT(''Script: Ya existe la la View: '+@SPActual+''')' +char(13)
				SET @TXTPRE = @TXTPRE + 'END' +char(13)
				SET @TXTPRE = @TXTPRE + 'GO' + CHAR(13)
			END

			SET @EXISTE = 1
		END ELSE BEGIN
			SET @EXISTE = 0
		END 
	
		IF @EXISTE = 1
		BEGIN
			IF ISNULL(@CAMBIO,'') = ''
				set @CAMBIO = ''

			SET @CAMBIO = REPLACE(REPLACE(REPLACE(@CAMBIO, char(10),''),char(13),''),'
			','')

			--IF @CAMBIO <> ''
			--BEGIN
				SELECT @SQL = @SQL + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
								TEXTO,
								'CREATE PROC', CASE WHEN @cambio <> '' THEN '-- ' + convert(varchar(50),getdate(),103) + ' ' + convert(varchar(50),getdate(),108) + ': ' + @cambio + char(13) else '' end + 'ALTER PROC'),
								'CREATE FUNC', CASE WHEN @cambio <> '' THEN '-- ' + convert(varchar(50),getdate(),103) + ' ' + convert(varchar(50),getdate(),108) + ': ' + @cambio + char(13) else '' end + 'ALTER FUNC'),
								'CREATE VIEW', CASE WHEN @cambio <> '' THEN '-- ' + convert(varchar(50),getdate(),103) + ' ' + convert(varchar(50),getdate(),108) + ': ' + @cambio + char(13) else '' end + 'ALTER VIEW'),
								'CREATE	PROC', CASE WHEN @cambio <> '' THEN '-- ' + convert(varchar(50),getdate(),103) + ' ' + convert(varchar(50),getdate(),108) + ': ' + @cambio + char(13) else '' end + 'ALTER PROC'),
								'CREATE	FUNC', CASE WHEN @cambio <> '' THEN '-- ' + convert(varchar(50),getdate(),103) + ' ' + convert(varchar(50),getdate(),108) + ': ' + @cambio + char(13) else '' end + 'ALTER FUNC'),
								'CREATE	VIEW', CASE WHEN @cambio <> '' THEN '-- ' + convert(varchar(50),getdate(),103) + ' ' + convert(varchar(50),getdate(),108) + ': ' + @cambio + char(13) else '' end + 'ALTER VIEW')
				FROM @TEXT
			--END			
		END
		ELSE
		BEGIN
			INSERT INTO @SPs_Inexistentes
			SELECT @SPActual as Objetos_Inexistentes
		END
		
		SET @SQL = @SQL + char(13) + 'GO' + char(13)
		SET @EXISTE = 0
		SET @ACTUAL = @ACTUAL + 1
	END
	
	SET @SQL = @TXTPRE + @SQL
	-- Imprimo todo el script, podr�a seleccionarlo pero si es muy largo NO me deja.
	DECLARE @C INT, @R INT
	SET @C = 0
	SET @R = ( LEN(@SQL) / 8000 )+ 1
	
	while @c <= @r
		begin
			print(substring(@SQL, ((@c-1)*8000)+1 ,8000))
			print('AcaSeDebeDividirTodoPorQueElSQLNoDaMas')
			set @c = @c + 1
		end
	
	SELECT [processing-instruction(x)]=@sql FOR XML PATH('')
	SELECT * FROM @SPs_Inexistentes
END

GO