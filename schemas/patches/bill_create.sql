alter table bill add column fiscalYear integer after chrono;
update bill set fiscalYear=fiscal_year(ctime);