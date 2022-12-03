:

aws s3 ls ordtidni/XML/| cut -c 32-| grep '/'| sed 's|/||g' > datasets.all
