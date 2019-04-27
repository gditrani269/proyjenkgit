<!DOCTYPE html>
<html lang="es">
  <head>
    <meta charset="UTF-8" />
    <title> Acción onclick en js </title>
    // Aquí esta la referencia a jquery
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
        <input type="text" name="BaselineNro" placeholder="BaselineNro" autofocus/>
        <input type="button" id="btn-ingresar" value="Ingresar" />
    </form>
    // Este div nos servirá para cachar la respuesta enviada 
    // por el backend en caso de que sea necesario.
    <div id="resp"></div>
  </body>
</html>