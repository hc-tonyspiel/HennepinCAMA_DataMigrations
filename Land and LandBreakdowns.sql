
--/*
--	Uncommented Logic is used for investigation and troubleshooting.
--	Actual logic used to perform migration from vision to landing 
--	Tables in Hennepin CAMA Database is at the bottom of this script and commented out

--	Investigation:
--	- @LAND_LINES Table Variable - Used to allow us to show what a linked Land <=> LandBreakdown(s) looks like
--	- Insert into @LAND_LINES - Performs Land Migration Query and inserts into table variable for joining with breakdowns
--	- Select @LAND_LINES - Show the data to migrate
--	- Select Land Breakdowns - Show the data to migrate with their associated land line.

--	Actual Migration Queries - Both are commented out and include a header comment of the following:
--	- Actual query used to generate land
--	- Actual query used to generate land breakdowns
--*/
--DECLARE @LAND_LINES TABLE (
--	Id uniqueidentifier,
--	PID nvarchar(255),
--	ParcelEntityId uniqueidentifier,
--	LineNum numeric(9,0),
--	LandLabel nvarchar(255),
--	TotalLandValue Decimal(14,2),
--	NeighborhoodCode nvarchar(255),
--	SiteAdjustment int,
--	LotSize numeric(9,0),
--	OnWaterCode nvarchar(255),
--	LakeNameCode nvarchar(255),
--	LakeName nvarchar(255),
--	EffectiveFrontage numeric(9,0),
--	SupersededById uniqueidentifier,
--	AssessmentEventId uniqueidentifier,
--	EffectiveDate datetime2,
--	EndDate datetime2,
--	CreatedAt datetime2,
--	CreatedByUserId uniqueidentifier,
--	SupersededAt datetime2,
--	SupersededByUserId uniqueidentifier
--)

--INSERT INTO @LAND_LINES
--	SELECT	NEWID() AS Id,
--			r.REM_ACCT_NUM AS PID,
--			CAST(NULL AS uniqueidentifier) AS ParcelEntityId,
--			l.LND_LINE_NUM as LineNum,
--			CASE l.LND_LINE_NUM
--				WHEN 1 THEN 'Primary'
--				ELSE NULL
--			END AS LandLabel,
--			CAST(NULL AS DECIMAL(14,2)) AS TotalLandValue, --TODO : SET BASED ON OVERRIDE OR NOT, NOT = VALUE FROM BREAKDOWN
--			RIGHT('000000' + p.PRC_ASSNG_DIST, 6) AS NeighborhoodCode,
--			CAST(CASE l.LND_CNDTN_FACTOR 
--				WHEN 1 THEN 0
--				ELSE (l.LND_CNDTN_FACTOR - 1.00) * 100.00
--			END AS INT) AS SiteAdjustment,
--			l.LND_UNITS AS LotSize, 
--			ISNULL(p.PRC_GIS_REGION, '04') AS OnWaterCode, --NULL, 01(Lake), 02(River), 03(Swamp), 04(None), 05(Ponds)
--			p.PRC_PROP_TYPE AS LakeNameCode,
--			d.DSC_DESC AS LakeName,
--			CASE l.LND_FRONTAGE
--				WHEN 0 THEN NULL
--				ELSE l.LND_FRONTAGE
--			END AS EffectiveFrontage,
--			CAST(NULL AS uniqueidentifier) AS SupersededById,
--			CAST('00000000-0000-0000-0000-000000000000' AS uniqueidentifier) AS AssessmentEventId, --DATA CORRECTION => CREATE ONE FOR DATA MIGRATION??!
--			CAST('1900-1-1' AS DATETIME2) AS EffectiveDate,
--			CAST(NULL AS DATETIME2) AS EndDate,
--			CAST(GETUTCDATE() AS DATETIME2) AS CreatedAt,
--			CAST('00000000-0000-0000-0000-000000000000' AS uniqueidentifier) AS CreatedByUserId, --UPDATE TO BE SOME 'SYSTEM USER ID'
--			CAST(NULL AS DATETIME2) AS SupersededAt,
--			CAST(NULL AS uniqueidentifier) AS SupersededByUserId
--	FROM REAL_PROP.LAND l
--	INNER JOIN REAL_PROP.PARCEL p ON p.PRC_PID = l.LND_PID
--	INNER JOIN REAL_PROP.REALMAST r ON r.REM_PID = l.LND_PID AND r.REM_PARCEL_STATUS = 'A'
--	LEFT JOIN COMMON.DESCRIPT d ON d.DSC_TYPE = 'LPT' AND DSC_CODE = p.PRC_PROP_TYPE

