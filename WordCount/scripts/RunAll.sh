:

#This souce will define for us the input data: XML_DATA and output dir, OUTPUTDIR
source ./config/variables.properties
echo "\tReading from: ${XML_DATA}"
echo "\tWriting to  : ${OUTPUTDIR}"
echo "\tI will process datasets by year if the total XML size is greater than ${MEGABYTE_LIMIT}"
DATASET=${1}

if [ -z "$1" ]
then
	echo "\t\tYou didn't supply a file with a list of datasets to process"
	echo "\t\tI will just gobble up everyting I can find in: ${XML_DATA}"
	DATASET=$(mktemp /tmp/ordtidni.XXX)
	./getDatasets.sh > ${DATASET}

else
	DATASET=${1}
fi

echo "\tOK. I will load in all the data in ${DATASET}"

while read dataset
do
	dsize=$(du -ms ${XML_DATA}/${dataset} | cut -f1)
	#printf "${dsize} ${dataset}\n"
	if [ ${dsize} -lt ${MEGABYTE_LIMIT} ]; 
	then
		printf "${dataset} I can gobble up in one go! (${dsize}MB)\n"
		/usr/bin/time -h  ./runScrape.sh --source $dataset --sourceFS ${XML_DATA} --targetFS ${OUTPUTDIR} &> logs/$dataset.ALL.log
	else
		printf "${dataset} I will gobble up by year: ${dsize}Mb \n "
		for year in $( ls -l ${XML_DATA}/${dataset} | grep ^d| cut -c48- )
		do
		echo "--source $dataset --year $year"
			/usr/bin/time -h  ./runScrape.sh --source $dataset --year $year --sourceFS ${XML_DATA} --targetFS ${OUTPUTDIR} &> logs/$dataset.$year.log
			printf "."
		done
		printf "\n"
	fi
done < ${DATASET}
