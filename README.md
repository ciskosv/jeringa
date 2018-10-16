# jeringa
La Jeringa es un secillo script escrito en Perl, inicialmente creada en el 2011, creada como herramienta didáctica para análisis de sitios con vulnerabilidades de SQL Inyection en bases de datos MySQL.

Qué hace?
- Comprueba si existe vulnerabilidad de SQL Injection en bases de datos MySQL, obteniendo hash utilizando el comando gnu md5sum.
- Verifica la version de base de datos MySql (si es 4 o 5, ya que solo continua si es 5).
- Si la version es 5 procede a hacer las peticiones a ciegas para obtener: Longitud del nombre de la BD, nombre de la BD y cantidad de tablas en la BD.
- Genera un archivo txt con el log de todas las pruebas realizadas y sus resultados para futuro estudio didáctico.

Este script utiliza los comandos "cut" y "md5sum" incluídos en el GNU Coreutils, distribuidos bajo los terminos de la licencia GNU Free Documentation Version 1.3 o superior publicada por Free Software Foundation.

GNU Coreutils puede descargarse desde:
http://www.gnu.org/software/coreutils/coreutils.html

GNU CoreUtils son distribuidos bajo la siguiente licencia:
http://www.gnu.org/software/coreutils/manual/html_node/GNU-Free-Documentation-License.html#GNU-Free-Documentation-License

Permission is granted to copy, distribute and/or modify this document under the terms of the GNU Free Documentation License, Version 1.3 or any later version published by the Free Software Foundation; with no Invariant Sections, with no Front-Cover Texts, and with no Back-Cover Texts. A copy of the license is included in the section entitled “GNU Free Documentation License”.

Uso de la Jeringa:
Solo agregar entre comillas la URL que queremos verificar su vulnerabilidad, incluyendo las variables en la url, que es donde se hará en si la prueba de inyección.

-----------------------------------------------------------------------
ciskosv@BlackAvenger:~/$ perl jeringa.pl "http://www.###./?art=1234"
Obteniendo hashes...
Hash verdadero: 6f337c327ce461481c36b628613300b2
Hash falso: 3db42bb78dc0eb0c61468d6e20e1b5cd
Hashes son diferentes, posible vulnerabilidad de inyeccion

Obteniendo version de BD...
Version 5 de MySQL, excelente obtengamos mas información!

Obteniendo longitud del nombre de la BD...1,2,3,4,5,6,7,8,9
El nombre de la BD tiene 9 caracteres

Obteniendo el nombre de la BD...
xxxxxxxxx

Obteniendo cantidad de tablas que tiene la BD...1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28
La BD tiene 28 tablas
-----------------------------------------------------------------------


Mayor información sobre SQL Injection:

http://ciskosv.blogspot.com/2009/08/sql-injection-basico-iii.html

http://ciskosv.blogspot.com/2009/08/sql-injection-basico-iiii.html


