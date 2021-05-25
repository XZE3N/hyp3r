<?php
//processing request data
header("Content-Type: application/json");


$filename = getcwd() . "\data.txt";
$json = file_get_contents('php://input');
$data = explode(' ', $json);
//file_put_contents($filename, $data[1].PHP_EOL , FILE_APPEND | LOCK_EX);
if($json!='') {
$readline = file($filename);
if(''==file_get_contents($filename)) {
    $line_i_am_looking_for = 0;
    $lines = file( $filename , FILE_IGNORE_NEW_LINES );
    $lines[$line_i_am_looking_for] = $json;
    file_put_contents( $filename , implode( "\n", $lines ).PHP_EOL);    
}
else {
    $id=explode('_', $data[0]); //id[1]=bios, id[2]=hdd, id[3]=uuid
    $added=false;
    for($i=0; $i <= count(file($filename)) - 1; $i++) {
        $fid = explode(' ', $readline[$i]);
        if($data[0]==$fid[0]) {
            $line_i_am_looking_for = $i;
            $lines = file( $filename , FILE_IGNORE_NEW_LINES );
            $lines[$line_i_am_looking_for] = $json;
            file_put_contents( $filename , implode( "\n", $lines ).PHP_EOL);  
            $added=true;
        }
        else {
            $ids = explode('_', $data[0]);
            $fids = explode('_', $fid[0]);
            $cnt = 0;
            if($ids[0]==$fids[0]) {$cnt++;}
            if(isset($ids[1]) && isset($fids[1])) { if($ids[1]==$fids[1]){$cnt++;} }
            if(isset($ids[2])==isset($fids[2])) { if($ids[2]==$fids[2]){$cnt++;} }
            if($cnt>=2) {
                $line_i_am_looking_for = $i;
                $lines = file( $filename , FILE_IGNORE_NEW_LINES );
                $lines[$line_i_am_looking_for] = $json;
                file_put_contents( $filename , implode( "\n", $lines ).PHP_EOL);
                $added=true;
            }
        }
    }
    if($added == false) {
        $line_i_am_looking_for = count(file($filename))+2;
        $lines = file( $filename , FILE_IGNORE_NEW_LINES );
        $lines[$line_i_am_looking_for] = $json;
        file_put_contents( $filename , implode( "\n", $lines ).PHP_EOL);
    }
}
}

//send response back 
$v=array(count(file($filename)), 'line(s)');
echo json_encode($v);
//done
header("Location: cpanel.php");
?>