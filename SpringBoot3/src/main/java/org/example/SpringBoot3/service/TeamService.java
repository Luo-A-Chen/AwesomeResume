package org.example.SpringBoot3.service;

import com.baomidou.mybatisplus.extension.service.IService;
import org.example.SpringBoot3.model.Team;
import org.example.SpringBoot3.model.User;

/**
* @author luochen
* @description 针对表【team(队伍)】的数据库操作Service
* @createDate 2025-07-27 17:31:58
*/
public interface TeamService extends IService<Team> {
    /**
     *   添加队伍
     * @param team
     * @param loginUser
     * @return
     */
    long addTeam(Team team, User loginUser);
}
