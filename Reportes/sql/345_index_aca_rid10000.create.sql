IF NOT EXISTS (SELECT name FROM sysindexes WHERE name = 'idx1_aca_rid10000')
	create index idx1_aca_rid10000 on aca_rid10000 (jrnentry, TXDTLTYP, DOCTYPE, VCHRNMBR)

go