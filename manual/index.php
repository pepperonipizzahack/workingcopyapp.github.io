<?php

$hash = $_REQUEST['hash'];
$scheme = isset($_SERVER['HTTPS']) ? 'https' : 'http';
$host = $_SERVER[HTTP_HOST];
header("Location: $scheme://$host/manual.html#" . $hash);
exit();