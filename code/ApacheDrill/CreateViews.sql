Use dfs.tmp;

drop view if exists ordtidni;

create view ordtidni
as 
	select `dir0` as `source`, 
		  `dir1` as `year`, 
		  input_file,
		  Paragraph,
		  Sentence,
		  word_number,
		  Lemma,
		  POS,
		  Word
	from s3.`output/`;


drop table if exists Ordtidni_POS;

create table Ordtidni_POS 
as 
	select POS,count(*) as freq from ordtidni group by POS;
	
select *,round(freq*1.0/sum(freq) over()*100.0,2)  pop
from Ordtidni_POS
order by freq desc limit 5;

create table Ordtidni_Summary as
SELECT `source`, 
	COUNT(*) AS `words`, 
	count(distinct word) as dist_word,
	count(distinct POS) as dist_POS,
	count(distinct Lemma) as dist_Lemma,
	MAX(`year`) AS `maxYear`, 
	MIN(`year`) AS `minYear`, 
	COUNT(DISTINCT `year`) AS `years`, 
	COUNT(DISTINCT `input_file`) AS `files`
FROM  dfs.tmp.`ordtidni`
GROUP BY `source`;