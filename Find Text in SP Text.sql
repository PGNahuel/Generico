-- USE BBDD PRUEBA COMIT

go

set nocount on;

DECLARE @nameSP varchar(500),
    	@textSP varchar(2000),
		@nombreABuscar VARCHAR(2000)

IF OBJECT_ID('tempdb..#TableText') IS NOT NULL 
	DROP TABLE #TableText

IF OBJECT_ID('tempdb..#TableResultMal') IS NOT NULL 
	DROP TABLE #TableResultMal

create table #TableText(campoText varchar(2000), line_number int identity(1,1)) 
create table #TableResultMal( nameSP varchar(500) NULL, line_text varchar(2000) NULL, line_number int)

SET @nombreABuscar  = ''

DECLARE C_NAME_SP CURSOR FOR 
	select [NAME] from sysobjects
	where type in ('T','P', 'V', 'FN')
	order by [NAME]

OPEN C_NAME_SP
FETCH NEXT FROM C_NAME_SP INTO @nameSP

IF @@FETCH_STATUS <> 0  
PRINT '<<None>>'     

WHILE @@FETCH_STATUS = 0
BEGIN
	BEGIN TRY
		insert into #TableText
		exec sp_helptext @nameSP

		if exists(select 1 from #TableText)
			insert into #TableResultMal
			select @namesp, campoText, line_number
			from #TableText
			where campotext like '%'+@nombreABuscar+'%'
	END TRY
	BEGIN CATCH
	END CATCH

	truncate table #TableText

	FETCH NEXT FROM C_NAME_SP INTO @nameSP
END

CLOSE C_NAME_SP
DEALLOCATE C_NAME_SP

select * from #TableResultMal

GO