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

if (!isset($data['fullName']) || empty($data['fullName'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Full name is required']);
    exit();
}

if (!isset($data['email']) || empty($data['email'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Email is required']);
    exit();
}

if (!isset($data['phone']) || empty($data['phone'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Phone is required']);
    exit();
}

if (!isset($data['address']) || empty($data['address'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Address is required']);
    exit();
}

// Sanitize and validate input
$worker_id = filter_var($data['worker_id'], FILTER_VALIDATE_INT);
$full_name = filter_var($data['fullName'], FILTER_SANITIZE_STRING);
$email = filter_var($data['email'], FILTER_SANITIZE_EMAIL);
$phone = filter_var($data['phone'], FILTER_SANITIZE_STRING);
$address = filter_var($data['address'], FILTER_SANITIZE_STRING);

// Validate worker_id
if (!$worker_id) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Invalid worker ID']);
    exit();
}

// Validate email format
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Invalid email format']);
    exit();
}

// Include database connection
require_once __DIR__ . '/database.php';

try {
    // Create database connection
    $database = new Database();
    $conn = $database->getConnection();
    
    // Check if worker exists
    $check_worker = "SELECT id FROM workers WHERE id = :worker_id";
    $stmt = $conn->prepare($check_worker);
    $stmt->bindParam(':worker_id', $worker_id);
    $stmt->execute();
    
    if ($stmt->rowCount() === 0) {
        http_response_code(404);
        echo json_encode(['success' => false, 'message' => 'Worker not found']);
        exit();
    }
    
    // Check if email already exists for another worker
    $check_email = "SELECT id FROM workers WHERE email = :email AND id != :worker_id";
    $stmt = $conn->prepare($check_email);
    $stmt->bindParam(':email', $email);
    $stmt->bindParam(':worker_id', $worker_id);
    $stmt->execute();
    
    if ($stmt->rowCount() > 0) {
        http_response_code(409);
        echo json_encode(['success' => false, 'message' => 'Email already in use by another worker']);
        exit();
    }
    
    // Update worker profile
    $update_sql = "UPDATE workers SET 
        full_name = :full_name, 
        email = :email, 
        phone = :phone, 
        address = :address,
        created_at = CURRENT_TIMESTAMP 
        WHERE id = :worker_id";
    
    $stmt = $conn->prepare($update_sql);
    $stmt->bindParam(':full_name', $full_name);
    $stmt->bindParam(':email', $email);
    $stmt->bindParam(':phone', $phone);
    $stmt->bindParam(':address', $address);
    $stmt->bindParam(':worker_id', $worker_id);
    
    if ($stmt->execute()) {
        // Get updated worker data
        $select_sql = "SELECT id, full_name, email, phone, address, created_at 
                      FROM workers WHERE id = :worker_id";
        $stmt = $conn->prepare($select_sql);
        $stmt->bindParam(':worker_id', $worker_id);
        $stmt->execute();
        $worker = $stmt->fetch(PDO::FETCH_ASSOC);
        
        // Convert full_name to fullName in response
        $worker['fullName'] = $worker['full_name'];
        unset($worker['full_name']);
        
        http_response_code(200);
        echo json_encode([
            'success' => true,
            'message' => 'Profile updated successfully',
            'worker' => $worker
        ]);
    } else {
        throw new Exception("Failed to update profile");
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage()
    ]);
}
?> 