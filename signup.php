<?php

header("Content-Type: text/plain");

if(!isset($_POST['email'])) {
    http_response_code(400);
    print("Missing signup email");
    return;
}

$email = $_POST['email'];
if(!strpos($email, '@')) {
    http_response_code(400);
    print("$email does not look like email address.");
    return;
}

$subject = "$email signed up for Working Copy";
$body = "$email\n\nhas signed up for Working Copy";

// send email
$ok = mail("working-copy-signup@appliedphasor.com", $subject, $body);
if($ok) {
    print("OK\n");
} else {
    http_response_code(400);
    print("Unable to deliver signup email.\n");
}

?>