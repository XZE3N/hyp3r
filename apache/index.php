<?php
// Processing Request Data
header("Content-Type: application/json");

$statusFile = getcwd() . "\data\data.txt";
$responseFile = getcwd() . "\data\output.txt";

// Get The Raw Data With The Data Identifier [...]
$rawData = file_get_contents('php://input');
$rawDataSplit = explode(' ', $rawData);

// file_put_contents($statusFile, $data[1].PHP_EOL , FILE_APPEND | LOCK_EX);

/* 
Every Request To The Server Is Preceded By The '[]' Data Identifier Wich 
Identifies The Type Of Request ([STATUS], [UPDATE], [RESPONSE], ETC...)
*/
if($rawDataSplit[0] == "[STATUS]") {
    array_shift($rawDataSplit); // Remove The First Element "[STATUS]"
    $json=implode(' ', $rawDataSplit);
    $data = explode(' ', $json);

    $readline = file($statusFile);
    if(''==file_get_contents($statusFile)) {
        $line_i_am_looking_for = 0;
        $lines = file( $statusFile , FILE_IGNORE_NEW_LINES );
        $lines[$line_i_am_looking_for] = $json;
        file_put_contents( $statusFile , implode( "\n", $lines ).PHP_EOL);    
    }
    else {
        $id=explode('_', $data[0]); //id[1]=bios, id[2]=hdd, id[3]=uuid
        $added=false;
        for($i=0; $i <= count(file($statusFile)) - 1; $i++) {
            $fid = explode(' ', $readline[$i]);
            if($data[0]==$fid[0]) {
                $line_i_am_looking_for = $i;
                $lines = file( $statusFile , FILE_IGNORE_NEW_LINES );
                $lines[$line_i_am_looking_for] = $json;
                file_put_contents( $statusFile , implode( "\n", $lines ).PHP_EOL);  
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
                    $lines = file( $statusFile , FILE_IGNORE_NEW_LINES );
                    $lines[$line_i_am_looking_for] = $json;
                    file_put_contents( $statusFile , implode( "\n", $lines ).PHP_EOL);
                    $added=true;
                }
            }
        }
        if($added == false) {
            $line_i_am_looking_for = count(file($statusFile))+2;
            $lines = file( $statusFile , FILE_IGNORE_NEW_LINES );
            $lines[$line_i_am_looking_for] = $json;
            file_put_contents( $statusFile , implode( "\n", $lines ).PHP_EOL);
        }
    }
}
if($rawDataSplit[0] == "[RESPONSE]") {
    array_shift($rawDataSplit); // Remove The First Element "[RESPONSE]"

    if(''==file_get_contents($responseFile)) { // If The Response File Is Empty
        $line_i_am_looking_for = 0;
        $lines = file( $responseFile , FILE_IGNORE_NEW_LINES );
        $lines[$line_i_am_looking_for] = implode(' ', $rawDataSplit);;
        file_put_contents( $responseFile , implode( "\n", $lines ).PHP_EOL);    
    }
    else { $line_i_am_looking_for = count(file($responseFile))+1; // Otherwise Add The Response To The File On A Separate Line
        $lines = file( $responseFile , FILE_IGNORE_NEW_LINES );
        $lines[$line_i_am_looking_for] = implode(' ', $rawDataSplit);;
        file_put_contents( $responseFile , implode( "\n", $lines ).PHP_EOL);
    }
}

// Send Response Back
$v=array(count(file($statusFile)), 'line(s)');
echo json_encode($v);
// Done. Redirect To Cpanel
header("Location: cpanel.php");
?>