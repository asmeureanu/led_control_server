<?php
$msg = "||restart||";
require("phpMQTT.php");
	
$mqtt = new phpMQTT("localhost", 1883, "led_controller"); //Change client name to something unique
if ($mqtt->connect(true,NULL,"aboss","nikecondor")) {
	$mqtt->publish("/private402303",$msg,0);
	$mqtt->close();
}

    echo "done."
?>
