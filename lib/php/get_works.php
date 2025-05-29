<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

if (!isset($_POST['worker_id']) || empty($_POST['worker_id'])) {
    echo json_encode(['success' => false, 'message' => 'Worker ID is required']);
    exit;

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "worker_db";

try {
    $conn = new PDO("mysql:host=$servername;dbname=$dbname", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    $worker_id = $_POST['worker_id'];
    
    $stmt = $conn->prepare("SELECT id, title, description, date_assigned, due_date, status 
                           FROM tbl_works 
                           WHERE assigned_to = :worker_id");
    $stmt->bindParam(':worker_id', $worker_id);
    $stmt->execute();
    
    $works = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode(['success' => true, 'works' => $works]);
    
} catch(PDOException $e) {
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}
$conn = null;

}
?>