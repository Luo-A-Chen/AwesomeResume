package org.example.SpringBoot3.model.request;

import lombok.Data;

import java.io.Serializable;

/**
 * @author luochen
 * @create 2023/8/16
 * @Description用户注册请求体
 */
@Data
public class UserRegisterRequest implements Serializable {
    private static final long serialVersionUID = 4254705131046832547L;

    private String userAccount;
    private String userPassword;
    private String checkPassword;

}
