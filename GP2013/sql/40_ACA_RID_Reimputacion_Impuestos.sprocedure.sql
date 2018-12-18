
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = 'dbo'
     AND SPECIFIC_NAME = 'ACA_RID_Reimputacion_Impuestos' 
)
   DROP PROCEDURE dbo.[ACA_RID_Reimputacion_Impuestos];
GO

SET QUOTED_IDENTIFIER OFF
GO
  create PROCEDURE [dbo].[ACA_RID_Reimputacion_Impuestos] @VCHRNMBR char(21) 
AS 
if not exists(select name from sysobjects where name = 'ACA_RID_TX00201' and xtype = 'U') return 
--SELECT @VCHRNMBR = 'OP00000022' 
declare @CURNCYID char(15), @FROMCURR char(15), @USERID CHAR(15), @RATETPID CHAR(15), @EXGTBLID CHAR(15) 
DECLARE @FUNLCURR CHAR(15), @DECPLCUR smallint, @FRMDCPLCUR smallint 
DECLARE @DSTSQNUM INT, @DSTINDX int, @ACTINDX INT, @DCINDX INT 
DECLARE @DEBITAMT numeric(19,5), @CRDTAMNT NUMERIC(19,5) 
DECLARE @ORDBTAMT NUMERIC(19,5), @ORCRDAMT NUMERIC(19,5) 
DECLARE @TAXAMNT NUMERIC(19,5), @ORTAXAMT NUMERIC(19,5), @DIF NUMERIC(19,5) 
DECLARE @VENDORID CHAR(15), @ICCURRID CHAR(15) 
DECLARE @CNTRLTYP smallint, @RTCLCMTD smallint, @DECPLACS smallint, @MCTRXSTT smallint 
DECLARE @CURRNIDX INT, @FROMCURNIDX INT, @ICCURRIX INT, @LINEA INT 
DECLARE @XCHGRATE NUMERIC(19,7), @DENXRATE NUMERIC(19,5) 
DECLARE @EXCHDATE datetime, @TIME1 datetime, @EXPNDATE datetime 
DECLARE @TAXDTLID CHAR(15), @APTVCHNM CHAR(21), @APTODCTY smallint 
DECLARE @DATE1 datetime, @TIME2 datetime 
SELECT @FUNLCURR = FUNLCURR FROM MC40000 
SELECT @DATE1 = convert(char(8), getdate(), 112) 
SELECT @TIME2 = '19000101 ' + convert(char(12), getdate(), 114) 
PRINT @FUNLCURR 
SELECT @DECPLCUR = DECPLCUR-1 FROM DYNAMICS..MC40200 WHERE CURNCYID = @FUNLCURR 
SELECT TOP 1 @DSTSQNUM = DSTSQNUM, @CURNCYID = CURNCYID, @CURRNIDX = CURRNIDX, @RATETPID = RATETPID, @EXGTBLID = EXGTBLID, @XCHGRATE = XCHGRATE,  
@EXCHDATE = EXCHDATE, @TIME1 = TIME1, @RTCLCMTD = RTCLCMTD, @DECPLACS = DECPLACS, @EXPNDATE = EXPNDATE, @ICCURRID = ICCURRID,  
@ICCURRIX = ICCURRIX, @DENXRATE = DENXRATE, @MCTRXSTT = MCTRXSTT, @VENDORID = VENDORID 
FROM PM10100 WHERE VCHRNMBR = @VCHRNMBR ORDER BY DSTSQNUM DESC 
SELECT @FRMDCPLCUR = DECPLCUR-1 FROM DYNAMICS..MC40200 WHERE CURNCYID = @CURNCYID 
SELECT @DCINDX = ISNULL((SELECT TOP 1 ACTINDX FROM SY01100 WHERE SERIES = 2 AND SEQNUMBR IN(100, 200, 300, 400) AND ACTINDX <> 0), 0) 
DECLARE TAXES CURSOR FOR 
SELECT A.VCHRNMBR, A.DOCTYPE, A.TAXDTLID,  
ISNULL(ROUND((CASE WHEN A.TAXAMNT < 0 THEN ABS(A.TAXAMNT) ELSE 0 END)*B.ORAPPAMT/ISNULL(E.ORDOCAMT, D.DOCAMNT), @DECPLCUR), 0) DEBITAMT,  
ISNULL(ROUND((CASE WHEN A.TAXAMNT < 0 THEN 0 ELSE ABS(A.TAXAMNT) END)*B.ORAPPAMT/ISNULL(E.ORDOCAMT, D.DOCAMNT), @DECPLCUR), 0) CRDTAMNT, 
ISNULL(ROUND((CASE WHEN A.ORTAXAMT < 0 THEN ABS(A.ORTAXAMT) ELSE 0 END)*B.ORAPPAMT/ISNULL(E.ORDOCAMT, D.DOCAMNT), @FRMDCPLCUR), 0) ORDBTAMT,  
ISNULL(ROUND((CASE WHEN A.ORTAXAMT < 0 THEN 0 ELSE ABS(A.ORTAXAMT) END)*B.ORAPPAMT/ISNULL(E.ORDOCAMT, D.DOCAMNT), @FRMDCPLCUR), 0) ORCRDAMT,  
ACTINDX, 0 DIF, A.ORTAXAMT, 1 LINEA 
FROM PM10500 A INNER JOIN PM10200 B ON A.VCHRNMBR = B.APTVCHNM AND A.DOCTYPE = B.APTODCTY 
INNER JOIN ACA_RID_TX00201 C ON A.TAXDTLID = C.TAXDTLID 
INNER JOIN PM20000 D ON A.VCHRNMBR = D.VCHRNMBR AND A.DOCTYPE = D.DOCTYPE 
INNER JOIN ACA_IETU00400 F ON A.VCHRNMBR = F.VCHRNMBR AND A.DOCTYPE = F.DOCTYPE 
LEFT OUTER JOIN MC020103 E ON A.VCHRNMBR = E.VCHRNMBR AND A.DOCTYPE = E.DOCTYPE 
WHERE B.VCHRNMBR = @VCHRNMBR AND C.CB_RID_Reimputa = 1  
AND (B.CURNCYID <> B.FROMCURR OR B.CURNCYID = @FUNLCURR OR B.FROMCURR = @FUNLCURR) AND F.ACA_Gasto = 1 
UNION ALL 
SELECT A.VCHRNMBR, A.DOCTYPE, A.TAXDTLID,  
ISNULL(ROUND((CASE WHEN A.TAXAMNT < 0 THEN 0 ELSE ABS(A.TAXAMNT) END)*B.ORAPPAMT/ISNULL(E.ORDOCAMT, D.DOCAMNT), @DECPLCUR), 0) DEBITAMT,  
ISNULL(ROUND((CASE WHEN A.TAXAMNT < 0 THEN ABS(A.TAXAMNT) ELSE 0 END)*B.ORAPPAMT/ISNULL(E.ORDOCAMT, D.DOCAMNT), @DECPLCUR), 0) CRDTAMNT, 
ISNULL(ROUND((CASE WHEN A.ORTAXAMT < 0 THEN 0 ELSE ABS(A.ORTAXAMT) END)*B.ORAPPAMT/ISNULL(E.ORDOCAMT, D.DOCAMNT), @FRMDCPLCUR), 0) ORDBTAMT,  
ISNULL(ROUND((CASE WHEN A.ORTAXAMT < 0 THEN ABS(A.ORTAXAMT) ELSE 0 END)*B.ORAPPAMT/ISNULL(E.ORDOCAMT, D.DOCAMNT), @FRMDCPLCUR), 0) ORCRDAMT,  
LI_Cuenta_ImpPagado ACTINDX, 0 DIF, A.ORTAXAMT, 2 LINEA 
FROM PM10500 A INNER JOIN PM10200 B ON A.VCHRNMBR = B.APTVCHNM AND A.DOCTYPE = B.APTODCTY 
INNER JOIN ACA_RID_TX00201 C ON A.TAXDTLID = C.TAXDTLID 
INNER JOIN PM20000 D ON A.VCHRNMBR = D.VCHRNMBR AND A.DOCTYPE = D.DOCTYPE 
INNER JOIN ACA_IETU00400 F ON A.VCHRNMBR = F.VCHRNMBR AND A.DOCTYPE = F.DOCTYPE 
LEFT OUTER JOIN MC020103 E ON A.VCHRNMBR = E.VCHRNMBR AND A.DOCTYPE = E.DOCTYPE 
WHERE B.VCHRNMBR = @VCHRNMBR AND C.CB_RID_Reimputa = 1  
AND (B.CURNCYID <> B.FROMCURR OR B.CURNCYID = @FUNLCURR OR B.FROMCURR = @FUNLCURR) AND F.ACA_Gasto = 1 
UNION ALL 
SELECT A.VCHRNMBR, A.DOCTYPE, A.TAXDTLID,  
ISNULL(ROUND((CASE WHEN A.ORTAXAMT < 0 THEN ABS(A.ORTAXAMT) ELSE 0 END)*(B.ORAPPAMT/ISNULL(E.ORDOCAMT, D.DOCAMNT))*B.APTOEXRATE, @DECPLCUR), 0) DEBITAMT,  
ISNULL(ROUND((CASE WHEN A.ORTAXAMT < 0 THEN 0 ELSE ABS(A.ORTAXAMT) END)*(B.ORAPPAMT/ISNULL(E.ORDOCAMT, D.DOCAMNT))*B.APTOEXRATE, @DECPLCUR), 0) CRDTAMNT, 
ISNULL(ROUND((CASE WHEN A.ORTAXAMT < 0 THEN ABS(A.ORTAXAMT) ELSE 0 END)*B.ORAPPAMT/ISNULL(E.ORDOCAMT, D.DOCAMNT), @FRMDCPLCUR), 0) ORDBTAMT,  
ISNULL(ROUND((CASE WHEN A.ORTAXAMT < 0 THEN 0 ELSE ABS(A.ORTAXAMT) END)*B.ORAPPAMT/ISNULL(E.ORDOCAMT, D.DOCAMNT), @FRMDCPLCUR), 0) ORCRDAMT,  
ACTINDX, 0 DIF, A.ORTAXAMT, 1 LINEA 
FROM PM10500 A INNER JOIN PM10200 B ON A.VCHRNMBR = B.APTVCHNM AND A.DOCTYPE = B.APTODCTY 
INNER JOIN ACA_RID_TX00201 C ON A.TAXDTLID = C.TAXDTLID 
INNER JOIN PM20000 D ON A.VCHRNMBR = D.VCHRNMBR AND A.DOCTYPE = D.DOCTYPE 
INNER JOIN ACA_IETU00400 F ON A.VCHRNMBR = F.VCHRNMBR AND A.DOCTYPE = F.DOCTYPE 
LEFT OUTER JOIN MC020103 E ON A.VCHRNMBR = E.VCHRNMBR AND A.DOCTYPE = E.DOCTYPE 
WHERE B.VCHRNMBR = @VCHRNMBR AND C.CB_RID_Reimputa = 1 AND B.CURNCYID = B.FROMCURR AND B.CURNCYID <> @FUNLCURR AND F.ACA_Gasto = 1 
UNION ALL 
SELECT A.VCHRNMBR, A.DOCTYPE, A.TAXDTLID,  
ISNULL(ROUND((CASE WHEN A.ORTAXAMT < 0 THEN 0 ELSE ABS(A.ORTAXAMT) END)*(B.ORAPPAMT/ISNULL(E.ORDOCAMT, D.DOCAMNT))*B.APFRMEXRATE, @DECPLCUR), 0) DEBITAMT,  
ISNULL(ROUND((CASE WHEN A.ORTAXAMT < 0 THEN ABS(A.ORTAXAMT) ELSE 0 END)*(B.ORAPPAMT/ISNULL(E.ORDOCAMT, D.DOCAMNT))*B.APFRMEXRATE, @DECPLCUR), 0) CRDTAMNT, 
ISNULL(ROUND((CASE WHEN A.ORTAXAMT < 0 THEN 0 ELSE ABS(A.ORTAXAMT) END)*B.ORAPPAMT/ISNULL(E.ORDOCAMT, D.DOCAMNT), @FRMDCPLCUR), 0) ORDBTAMT,  
ISNULL(ROUND((CASE WHEN A.ORTAXAMT < 0 THEN ABS(A.ORTAXAMT) ELSE 0 END)*B.ORAPPAMT/ISNULL(E.ORDOCAMT, D.DOCAMNT), @FRMDCPLCUR), 0) ORCRDAMT,  
LI_Cuenta_ImpPagado ACTINDX, 0 DIF, A.ORTAXAMT, 2 LINEA 
FROM PM10500 A INNER JOIN PM10200 B ON A.VCHRNMBR = B.APTVCHNM AND A.DOCTYPE = B.APTODCTY 
INNER JOIN ACA_RID_TX00201 C ON A.TAXDTLID = C.TAXDTLID 
INNER JOIN PM20000 D ON A.VCHRNMBR = D.VCHRNMBR AND A.DOCTYPE = D.DOCTYPE 
INNER JOIN ACA_IETU00400 F ON A.VCHRNMBR = F.VCHRNMBR AND A.DOCTYPE = F.DOCTYPE 
LEFT OUTER JOIN MC020103 E ON A.VCHRNMBR = E.VCHRNMBR AND A.DOCTYPE = E.DOCTYPE 
WHERE B.VCHRNMBR = @VCHRNMBR AND C.CB_RID_Reimputa = 1 AND B.CURNCYID = B.FROMCURR AND B.CURNCYID <> @FUNLCURR AND F.ACA_Gasto = 1 
UNION ALL 
SELECT A.VCHRNMBR, A.DOCTYPE, A.TAXDTLID, 0 DEBITAMT, 0 CRDTAMNT, 
0 ORDBTAMT,  
0 ORCRDAMT,  
@DCINDX ACTINDX, 
(ROUND(ABS(A.ORTAXAMT)*(B.ORAPPAMT/ISNULL(E.ORDOCAMT, D.DOCAMNT))*B.APFRMEXRATE, @DECPLCUR) - 
ROUND(ABS(A.ORTAXAMT)*(B.ORAPPAMT/ISNULL(E.ORDOCAMT, D.DOCAMNT))*B.APTOEXRATE, @DECPLCUR)) DIF, A.ORTAXAMT, 3 LINEA 
FROM PM10500 A INNER JOIN PM10200 B ON A.VCHRNMBR = B.APTVCHNM AND A.DOCTYPE = B.APTODCTY 
INNER JOIN ACA_RID_TX00201 C ON A.TAXDTLID = C.TAXDTLID 
INNER JOIN PM20000 D ON A.VCHRNMBR = D.VCHRNMBR AND A.DOCTYPE = D.DOCTYPE 
INNER JOIN ACA_IETU00400 F ON A.VCHRNMBR = F.VCHRNMBR AND A.DOCTYPE = F.DOCTYPE 
LEFT OUTER JOIN MC020103 E ON A.VCHRNMBR = E.VCHRNMBR AND A.DOCTYPE = E.DOCTYPE 
WHERE B.VCHRNMBR = @VCHRNMBR AND C.CB_RID_Reimputa = 1 AND B.CURNCYID = B.FROMCURR AND B.CURNCYID <> @FUNLCURR AND F.ACA_Gasto = 1 
ORDER BY A.VCHRNMBR, A.DOCTYPE, A.TAXDTLID, LINEA 
OPEN TAXES 
FETCH NEXT FROM TAXES INTO @APTVCHNM, @APTODCTY, @TAXDTLID, @DEBITAMT, @CRDTAMNT, @ORDBTAMT, @ORCRDAMT, @ACTINDX, @DIF, @ORTAXAMT, @LINEA 
IF @@FETCH_STATUS = 0 DELETE PM10100 WHERE VCHRNMBR = @VCHRNMBR AND DISTTYPE = 12 
WHILE @@FETCH_STATUS = 0  
BEGIN 
	IF @LINEA <> 3 
	BEGIN 
		IF (@DEBITAMT <> 0 OR @CRDTAMNT <> 0 OR @ORDBTAMT <> 0 OR @ORCRDAMT <> 0) 
		BEGIN 
			SELECT @DSTSQNUM = @DSTSQNUM + 16384 
			INSERT INTO PM10100 (VCHRNMBR, DSTSQNUM, CNTRLTYP, CRDTAMNT, DEBITAMT, DSTINDX, DISTTYPE, VENDORID, INTERID,  
							CURNCYID, CURRNIDX, ORCRDAMT, ORDBTAMT, RATETPID, EXGTBLID, XCHGRATE, EXCHDATE, TIME1,  
							RTCLCMTD, DECPLACS, EXPNDATE, ICCURRID, ICCURRIX, DENXRATE, MCTRXSTT) 
						SELECT @VCHRNMBR, @DSTSQNUM, 1 CNTRLTYP, @CRDTAMNT, @DEBITAMT, @ACTINDX, 12 DISTTYPE, @VENDORID, 
						db_name() INTERID, @CURNCYID, @CURRNIDX, @ORCRDAMT, @ORDBTAMT, @RATETPID, @EXGTBLID, @XCHGRATE, 
						@EXCHDATE, @TIME1, @RTCLCMTD, @DECPLACS, @EXPNDATE, @ICCURRID, @ICCURRIX, @DENXRATE, @MCTRXSTT 
		END 
	END 
	ELSE 
	BEGIN 
		IF (@DIF <> 0) 
		BEGIN 
			SELECT @DSTSQNUM = @DSTSQNUM + 16384 
			IF @ORTAXAMT < 0 
			BEGIN 
				IF @DIF > 0 
				BEGIN 
					INSERT INTO PM10100 (VCHRNMBR, DSTSQNUM, CNTRLTYP, CRDTAMNT, DEBITAMT, DSTINDX, DISTTYPE, VENDORID, INTERID,  
									CURNCYID, CURRNIDX, ORCRDAMT, ORDBTAMT, RATETPID, EXGTBLID, XCHGRATE, EXCHDATE, TIME1,  
									RTCLCMTD, DECPLACS, EXPNDATE, ICCURRID, ICCURRIX, DENXRATE, MCTRXSTT) 
								SELECT @VCHRNMBR, @DSTSQNUM, 1 CNTRLTYP, 0 CRDTAMNT, ABS(@DIF) DEBITAMT, @ACTINDX, 12 DISTTYPE, @VENDORID, 
								db_name() INTERID, @CURNCYID, @CURRNIDX, 0 ORCRDAMT, 0 ORDBTAMT, @RATETPID, @EXGTBLID, @XCHGRATE, 
								@EXCHDATE, @TIME1, @RTCLCMTD, @DECPLACS, @EXPNDATE, @ICCURRID, @ICCURRIX, @DENXRATE, @MCTRXSTT 
				END 
				ELSE 
				BEGIN 
					INSERT INTO PM10100 (VCHRNMBR, DSTSQNUM, CNTRLTYP, CRDTAMNT, DEBITAMT, DSTINDX, DISTTYPE, VENDORID, INTERID,  
									CURNCYID, CURRNIDX, ORCRDAMT, ORDBTAMT, RATETPID, EXGTBLID, XCHGRATE, EXCHDATE, TIME1,  
									RTCLCMTD, DECPLACS, EXPNDATE, ICCURRID, ICCURRIX, DENXRATE, MCTRXSTT) 
								SELECT @VCHRNMBR, @DSTSQNUM, 1 CNTRLTYP, ABS(@DIF) CRDTAMNT, 0 DEBITAMT, @ACTINDX, 12 DISTTYPE, @VENDORID, 
								db_name() INTERID, @CURNCYID, @CURRNIDX, 0 ORCRDAMT, 0 ORDBTAMT, @RATETPID, @EXGTBLID, @XCHGRATE, 
								@EXCHDATE, @TIME1, @RTCLCMTD, @DECPLACS, @EXPNDATE, @ICCURRID, @ICCURRIX, @DENXRATE, @MCTRXSTT 
				END 
			END 
			ELSE 
			BEGIN 
				IF @DIF > 0 
				BEGIN 
					INSERT INTO PM10100 (VCHRNMBR, DSTSQNUM, CNTRLTYP, CRDTAMNT, DEBITAMT, DSTINDX, DISTTYPE, VENDORID, INTERID,  
									CURNCYID, CURRNIDX, ORCRDAMT, ORDBTAMT, RATETPID, EXGTBLID, XCHGRATE, EXCHDATE, TIME1,  
									RTCLCMTD, DECPLACS, EXPNDATE, ICCURRID, ICCURRIX, DENXRATE, MCTRXSTT) 
								SELECT @VCHRNMBR, @DSTSQNUM, 1 CNTRLTYP, ABS(@DIF) CRDTAMNT, 0 DEBITAMT, @ACTINDX, 12 DISTTYPE, @VENDORID, 
								db_name() INTERID, @CURNCYID, @CURRNIDX, 0 ORCRDAMT, 0 ORDBTAMT, @RATETPID, @EXGTBLID, @XCHGRATE, 
								@EXCHDATE, @TIME1, @RTCLCMTD, @DECPLACS, @EXPNDATE, @ICCURRID, @ICCURRIX, @DENXRATE, @MCTRXSTT 
				END 
				ELSE 
				BEGIN 
					INSERT INTO PM10100 (VCHRNMBR, DSTSQNUM, CNTRLTYP, CRDTAMNT, DEBITAMT, DSTINDX, DISTTYPE, VENDORID, INTERID,  
									CURNCYID, CURRNIDX, ORCRDAMT, ORDBTAMT, RATETPID, EXGTBLID, XCHGRATE, EXCHDATE, TIME1,  
									RTCLCMTD, DECPLACS, EXPNDATE, ICCURRID, ICCURRIX, DENXRATE, MCTRXSTT) 
								SELECT @VCHRNMBR, @DSTSQNUM, 1 CNTRLTYP, 0 CRDTAMNT, ABS(@DIF) DEBITAMT, @ACTINDX, 12 DISTTYPE, @VENDORID, 
								db_name() INTERID, @CURNCYID, @CURRNIDX, 0 ORCRDAMT, 0 ORDBTAMT, @RATETPID, @EXGTBLID, @XCHGRATE, 
								@EXCHDATE, @TIME1, @RTCLCMTD, @DECPLACS, @EXPNDATE, @ICCURRID, @ICCURRIX, @DENXRATE, @MCTRXSTT 
				END 
			END 
		END 
	END 
	FETCH NEXT FROM TAXES INTO @APTVCHNM, @APTODCTY, @TAXDTLID, @DEBITAMT, @CRDTAMNT, @ORDBTAMT, @ORCRDAMT, @ACTINDX, @DIF, @ORTAXAMT, @LINEA 
