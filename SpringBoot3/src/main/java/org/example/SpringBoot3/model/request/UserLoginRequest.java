package org.example.SpringBoot3.model.request;

import lombok.Data;

import java.io.Serializable;

/**
 * @author luochen
 * @create 2023/8/16
 * @Description用户登录请求体
 */
@Data
public class UserLoginRequest implements Serializable {
    private static final long serialVersionUID = 4254705131046832547L;

    private String userAccount;
    private String userPassword;

}
