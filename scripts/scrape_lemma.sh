:
#set -x

#export TARGETDIR=/Volumes/Spock/Gigaword
export TARGETDIR=/Users/borkur/Downloads/Gigaword
export SOURCEDIR=/Users/borkur/Downloads/Arnastofnun
#export SOURCEDIR=/Users/borkur/Downloads/Arnastofnun/MIM/mbl/1998/06/


FILES=$1
if [ -z "$FILES" ]
then
	FILES=filelist.txt
	echo "\$FILES not supplied. Setting to $FILES"
fi

if [ -f "$FILES" ]
then
	echo "$FILES found."
else
	echo "$FILES not found."
	pushd .
	cd $SOURCEDIR
	find $SOURCEDIR -name '*.xml' > $FILES
	popd
fi

while read input_file
do
  mkdir -p ${TARGETDIR}/$(dirname $input_file)
  SOURCE_FILE=$SOURCEDIR/$input_file 
  LEMMA_FILE=${TARGETDIR}/$(dirname $input_file)/$(basename $input_file .xml).lem
  TEXT_FILE=${TARGETDIR}/$(dirname $input_file)/$(basename $input_file .xml).txt
  #ls $SOURCE_FILE
  #echo $LEMMA_FILE
  #touch $LEMMA_FILE
  grep "<w lemma" $SOURCE_FILE | cut -d"=" -f2|cut -d" " -f1| sed 's/"//g' > $LEMMA_FILE &
  grep "<w lemma" $SOURCE_FILE | cut -d ">" -f2| sed 's/\<\/w//g' > $TEXT_FILE &
  wait
done < $FILES
