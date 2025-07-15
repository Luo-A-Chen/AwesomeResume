package org.example.SpringBoot3.service.impl;

import java.util.*;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.example.SpringBoot3.common.ErrorCode;
import org.example.SpringBoot3.exception.BusinessException;
import org.example.SpringBoot3.model.User;
import org.example.SpringBoot3.service.UserService;
import org.example.SpringBoot3.mapper.UserMapper;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.util.DigestUtils;

import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

/**
 * @author luochen
 * @description 用户服务实现类，具体为注册实现类
 * @createDate 2025-04-08 15:43:08
 */
@Service
@Slf4j
public class UserServiceImpl extends ServiceImpl<UserMapper, User>
        implements UserService {

    @Resource
    private UserMapper userMapper;
    /**
     * 盐值，混淆密码
     */
    private static final String SALT = "luochen";
    /**
     * 用户登录态键
     */
    public static final String USER_LOGIN_STATE = "userLoginState";

    @Override
    public long userRegister(String userAccount, String userPassword, String checkPassword) {
        //1.校验
        if (StringUtils.isAnyBlank(userAccount, userPassword, checkPassword)) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR,"参数为空");
        }
        if (userAccount.length() < 4) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR,"账户名长度小于4");
        }
        if (userPassword.length() < 8 || checkPassword.length() < 8) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR,"密码长度小于8");
        }
        //账户不能包含特殊字符
        String validPattern = "[`~!@#$%^&*()+=|{}':;',\\\\[\\\\].<>/?~！@#￥%……&*（）——+|{}【】‘；：”“’。，、？]";
        Matcher matcher = Pattern.compile(validPattern).matcher(userAccount);
        if (matcher.find()) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR,"账户名包含特殊字符");
        }
        //密码和校验密码相同
        if (!userPassword.equals(checkPassword)) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR,"密码和校验密码不一致");
        }
        //账户不能重复
        QueryWrapper<User> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("userAccount", userAccount);
        long count = this.count(queryWrapper);
        if (count > 0) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR,"账户名重复");
        }
        //星球编号不能重复
        queryWrapper= new QueryWrapper<>();
        count = this.count(queryWrapper);
        if (count > 0) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR,"星球编号重复");
        }
        //对密码进行加密
        String encryptPassword = DigestUtils.md5DigestAsHex((SALT + "myPassword").getBytes());

        //向用户数据库插入数据
        User user = new User();
        user.setUserAccount(userAccount);
        user.setUserPassword(encryptPassword);
        boolean saveresult = this.save(user);
        if (!saveresult) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR,"插入数据失败");
        }
        return user.getId();
    }


    @Override
    public User userLogin(String userAccount, String userPassword, HttpServletRequest request)
    {
        //不能为空
        if (StringUtils.isAnyBlank(userAccount, userPassword)) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR,"参数为空");
        }
        //账户不能小于4位
        if (userAccount.length() < 4) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR,"账户名长度小于4");
        }
        //密码不能小于8位
        if (userPassword.length() < 8) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR,"密码长度小于8");
        }
        //账户不能包含特殊字符
        String validPattern = "[`~!@#$%^&*()+=|{}':;',\\\\[\\\\].<>/?~！@#￥%……&*（）——+|{}【】‘；：”“’。，、？]";
        Matcher matcher = Pattern.compile(validPattern).matcher(userAccount);
        if (matcher.find()) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR,"账户名包含特殊字符");
        }
        //对密码进行加密
        String encryptPassword = DigestUtils.md5DigestAsHex((SALT + "myPassword").getBytes());
        //查询用户
        QueryWrapper<User> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("userAccount", userAccount);
        queryWrapper.eq("userPassword", encryptPassword);
        User user = userMapper.selectOne(queryWrapper);
        //用户不存在
        if (user == null) {
            log.info("user login failed,userAccount cannot match userPassword");
            throw new BusinessException(ErrorCode.PARAMS_ERROR,"用户不存在或密码错误");
        }
        //用户脱敏，去掉用户密码
        User safetyUser = getSafetyUser(user);

        //记录用户登录状态
        request.getSession().setAttribute(USER_LOGIN_STATE, safetyUser);
        return safetyUser;
    }

    /**
     * 用户脱敏
     * @param originUser
     * @return
     */
    @Override
    public User getSafetyUser(User originUser) {
        if(originUser == null){
            throw new BusinessException(ErrorCode.PARAMS_ERROR,"用户不存在");
        }
        //用户脱敏，去掉用户密码
        User safetyUser = new User();
        safetyUser.setId(originUser.getId());
        safetyUser.setUserAccount(originUser.getUserAccount());
        safetyUser.setUsername(originUser.getUsername());
        safetyUser.setAvatarUrl(originUser.getAvatarUrl());
        safetyUser.setGender(originUser.getGender());
        safetyUser.setPhone(originUser.getPhone());
        safetyUser.setEmail(originUser.getEmail());
        safetyUser.setUserRole(originUser.getUserRole());
        safetyUser.setUserStatus(originUser.getUserStatus());
        safetyUser.setCreateTime(originUser.getCreateTime());
        safetyUser.setUpdateTime(new Date());
        return safetyUser;
     }

     /**
     * 用户注销
     * @param request
     * @return
     */
    @Override
    public int userLogout(HttpServletRequest request) {
        //移除用户登录态
        request.getSession().removeAttribute(USER_LOGIN_STATE);
        return 1;
    }
    /**
     * 根据标签搜索用户(内存过滤)
     * @param tagNameList
     * @return
     */
    @Override
    public List<User> serchUsersBytags(List<String> tagNameList){
        //判断标签是否为空
        if (CollectionUtils.isEmpty(tagNameList)){
            throw new BusinessException(ErrorCode.PARAMS_ERROR);
        }
        //memory方法查询所有用户
        QueryWrapper<User> queryWrapper = new QueryWrapper<>();
        List<User> userList = userMapper.selectList(queryWrapper);
        //在内存中筛选
        Gson gson = new Gson();
        return userList.stream().filter(user -> {
            String tagsStr = user.getTags();
            Set<String> tempTagNameSet = gson.fromJson(tagsStr, new TypeToken<Set<String>>(){}.getType());
            tempTagNameSet = Optional.ofNullable(tempTagNameSet).orElse(new HashSet<>());
            for(String tagName : tagNameList){
                if(!tempTagNameSet.contains(tagName)){
                    return false;
                }
            }
            return true;
        }).map(this::getSafetyUser).collect(Collectors.toList());
    }

    /**
     * 根据标签搜索用户(sql版)
     * @param tagNameList
     * @return
     */
    @Deprecated
    private List<User> serchUsersBytagsBySQL(List<String> tagNameList) {
        if (CollectionUtils.isEmpty(tagNameList)){
            throw new BusinessException(ErrorCode.PARAMS_ERROR);
        }
        //sql方法查询所有用户
        QueryWrapper<User> queryWrapper = new QueryWrapper<>();
        //拼接and查询，将输入的标签内容拼接在查询语句中
        for (String tagName : tagNameList) {
            queryWrapper = queryWrapper.like("tags", tagName);
        }
        //查询内容放入list中
        List<User> userList = userMapper.selectList(queryWrapper);
        //在sql中筛选
        return userList.stream().map(this::getSafetyUser).collect(Collectors.toList());
    }


}




