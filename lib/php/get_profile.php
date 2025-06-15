<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Check if the request method is POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Only POST method is allowed']);
    exit();
}

// Get JSON input
$data = json_decode(file_get_contents('php://input'), true);

// Validate input
if (!isset($data['worker_id']) || empty($data['worker_id'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Worker ID is required']);
    exit();
}

// Include database connection
require_once __DIR__ . '/database.php';

try {
    // Create database connection
    $database = new Database();
    $conn = $database->getConnection();
    
    // Get worker profile data
    $query = "SELECT id, full_name, email, phone, address, created_at 
              FROM workers 
              WHERE id = :worker_id";
    
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':worker_id', $data['worker_id']);
    $stmt->execute();
    
    if ($stmt->rowCount() === 0) {
        http_response_code(404);
        echo json_encode(['success' => false, 'message' => 'Worker not found']);
        exit();
    }
    
    $worker = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // Convert full_name to fullName in response
    $worker['fullName'] = $worker['full_name'];
    unset($worker['full_name']);
    
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'worker' => $worker
    ]);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage()
    ]);
}
?> 