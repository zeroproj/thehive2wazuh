unlink /etc/kibana/kibana.yml
apt purge kibana -y
rm /usr/share/kibana -rf
rm /etc/kibana -rf

unlink /etc/filebeat/wazuh-template.json
unlink /etc/filebeat/filebeat.yml
apt purge filebeat -y
rm /usr/share/filebeat/module -rf
rm /etc/filebeat -rf

apt purge wazuh-manager -y

unlink /etc/elasticsearch/elasticsearch.yml
apt purge elasticsearch -y
rm /var/lib/elasticsearch -rf
rm /etc/elasticsearch -rf
rm /usr/share/elasticsearch -rf

apt purge cassandra -y
unlink /etc/thehive/application.conf
unlink /var/ossec/integrations/custom-w2thive.py
unlink /var/ossec/integrations/custom-w2thive
apt purge thehive4 -y