END 
CLOSE TAXES 
DEALLOCATE TAXES 
IF EXISTS(SELECT VCHRNMBR FROM PM10100 WHERE VCHRNMBR = @VCHRNMBR AND DISTTYPE = 12)
BEGIN
	INSERT INTO ACA_RID10100 SELECT 2 TXDTLTYP, 6 DOCTYPE, VCHRNMBR, @DATE1, @TIME2, DSTSQNUM, DEBITAMT, CRDTAMNT, ORDBTAMT, ORCRDAMT 
	FROM PM10100 WHERE VCHRNMBR = @VCHRNMBR AND DISTTYPE = 12 
	DELETE ACA_RID10000 WHERE TXDTLTYP = 2 AND DOCTYPE = 6 AND VCHRNMBR = @VCHRNMBR AND ACA_RID_Last = 1 
	IF NOT EXISTS(SELECT VCHRNMBR FROM ACA_RID10100 WHERE VCHRNMBR = @VCHRNMBR AND DATE1 = @DATE1 AND TIME1 = @TIME1)
	BEGIN
		INSERT INTO ACA_RID10000 SELECT 2 TXDTLTYP, 6 DOCTYPE, @VCHRNMBR, 1 ACA_RID_Origen, 0 YEAR1, 0 MONTH1, 0 TRXDATE, 1 ACA_RID_Tax_Status, 1 ACA_RID_Last, @DATE1, @TIME2, '' USERID, 0 JRNENTRY 
	END

END

go