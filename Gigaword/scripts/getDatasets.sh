source ./config/setenv.sh

for i in ${XML_DATA}/*
do
echo $(basename $i)
done
