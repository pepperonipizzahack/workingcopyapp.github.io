<?php

$hash = $_REQUEST['hash'];
header("Location: https:/workingcopyapp.com/manual.html#" . $hash);
exit();