--SELECT * FROM @LAND_LINES

--/******************************************************************************************************************
-- Breakdowns - HOW DO WE ENSURE THESE ARE MATCHED TO THEIR PARENT??
--******************************************************************************************************************/
--SELECT	NEWID() AS Id, --AND ENTITY_ID ON INITIAL INSERT
--		ll.Id AS LandEntityId,
--		r.REM_ACCT_NUM AS PID,
--		RIGHT('0000' + l.LND_USE_CODE, 4) AS LandUseCodeValue,
--		l.LND_USE_DESC AS LandUseCodeName,
--		CASE ISNULL(l.LND_IS_EXEMPT, 0)
--			WHEN 0 THEN 1
--			ELSE 0
--		END AS IsContributing,
--		CAST(NULL AS INT) AS ZoningClassificationId,
--		l.LND_OCC AS ValuationClassificationUseCode,
--		l.LND_OCC_DESC AS ValuationClassificationUseCodeDescription,
--		l.LND_UNIT_TYPE AS UnitTypeValue, --TODO - NEEDS UPDATED TO SUPPORT DYNAMIC TYPES
--		l.LND_UNIT_TYPE_DESC AS UnitTypeName,
--		l.LND_UNITS AS UnitCount,
--		l.LND_UNIT_PRICE AS RatePerUnit, --TODO : AFFECTED BY TYPE CHOICE
--		CAST(0 AS DECIMAL(6,3)) AS AdjustmentPercent, --TODO : IDENTIFY WHERE THIS COMES FROM & VALUE
--		l.LND_UNIT_PRICE AS SegmentValue, --TODO : AFFECTED BY TYPE CHOICE
--		l.LND_LINE_NUM AS SortOrder,
--		CAST(NULL AS uniqueidentifier) AS SupersededById,
--		CAST('00000000-0000-0000-0000-000000000000' AS uniqueidentifier) AS AssessmentEventId, --DATA CORRECTION => CREATE ONE FOR DATA MIGRATION??!
--		CAST('1900-1-1' AS DATETIME2) AS EffectiveDate,
--		CAST(NULL AS DATETIME2) AS EndDate,
--		CAST(GETUTCDATE() AS DATETIME2) AS CreatedAt,
--		CAST('00000000-0000-0000-0000-000000000000' AS uniqueidentifier) AS CreatedByUserID, --UPDATE TO BE SOME 'SYSTEM USER ID'
--		CAST(NULL AS DATETIME2) AS SupersededAt,
--		CAST(NULL AS uniqueidentifier) AS SupersededByUserId
--FROM REAL_PROP.LAND l
--INNER JOIN REAL_PROP.PARCEL p ON p.PRC_PID = l.LND_PID
--INNER JOIN REAL_PROP.REALMAST r ON r.REM_PID = p.PRC_PID AND r.REM_PARCEL_STATUS = 'A'
--INNER JOIN @LAND_LINES ll ON ll.PID = r.REM_ACCT_NUM






