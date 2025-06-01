alter table quotation add column fiscalYear integer after chrono;
update quotation set fiscalYear=fiscal_year(ctime);