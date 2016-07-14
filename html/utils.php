<?php
include "settings.php";
if (isset($_GET["op"]))
{
    $_GET["op"]();
}
function list_nodes()
{
    global $nodes;
    header('Content-Type: application/json');
    echo json_encode($nodes);
}

function poweroff()
{
    $_GET["color"]="0,0,0";
    color();
}

function color()
{
 
    global $MQTT_SERVER,$MQTT_USER,$MQTT_PASS,$MQTT_PORT;

    if(!isset($_GET["color"]))
        $_GET["color"]="0,0,0";

    header('Content-Type: text/plain');
    global $nodes;
    $msg = "||rgb||".$_GET["color"];
    require("phpMQTT.php"); 
    $mqtt = new phpMQTT($MQTT_SERVER, $MQTT_PORT, "led_controller"); //Change client name to something unique
    if ($mqtt->connect(true,NULL,$MQTT_USER,$MQTT_PASS)) {
        echo("\nconnected to mqtt.");  
        
        $target_nodes=explode(",",$_GET["nodes"]);
        foreach ($target_nodes as $value) {
            $mqtt->publish("/private".$value,$msg,0);
            echo("\nsent color mqtt to  : ".$nodes[$value]["name"]."(".$nodes[$value]["chipid"].")");
        }
        $mqtt->close();
    }
    echo("\ndone.".$_GET["color"]);
}



function reboot()
{

    header('Content-Type: text/plain');
    global $nodes;
    $msg1 = "||rgb||0,0,0"; // shutdown the MOSFETs
    $msg2 = "||restart||";  // booting takes 5 sec
    require("phpMQTT.php"); 
    $mqtt = new phpMQTT($MQTT_SERVER, $MQTT_PORT, "led_controller"); //Change client name to something unique
    if ($mqtt->connect(true,NULL,$MQTT_USER,$MQTT_PASS)) {
        echo("\nconnected to mqtt.");  
        $target_nodes=explode(",",$_GET["nodes"]);
        foreach ($target_nodes as $value) {
            $mqtt->publish("/private".$value,$msg1,0);
            $mqtt->publish("/private".$value,$msg2,0);
            echo("\nsent restart mqtt to  : ".$nodes[$value]["name"]."(".$nodes[$value]["chipid"].")");
        }
        $mqtt->close();
    }
    echo("\ndone.");
}

?>