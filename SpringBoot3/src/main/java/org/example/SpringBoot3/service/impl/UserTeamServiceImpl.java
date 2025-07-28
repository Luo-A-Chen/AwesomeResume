package org.example.SpringBoot3.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;

import org.example.SpringBoot3.mapper.UserTeamMapper;
import org.example.SpringBoot3.model.UserTeam;
import org.example.SpringBoot3.service.UserTeamService;
import org.springframework.stereotype.Service;

/**
* @author luochen
* @description 针对表【user_team(用户队伍关系)】的数据库操作Service实现
* @createDate 2025-07-27 17:32:04
*/
@Service
public class UserTeamServiceImpl extends ServiceImpl<UserTeamMapper, UserTeam>
    implements UserTeamService {

}




