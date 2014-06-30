#!/bin/bash
#The script will ensure proper alerting of keystore expiry 

#relocating to the location where the keys are  placed
cd /usr/local/config/keystore/prod/

#cutting the key valid date
valid=`/usr/lib/jvm/java-6-sun/bin/keytool -list -v -keystore KEYSTORENAME -storepass PASSWORD -alias ALIASNAME | grep 'Valid from:' | head -1 | awk -F ' ' '{print $4,$5,$8}' | tr ' ' '-'`
#echo "valid = $valid"

#cutting the key expiry date
until=`/usr/lib/jvm/java-6-sun/bin/keytool -list -v -keystore KEYSTORENAME -storepass PASSWORD -alias ALIASNAME | grep 'Valid from:' | head -1 | awk -F ' ' '{print $11,$12,$15}' | tr ' ' '-'`
#echo "until = $until"

#convert the Expiration TimeStamp into EPOCH Seconds
untilEpochSecs=$( date --date="${until}" '+%s');
currentEpochSecs=$( date '+%s' );
differenceSecs=$(( untilEpochSecs - currentEpochSecs ));
DaysToCertExpiration=$((differenceSecs / 86400));
echo "We have only $DaysToCertExpiration days left"i

if [ ${DaysToCertExpiration} -ge 60 ]; then
echo "OK - $DaysToCertExpiration days left"
Days=0
elif [ ${DaysToCertExpiration} -gt 30 ]; then
echo "Warning :  Expiration days less than or equal to 60 days  : Need to create CVSP ticket. Only ${DaysToCertExpiration} days left"
Days=1
else
echo "Critical : Expiration date less than or equal to 30 days. Only $DaysToCertExpiration days left"
Days=2
fi
exit $Days

