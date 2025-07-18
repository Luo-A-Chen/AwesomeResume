package org.example.SpringBoot3.utils;

import jakarta.servlet.http.HttpServletRequest;
import org.example.SpringBoot3.model.User;
import org.springframework.stereotype.Component;

import static org.example.SpringBoot3.constant.UserConstant.ADMIN_ROLE;
import static org.example.SpringBoot3.constant.UserConstant.USER_LOGIN_STATE;

/**
 * 是否为管理员
 */
@Component
public class IsAdmin {

    public boolean checkAdmin(HttpServletRequest request){
        // 仅管理员可查询
        Object userObj = request.getSession().getAttribute(USER_LOGIN_STATE);
        User user = (User) userObj;
        return user != null && user.getUserRole() == ADMIN_ROLE;
    }
}
