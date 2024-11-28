# TODO: check if env variable $MODE is set and start another chain
# check if there's present db dump,if not, leave database blank
if [ $MODE -eq "production" ]
    exit;
fi