/********************************************************************************
	Actual query used to generate land lines
********************************************************************************/
SELECT		m.SBM_SUBMNC,
			m.SBM_DESCRIP,
			NEWID() AS Id,
			r.REM_ACCT_NUM AS PID,
			CAST(NULL AS uniqueidentifier) AS ParcelEntityId,
			l.LND_LINE_NUM as LineNum,
			CASE l.LND_LINE_NUM
				WHEN 1 THEN 'Primary'
				ELSE NULL
			END AS LandLabel,
			CAST(NULL AS DECIMAL(14,2)) AS TotalLandValue, --TODO : SET BASED ON OVERRIDE OR NOT, NOT = VALUE FROM BREAKDOWN
			RIGHT('000000' + p.PRC_ASSNG_DIST, 6) AS NeighborhoodCode,
			CAST(CASE l.LND_CNDTN_FACTOR 
				WHEN 1 THEN 0
				ELSE (l.LND_CNDTN_FACTOR - 1.00) * 100.00
			END AS INT) AS SiteAdjustment,
			--p.PRC_GROSS_AREA AS LotSize, 
			r.REM_LEGAL_AREA AS LEGAL_AREA_LotSize,
			l.LND_UNITS AS LotSize, 
			l.LND_TOTAL_UNITS AS LandTotalUnits,
			l.LND_TOTAL_UNITS_SF AS LandTotalUnitsSF, 
			l.LND_UNIT_TYPE,
			l.LND_UNIT_TYPE_DESC,
			ISNULL(p.PRC_GIS_REGION, '04') AS OnWaterCode, --NULL, 01(Lake), 02(River), 03(Swamp), 04(None), 05(Ponds)
			p.PRC_PROP_TYPE AS LakeNameCode,
			d.DSC_DESC AS LakeName,
			CASE l.LND_FRONTAGE
				WHEN 0 THEN NULL
				ELSE l.LND_FRONTAGE
			END AS EffectiveFrontage,
			CAST(NULL AS uniqueidentifier) AS SupersededById,
			CAST('00000000-0000-0000-0000-000000000000' AS uniqueidentifier) AS AssessmentEventId, --DATA CORRECTION => CREATE ONE FOR DATA MIGRATION??!
			CAST('1900-1-1' AS DATETIME2) AS EffectiveDate,
			CAST(NULL AS DATETIME2) AS EndDate,
			CAST(GETUTCDATE() AS DATETIME2) AS CreatedAt,
			CAST('00000000-0000-0000-0000-000000000000' AS uniqueidentifier) AS CreatedByUserId, --UPDATE TO BE SOME 'SYSTEM USER ID'
			CAST(NULL AS DATETIME2) AS SupersededAt,
			CAST(NULL AS uniqueidentifier) AS SupersededByUserId
FROM REAL_PROP.LAND l WITH(NOLOCK)
INNER JOIN REAL_PROP.PARCEL p WITH(NOLOCK) ON p.PRC_PID = l.LND_PID
INNER JOIN REAL_PROP.REALMAST r WITH(NOLOCK) ON r.REM_PID = l.LND_PID AND r.REM_PARCEL_STATUS = 'A'
INNER JOIN COMMON.SUBMUNICIP m WITH(NOLOCK) ON m.SBM_SUBMNC = r.REM_SUBMNC
LEFT JOIN COMMON.DESCRIPT d WITH(NOLOCK) ON d.DSC_TYPE = 'LPT' AND DSC_CODE = p.PRC_PROP_TYPE
WHERE --r.REM_LEGAL_AREA != l.LND_UNITS AND r.REM_LEGAL_AREA < l.LND_UNITS
--AND l.LND_UNITS != 0 
--AND m.SBM_SUBMNC != '01'
--AND 
r.REM_ACCT_NUM = '1511924110001' --'0102724410011'
--ORDER BY m.SBM_SUBMNC, r.REM_ACCT_NUM, LND_UNIT_TYPE, l.LND_LINE_NUM
--WHERE l.LND_UNIT_TYPE IS NULL


/**************************************************************************************************
  LAND UNIT TYPES BY COUNT
  NULL	- 7
  AC	- 10756
  BL	- 279472
  FF	- 3943
  SF	- 166548
**************************************************************************************************/
--SELECT l.LND_UNIT_TYPE, COUNT(1)
--FROM REAL_PROP.LAND l WITH(NOLOCK)
--INNER JOIN REAL_PROP.PARCEL p WITH(NOLOCK) ON p.PRC_PID = l.LND_PID
--INNER JOIN REAL_PROP.REALMAST r WITH(NOLOCK) ON r.REM_PID = l.LND_PID AND r.REM_PARCEL_STATUS = 'A'
--INNER JOIN COMMON.SUBMUNICIP m WITH(NOLOCK) ON m.SBM_SUBMNC = r.REM_SUBMNC
--LEFT JOIN COMMON.DESCRIPT d WITH(NOLOCK) ON d.DSC_TYPE = 'LPT' AND DSC_CODE = p.PRC_PROP_TYPE
--GROUP BY l.LND_UNIT_TYPE


