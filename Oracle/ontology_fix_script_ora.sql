--clean metadata
--Updated lcp@20141010
--AHA@20140925 and jgk@20141003 and lcp@20141007
-- fix problems with pcornet metadata pcori_basecode column so the code AHA writes creates valid popmednet data

-- 1) If you used the Mapper tool, then after running the integration step, run the following script to correct the pcori_basecode column.
update integration
set pcori_basecode = (select project_ont_mapping.destination_basecode from project_ont_mapping
where integration.c_basecode = project_ont_mapping.source_basecode
and integration.c_path = project_ont_mapping.destination_fullname
)
where exists (select 1 from project_ont_mapping
where integration.c_basecode = project_ont_mapping.source_basecode
and integration.c_path = project_ont_mapping.destination_fullname
and project_ont_mapping.status_cd != 'D' or project_ont_mapping.status_cd is null)
and integration.pcori_basecode is null
/

-- 2) Run this script to fix some errors in pcori_basecode

-- Remove scheme prefixes
update pcornet_demo set pcori_basecode=substr(pcori_basecode, instr(pcori_basecode,':')+1,100 )	 where c_fullname like '\PCORI\DEMOGRAPHIC\SEX\%'
  or c_fullname like '\PCORI\DEMOGRAPHIC\RACE\%' or c_fullname like '\PCORI\DEMOGRAPHIC\HISPANIC\%'
/
-- Fix a problem with the hispanic codes
update pcornet_demo set pcori_basecode='Y' where pcori_basecode='HISPANIC' 
/
update pcornet_demo set pcori_basecode='N' where pcori_basecode='NOTHISPANIC'
/
-- Scheme prefixes again
update pcornet_diag set pcori_basecode=substr(pcori_basecode,  instr(pcori_basecode,':')+1,100 )
  where c_fullname like '\PCORI\DIAGNOSIS\09\%' or c_fullname like '\PCORI_MOD\%'
/
-- Data truncation errors occur if modifier folders have a pcori_basecode
update pcornet_diag set pcori_basecode=null where c_visualattributes like 'O%'
/
-- Scheme prefixes
update pcornet_proc set pcori_basecode=substr(pcori_basecode,  instr(pcori_basecode,':')+1,100 )
  where c_fullname like '\PCORI\PROCEDURE\09\%'
/

