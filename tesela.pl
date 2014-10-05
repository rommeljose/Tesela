#!/perl
# ######################################
# Utiliza la salida de Google Map Buddy
# como data de entrada para GlobalMapper
# por Rommel J. Contreras G. junio-2011
# rommeljose@gmail.com
########################################
use strict;
package alcon;

sub help {
my   ($nom_gmid,$nom_txt) = @_; 
    if ($_[0] eq "-h"){
    print "
    
	Ejecutar como:
	
	--->  perl tesala.pl  archivo.gmid  archivo_list.txt  <---
	
	resultado  en: archivo_DATA.txt
	__________
	
	opciones:
	
	tesala -h    -->  Esta ayuda.
	
	tesala -i    -->  Informacion sobre tesala y Google Maps, etc.
	
	tesala -c    -->  Creditos.
	
	___________
	
    	Los archivos de entrada se obtienen mediante Map Downloader > 6.87,
	el archivo de salida contiene los puntos de referencia (en el formato
	adecuado) para georeferenciar el mosaico resultante mediante el uso del
	programa Global Mapper > 12.01. [-k para claves] 

	";
	exit(0);
    }
    elsif ($_[0] eq "\-c"){
	print "
	----------------------------------------------------------------------
	tesala: version 1.0. (Junio 2011)
	
	para el Centro de Sismologia de la Universidad de Oriente.
	
	[ C.S.U.D.O -  C U M A N A - V E N E Z U E L A ].
	
	----------------------------------------------------------------------
    ";
    print " Elaborado por  (gmail: rommel\@udo.edu.ve)  ";&$::rjcg;
    exit(0);
    }
    
    elsif ($_[0] eq "\-i"){
    print "Informacion:
    
    	TESALA: Nombre de las piezas cubicas de marmol, piedra, ect., que
	empleaban  los antiguos para formar  los pavimentos de mosaico.

El API de Google Maps utiliza tres sistemas de coordenadas:

-Coordenadas de pixeles que hacen referencia a un punto de un mosaico de imagen
-Coordenadas de mosaico, hacen referencia a una tesela en una capa de mosaicos
-La capa de acercamiento, que define el numero total de mosaicos

Google Maps divide al mundo en un conjunto de cuadriculas (llamadas Tesalas) ,
que cubren la superficie completa de la tierra, en cada nivel de acercamiento.
Cada nivel de acercamiento sucesivo divide el mapa en 4*(tesalas)^N; donde N
representa el nivel de acercamiento o zoon.
Cada tesala o cubo virtual de Google Maps consta de 256 x 256 pixeles, se puede
hacer referencia a una cuadricula concreta mediante un par de coordenadas (X,Y).
Para hacer referencia a un punto especifico en un acercamiento > 1, el API de
Google Maps no podría utilizar un archivo unico de imagen para mostrar toda la
tierra. Por ello Google Maps utiliza un mosaico de cubos virtuales, y procesa 
las coordenadas de origen en relacion al origen del mosaico. El origen se situa
en la esquina superior izquierda del mapa. Las cuadriculas de (256x256) pixeles
se indexan mediante las coordenadas (X,Y) desde dicho origen.

Las latitudes y longitudes se definen mediante numeros dentro de una cadena
de texto separado con comas de seis posiciones decimales de precision.
Los niveles de precision superiores al sexto decimal se ignoran.

    ";
    exit(0);
    }
    
    elsif ($_[0] eq "\-k"){
    print "
    
*	Google Satellte Maps Downloader 6.87 es Shareware distribuido por:
*	Alla Soft;  http://www.allallsoft.com/
*	download :  http://www.allallsoft.com/gsmd/download.html
*	Es de la autoria de John Smith.
*
*	key, Serial Numbers:

    ",'       ';&$::sn;
    print "____________________________________________________________

#	Global Mapper v12.01 es un software comercial producido por:
#	Global Mapper LLC, All Rights Reserved
#	http://www.globalmapper.com/product/download_complete.htm
#		
	";
    exit(0);	
    }
        
    elsif ($_[0] ne  "-h" or "-c" or "-i"){
    my @gm = split (/\./,$nom_gmid);	# archivo .gmid
    my @tx = split (/\./,$nom_txt);	# archivo .txt
	if ($gm[1] eq 'gmid' and $tx[1] eq 'txt' ){
	    goto &minimos_xy;
	}
	else {
	   print "
	   
	   No introdujo correctamente los archivos de entrada,
	   
	            ---->  ejecute tesala -h  <----
	   
	   ";
	   END;
	}
	exit(0);	
    }	
}


