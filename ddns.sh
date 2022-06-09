#!/bin/bash

# Cloudflare API token and zone id
apiToken="putYourApiTokenHere"
zoneId="putYourZoneIdHere"

updateDNS () {
        domain=$1
        type=$2
        ttl=$3
        proxied=$4

        ping -q -w 1 -c 1 8.8.8.8 > /dev/null
        if [ $? -eq 1 ]; then
                echo "Not connected to internet"
                exit 1
        fi

        ipAddress=$(curl -s https://ipinfo.io/ip)
        if [ "ipAddress" = "" ]; then
                echo "No IP address to set record value with."
                exit 1
        fi

        echo "New IP is: $ipAddress"

        nameDetails=`curl -s --request GET --url "https://api.cloudflare.com/client/v4/zones/$zoneId/dns_records?name=$domain" --header "Authorization: Bearer $apiToken"`
        nameId=`echo $nameDetails | grep -Po '"id": *\K"[^"]*"'`
        nameId=`echo "$nameId" | tr -d '"'`
        if [ "$nameId" = "" ]; then
                echo "Cloudflare DNS Record id could not be found, please make sure it exists"
                exit 1
        fi

        updateResponse=`curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zoneId/dns_records/$nameId" -H "Authorization: Bearer $apiToken" -H "content-type: application/json" --data "{\"type\":\"$type\",\"name\":\"$domain\",\"content\":\"$ipAddress\",\"ttl\":$ttl,\"proxied\":$proxied}"`

        successValue=`echo $updateResponse | sed -E "s/.+\"success\":(true|false).+/\1/g"`

        if [ "$successValue" = "true" ]; then
                echo "$domain updated."
        else
                echo "$domain update failed."
                exit 1
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
