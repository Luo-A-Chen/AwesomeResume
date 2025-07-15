package org.example.SpringBoot3.service;
import java.util.Arrays;
import java.util.List;

import jakarta.annotation.Resource;
import org.example.SpringBoot3.model.User;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

/**
 * @author luochen
 * @date 2023/07/06
 **/
@SpringBootTest
class UserServiceTest {
    @Resource
    private UserService userService;
    @Test
    public void serchUsersBytags(){
        List<String> tagNameList = Arrays.asList("java", "python");
        List<User> userList = userService.serchUsersBytags(tagNameList);
        Assertions.assertNotNull(userList);
    }

}