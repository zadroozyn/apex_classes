cat >build.properties <<EOF
sf.username = $SFDC_USERNAME
sf.password = $SFDC_PASSWORD$SFDC_TOKEN
sf.serverurl = $SFDC_URL
sf.maxPoll = 20
EOF
