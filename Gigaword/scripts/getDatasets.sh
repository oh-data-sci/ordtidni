source ./config/variables.properties

for i in ${XML_DATA}/*
do
echo $(basename $i)
done
