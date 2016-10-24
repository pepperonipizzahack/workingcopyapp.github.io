<?php

$url = $_SERVER['QUERY_STRING'];
if(strpos($url, 'http://') === 0 || strpos($url, 'https://') === 0) {
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_NOBODY, true);
    curl_exec($ch);
    $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    if($code) {
        http_response_code($code);
    } else {
        http_response_code(404);
        print(curl_error($ch));
    }
    curl_close($ch);

} else {
    // we refuse to check anything except http(s)
    http_response_code(400);
    die("Bad URL: $url");
}