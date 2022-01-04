<?php
// Sync Let's Encrypt SSL certificates with AppNode sitemgr database. (AppNode ONLY!)
// Check Medoo.php and PHP privileges before running

require_once('Medoo.php');
use Medoo\Medoo;

$sitecode = array('sitecode1', 'sitecode2');  // 'site_code' in sitemgr.db (网站代号)
$certpath = '/data/ssl';
$dbpath = '/opt/appnode/agent/apps/sitemgr/db/sitemgr.db';
$certname = array('*.example.com', 'example.com');  // folder name in Let's Encrypt home directory

$enable_nginx_cert_replace = true;

$ngxcertdir = array('/path/to/cert', '/path/to/cert');   // nginx cert path

$db = new Medoo([
    'type' => 'sqlite',
    'database' => $dbpath
]);

$size = count($sitecode);
for ($i=0;$i<$size;$i++)
{
    $data = $db -> get("site",[
        "setting"
    ],[
        "site_code" => $sitecode[$i]
    ]);

    $data = json_decode($data["setting"]);
    
    $newkey = file_get_contents("$certpath/$certname[$i]/$certname[$i].key");
    $newcert = file_get_contents("$certpath/$certname[$i]/fullchain.cer");

    $data -> SSLKeyPemCode = $newkey;
    $data -> SSLCertPemCode = $newcert;

    $data = json_encode($data);

    $data = $db -> update("site",[
        "setting" => $data
    ],[
        "site_code" => $sitecode[$i]
    ]);
    
    if ($enable_nginx_cert_replace && $ngxcertdir[$i] != '') {
        file_put_contents("$ngxcertdir[$i]/site.key", $newkey);
        file_put_contents("$ngxcertdir[$i]/site.crt", $newcert);
    }
}

echo 'Done!';