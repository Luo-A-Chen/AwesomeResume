//package org.example.SpringBoot3.config;
//
//import org.springframework.context.annotation.Bean;
//import org.springframework.context.annotation.Configuration;
//import springfox.documentation.builders.ApiInfoBuilder;
//import springfox.documentation.builders.PathSelectors;
//import springfox.documentation.builders.RequestHandlerSelectors;
//import springfox.documentation.service.ApiInfo;
//import springfox.documentation.service.Contact;
//import springfox.documentation.spi.DocumentationType;
//import springfox.documentation.spring.web.plugins.Docket;
//import springfox.documentation.swagger2.annotations.EnableSwagger2WebMvc;
//
//
//@Configuration
//@EnableSwagger2WebMvc
//public class SwaggerConfig {
//    @Bean(value = "docket")
//    public Docket docket() {
//        return new Docket(DocumentationType.SWAGGER_2)
//                .apiInfo(apiInfo()).enable(true)
//                .select()
//                .apis(RequestHandlerSelectors.basePackage("org.example.SpringBoot3.controller"))
//                .paths(PathSelectors.any())
//                .build();
//    }
//    private ApiInfo apiInfo() {
//        return new ApiInfoBuilder()
//                .title("编程猫实战项目笔记")
//                .description("编程喵是一个 Spring Boot+Vue 的前后端分离项目")
//                .contact(new Contact("沉默王二", "https://codingmore.top","www.qing_gee@163.com"))
//                .version("v1.0")
//                .build();
//    }
//}