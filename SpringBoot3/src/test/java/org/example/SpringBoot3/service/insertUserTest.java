package org.example.SpringBoot3.service;

import org.apache.commons.lang3.time.StopWatch;
import org.example.SpringBoot3.model.User;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.concurrent.*;

@SpringBootTest
public class insertUserTest {
    @Autowired
    private UserService userService;
    //自定义线程池
    ExecutorService executorService = new ThreadPoolExecutor(
            10,
            100,
            10L, TimeUnit.MINUTES,
            new LinkedBlockingQueue<>(10000),
            Executors.defaultThreadFactory(),
            new ThreadPoolExecutor.AbortPolicy()
    );
    @Test
    public void insertUserFrist() {
        //检测当前时间
        StopWatch watch = new StopWatch();
        watch.start();

        final int INSERT_NUM=100000;
        int batchSize=10000;
        int j=0;
        for(int i=0;i<INSERT_NUM/batchSize;i++){
            List<User> userList = new ArrayList<>();
            while(true){
                j++;
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
                userList.add(user);
                if(j%batchSize==0){
                    break;
                }
            }
            userService.saveBatch(userList,batchSize);
        }
        watch.stop();
        System.out.println("插入十万条数据非并发所用时间"+(watch.getTime(TimeUnit.MILLISECONDS)));
    }

    @Test
    public void insertUser() {
        //检测当前时间
        StopWatch watch = new StopWatch();
        watch.start();

        final int INSERT_NUM=100000;
        int batchSize=10000;
        int j=0;
        List<CompletableFuture<Void>> futureList = new ArrayList<>();
        for(int i=0;i<INSERT_NUM/batchSize;i++){
            List<User> userList = new ArrayList<>();
            while(true){
                j++;
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
                userList.add(user);
                if(j%batchSize==0){
                   break;
                }
            }
            CompletableFuture<Void> futrue=CompletableFuture.runAsync(()->{
                userService.saveBatch(userList,batchSize);
            },executorService);
            futureList.add(futrue);
        }
        CompletableFuture.allOf(futureList.toArray(new CompletableFuture[]{})).join();
        watch.stop();
        System.out.println("插入十万条数据非并发所用时间"+(watch.getTime(TimeUnit.MILLISECONDS)));
    }
}
