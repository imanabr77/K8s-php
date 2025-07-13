# Test

To test the project and ensure the application is up and running.

   On master node: 
   ````
   $  kubectl exec -it php-app-69d95fbcd4-tnqfs -n php-app -c nginx -- tail -f /var/log/nginx/access.log
   $ curl -H "X-Real-IP: 123.123.123.123" http://192.168.56.10:30080


   $ http://194.5.206.82/ --> Grafana project is public with service nodeport

   $ http://194.5.206.82/service3/#/alerts --> Alertmanager
   ````