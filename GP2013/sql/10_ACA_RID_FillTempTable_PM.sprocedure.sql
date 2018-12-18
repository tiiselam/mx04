
/****** Object:  StoredProcedure [dbo].[ACA_RID_FillTempTable_PM]    Script Date: 22/05/2017 07:36:39 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = 'dbo'
     AND SPECIFIC_NAME = 'ACA_RID_FillTempTable_PM' 
)
   DROP PROCEDURE dbo.[ACA_RID_FillTempTable_PM];
GO

  create PROCEDURE [dbo].[ACA_RID_FillTempTable_PM] @TEMPTABLE CHAR(100), @FECHAD CHAR(8), @FECHAH CHAR(8), @VENDNAME CHAR(64), @VCHRNMBR CHAR(21), @YEAR1 INT, @MONTH1 INT, @TAXSTATUS tinyint 
AS 
DECLARE @EJECUTAR CHAR(300) 
--SELECT @TEMPTABLE = '##1274428' 
-- EXEC ACA_RID_FillTempTable_PM '##1112102', '19000101', '99991231', '', '', 0, 0 
SELECT @EJECUTAR = 'DELETE ' + rtrim(@TEMPTABLE) 
EXEC (@EJECUTAR) 
CREATE TABLE #TEMPORAL 
	(Selected tinyint, 
	CHEKBKID CHAR(15), 
	VCHRNMBR CHAR(21), 
	VENDORID CHAR(15), 
	VENDNAME CHAR(64), 
	DATE1 DATETIME, 
	DOCAMNT NUMERIC(19, 5), 
	DSCRIPTN CHAR(30), 
	STSDESCR CHAR(30), 
	COMMENT1 CHAR(30), 
	YEAR1 smallint, 
	MONTH1 smallint, 
	DEX_ROW_ID INT IDENTITY(1,1) 
	) 

INSERT INTO #TEMPORAL 
SELECT DISTINCT 0 Selected, CASE WHEN A.CHEKBKID = '' THEN  
ISNULL((SELECT TOP 1 TII_CHEKBKID FROM nfMCP_PM20100 WHERE NUMBERIE = A.VCHRNMBR AND TII_CHEKBKID <> ''),  
ISNULL((SELECT TOP 1 MEDIOID FROM nfMCP_PM20100 WHERE NUMBERIE = A.VCHRNMBR AND TII_CHEKBKID = ''), '')) 
 ELSE A.CHEKBKID END CHEKBKID, 
A.VCHRNMBR, A.VENDORID, B.VENDNAME, A.DOCDATE, A.DOCAMNT, '' DSCRIPTN, 
CASE WHEN A.VOIDED = 1 THEN 'Anulado' ELSE '' END STSDESCR, '' COMMENT1, YEAR(A.PSTGDATE) YEAR1, 
MONTH(A.PSTGDATE) MONTH1  
FROM PM20000 A INNER JOIN PM00200 B ON A.VENDORID = B.VENDORID INNER JOIN PM00400 KM ON A.DOCTYPE = KM.DOCTYPE AND A.VCHRNMBR = KM.CNTRLNUM 
LEFT OUTER JOIN ACA_RID10000 D ON A.DOCTYPE = D.DOCTYPE AND A.VCHRNMBR = D.VCHRNMBR
WHERE A.DOCTYPE = 6 AND KM.DCSTATUS = 2 AND D.VCHRNMBR IS NULL 
UNION  
SELECT DISTINCT 0 Selected, CASE WHEN A.CHEKBKID = '' THEN  
ISNULL((SELECT TOP 1 TII_CHEKBKID FROM nfMCP_PM20100 WHERE NUMBERIE = A.VCHRNMBR AND TII_CHEKBKID <> ''),  
ISNULL((SELECT TOP 1 MEDIOID FROM nfMCP_PM20100 WHERE NUMBERIE = A.VCHRNMBR AND TII_CHEKBKID = ''), '')) 
 ELSE A.CHEKBKID END CHEKBKID, 
A.VCHRNMBR, A.VENDORID, B.VENDNAME, A.DOCDATE, A.DOCAMNT, '' DSCRIPTN, 
CASE WHEN A.VOIDED = 1 THEN 'Anulado' ELSE '' END STSDESCR, '' COMMENT1, YEAR(A.PSTGDATE) YEAR1, 
MONTH(A.PSTGDATE) MONTH1  
FROM PM30200 A INNER JOIN PM00200 B ON A.VENDORID = B.VENDORID INNER JOIN PM00400 KM ON A.DOCTYPE = KM.DOCTYPE AND A.VCHRNMBR = KM.CNTRLNUM 
LEFT OUTER JOIN ACA_RID10000 D ON A.DOCTYPE = D.DOCTYPE AND A.VCHRNMBR = D.VCHRNMBR
WHERE A.DOCTYPE = 6 AND KM.DCSTATUS = 3 AND D.VCHRNMBR IS NULL 
UNION
SELECT DISTINCT 0 Selected, CASE WHEN A.CHEKBKID = '' THEN  
ISNULL((SELECT TOP 1 TII_CHEKBKID FROM nfMCP_PM20100 WHERE NUMBERIE = A.VCHRNMBR AND TII_CHEKBKID <> ''),  
ISNULL((SELECT TOP 1 MEDIOID FROM nfMCP_PM20100 WHERE NUMBERIE = A.VCHRNMBR AND TII_CHEKBKID = ''), '')) 
 ELSE A.CHEKBKID END CHEKBKID, 
A.VCHRNMBR, A.VENDORID, B.VENDNAME, A.DOCDATE, A.DOCAMNT, '' DSCRIPTN, 
CASE WHEN A.VOIDED = 1 THEN 'Anulado' ELSE '' END STSDESCR, '' COMMENT1, YEAR(A.PSTGDATE) YEAR1, 
MONTH(A.PSTGDATE) MONTH1  
FROM PM20000 A INNER JOIN PM00200 B ON A.VENDORID = B.VENDORID INNER JOIN PM00400 KM ON A.DOCTYPE = KM.DOCTYPE AND A.VCHRNMBR = KM.CNTRLNUM 
INNER JOIN ACA_RID10000 D ON A.DOCTYPE = D.DOCTYPE AND A.VCHRNMBR = D.VCHRNMBR
WHERE A.DOCTYPE = 6 AND KM.DCSTATUS = 2 AND D.ACA_RID_Last = 1 
UNION  
SELECT DISTINCT 0 Selected, CASE WHEN A.CHEKBKID = '' THEN  
ISNULL((SELECT TOP 1 TII_CHEKBKID FROM nfMCP_PM20100 WHERE NUMBERIE = A.VCHRNMBR AND TII_CHEKBKID <> ''),  
ISNULL((SELECT TOP 1 MEDIOID FROM nfMCP_PM20100 WHERE NUMBERIE = A.VCHRNMBR AND TII_CHEKBKID = ''), '')) 
 ELSE A.CHEKBKID END CHEKBKID, 
A.VCHRNMBR, A.VENDORID, B.VENDNAME, A.DOCDATE, A.DOCAMNT, '' DSCRIPTN, 
CASE WHEN A.VOIDED = 1 THEN 'Anulado' ELSE '' END STSDESCR, '' COMMENT1, YEAR(A.PSTGDATE) YEAR1, 
MONTH(A.PSTGDATE) MONTH1  
FROM PM30200 A INNER JOIN PM00200 B ON A.VENDORID = B.VENDORID INNER JOIN PM00400 KM ON A.DOCTYPE = KM.DOCTYPE AND A.VCHRNMBR = KM.CNTRLNUM 
INNER JOIN ACA_RID10000 D ON A.DOCTYPE = D.DOCTYPE AND A.VCHRNMBR = D.VCHRNMBR
WHERE A.DOCTYPE = 6 AND KM.DCSTATUS = 3 AND D.ACA_RID_Last = 1
ORDER BY A.VCHRNMBR

UPDATE #TEMPORAL SET DSCRIPTN = CASE ISNULL(B.ACA_RID_Tax_Status, 0)  
WHEN 0 THEN 'No procesado' WHEN 1 THEN 'Reclasificado' ELSE 'Revertido' END, YEAR1 = CASE WHEN ISNULL(B.YEAR1, 0) = 0 THEN A.YEAR1 ELSE B.YEAR1 END, MONTH1 = CASE WHEN ISNULL(B.YEAR1, 0) = 0 THEN A.MONTH1 ELSE B.MONTHINTERVAL END 
FROm #TEMPORAL A LEFT OUTER JOIN ACA_RID10000 B ON A.VCHRNMBR = B.VCHRNMBR AND B.TXDTLTYP = 2 AND B.DOCTYPE = 6 AND B.ACA_RID_Last = 1 
UPDATE #TEMPORAL SET STSDESCR = CASE WHEN ISNULL((select SUM(APFRMAPLYAMT) APPLDAMT from PM10200 A INNER JOIN ACA_IETU00400 B ON A.APTODCTY = B.DOCTYPE AND A.APTVCHNM = B.VCHRNMBR 
WHERE APTODCTY IN( 1, 2, 3) AND B.ACA_Gasto = 1 AND A.VCHRNMBR = TMP.VCHRNMBR), 0) = TMP.DOCAMNT THEN 'Aplicado' ELSE 'Otros' END 
FROM #TEMPORAL TMP INNER JOIN PM00400 KM ON TMP.VCHRNMBR = KM.CNTRLNUM WHERE KM.DOCTYPE = 6 AND DCSTATUS = 2 AND STSDESCR <> 'Anulado' 
UPDATE #TEMPORAL SET STSDESCR = CASE WHEN ISNULL((select SUM(APFRMAPLYAMT) APPLDAMT from PM30300 A INNER JOIN ACA_IETU00400 B ON A.APTODCTY = B.DOCTYPE AND A.APTVCHNM = B.VCHRNMBR 
WHERE APTODCTY IN( 1, 2, 3) AND B.ACA_Gasto = 1 AND A.VCHRNMBR = TMP.VCHRNMBR), 0) = TMP.DOCAMNT THEN 'Aplicado' ELSE 'Otros' END 
FROM #TEMPORAL TMP INNER JOIN PM00400 KM ON TMP.VCHRNMBR = KM.CNTRLNUM WHERE KM.DOCTYPE = 6 AND DCSTATUS = 3 AND STSDESCR <> 'Anulado' 
UPDATE #TEMPORAL SET STSDESCR = CASE WHEN ISNULL((select SUM(APFRMAPLYAMT) APPLDAMT from PM10200 A LEFT OUTER JOIN ACA_IETU00400 B ON A.APTODCTY = B.DOCTYPE AND A.APTVCHNM = B.VCHRNMBR 
WHERE APTODCTY IN( 2, 3) AND ISNULL(B.ACA_Gasto, 0) = 0 AND A.VCHRNMBR = TMP.VCHRNMBR), 0) = TMP.DOCAMNT THEN 'Anulado ND' ELSE STSDESCR END 
FROM #TEMPORAL TMP INNER JOIN PM00400 KM ON TMP.VCHRNMBR = KM.CNTRLNUM WHERE KM.DOCTYPE = 6 AND DCSTATUS = 2 
UPDATE #TEMPORAL SET STSDESCR = CASE WHEN ISNULL((select SUM(APFRMAPLYAMT) APPLDAMT from PM30300 A LEFT OUTER JOIN ACA_IETU00400 B ON A.APTODCTY = B.DOCTYPE AND A.APTVCHNM = B.VCHRNMBR 
WHERE APTODCTY IN( 2, 3) AND ISNULL(B.ACA_Gasto, 0) = 0 AND A.VCHRNMBR = TMP.VCHRNMBR), 0) = TMP.DOCAMNT THEN 'Anulado ND' ELSE STSDESCR END 
FROM #TEMPORAL TMP INNER JOIN PM00400 KM ON TMP.VCHRNMBR = KM.CNTRLNUM WHERE KM.DOCTYPE = 6 AND DCSTATUS = 3 
UPDATE #TEMPORAL SET DSCRIPTN = 'Anulado Revertido' 
FROM #TEMPORAL TMP INNER JOIN PM30200 HS ON TMP.VCHRNMBR = HS.VCHRNMBR 
INNER JOIN ACA_RID10000 D ON TMP.VCHRNMBR = D.VCHRNMBR WHERE HS.DOCTYPE = 6 AND HS.VOIDED = 1 AND D.ACA_RID_Origen = 1 AND D.ACA_RID_Tax_Status = 1
UPDATE #TEMPORAL  
SET COMMENT1 =  
		CASE DSCRIPTN 
			WHEN 'No procesado' THEN 
				CASE STSDESCR 
				WHEN 'Aplicado' THEN	'Debe reclasificar' 
				WHEN 'Anulado' THEN	'No es posible reclasificar' 
				WHEN 'Anulado ND' THEN 'No es posible reclasificar' 
				WHEN 'Otros' THEN 'No es posible reclasificar' 
				END 
			WHEN 'Reclasificado' THEN 
				CASE STSDESCR 
				WHEN 'Aplicado' THEN 'OK (puede revertir)' 
				WHEN 'Anulado' THEN 'Debe revertir' 
				WHEN 'Anulado ND' THEN 'No es posible reclasificar' 
				WHEN 'Otros' THEN	'Debe revertir o corregir FC IE' 
				END 
			WHEN 'Revertido' THEN 
				CASE STSDESCR 
				WHEN 'Aplicado' THEN 'Puede reclasificar' 
				WHEN 'Anulado' THEN 'No es posible reclasificar' 
				WHEN 'Otros' THEN 'No es posible reclasificar' 
				END 
			WHEN 'Anulado Revertido' THEN 
				'No es posible reclasificar' 
			ELSE
				'A Revisar'
		END 

IF RTRIM(@VENDNAME)<>'' BEGIN DELETE #TEMPORAL WHERE VENDNAME NOT LIKE '%'+RTRIM(@VENDNAME)+'%' END 
IF RTRIM(@VCHRNMBR)<>'' BEGIN DELETE #TEMPORAL WHERE VCHRNMBR NOT LIKE '%'+RTRIM(@VCHRNMBR)+'%' END 
IF @FECHAD <> '19000101' BEGIN DELETE #TEMPORAL WHERE DATE1 < @FECHAD END 
IF @FECHAH <> '19000101' BEGIN DELETE #TEMPORAL WHERE DATE1 > @FECHAH END 
IF @YEAR1 <> 0 BEGIN DELETE #TEMPORAL WHERE YEAR1 <> @YEAR1 END 
IF @MONTH1 <> 0 BEGIN DELETE #TEMPORAL WHERE MONTH1 <> @MONTH1 END 
if @TAXSTATUS = 0 BEGIN DELETE #TEMPORAL WHERE DSCRIPTN <> 'No procesado' END
if @TAXSTATUS = 1 BEGIN DELETE #TEMPORAL WHERE DSCRIPTN <> 'Reclasificado' END
if @TAXSTATUS = 2 BEGIN DELETE #TEMPORAL WHERE DSCRIPTN <> 'Revertido' END
if @TAXSTATUS = 0 BEGIN UPDATE #TEMPORAL SET Selected = 1 WHERE DSCRIPTN = 'No procesado' AND RTRIM(COMMENT1) NOT LIKE 'No es%' END

SELECT @EJECUTAR = 'INSERT INTO ' + RTRIM(@TEMPTABLE) + ' SELECT Selected, CHEKBKID, VCHRNMBR, VENDORID, VENDNAME, DATE1, DOCAMNT, DSCRIPTN, STSDESCR, COMMENT1, YEAR1, MONTH1 FROM #TEMPORAL' 

EXEC (@EJECUTAR) 

DROP TABLE #TEMPORAL 


go
