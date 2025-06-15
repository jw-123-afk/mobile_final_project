<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

include 'db_connect.php';

$response = array('success' => false, 'submissions' => array());

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $worker_id = $_POST['worker_id'] ?? '';

    if (!empty($worker_id)) {
        try {
            // Get all submissions for the worker
            $stmt = $conn->prepare("
                SELECT s.*, t.name as task_name
                FROM submissions s
                JOIN tasks t ON s.task_id = t.id
                WHERE s.worker_id = ?
                ORDER BY s.submitted_at DESC
            ");
            $stmt->bind_param("i", $worker_id);
            $stmt->execute();
            $result = $stmt->get_result();

            $submissions = array();
            while ($row = $result->fetch_assoc()) {
                $submissions[] = array(
                    'id' => $row['id'],
                    'task_id' => $row['task_id'],
                    'task_name' => $row['task_name'],
                    'status' => $row['status'],
                    'remarks' => $row['remarks'],
                    'submitted_at' => $row['submitted_at']
                );
            }

            $response['success'] = true;
            $response['submissions'] = $submissions;
        } catch (Exception $e) {
            $response['error'] = 'Database error: ' . $e->getMessage();
        }
    } else {
        $response['error'] = 'Worker ID is required';
    }
} else {
    $response['error'] = 'Invalid request method';
}

echo json_encode($response);
$conn->close();
?> 