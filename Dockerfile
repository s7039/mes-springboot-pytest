# ---------- 构建阶段：Maven 打包 ----------
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /src
COPY MES-Springboot-master/mes ./mes
RUN mvn -f mes/pom.xml -B clean package -DskipTests

# ---------- 运行阶段：只要 JRE ----------
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /src/mes/target/*.jar app.jar
EXPOSE 9090
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
