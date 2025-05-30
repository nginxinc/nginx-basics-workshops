echo "Generate 1-day cert."
openssl req -x509 -nodes -days 1 -newkey rsa:2048 -keyout nginx-oss/etc/ssl/nginx/1-day.key -out nginx-oss/etc/ssl/nginx/1-day.crt -subj "/CN=$NAME-NginxBasicsWorkshop"
echo "Generate 30-day cert."
openssl req -x509 -nodes -days 30 -newkey rsa:2048 -keyout nginx-oss/etc/ssl/nginx/30-day.key -out nginx-oss/etc/ssl/nginx/30-day.crt -subj "/CN=$NAME-NginxBasicsWorkshop"