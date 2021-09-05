<?php
// Sync Let's Encrypt SSL certificates with AppNode sitemgr database. (AppNode ONLY!)
// Check Medoo.php and PHP privileges before running

require_once('Medoo.php');
use Medoo\Medoo;

$siteid = array(1,2);  // 'siteid' in sitemgr.db
$certpath = '/data/ssl';
$dbpath = '/opt/appnode/agent/apps/sitemgr/db/sitemgr.db';
$certname = array('*.example.com', 'example.com');   // folder name in Let's Encrypt home directory

$db = new Medoo([
    'type' => 'sqlite',
    'database' => $dbpath
]);

$size = count($siteid);
for ($i=0;$i<$size;$i++)
{
    $data = $db -> get("site",[
        "setting"
    ],[
        "site_id" => $siteid[$i]
    ]);

    $data = json_decode($data["setting"]);

    $data -> SSLKeyPemCode = file_get_contents("$certpath/$certname[$i]/$certname[$i].key");
    $data -> SSLCertPemCode = file_get_contents("$certpath/$certname[$i]/fullchain.cer");

    $data = json_encode($data);

    $data = $db -> update("site",[
        "setting" => $data
    ],[
        "site_id" => $siteid[$i]
    ]);
}

echo 'Done!';