---
layout: post
title: Cómo compartir secretos en un equipo usando pass
---

Cuando trabajamos en un equipo de desarrollo de software y queremos compartir
credenciales, contraseñas, llaves, _tokens_ u otro tipo de secretos, es
importante hacerlo de una manera segura. Hay varios artículos que explican
cómo conseguirlo con herramientas como
[BlackBox](http://www.zero-one.io/blog/2015/04/14/safely-storing-passwords-and-secrets-in-your-git-repo/),
[git-crypt](http://www.twinbit.it/en/blog/storing-sensitive-data-git-repository-using-git-crypt)
o [1Password](https://blog.snap-ci.com/blog/2015/11/11/sharing-secrets-team/).

Otra opción bastante útil es el
[almacén de contraseñas `pass`](http://www.passwordstore.org/), que hace uso
de `gpg` para cifrar los secretos almacenados y, gracias a su integración con
`git`, permite llevar un control de versiones y compartir secretos entre los
miembros de un equipo.

## Instrucciones

Comenzamos instalando `pass` como se indica en la
[sección de descargas en su página oficial](http://www.passwordstore.org/#download).
En versiones recientes de Debian y Ubuntu, por ejemplo, se lo puede instalar
desde los repositorios oficiales:

```sh
sudo apt-get install pass
```

A continuación, necesitamos crear un _wrapper_ ejecutable para `pass` dentro de un nuevo
directorio. Esto nos permitirá almacenar los secretos en el directorio actual
y no en el directorio por defecto (`~/.password-store`). De esta manera,
evitamos mezclar los secretos del equipo con los personales.

Para esto, creamos un archivo llamado `passw` con el siguiente contenido:

```sh
#!/bin/sh

PASSWORD_STORE_DIR=. pass "$@"
```

Posteriormente, agregamos permisos de ejecución al archivo:

```sh
chmod +x passw
```

Estamos listos para inicializar nuestro almacén de secretos, para lo cual
ejecutamos el comando `./passw init` seguido de los correos electrónicos de los
miembros del equipo separados por espacios, así:

```sh
./passw init <email 1> <email 2> ...
```

Es importante que todos los correos electrónicos tengan una llave PGP válida
asociada; si no, los próximos pasos fallarán.

A continuación, inicializamos el repositorio de `git` corriendo:

```sh
./passw git init
```

Este repositorio es el que compartiremos con nuestro equipo.

A partir de este punto, podemos continuar usando los comandos usuales de `pass`,
recordando siempre utilizar el _wrapper_ `./passw` que creamos al inicio. Por
ejemplo, para añadir la contraseña del ambiente de QA de nuestro proyecto
ejecutaríamos:

```sh
./passw insert logins/qa
```

Y para copiar la contraseña al portapapeles:

```sh
./passw -c logins/qa
```

La herramienta `pass` es bastante versátil y tiene muchos otros comandos y
opciones, los cuales están documentados en su
[página oficial](http://www.passwordstore.org/) y, con más detalle, en su
[manual](http://git.zx2c4.com/password-store/about/).

## ¿Qué pasa si alguien se va del equipo? ¿Y si alguien más se une?

Si queremos agregar o remover a alguien del equipo, basta con correr de nuevo el
comando `./passw init` con la lista actualizada de correos electrónicos. Sin
embargo, quienes salgan del equipo aún tendrán acceso a las versiones anteriores
del repositorio, por lo que es recomendable restablecer los secretos.
