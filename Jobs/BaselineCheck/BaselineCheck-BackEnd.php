<?php   
	$BaselineNro = $_POST["BaselineNro"];
    echo "BaselineNro: ".$BaselineNro; 
			$resultado = exec ('C:\Bitnami\wampstack-7.1.26-0\apps\HW\htdocs\Main\BaselineCheck\BaselineCheck.bat 1 2 ' . $BaselineNro . ' 4', $output);
			foreach ($output as $value) 
			{ 
				$sColorTexto = "black";
				if ($value == "El archivo esta en la baseline"){
					$sColorTexto = "green"; 
					//Estado de la actividad: CERRADO
				}
				if ($value == "ERROR: No se encuentra el archivo en la baseline"){
					$sColorTexto = "red"; 
					//Estado de la actividad: CERRADO
				}
				?> <p style="color:<?php echo $sColorTexto ?>;"><?php echo $value . "<br>";
			} 
			echo $result;

?>