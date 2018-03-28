<?php
error_reporting(E_ALL);

$cachefile = '/tmp/app-lookup.json';
$cachetime = 120 * 60; // 2 hours
// serve from the cache if it is younger than $cachetime
if (file_exists($cachefile) && (time() - $cachetime < filemtime($cachefile))) {
    include($cachefile);
    exit;
}

// fetch from apple
$data = file_get_contents('https://itunes.apple.com/lookup?id=896694807');

// store in cache for next time
$fp = fopen($cachefile, 'w');
fwrite($fp, $data);
fclose($fp);

// show user
print($data);
