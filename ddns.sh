#!/bin/bash

# Cloudflare API token and zone id
apiToken="putYourApiTokenHere"
zoneId="putYourZoneIdHere"

datetime=`date '+%d/%m/%Y %H:%M:%S'`
echo  "Time: $datetime"

updateDNS () {
        domain=$1
        type=$2
        ttl=$3
        proxied=$4

        if [ "${ttl}" -lt 120 ] || [ "${ttl}" -gt 7200 ] && [ "${ttl}" -ne 1 ]; then
          echo "Error: ttl out of range (120-7200) or 1 for auto"
          return
        fi

        if [ "${proxied}" != "false" ] && [ "${proxied}" != "true" ]; then
          echo "Error: Incorrect 'proxied' parameter choose 'true' or 'false'"
          return
        fi

        ping -q -w 1 -c 1 8.8.8.8 > /dev/null
        if [ $? -eq 1 ]; then
                echo "Error: Not connected to internet"
                exit 1
        fi

        ipAddress=$(curl -s -X GET https://checkip.amazonaws.com --max-time 10)
        if [ "ipAddress" = "" ]; then
                echo "Error: No IP address to set record value with."
                exit 1
        fi

        nameDetails=`curl -s --request GET --url "https://api.cloudflare.com/client/v4/zones/$zoneId/dns_records?name=$domain&type=$type" --header "Authorization: Bearer $apiToken"`
        nameId=`echo $nameDetails | grep -o '"id":"[^"]*' | cut -d'"' -f 4`
        oldIP=`echo $nameDetails | grep -o '"content":"[^"]*' | cut -d'"' -f 4`

        if [ "$nameId" = "" ]; then
                echo "Error: Cloudflare DNS Record id could not be found, please make sure it exists"
                return
        fi

        echo "New IP: $ipAddress | Old Ip: $oldIP"

        if [ $oldIP = $ipAddress ]; then
          echo "No changes in IP address"
          return
        fi

        updateResponse=`curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zoneId/dns_records/$nameId" -H "Authorization: Bearer $apiToken" -H "content-type: application/json" --data "{\"type\":\"$type\",\"name\":\"$domain\",\"content\":\"$ipAddress\",\"ttl\":$ttl,\"proxied\":$proxied}"`

        successValue=`echo $updateResponse | sed -E "s/.+\"success\":(true|false).+/\1/g"`

        if [ "$successValue" = "true" ]; then
                echo "$domain updated."
        else
                echo "$domain update failed."
                return
        fi
}

# Call the 'updateDNS' function for each record that needs to be updated
# example: updateDNS 'domain.name' 'RecordType' 'TTL' 'Proxied'

domain1="*.local.example.com"
domain2="local.example.com"
type1="A"
ttl1=1
proxied1=true

updateDNS $domain1 $type1 $ttl1 $proxied1
updateDNS $domain2 $type1 $ttl1 $proxied1
