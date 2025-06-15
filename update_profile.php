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
    $conn = createConnection();
    
    // Check if worker exists
    $check_worker = "SELECT id, username FROM tbl_users WHERE id = ?";
    $stmt = $conn->prepare($check_worker);
    $stmt->bind_param('i', $worker_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        http_response_code(404);
        echo json_encode(['success' => false, 'message' => 'Worker not found']);
        exit();
    }
    $worker_data = $result->fetch_assoc();
    $username = $worker_data['username']; // Store username for later use
    $stmt->close();
    
    // Check if email already exists for another worker
    $check_email = "SELECT id FROM tbl_users WHERE email = ? AND id != ?";
    $stmt = $conn->prepare($check_email);
    $stmt->bind_param('si', $email, $worker_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows > 0) {
        http_response_code(409);
        echo json_encode(['success' => false, 'message' => 'Email already in use by another worker']);
        exit();
    }
    $stmt->close();
    
    // Update worker profile (excluding username)
    $update_sql = "UPDATE tbl_users SET 
        full_name = ?, 
        email = ?, 
        phone = ?, 
        address = ?,
        updated_at = CURRENT_TIMESTAMP 
        WHERE id = ?";
    
    $stmt = $conn->prepare($update_sql);
    $stmt->bind_param('ssssi', $full_name, $email, $phone, $address, $worker_id);
    
    if ($stmt->execute()) {
        // Get updated worker data
        $select_sql = "SELECT id, username, full_name, email, phone, address, created_at, updated_at 
                      FROM tbl_users WHERE id = ?";
        $stmt = $conn->prepare($select_sql);
        $stmt->bind_param('i', $worker_id);
        $stmt->execute();
        $result = $stmt->get_result();
        $worker = $result->fetch_assoc();
        
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
} finally {
    if (isset($stmt)) {
        $stmt->close();
    }
    if (isset($conn)) {
        $conn->close();
    }
}
?> 