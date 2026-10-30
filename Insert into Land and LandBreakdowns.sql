/*

*/

/*************************************************************
	Update Land  to assign ParcelEntityId parent
	Based on PID (without dashes for Vision Parcels)
*************************************************************/
--UPDATE l
--SET l.ParcelEntityId = p.EntityId
--FROM VisionLand l
--INNER JOIN VisionParcels p ON p.PID_WITHOUT_DASHES = l.PID

/*************************************************************
	Update LandBreakdowns to assign LandEntityId parent
	Based on PIDs
*************************************************************/
--UPDATE lb
--SET lb.LandEntityId = l.Id
--FROM VisionLandBreakdowns lb
--INNER JOIN VisionLand l ON lb.PID = l.PID

--/*************************************************************
--    Insert into Parcels.Land (reuse Id for first EntityId)
--*************************************************************/
--INSERT INTO [Parcels].[Land]
--           ([Id]
--           ,[ParcelEntityId]
--           ,[LandLabel]
--           ,[TotalLandValue]
--           ,[NeighborhoodCode]
--           ,[SiteAdjustment]
--           ,[LotSize]
--           ,[OnWaterId]
--           ,[LakeNameId]
--           ,[EffectiveFrontage]
--           ,[SupersededById]
--           ,[EntityId]
--           ,[AssessmentEventId]
--           ,[EffectiveDate]
--           ,[EndDate]
--           ,[CreatedAt]
--           ,[CreatedByUserId]
--           ,[SupersededAt]
--           ,[SupersededByUserId])
--     SELECT l.[Id]
--          ,l.[ParcelEntityId]
--          ,l.[LandLabel]
--          ,ISNULL(l.[TotalLandValue], 0)
--          ,l.[NeighborhoodCode]
--          ,l.[SiteAdjustment]
--          ,l.[LotSize]
--          ,CASE WHEN ln.Id IS NULL THEN '04' ELSE w.Id END AS OnWaterCode
--          ,ln.Id as LakeNameId
--          ,CASE WHEN ln.Id IS NULL THEN NULL ELSE l.[EffectiveFrontage] END AS [EffectiveFrontage]
--          ,l.[SupersededById]
--          ,l.Id AS EntityId
--          ,l.[AssessmentEventId]
--          ,l.[EffectiveDate]
--          ,l.[EndDate]
--          ,l.[CreatedAt]
--          ,l.[CreatedByUserId]
--          ,l.[SupersededAt]
--          ,l.[SupersededByUserId]
--  FROM [dbo].[VisionLand] l
--  INNER JOIN Parcels.Parcel p ON p.EntityId = l.ParcelEntityId
--  INNER JOIN [Configuration].OnWaterTypes w ON w.Id = CASE l.OnWaterCode
--                                                        WHEN '04' THEN 1 --None
--                                                        WHEN '01' THEN 2 --Lake
--                                                        WHEN '02' THEN 3 --River
--                                                        WHEN '03' THEN 4 --Swamp or slough
--                                                        WHEN '05' THEN 6 --Pond, creek, or stream
--                                                        --WHEN '??' THEN 5 --Other water influence
--                                                      END
--  LEFT JOIN [Configuration].LakeNames ln ON  ln.[Name] = l.LakeName 
--                                         AND ln.DORLakeCode = CASE l.LakeName WHEN 'BASS' THEN 1500 ELSE ln.DORLakeCode END


--/*************************************************************
--    Insert into breakdowns. The LandEntityId's need to be updated before this will work
--*************************************************************/
--INSERT INTO [Parcels].[LandBreakdown]
--           ([Id]
--           ,[LandEntityId]
--           ,[LandUseCodeId]
--           ,[IsContributing]
--           ,[ZoningClassificationId]
--           ,[ValuationClassification]
--           ,[UnitType]
--           ,[UnitCount]
--           ,[RatePerUnit]
--           ,[AdjustmentPercent]
--           ,[SegmentValue]
--           ,[SortOrder]
--           ,[SupersededById]
--           ,[EntityId]
--           ,[AssessmentEventId]
--           ,[EffectiveDate]
--           ,[EndDate]
--           ,[CreatedAt]
--           ,[CreatedByUserId]
--           ,[SupersededAt]
--           ,[SupersededByUserId])
--    SELECT lb.[Id]
--          ,lb.[LandEntityId]
--          ,lb.[LandUseCodeValue]
--          ,lb.[IsContributing]
--          ,lb.[ZoningClassificationId]
--          ,lb.[LandUseCodeValue] AS ValuationClassification --TODO - FIX THIS FOR Highest and Best Use (HBU)
--          ,ISNULL(lb.[UnitTypeName], '?')
--          ,ISNULL(lb.[UnitCount], 0)
--          ,ISNULL(lb.[RatePerUnit], 0)
--          ,lb.[AdjustmentPercent]
--          ,ISNULL(lb.[SegmentValue], 0)
--          ,lb.[SortOrder]
--          ,lb.[SupersededById]
--          ,lb.[Id] AS EntityId
--          ,lb.[AssessmentEventId]
--          ,lb.[EffectiveDate]
--          ,lb.[EndDate]
--          ,lb.[CreatedAt]
--          ,lb.[CreatedByUserID]
--          ,lb.[SupersededAt]
--          ,lb.[SupersededByUserId]
--      FROM [dbo].[VisionLandBreakdowns] lb
--      INNER JOIN VisionLand l on l.Id = lb.LandEntityId
--      INNER JOIN Parcels.Parcel p ON p.EntityId = l.ParcelEntityId
--      WHERE lb.LandUseCodeValue NOT IN (
--        '00LR',
--        '0SKL',
--        'NULL',
--        '28HA'
--      )