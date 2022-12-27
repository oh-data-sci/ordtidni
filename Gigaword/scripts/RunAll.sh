:

#This get some definitions for us e.g.  input data: XML_DATA and output dir, OUTPUTDIR
source ./config/setenv.sh

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
	# Sourcing each loop to check if BREAK_NOW has changed
	source ./config/setenv.sh
	if [ "$BREAK_NOW" != "NO" ]; then
	echo "The BREAK_NOW variable told us to stop!"
	exit 0
	fi

	dsize=$(du -Lms ${XML_DATA}/${dataset} | cut -f1)
	
	if [ ${dsize} -lt ${MEGABYTE_LIMIT} ]; 
	then
		printf "${dataset} I can gobble up in one go! (${dsize}MB)\n"
		/usr/bin/time -h  ./runScrape.sh --source $dataset --sourceFS ${XML_DATA} --targetFS ${OUTPUTDIR} &> logs/$dataset.ALL.log
	else
		printf "${dataset} I will gobble up by year: ${dsize}Mb \n "
		for year in $( ls -1 ${XML_DATA}/${dataset}/ )
		do
			# Sourcing each loop to check if BREAK_NOW has changed
			source ./config/setenv.sh
			if [ "$BREAK_NOW" != "NO" ]; then
			echo "The BREAK_NOW variable told us to stop!"
			exit 0
			fi
		 	/usr/bin/time -h  ./runScrape.sh --source $dataset --year $year --sourceFS ${XML_DATA} --targetFS ${OUTPUTDIR} &> logs/$dataset.$year.log 
			ret=$?
			if [ $ret -ne 0 ]; then
				printf "X"
			else
				printf "."
			fi
		done
		printf "\n"
	fi
done < ${DATASET}
