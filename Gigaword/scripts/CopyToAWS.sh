:

Usage(){
echo "Usage: $(basename $0) -d directory [-b bucket] "
}


while getopts 'd:b:h' opt; do
  case "$opt" in
    d)
      arg="$OPTARG"
      source=${OPTARG}
      ;;

    b)
      bucket=${OPTARG}
      ;;

    h)
      Usage
      exit 0
      ;;

    :)
      echo "option requires an argument"
      Usage
      exit 1
      ;;

    ?)
      echo "Invalid command option.\n"
      Usage
      exit 1
      ;;
  esac
done
shift "$(($OPTIND -1))"

if [ -z "$source" ]
then
	echo You must supply the bucket to copy to AWS S3
	exit 1
fi


if [ -d ${source} ] 
then
	echo "Directory ${source} found."
else
	echo "Error: Directory ${source} does not exist"
	exit 1
fi

if [ -z "$bucket" ]
then
	bucket="gigaword"
fi

target=$(basename ${source})

bucket=s3://${bucket}
target=${bucket}/${target}

aws s3 ls ${target}
ret=$?

if [ ${ret} == 0 ];
then
	echo ${target} aleady exists.
	exit 1
fi

echo Copying ${source} to ${target}
aws s3 cp ${source} ${target} --recursive
