<?php
    $array = explode("\n", file_get_contents('data.txt'));
        $heading1 = 'IP';
        $heading2 = 'USER';
        $heading3 = 'ROOT';
        $heading4 = 'LOCAL_IP';
        $heading5 = ' ';
        $output     = '<link rel="stylesheet" href="main.css?" type="text/css">';
        $output    .= "<table cellspacing='0' cellpadding='0'>" . PHP_EOL;
        $output    .= "<tr class=''>" . PHP_EOL;
        $output    .= "<th class='status'>{$heading5}</th>" . PHP_EOL;
        $output    .= "<th class=''>{$heading1}</th>" . PHP_EOL;
        $output    .= "<th class=''>{$heading2}</th>" . PHP_EOL;
        $output    .= "<th class=''>{$heading3}</th>" . PHP_EOL;
        $output    .= "<th class=''>{$heading4}</th>" . PHP_EOL;
        //add more headers here
        $output    .= "</tr>" . PHP_EOL;
        $output    .= "<tbody>" . PHP_EOL;
    for($i=0; $i<=count(file('data.txt'))-1; $i++) {
        $line = $array[$i];
        $data = explode(" ", $line);
        $output.= "<tr>" . PHP_EOL;

        date_default_timezone_set('Europe/Bucharest');
        $date = date('YmdHis', time());
        if($date-$data[5]<=100) {
            $output.= "<td><span id='online'></span></td>";
        }
        else $output.= "<td><span id='offline'></span></td>";
        for($j=1; $j<=4; $j++) { //add more to 4 if i need more data strings
            $str = $data[$j];
            $output.= "<td class=''>{$str}</td>" . PHP_EOL;
        }
        $output.= "</tr>" . PHP_EOL;
    }
        $output    .= "</tbody>" . PHP_EOL;
        $output    .= "</table>" . PHP_EOL;
        echo $output;
?>