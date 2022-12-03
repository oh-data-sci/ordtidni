Use dfs.tmp;

drop view if exists v_XX;

create view v_XX
as 
select *
from dfs.tmp.ordtidni
where source ='XX';