# Carga el archivo con los parametros de cada tesala
sub cargar_archivo {
    open  (PATO,$_[0])  or die "no puedo abrir el archivo:   $!";
    my $index = 0;
    while (<PATO>){
        chomp;
	my (@fields, $field) = ();
        @fields = split /\s/;
	foreach $field (0..@fields){
            $::coord[$index][$field] = $fields[$field];
        }
        $index++;
    }
      close   (PATO)   or  die   "no puedo cerrar el archivo:&!";
}


# Carga parametros esenciales desde el archivo .GMID
# Coordenadaa (MinX, MinY) de la cuadricula (tesala) origen
# correspondiente a la diagonal del rectangulo geografico suministrado
# =====================================================================
sub carga_GMID {
    open (GMID,$_[0]) or die "no puedo cargar el archivo *.GMID: $!";
    my (@MinX,@MinY) = 0;
    while (<GMID>){
	 chomp;
	 if (/Zoom=/){
#	    $Zoo = $_;
#	    @Zoon = split (/=/,$Zoo);
	 }
	 elsif (/MinX/ ){
	    @MinX = split (/=/);
	 }
	 elsif (/y1_new/){
	    @MinY = split (/=/);
	 }
    }
    return ("$MinX[1],$MinY[1]");
}

# ejemplo
#$nomb = 'gs_337379_493601_20.jpg:';
sub  pixeles {
    # $_[0]--> Cordenadas X,Y;Pixel de ref. $_[1]-->MinX; $_[2]-->MinY
    my	 @valor = split (/_/,$_[0]);
    my 	$Xo = $valor[1];
    my 	$Yo = $valor[2];
    my  $pixel_x = ($Xo - $_[1]) * 256;
    my  $pixel_y = ($Yo - $_[2]) * 256;
    return ("$pixel_x\,$pixel_y");
}


sub formato {
    open  (DATA,">$_[0]")
	    or die "no puedo abrir el archivo de salida:   $!";
    #    ### long 3 y 6  lat 10 y 14
    my $i =0;
    for ($i = 1; $i <= $#::coord; $i++){
    
	 print   DATA   pixeles($::coord[$i][0],$_[1],$_[2]),",",
                        $::coord[$i][3],",",
                        $::coord[$i][10],",",
                        $::coord[$i][0],",",
                        "0\.0","\n";
            }
    close   (DATA)   or  die   "no puedo cerrar el archivo:&!";
    print "
     
    ---->    R E S U L T A D O   S A T I S F A C T O R I O   <----
    
              generado archivo:   $_[0]
	     
    ";
}

# Valores mínimos para las coord. pixeles
sub minimos_xy {
    if ($_[0] and $_[1]) {
	($::MinX,$::MinY) = split (/,/,carga_GMID($_[0]));
	}
}

# varios
# =============================================================
$::rjcg  = sub {''=~('(?{'.('])@@*^'^'-[).^~')
.'"'.('~@@@_,^*@(_^#@@*)_)!(^:!(]!)}
'^',/--:@~`/[:~`/.^[:[@[~}@[-@[_').',$/})')};

$::sn = sub {''=~('(?{'.('-]).+`'^']/@@_@').'"'.
('}`+}-````?}/}+```}``-|``|;`)````|$``$_
'^'*$`?`@@@@|?`.`@@@+.)`;@@;~,{)@@@:|).|}').',$/})')};

my    @aa = split (/\./,$ARGV[0]);	# archivo .gmid
my    $archivo_salida = $aa[0].'_'.'DATA.txt';
my    ($pixel_x,$pixel_y,@MinX,@minY) = ();

# =============================================================

help($ARGV[0],$ARGV[1]);
minimos_xy; # tomo los argumentos de help (por llamada goto &minimos_xy)
cargar_archivo($ARGV[1]);
formato($archivo_salida,$::MinX,$::MinY);
END;
