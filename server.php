<?php
require_once('OAuth2/Autoloader.php');
OAuth2\Autoloader::register();
$dsn = 'sqlite:/var/www/html/oauth/data/db.sqlite';
$db_user = '';
$db_pass = '';
$storage = new OAuth2\Storage\Pdo(array('dsn' => $dsn, 'username' => $db_user, 'password' => $db_pass));
$server = new OAuth2\Server($storage);
$server->addGrantType(new OAuth2\GrantType\AuthorizationCode($storage));
?>