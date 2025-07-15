package org.example.SpringBoot3;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("org.example.SpringBoot3.mapper")
public class SpringBoot3Application {

    public static void main(String[] args) {
        SpringApplication.run(SpringBoot3Application.class, args);
    }

}
