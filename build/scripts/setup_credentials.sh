cat >build.properties <<EOF
sf.username = $SFDC_USERNAME
sf.password = $SFDC_PASSWORD$SFDC_TOKEN
sf.serverurl = https://test.salesforce.com
sf.maxPoll = 20
EOF
