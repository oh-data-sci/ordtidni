Use dfs.giga;

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

create table Ordtidni_Summary_years as
SELECT year,
  COUNT(*) AS `words`,
  count(distinct word) as dist_word,
  count(distinct POS) as dist_POS,
  count(distinct Lemma) as dist_Lemma,
  count(distinct source) as dist_source,
  COUNT(DISTINCT `year`) AS `years`,
  COUNT(DISTINCT `input_file`) AS `files`
FROM  dfs.tmp.`ordtidni`
GROUP by year;

create table Ordtidni_Summary_all as
SELECT 
  COUNT(*) AS `words`,
  count(distinct word) as dist_word,
  count(distinct POS) as dist_POS,
  count(distinct Lemma) as dist_Lemma,
  count(distinct source) as dist_source,
  COUNT(DISTINCT `year`) AS `years`,
  COUNT(DISTINCT `input_file`) AS `files`
FROM  dfs.tmp.`ordtidni`
where substr(POS,1,1) in ('e','v','x') and POS not in ('ta');

POS not in ('ta','e','v','x','as') and POS not like 'n%s'

select substr(POS,1,1) as flokkur,
   count(*) as words,
   count(distinct word) as dist_word,
   count(distinct Lemma) as dist_Lemma
   from dfs.tmp.`ordtidni`
group by substr(POS,1,1)
order by words desc

select count(*) from (
select lemma,
   count(*) as words,
   count(distinct lower(word)) as dist_word
   from dfs.tmp.`ordtidni`
   where substr(POS,1,1) NOT in ('e','v','x')  // foreign, web and non-classified
     and POS not in ('ta') // numbers ?
group by lemma
having count(distinct lower(word)) = 1)
order by lemma limit 100
