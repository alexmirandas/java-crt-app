# MyJavaApp Deployment en Kubernetes

Este proyecto contiene una aplicación Java simple que sirve contenido a través de HTTPS. Utilizamos un init container para agregar un certificado autofirmado al **keystore** de Java, permitiendo que el servidor HTTPS en la aplicación Java responda de manera segura a las solicitudes entrantes.

## Prerrequisitos

1. **Java JDK** instalado localmente.
2. **Docker** instalado y en funcionamiento.
3. **Kubernetes** para pruebas locales.
4. **kubectl** para la interacción con el clúster de Kubernetes.
5. **OpenSSL** para generar certificados autofirmados.

## Pasos

### 1. Crear la Aplicación Java

1. Crea un directorio para la aplicación, por ejemplo, `MyJavaApp/`.
2. Dentro del directorio, crea la estructura `src/` y agrega un archivo `Main.java` con el codigo para probar el cert:
3. Compila el proyecto y crea un archivo JAR:

   ```bash
   mkdir -p output
   javac -d output src/Main.java
   cd output
   jar cfe MyJavaApp.jar Main Main.class
   ```

### 2. Contruye la imagen Docker

Usa el comando para construir la imagen docker

```bash
docker build . -t local/my-java-app:1.0 -f Dockerfile
```

### 3. Generar el Certificado Autofirmado

Usa el siguiente comando para generar un certificado autofirmado de prueba:

```bash
openssl req -x509 -newkey rsa:4096 -sha256 -days 365 -nodes -keyout ./certs/my-cert.key -out ./certs/my-cert.crt -subj "/CN=my-java-app"
```

Esto generará dos archivos:
- `my-cert.key`: La clave privada.
- `my-cert.crt`: El certificado público.

### 4. Crear el ConfigMap en Kubernetes

Crea  un ConfigMap que contenga el certificado generado en el paso anterior.


```bash
kubectl create configmap cert-cfg --from-file=my-cert.crt
```

### 5. Crear el Deployment en Kubernetes

Crea un archivo `deployment.yaml` para definir el init container, el contenedor principal y los volúmenes necesarios

Aplica el deployment:

```bash
kubectl apply -f deployment.yaml
```

### 6. Crea el service de kubernetes

Crea un archivo `service.yaml` para exponer el servicio en k8s

Aplica el Service:

```bash
kubectl apply -f service.yaml
```

### 7. Verificar el Despliegue

1. Revisa el estado del pod para asegurarte de que el init container y el contenedor principal se ejecutan correctamente:

   ```bash
   kubectl get pods
   ```

2. Consulta los logs del init container para verificar la importación del certificado:

   ```bash
   kubectl logs <POD_NAME> -c init-certificates
   ```

   Reemplaza `<POD_NAME>` con el nombre del pod de `my-java-app`.

### 8. Probar el Endpoint HTTPS

Usa `curl` para probar el endpoint, debes de obtener la ip del servicio:

   ```bash
   curl -k https://{service-ip}:30443/hello
   ```

Si el despliegue es exitoso, deberías ver el mensaje:

   ```plaintext
   ¡Hola, Mundo! Esta es una conexión segura.
   ```

## Limpieza

Cuando hayas terminado, puedes eliminar los recursos creados con:

```bash
kubectl delete -f configmap.yaml
kubectl delete -f deployment.yaml
kubectl delete -f service.yaml
```
