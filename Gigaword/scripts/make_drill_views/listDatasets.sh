:

while read ds
do
	for year in $( aws s3 ls ordtidni/XML/$ds/ |  cut -c 32-| grep '/'| sed 's|/||g')
	do
		echo "--dataset $ds --year $year"
	done
done < datasets.all
