FROM openjdk:17-slim

WORKDIR /app

COPY MyJavaApp/build/libs/MyJavaApp-v1.0.jar /app/MyJavaApp.jar

ENV JAVA_OPTS="-Djavax.net.ssl.trustStore=/etc/keystore/cacerts -Djavax.net.ssl.trustStorePassword=changeit"

EXPOSE 8443

CMD ["sh", "-c", "java $JAVA_OPTS -jar /app/MyJavaApp.jar"]
