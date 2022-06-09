# Use cloudflare DNS as Dynamic DNS for your local server
Dynamic DNS with Cloudflare DNS for Linux

### How to use?
Download the `ddns.sh` file or copy its content. Then open the file in any editor and follow these steps.
1. Add your Cloudflare API Token and Zone Id (Make sure the API Token has DNS Edit Permission).
	```bash
    apiToken="yourApiTokenHere"
    zoneId="yourZoneIdHere"
2. Go to end of the file and call the `updateDNS` funcation for each record that needs to be updated. The function accepts four parameters and all are required. Example: `updateDNS 'test.thintake.in' 'A' 1 true`
	1. `Record Name`: The Domain or Subdomain that you want to update.
	2. `Record Type`: Type of record. (Like: A, AAAA, CNAME)
	3. `TTL`: Set 1 for auto
	4. `proxied`: true or false
3. Save the file, and try it by `sh filename.sh`
4. Create a cron job to run this file every minute. Thats all.
