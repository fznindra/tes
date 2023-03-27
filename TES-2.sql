USE db_link_server

--DECLARE @v_start_date AS DATE,
--		@v_end_date AS DATE

--SET @v_start_date = '2022-01-01'
--SET @v_end_date = '2022-12-31'
------db_link_Server.EQLIFE.view_RIMPOL r
------	ON scope.no_polis = r.SPOLICYNO
------	INNER JOIN
------	EQLIFE.view_RIMPREMRISK pr
------	on r.SPOLICYNO = pr.SPOLICYNO
------	INNER JOIN
------    db_link_Server.EQLIFE.view_RIMPOLCEDE AS rr
------    ON r.LSEQID = rr.LFKRIMPOL
------    INNER JOIN
------    db_link_Server.EQLIFE.view_RIMPOLCEDERISK AS r2
------    ON rr.LSEQID = r2.LFKRIMPOLCEDE
------    INNER JOIN
------    db_link_Server.EQLIFE.view_RIMPOLCEDEBENCOV AS r3
------    ON r2.LSEQID = r3.LFKRIMPOLCEDERISK
------    INNER JOIN
------    db_link_Server.EQLIFE.view_PDTPLANCODE pp
------    ON r3.SPLANCODE = pp.SPLANCODE      
------    INNER JOIN
------    db_link_Server.EQLIFE.view_RIMPOLCEDECOM AS r4
------    ON r3.LSEQID = r4.LFKRIMPOLCEDEBENCOV

	SELECT  FRISAR FROM db_link_Server.EQLIFE.view_RIMPOL 
	SELECT FRISAR FROM db_link_Server.EQLIFE.view_RIMPOLCEDE
	SELECT FRISAR FROM db_link_Server.EQLIFE.view_RIMPOLCEDERISK
	SELECT top 1 * FROM db_link_Server.EQLIFE.view_RIMPOLCEDEBENCOV	WHERE LSEQID = '11.00856.0'
	SELECT FRISA FROM db_link_Server.EQLIFE.view_RIMPOLCEDECOM	
	SELECT TOP 1 * FROM db_link_Server.EQLIFE.view_RIMPREMRISK WHERE SPOLICYNO = '17.1009524.1'
	SELECT TOP 100 * FROM db_link_Server.EQLIFE.view_RIMPOLCEDESCH WHERE LSEQID = '5539300'
	SELECT TOP 1 * FROM db_link_server.EQLIFE.view_CWMPOLDET
	SELECT TOP 1 * FROM db_link_server.EQLIFE.view_CWMPOLINS
--	--SELECT TOP 1 * FROM db_link_Server.EQLIFE.view_RIMPOL 
	--SELECT TOP 1 * FROM db_link_Server.EQLIFE.view_RIMPOL 
	--SELECT TOP 1 * FROM db_link_Server.EQLIFE.view_RIMPOL 

	SELECT DISTINCT
	rimprem_risk.DRIPREMDT,pol.SPOLSTAT + ' - ' + policy_status.SDESC AS 'Status Polis',rimpol.SPOLSTAT + ' - ' + policy_status_ri.SDESC AS 'Status Reas',*
	--CONVERT (decimal (19,2),((10 * 4)/100)) AS COMMRT

	
	
--INTO
--	dbo.RPTFQYACTU20220823001_scope 
FROM
	db_link_server.EQLIFE.view_RIMPOL AS rimpol WITH (NOLOCK)
	INNER JOIN
	db_link_server.EQLIFE.view_RIMPOLCEDE AS rimpol_cede WITH (NOLOCK)
	ON rimpol.LSEQID = rimpol_cede.LFKRIMPOL
	INNER JOIN
	db_link_server.EQLIFE.view_RIMPOLCEDERISK AS rimpol_cederisk WITH (NOLOCK)
	ON rimpol_cede.LSEQID = rimpol_cederisk.LFKRIMPOLCEDE
	INNER JOIN
	db_link_server.EQLIFE.view_RIMPOLCEDEBENCOV AS rimpol_cede_bencov WITH (NOLOCK)
	ON rimpol_cederisk.LSEQID = rimpol_cede_bencov.LFKRIMPOLCEDERISK
    INNER JOIN
	db_link_server.EQLIFE. view_RIMPOLCEDESCH as rdsc
	ON rimpol_cede_bencov.LSEQID = rdsc.LFKRIMPOLCEDEBENCOV
	INNER JOIN
	(
		SELECT
			*
		FROM
			db_link_server.EQLIFE.view_RIMPREMRISK WITH (NOLOCK)
		--WHERE
		--	(
		--		CAST (DRIPREMDT AS DATE) >= @pi_start_date
		--		AND CAST (DRIPREMDT AS DATE) <= @pi_end_date
		--	) 
		--	AND 
		--	FRETAMT > 0
		--	AND SAPPLCODE IN ('RIPREM')
		--	AND CAST (DPOLCOMDT AS DATE) >= '2022-04-01'
	) AS rimprem_risk
	ON
		rimprem_risk.SPOLICYNO = rimpol.SPOLICYNO AND
		rimprem_risk.SBENCOMP = rimpol_cede_bencov.SBENCOMP AND
		rimprem_risk.SPLANCODE = rimpol_cede_bencov.SPLANCODE AND
		rimprem_risk.SRISKCLASS = rimpol_cederisk.SRISKCLASS
	INNER JOIN 
	db_link_server.EQLIFE.view_CWHPOLDET AS pol 
	ON rimpol.SPOLICYNO = pol.SPOLNO

	LEFT JOIN
	(
			SELECT DISTINCT
				cp.SPOLNO,
				hdr.SPROPOSALNO,
				sh.SFACREFNO,
				det.BFACIND
				
			FROM 
				db_link_server.EQLIFE.view_RITFACULTATIVEHDR hdr
				INNER JOIN
				db_link_server.EQLIFE.view_RITFACULTATIVEDET det
				ON hdr.LSEQID = det.LFKFACULTATIVEHDR
				INNER JOIN
				db_link_server.EQLIFE.view_RITFACULTATIVESHARE sh
				ON det.LSEQID = sh.LFKFACULTATIVEDET
				INNER JOIN
				db_link_server.EQLIFE.view_CWMPOLDET cp
				ON 
				hdr.SPOLNO = cp.SPOLNO OR
				hdr.SPROPOSALNO = cp.SPROPOSALNO

	) fac
	ON fac.SPOLNO = POL.SPOLNO
	left JOIN 
	(SELECT * FROM EQLIFE.view_PDTMASTERDET WHERE LFKMASTERHDR = 563) policy_status
	ON policy_status.SCODE = POL.SPOLSTAT
	LEFT JOIN
	(SELECT * FROM EQLIFE.view_PDTMASTERDET WHERE LFKMASTERHDR = 563) policy_status_ri
	ON policy_status_ri.SCODE = rimpol.SPOLSTAT
