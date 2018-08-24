import java.io.*;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

//"C:\Program Files (x86)\Java\jre1.8.0_171\bin\java" -jar C:\Users\l0646482\n\mi_desa\Eclipse\CustomUpDate\CustomUpDate.jar
public class HandleCustom {
    public static void main(String[] args) {
        File archivo = null;
        FileReader fr = null;
        BufferedReader br = null;
        String sCustom = null;
        String sOperacion = null;
        String sURI = null;

        Integer iCountOperacion = 0;
        for (String s: args) {
        }
        if (args.length > 2) {
	        sCustom = args [0];
	        sOperacion = args [1]+"<";
	        sURI = args [2];
        }
        String sTmpCaracteresEspeciales = null;
        sTmpCaracteresEspeciales = sURI.replaceAll("&","&amp;");
        sURI = sTmpCaracteresEspeciales.replaceAll(" ","%20");
       
        try {
           // Apertura del fichero y creacion de BufferedReader para poder
           // hacer una lectura comoda (disponer del metodo readLine()).
           archivo = new File (sCustom);
           fr = new FileReader (archivo);
           br = new BufferedReader(fr);

           // Lectura del fichero
           String linea;
           String nombrecambiado;
           String sUriOriginal = null;
           boolean bReemplazar = false;

           while((linea=br.readLine())!=null) {
        	   if (iCountOperacion == 3 && bReemplazar != true) {
            	   nombrecambiado=linea;
            	   Integer iTagClose = nombrecambiado.indexOf('>');
        		   Integer iTagOpen = nombrecambiado.indexOf('<',iTagClose);
//                   System.out.println(nombrecambiado.substring(iTagClose+1, iTagOpen));
                   sUriOriginal = nombrecambiado.substring(iTagClose+1, iTagOpen);
                   bReemplazar = true;
        	   }
        	   if (iCountOperacion==2) iCountOperacion++;
        	   if (linea.indexOf(sOperacion)!=-1) iCountOperacion++;
           }
           if( null != fr ){   
               fr.close();     
            } 
           
           br.close();
           File archivo2 = null;
           FileReader fr2 = null;
           BufferedReader br2 = null;
           archivo2 = new File (sCustom);
           fr2 = new FileReader (archivo2);
           br2 = new BufferedReader(fr2);
 
           FileWriter fichero = null;
           PrintWriter pw = null;
           fichero = new FileWriter(sCustom+".bck");
           pw = new PrintWriter(fichero);
           
           String sUriNew = null;
           String sLinea2 = null;
           int iCont = 0;
           if (bReemplazar==true) {
               while((sLinea2=br2.readLine())!=null) {
            	   iCont++;
            	   if (sLinea2.indexOf(sUriOriginal)!=-1) {
//            		   System.out.println ("Encontro la URI");
//            		   System.out.println(sLinea2);
//            		   System.out.println (sLinea2.replaceAll(sUriOriginal,sURI));
//                       System.out.println(nombrecambiado.substring(iTagClose+1, iTagOpen));
            		   pw.println(sLinea2.replaceAll(sUriOriginal,sURI));
            		   pw.flush();
            	   } else {
            		   pw.println(sLinea2);
            		   pw.flush();
            	   }
                }
           }
        }
        catch(Exception e){
           e.printStackTrace();
        }finally{
           // En el finally cerramos el fichero, para asegurarnos
           // que se cierra tanto si todo va bien como si salta 
           // una excepcion.
           try{                    
              if( null != fr ){   
                 fr.close();     
              }                  
           }catch (Exception e2){ 
              e2.printStackTrace();
           }
        }
    }

}
