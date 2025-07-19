package org.example.SpringBoot3.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.RedisSerializer;

/**
 *
 *  自定义序列化
 *
 */
@Configuration
public class RedisTemplateConfig {

    /**
     * 为业务代码创建的自定义redis序列化模板
     * 需要调用时实例化调用即可
     */
    @Bean
    public RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory connectionFactory) {
        //创建RedisTemplate对象
        RedisTemplate<String, Object> redisTemplate = new RedisTemplate<>();
        //设置连接工厂
        redisTemplate.setConnectionFactory(connectionFactory);
        //创建Json序列化工具
        GenericJackson2JsonRedisSerializer jsonRedisSerializer = new GenericJackson2JsonRedisSerializer();

        //设置Key的序列化
        redisTemplate.setKeySerializer(RedisSerializer.string());
        //设置Value的序列化
        redisTemplate.setValueSerializer(jsonRedisSerializer);

        //设置Hash的Key和Value的序列化
        redisTemplate.setHashKeySerializer(RedisSerializer.string());
        redisTemplate.setHashValueSerializer(jsonRedisSerializer);

        return redisTemplate;
    }
    /**
     * Spring Session 会自动识别这个 Bean
     * 全局替换掉默认的 JDK 序列化器
     */
    @Bean
    public RedisSerializer<Object> springSessionDefaultRedisSerializer() {
        return new GenericJackson2JsonRedisSerializer();
    }
}

