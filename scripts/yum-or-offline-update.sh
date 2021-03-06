#!/usr/bin/env bash

insight_product=$1

if [[ -z $UPDATE_PROGRESS_FILE ]]; then
	echo "Insight UPDATE_PROGRESS_FILE is not set! Set it for example /tmp/insight-update-progress.log ."
	echo "Exiting..."
	exit 1
fi

if [[ -n "$insight_product" ]]; then
    echo "Trying to update Insight product: $insight_product"
else
    echo "Missing parameter!"
    echo "Usage: yum-or-offline-update.sh <product>"
    exit 1
fi

echo "$PROGRESS,Gathering update packages for $insight_product via yum..." >> $UPDATE_PROGRESS_FILE

# We need to make sure we don't get our latest package from yum cache.
sudo yum install -y $insight_product
return_code=$?

if [[ return_code -ne 0 ]]; then
	echo "$PROGRESS,Failed to update $insight_product via yum! Trying to perform an offline install..." >> $UPDATE_PROGRESS_FILE
	/opt/insight-toolkit/offline-update-insight-product.sh $insight_product
	
	return_code=$?

	# Check if offline install went alright
	if [[ return_code -ne 0 ]]; then
		echo "0,Failed to update $insight_product! Both yum and offline install failed." >> $UPDATE_PROGRESS_FILE
		exit $return_code
	fi
fi

echo "$((PROGRESS+PROGRESS_RANGE/2)),Successfully installed packages for $insight_product." >> $UPDATE_PROGRESS_FILE

