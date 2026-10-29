package com.wangziyang.mes.common.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Web MVC 配置
 * 配置上传文件的静态资源映射
 *
 * @author WangZiYang
 * @since 2020-03-19
 */
@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Value("${web.upload-path:src/main/resources/static/upload/}")
    private String uploadPath;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // 映射 /upload/** 到上传目录
        registry.addResourceHandler("/upload/**")
                .addResourceLocations("file:" + uploadPath);
    }
}