WHERE
	rimpol.SPOLICYNO = '17.1009524.1'

	AND
		(
			CAST(rimprem_risk.DRIPREMDT AS DATE) >= '2022-01-01'
		AND
			CAST(rimprem_risk.DRIPREMDT AS DATE) <= '2022-12-31'
		
		)


--	SELECT TOP 1 * FROM db_link_server.EQLIFE.view_RITFACULTATIVEHDR hdr
--				INNER JOIN
--				db_link_server.EQLIFE.view_RITFACULTATIVEDET det
--				ON hdr.LSEQID = det.LFKFACULTATIVEHDR
--				INNER JOIN
--				db_link_server.EQLIFE.view_RITFACULTATIVESHARE sh
--				ON det.LSEQID = sh.LFKFACULTATIVEDET
--				INNER JOIN
--				db_link_server.EQLIFE.view_CWMPOLDET cp
--				ON 
--				hdr.SPOLNO = cp.SPOLNO OR
--				hdr.SPROPOSALNO = cp.SPROPOSALNO
--				WHERE cp.SPOLNO = '17.1009524.1'

--SELECT DISTINCT TOP 1
--				cp.SPOLNO,
--				hdr.SPROPOSALNO,
--				sh.SFACREFNO,
--				det.BFACIND,
--				hdr.SRISTAT
				
--			FROM 
--				db_link_server.EQLIFE.view_RITFACULTATIVEHDR hdr
--				INNER JOIN
--				db_link_server.EQLIFE.view_RITFACULTATIVEDET det
--				ON hdr.LSEQID = det.LFKFACULTATIVEHDR
--				INNER JOIN
--				db_link_server.EQLIFE.view_RITFACULTATIVESHARE sh
--				ON det.LSEQID = sh.LFKFACULTATIVEDET
--				INNER JOIN
--				db_link_server.EQLIFE.view_CWMPOLDET cp
--				ON 
--				hdr.SPOLNO = cp.SPOLNO OR
--				hdr.SPROPOSALNO = cp.SPROPOSALNO
--			WHERE hdr.SPOLNO = '11.00856.0'

SELECT rimpol_cederisk.FRISAR AS 'FIRSAR CD RISK',rimpol.SPOLICYNO,rcdb.FRISAR AS 'FRISAR CD BENCOV'
FROM
	db_link_server.EQLIFE.view_RIMPOL AS rimpol WITH (NOLOCK)
	INNER JOIN
	db_link_server.EQLIFE.view_RIMPOLCEDE AS rimpol_cede WITH (NOLOCK)
	ON rimpol.LSEQID = rimpol_cede.LFKRIMPOL
	INNER JOIN
	db_link_server.EQLIFE.view_RIMPOLCEDERISK AS rimpol_cederisk WITH (NOLOCK)
	ON rimpol_cede.LSEQID = rimpol_cederisk.LFKRIMPOLCEDE
	INNER JOIN
	db_link_server.EQLIFE.view_RIMPOLCEDEBENCOV AS rcdb
	ON rimpol_cederisk.LSEQID = rcdb.LFKRIMPOLCEDERISK
	WHERE rimpol.SPOLICYNO = '11.00856.0'

SELECT FRISAR FROM db_link_server.EQLIFE.view_RIMPREMRISK
WHERE SPOLICYNO = '11.00856.0'