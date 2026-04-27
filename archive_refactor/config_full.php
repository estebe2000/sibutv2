<?php
// Database
$db_driver = 'pdo_sqlite';
$db_name = '/var/www/html/data/db.sqlite';
$dsn = 'sqlite:/var/www/html/data/db.sqlite';
$db_user = '';
$db_pass = '';

// LDAP
$ldap_url = 'ldap://172.16.95.98';
$ldap_port = 389;
$ldap_base_dn = 'dc=univ-lehavre,dc=fr';
$ldap_bind_dn = 'cn=admin,dc=univ-lehavre,dc=fr';
$ldap_bind_pass = 'Rangetachambre76*';
$ldap_search_filter = '(uid=%s)';

// OAuth2
$oauth_client_id = 'mattermost-ldap';
$oauth_client_secret = 'ldap_secret_key_76';
$oauth_redirect_uri = 'https://mattermost.educ-ai.fr/signup/gitlab/complete';
?>