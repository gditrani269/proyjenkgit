<html>
	<head>
		<script>
			function showHint(str) {
//					window.parent.frames[1].location="serv3.php?Fwk="+str;
	//				window.parent.frames[2].location="Version.php";
			}
		</script>
	</head>
	<body>
		<h1>
			BaselineCheck 1.0
		</h1>
		<?php
			$BaselineNro = $_GET["BaselineNro"];
//			$resultado = exec ('java -jar C:\Dimensions\Workspace2\test\test.jar', $output);
						$resultado = exec ('C:\Bitnami\wampstack-7.1.26-0\apps\HW\htdocs\Main\BaselineCheck\BaselineCheck.bat 1 2 ' . $BaselineNro . ' 4', $output);
			foreach ($output as $value) 
			{ 
				echo $value . "<br>"; 
			} 
			echo $result;
		?>
	</body>
</html>