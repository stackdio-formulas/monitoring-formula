#!/bin/bash

# 
# A Sensu plugin to count files in an S3 bucket.  If min_count files aren't
# found in the bucket, then the check will fail.
#

bucket_name="$1"
min_count="$2"

if [ -z $bucket_name ]; then
    echo "Usage: $0 bucket_name [min_count]"
    exit 3
fi

if [ -z $min_count ]; then
    min_count=0
fi

if ( ! aws s3 ls | grep $bucket_name &>/dev/null ); then
    echo "Unable to access S3"
    exit 3
fi

count=`aws s3 ls s3://${bucket_name} | wc -l`

if [ $count -le $min_count ]; then
    echo "S3 Count WARN $bucket_name | count:$count;min_count:$min_count"
    exit 1
else
    echo "S3 Count OK $bucket_name | count:$count;min_count:$min_count"
    exit 0
fi

