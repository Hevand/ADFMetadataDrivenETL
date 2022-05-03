/****** Object: StoredProcedure [dbo].[UpdateWatermarkColumnValue_aa1] ******/
IF OBJECT_ID ( 'dbo.usp_UpdateMetadataConfigurationDatabaseWatermark', 'P' ) IS NOT NULL   
    DROP PROCEDURE [dbo].[usp_UpdateMetadataConfigurationDatabaseWatermark];  
GO  

CREATE PROCEDURE [dbo].[usp_UpdateMetadataConfigurationDatabaseWatermark]	
	@DatabaseConfigTableName nvarchar(100),
	@watermarkColumnStartValue bigint,
	@Id [int]
AS
BEGIN
	DECLARE @UPDATEWATERMARK NVARCHAR(1000);
	
	SET @UPDATEWATERMARK = 'UPDATE [dbo].[' +  QUOTENAME(@DatabaseConfigTableName) + ']
	SET [DataLoadingBehaviorSettings]=JSON_MODIFY([DataLoadingBehaviorSettings],''$.watermarkColumnStartValue'', ' + @watermarkColumnStartValue + ') WHERE Id = ' + @Id

	EXEC (@UPDATEWATERMARK)

END
