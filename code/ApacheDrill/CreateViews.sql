

use dfs.gw;

create or replace view ordtidni
as 
	select `dir0` as source, 
		  `dir1` as year, 
		  input_file,
		  Paragraph,
		  Sentence,
		  word_number,
		  Lemma,
		  POS,
		  Word
	from dfs.gw.`output/`;
	
select source,count(*) as words 
from ordtidni 
group by source
order by 2 DESC ;

select count(distinct Word),
       count(distinct lemma )
  from ordtidni;

drop table if exists Ordtidni_POS;

create table Ordtidni_POS 
as 
	select POS,count(*) as freq from ordtidni group by POS;
	
select *,round(freq*1.0/sum(freq) over()*100.0,2)  pop
from Ordtidni_POS
order by freq desc limit 5;

select *
  from Ordtidni_Summary;

create table Ordtidni_Summary as
SELECT source, 
	COUNT(*) AS words, 
	count(distinct word) as dist_word,
	count(distinct POS) as dist_POS,
	count(distinct Lemma) as dist_Lemma,
	MAX(year) AS max_Year, 
	MIN(year) AS min_Year , 
	COUNT(DISTINCT year) AS num_years, 
	COUNT(DISTINCT input_file) AS input_files
FROM  ordtidni
GROUP BY source;

create table Ordtidni_Summary_years as
SELECT year,
  COUNT(*) AS words,
  COUNT(distinct word) as dist_word,
  COUNT(distinct POS) as dist_POS,
  COUNT(distinct Lemma) as dist_Lemma,
  COUNT(distinct source) as dist_source,
  COUNT(DISTINCT year) AS num_years,
  COUNT(DISTINCT input_file) AS input_files
FROM  ordtidni
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
FROM  ordtidni
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
order by lemma limit 100;

create table Ordtidni_Nafnord_an_Serheita
	as
	select lemma,count(*) as occ
	from ordtidni
	where POS like 'n%' --nafnorð
	and POS not like '%s' -- ekki sérheiti
	group by lemma
	order by occ desc;
	
select lower(Lemma) lem,
	    year,
	   count(*) occ
  from ordtidni 
  where lower(Lemma) in ('börkur','óskar')
  and source='mbl'
  group by lower(Lemma),YEAR 
 order by year,lem;
 
 select Lemma,count(*)
  from ordtidni 
  where Lemma in ('börkur','óskar')
    and 
  group by Lemma;
  
 select word --,sentence,paragraph,word_number
  from ordtidni 
  where input_file  = '02/R-33-4630094.xml';
 
 SELECT 
    lower(lemma),
    COUNT(*) AS num_occur
FROM ordtidni
GROUP BY lower(lemma)
HAVING num_occur BETWEEN 10000 AND 11273
ORDER BY num_occur DESC
;
