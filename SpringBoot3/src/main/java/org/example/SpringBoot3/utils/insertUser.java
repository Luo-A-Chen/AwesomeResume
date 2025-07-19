package org.example.SpringBoot3.utils;

import jakarta.annotation.Resource;
import org.example.SpringBoot3.mapper.UserMapper;
import org.example.SpringBoot3.model.User;

import java.util.Date;
public class insertUser {
    @Resource
    UserMapper userMapper;
    public void insertUser() {
        //检测当前时间
        long startTime=System.currentTimeMillis();
        for(int i=0;i<10;i++){
            User user = new User();
            user.setUserAccount("chenxin");
            user.setUsername("chenxin");
            user.setUserPassword("123456");
            user.setAvatarUrl("https://cdn.nlark.com/yuque/0/2022/png/307263/1668938400000-f0c0c0c0-c5c0-4c0c-80c0-c0c080c080c0.png");
            user.setGender(0);
            user.setPhone("12345678901");
            user.setEmail("<EMAIL>");
            user.setUserStatus(0);
            user.setCreateTime(new Date());
            user.setUpdateTime(new Date());
            user.setUserRole(0);
            user.setTags("[]");
            user.setProfile("假用户");
            userMapper.insert(user);
        }
        long endTime=System.currentTimeMillis();
        System.out.println("插入十万条数据非并发所用时间"+(endTime-startTime));
    }
}
