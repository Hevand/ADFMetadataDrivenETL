DROP PROCEDURE  [dbo].[usp_CreateMetadataConfigurationTableForDatabase]  
go

CREATE PROCEDURE [dbo].[usp_CreateMetadataConfigurationTableForDatabase]   
   @DatabaseConfigTableName nvarchar(100)
AS
BEGIN
	-- Define the tables, load type and columns to exclude
	DECLARE @tablesOfInterest table(
		Name NVARCHAR(200) NOT NULL,
		IsDelta BIT NOT NULL,
		WatermarkColumnName NVARCHAR(MAX) NULL,
		WatermarkColumnType NVARCHAR(MAX) NULL,
		WatermarkColumnStart NVARCHAR(MAX) NULL,
		IncludedColumns NVARCHAR(MAX) NULL
	);

	INSERT INTO @tablesOfInterest ([Name],[IsDelta], [WatermarkColumnName], [WatermarkColumnType], [WatermarkColumnStart], [IncludedColumns])
	VALUES
	('SampleFull', 0, NULL, NULL, NULL,  'Id, Version'),
	('SampleIncrement', 1, 'Version', 'timestamp', 0, 'Id, Version')

	--CREATE TEMPORARY TABLE
	CREATE TABLE #TEMPTABLE (
		Id INT IDENTITY(1,1),
		SourceObjectSettings NVARCHAR(MAX) NULL,		
		CopySourceSettings NVARCHAR(MAX) NULL,
		SinkObjectSettings NVARCHAR(MAX) NULL,
		CopyActivitySettings NVARCHAR(MAX) NULL,
		DataLoadingBehaviorSettings NVARCHAR(MAX) NULL,
		TaskId INT NULL,
		CopyEnabled BIT NULL
	)

	INSERT INTO #TEMPTABLE ([SourceObjectSettings], [CopySourceSettings],[SinkObjectSettings],[CopyActivitySettings], [DataLoadingBehaviorSettings], [TaskId], [CopyEnabled])
	SELECT 
		--SourceObjectSettings
		JSON_MODIFY(JSON_MODIFY('{}', '$.schema', 'dbo'), '$.table', toi.Name),		
		--CopySourceSettings
		(
			JSON_MODIFY(
			'{ "isolationLevel": "ReadUncommitted", "partitionOption": "None", "sqlReaderQuery": "", "partitionLowerBound": null, "partitionUpperBound": null, "partitionColumnName": null, "partitionNames": null }', 
			'$.sqlReaderQuery', 
			'select ' + toi.IncludedColumns
			)
		),
		--SinkObjectSettings
		JSON_MODIFY(
			'{ "fileName": "TOBEREPLACED", "folderPath": null, "container": "temproot" }', 
			'$.fileName', 
			toi.Name + '.parquet'
		),
		--CopyActivitySettings
		'{ "translator": null }',
		--DataLoadingBehavior

		JSON_MODIFY(
			JSON_MODIFY(		
				JSON_MODIFY(
					JSON_MODIFY(
						'{ "dataLoadingBehavior": "DeltaLoad", "watermarkColumnName": "Id", "watermarkColumnType": "Int32", "watermarkColumnStartValue": 0 }', 
						'$.dataLoadingBehavior', 
						( CASE WHEN toi.IsDelta = 1 THEN 'DeltaLoad' ELSE 'FullLoad' END)
					),
					'$.watermarkColumnName', 
					toi.WatermarkColumnName
				),
				'$.watermarkColumnType',
				toi.WatermarkColumnType
			),
			'$.watermarkColumnStartValue',
			toi.WatermarkColumnStart
		),	
		--TaskId
		0,
		--CopyEnabled	
		1
	FROM @tablesOfInterest toi

	DECLARE @CREATETABLE NVARCHAR(100);
	SET @CREATETABLE = 'SELECT * INTO ' + QUOTENAME(@DatabaseConfigTableName) + ' FROM #TEMPTABLE'
	EXEC (@CREATETABLE)

END
