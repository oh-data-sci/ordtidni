
SourceFS=/Users/borkur/Downloads/Gigaword/Data

while read dataset
do
echo $dataset
	for year in $( ls -l ${SourceFS}/${dataset} | grep ^d| cut -c48- )
	do
		echo "--source $dataset --year $year"
		time  ./runScrape.sh --source $dataset --year $year --sourceFS /Users/borkur/Downloads/Gigaword/Data --targetFS /Users/borkur/Downloads/Gigaword/output  &> logs/$dataset.$year.log
	done
#	echo Finished processing ${dataset} :
#	echo \t Input: $(du -hs /Users/borkur/Downloads/Gigaword/Data/${dataset})
#	echo \t Output:$(du -hs /Users/borkur/Downloads/Gigaword/output/${dataset}
done < $1
