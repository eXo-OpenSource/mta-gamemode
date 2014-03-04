<?php
require_once("libraries/TeamSpeak3/TeamSpeak3.php");

function refValues($arr){
    $refs = array();
    foreach($arr as $key => $value)
        $refs[$key] = &$arr[$key];
    return $refs;
} 

function dbExec() { return dbExecArray(func_get_args()); }
function dbQueryFetch() { return dbQueryFetchArray(func_get_args()); }
function dbQueryFetchSingle() { return dbQueryFetchSingleArray(func_get_args()); }

function dbExecArray($arg)
{
	// $arg[0] -> sql handle
	// $arg[1] -> query
	// $arg[2] -> bind string
	// $arg[...]-> bind params
	$sql = $arg[0];
	$query = $arg[1];
	unset($arg[0]);
	unset($arg[1]);
	$arg = array_values($arg);
	$stmt = $sql->prepare($query);
	call_user_func_array(array($stmt, "bind_param"),refValues($arg));
	$stmt->execute();
	$stmt->close();
}

function dbQueryFetchSingleArray($arg)
{
	// $arg[0] -> sql handle
	// $arg[1] -> query
	// $arg[2] -> bind string
	// $arg[...]-> bind params
	$sql = $arg[0];
	$query = $arg[1];
	unset($arg[0]);
	unset($arg[1]);
	$arg = array_values($arg);
	$stmt = $sql->prepare($query);
	call_user_func_array(array($stmt, "bind_param"),refValues($arg));
	$stmt->execute();
	$res = $stmt->get_result();
	$data = $res->fetch_assoc();
	$res->free();
	
	return $data;
}

function dbQueryFetchArray($arg)
{
	// $arg[0] -> sql handle
	// $arg[1] -> query
	// $arg[2] -> bind string
	// $arg[...]-> bind params
	$sql = $arg[0];
	$query = $arg[1];
	unset($arg[0]);
	unset($arg[1]);
	$arg = array_values($arg);
	$stmt = $sql->prepare($query);
	call_user_func_array(array($stmt, "bind_param"),refValues($arg));
	$stmt->execute();
	$res = $stmt->get_result();
	$data = $res->fetch_all(MYSQLI_ASSOC);
	$res->free();
	
	return $data;
}

function generateRandomString($length = 10) {
    $characters = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    $randomString = '';
    for ($i = 0; $i < $length; $i++) {
        $randomString .= $characters[rand(0, strlen($characters) - 1)];
    }
    return $randomString;
}
?>