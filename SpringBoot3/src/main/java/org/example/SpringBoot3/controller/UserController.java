package org.example.SpringBoot3.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpServletRequest;
import org.apache.commons.lang3.StringUtils;
import org.example.SpringBoot3.common.BaseResponse;
import org.example.SpringBoot3.common.ErrorCode;
import org.example.SpringBoot3.common.ResultUtils;
import org.example.SpringBoot3.exception.BusinessException;
import org.example.SpringBoot3.model.User;
import org.example.SpringBoot3.model.request.UserLoginRequest;
import org.example.SpringBoot3.model.request.UserRegisterRequest;
import org.example.SpringBoot3.service.UserService;
import org.example.SpringBoot3.utils.IsAdmin;
import org.springframework.util.CollectionUtils;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;
import static org.example.SpringBoot3.constant.UserConstant.USER_LOGIN_STATE;

/**
 * @author luochen
 */
@RestController
@RequestMapping("/user")
@CrossOrigin(origins = {"*"})
public class UserController {
    @Resource
    private UserService userService;
    @Resource
    private IsAdmin isAdmin;

    @PostMapping("/register")
    public BaseResponse<Long> register(@RequestBody UserRegisterRequest userRegisterRequest){
        if(userRegisterRequest == null){
            throw new BusinessException(ErrorCode.PARAMS_ERROR);
        }
        String userAccount = userRegisterRequest.getUserAccount();
        String userPassword = userRegisterRequest.getUserPassword();
        String checkPassword = userRegisterRequest.getCheckPassword();
        if(StringUtils.isAnyBlank(userAccount,userPassword,checkPassword)){
            throw new BusinessException(ErrorCode.PARAMS_ERROR);
        }
        long result= userService.userRegister(userAccount,userPassword,checkPassword);
        return ResultUtils.success(result);
    }

    @PostMapping("/login")
    public BaseResponse<User> userLogin(@RequestBody UserLoginRequest userLoginRequest, HttpServletRequest request){
        if(userLoginRequest == null){
            throw new BusinessException(ErrorCode.PARAMS_ERROR);
        }
        String userAccount = userLoginRequest.getUserAccount();
        String userPassword = userLoginRequest.getUserPassword();
        if(StringUtils.isAnyBlank(userAccount,userPassword)){
            throw new BusinessException(ErrorCode.PARAMS_ERROR);
        }
        User user= userService.userLogin(userAccount,userPassword,request);
        return ResultUtils.success(user);
    }

    @PostMapping("/logout")
    public BaseResponse<Integer>usersLogout(HttpServletRequest request){
        if(request == null){
            throw new BusinessException(ErrorCode.PARAMS_ERROR);
        }
        int result=userService.userLogout(request);
        return ResultUtils.success(result);
    }

    @GetMapping("/current")
    public BaseResponse<User> getCurrentUser(HttpServletRequest request){
        Object userObj = request.getSession().getAttribute(USER_LOGIN_STATE);
        User currentUser = (User) userObj;
        if(currentUser == null){
            throw new BusinessException(ErrorCode.NOT_LOGIN_ERROR);
        }
        long userId = currentUser.getId();
        //todo校验用户是否合法，登录态是否是管理员状态
        User user= userService.getById(userId);
        User safetyUser = userService.getSafetyUser(user);
        return ResultUtils.success(safetyUser);
    }

    @GetMapping("/search")
    public BaseResponse<List<User>> searchUsers(String username, HttpServletRequest request){
        //仅管理员可以查询
        if(!isAdmin.checkAdmin(request)){
            throw new BusinessException(ErrorCode.NO_AUTH_ERROR);
        }
        QueryWrapper<User> queryWrapper = new QueryWrapper<>();
        if(StringUtils.isNotBlank(username)){
            queryWrapper.like("username",username);
        }

        List<User> userlist = userService.list(queryWrapper);
        List<User> list = userlist.stream().map(user -> {
            return userService.getSafetyUser(user);
        }).collect(Collectors.toList());
        return ResultUtils.success(list);
    }
    @GetMapping("/delete")
    public BaseResponse<Boolean>deleteUser(Long id,HttpServletRequest request){
        //仅管理员可以查询
        if(!isAdmin.checkAdmin(request)){
            throw new BusinessException(ErrorCode.NO_AUTH_ERROR);
        }
        if(id <=0){
            throw new BusinessException(ErrorCode.PARAMS_ERROR);
        }
        boolean byId = userService.removeById(id);
        return ResultUtils.success(byId);
    }
    @GetMapping("/search/tags")
    public BaseResponse<List<User>> searchUsersByTags(@RequestParam(required =false) List<String> tagNameList){
        if(CollectionUtils.isEmpty(tagNameList)){
            throw new BusinessException(ErrorCode.PARAMS_ERROR);
        }
        List<User> userList = userService.serchUsersBytags(tagNameList);
        return ResultUtils.success(userList);
    }

}
