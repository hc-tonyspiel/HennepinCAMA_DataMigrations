DECLARE @SQ_FT_IN_ACRE NUMERIC(19,4) = 43560.0000,
        @VID VARCHAR(10) = '236568';

SELECT 
		t.TUS_ID,
        t.TUS_PID,
        t.TUS_BID,
        t.TUS_LINE_NUM,
        t.TUS_COMPONENT_TYPE,
        CASE t.TUS_LINE_CODE
            WHEN 'B' THEN 'B (BUILDING)'
            WHEN 'L' THEN 'L (LAND)'
            WHEN 'M' THEN 'M (MIXED USE)'
        END AS TUS_LINE_CODE,
        t.TUS_DESCRIPTION, 
        t.TUS_ACRES,
        t.TUS_TAX_USE_CODE,
        t.TUS_TAXPROPERTYTYPE_LTP_CODE,
        t.TUS_TAXPROPERTYTYPE_DESC,
        t.TUS_PARENT_ID
FROM (

    SELECT *
    FROM (
	    SELECT *
	    FROM [CAMA_PROD].REAL_PROP.TAX_USE
	    WHERE TUS_PARENT_ID IS NULL
    ) AS p

    UNION 

    SELECT c.*
    FROM [CAMA_PROD].REAL_PROP.TAX_USE p
    INNER JOIN [CAMA_PROD].REAL_PROP.TAX_USE c ON c.TUS_PARENT_ID = p.TUS_ID
    WHERE p.TUS_LINE_CODE != 'OB'

) t
WHERE   t.TUS_PID = ISNULL(@VID, t.TUS_PID) --AND
        --t.TUS_ACRES > 0 --AND
        --t.TUS_LINE_CODE IN ('L', 'M')
ORDER BY    t.TUS_LINE_NUM, 
            t.TUS_COMPONENT_TYPE, 
            CASE t.TUS_LINE_CODE
                WHEN 'L' THEN 0 
                ELSE 1
            END, 
            t.TUS_ACRES