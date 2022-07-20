SET NOCOUNT ON;
 
DECLARE @spid INT,  @activas INT,  @query VARCHAR(255)  
 
SELECT @spid = MIN(spid), @activas = COUNT(*)  
FROM master..sysprocesses  
WHERE dbid = DB_ID('BBDD')  
AND spid != @@SPID  
 
PRINT 'Eliminando '+RTRIM(@activas)+' procesos.'  

WHILE @spid IS NOT NULL  
BEGIN  
    PRINT 'Eliminando el proceso '+ RTRIM(@spid)  
    SET @query = 'KILL '+RTRIM(@spid)  
    EXEC(@query)  --Ejecutamos el query
    SELECT @spid = MIN(spid), @activas = COUNT(*)  
    FROM master..sysprocesses  
    WHERE dbid = DB_ID('BBDD') AND spid != @@SPID  
      
    PRINT RTRIM(@activas)+ ' Procesos activos.'  
END 
GO