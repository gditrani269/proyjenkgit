<!DOCTYPE html>
<html lang="es">
  <head>
    <meta charset="UTF-8" />
    <title>Verificacion de Baseline 1.0</title>
    Verificacion de Baseline 1.1
    <script src="//code.jquery.com/jquery-1.11.2.min.js"></script>
    <script>
    $(document).on('ready',function(){

      $('#btn-ingresar').click(function(){
        var url = "BaselineCheck-BackEnd.php";                                      

        $.ajax({                        
           type: "POST",                 
           url: url,                    
           data: $("#formulario").serialize(),
           success: function(data)            
           {
             $('#resp').html(data);           
           }
         });
      });
    });
    </script>
  </head>
  <body>
    <form method="post" id="formulario">
        BaselineNro: <input type="text" name="BaselineNro" placeholder="BaselineNro" autofocus/>
        <input type="button" id="btn-ingresar" value="Ingresar" />
    </form>

    <div id="resp"></div>
  </body>
</html>