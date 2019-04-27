<?php   
	$BaselineNro = $_POST["BaselineNro"];
    echo "BaselineNro: ".$BaselineNro; 
			$resultado = exec ('C:\Bitnami\wampstack-7.1.26-0\apps\HW\htdocs\Main\BaselineCheck\BaselineCheck.bat 1 2 ' . $BaselineNro . ' 4', $output);
			foreach ($output as $value) 
			{ 
				echo $value . "<br>"; 
			} 
			echo $result;

?>