/********************************************************************************
	Actual query used to generate land breakdowns
********************************************************************************/
--SELECT	NEWID() AS Id, --AND ENTITY_ID ON INITIAL INSERT
--		--TODO - NEED TO FIGURE OUT HOW TO GENERATE A LAND ENTITY ID THAT CAN BE USED WHEN ADDING THE BREAKDOWN
--		cast(null as uniqueidentifier) AS LandEntityId,
--		r.REM_ACCT_NUM AS PID,
--		RIGHT('0000' + l.LND_USE_CODE, 4) AS LandUseCodeValue,
--		l.LND_USE_DESC AS LandUseCodeName,
--		CASE ISNULL(l.LND_IS_EXEMPT, 0)
--			WHEN 0 THEN 1
--			ELSE 0
--		END AS IsContributing,
--		CAST(NULL AS INT) AS ZoningClassificationId,
--		l.LND_OCC AS ValuationClassificationUseCode,
--		l.LND_OCC_DESC AS ValuationClassificationUseCodeDescription,
--		l.LND_UNIT_TYPE AS UnitTypeValue, --TODO - NEEDS UPDATED TO SUPPORT DYNAMIC TYPES
--		l.LND_UNIT_TYPE_DESC AS UnitTypeName,
--		l.LND_UNITS AS UnitCount,
--		l.LND_UNIT_PRICE AS RatePerUnit, --TODO : AFFECTED BY TYPE CHOICE
--		CAST(0 AS DECIMAL(6,3)) AS AdjustmentPercent, --TODO : IDENTIFY WHERE THIS COMES FROM & VALUE
--		l.LND_UNIT_PRICE AS SegmentValue, --TODO : AFFECTED BY TYPE CHOICE
--		l.LND_LINE_NUM AS SortOrder,
--		CAST(NULL AS uniqueidentifier) AS SupersededById,
--		CAST('00000000-0000-0000-0000-000000000000' AS uniqueidentifier) AS AssessmentEventId, --DATA CORRECTION => CREATE ONE FOR DATA MIGRATION??!
--		CAST('1900-1-1' AS DATETIME2) AS EffectiveDate,
--		CAST(NULL AS DATETIME2) AS EndDate,
--		CAST(GETUTCDATE() AS DATETIME2) AS CreatedAt,
--		CAST('00000000-0000-0000-0000-000000000000' AS uniqueidentifier) AS CreatedByUserID, --UPDATE TO BE SOME 'SYSTEM USER ID'
--		CAST(NULL AS DATETIME2) AS SupersededAt,
--		CAST(NULL AS uniqueidentifier) AS SupersededByUserId
--FROM REAL_PROP.LAND l
--INNER JOIN REAL_PROP.PARCEL p ON p.PRC_PID = l.LND_PID
--INNER JOIN REAL_PROP.REALMAST r ON r.REM_PID = p.PRC_PID AND r.REM_PARCEL_STATUS = 'A'


--SELECT r.REM_ACCT_NUM, COUNT(1)
--FROM REAL_PROP.LAND l WITH(NOLOCK)
--INNER JOIN REAL_PROP.PARCEL p WITH(NOLOCK) ON p.PRC_PID = l.LND_PID
--INNER JOIN REAL_PROP.REALMAST r WITH(NOLOCK) ON r.REM_PID = l.LND_PID AND r.REM_PARCEL_STATUS = 'A'
--INNER JOIN COMMON.SUBMUNICIP m WITH(NOLOCK) ON m.SBM_SUBMNC = r.REM_SUBMNC
--LEFT JOIN COMMON.DESCRIPT d WITH(NOLOCK) ON d.DSC_TYPE = 'LPT' AND DSC_CODE = p.PRC_PROP_TYPE
--GROUP BY r.REM_ACCT_NUM HAVING COUNT(1) > 4