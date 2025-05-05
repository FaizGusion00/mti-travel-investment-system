<?php
// Simple API test file to verify that API requests are working
header('Content-Type: application/json');
echo json_encode([
    'status' => 'success',
    'message' => 'API test endpoint is working',
    'timestamp' => date('Y-m-d H:i:s'),
]);
?>
