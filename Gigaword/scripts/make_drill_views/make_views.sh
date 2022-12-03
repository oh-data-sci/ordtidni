:

while read DS
do
sed "s/XX/${DS}/g" template.sql >> all_views.sql
done < datasets.all
