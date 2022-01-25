:

SourceFS=/Users/borkur/Downloads/Gigaword/Data

for i in ${SourceFS}/*
do
echo $(basename $i)
done
