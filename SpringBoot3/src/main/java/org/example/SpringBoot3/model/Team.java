package org.example.SpringBoot3.model;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

/**
 * 队伍
 * @TableName team
 */
@TableName(value ="team")
@Data
public class Team {
    /**
     * 队伍id
     */
    @TableId(type = IdType.AUTO)
    private Long id;
    /**
     * 队伍名称
     */
    private String name;

    /**
     * 描述
     */
    private String description;

    /**
     * 最大人数
     */
    private Integer maxNum;

    /**
     * 过期时间
     */
    private Date expireTime;

    /**
     * 用户id (队长 id) 
     */
    private Long userId;

    /**
     * 0 -公开,1 -私有, 2- 加密
     */
    private Integer status;

    /**
     * 密码
     */
    private String password;

    /**
     * 创建时间
     */
    private Date createTime;

    /**
     * 
     */
    private Date updateTime;

    /**
     * 是否删除
     */
    private Integer isDelete;

//    /**
//     * id
//     */
//    public Long getId() {
//        return id;
//    }
//
//    /**
//     * id
//     */
//    public void setId(Long id) {
//        this.id = id;
//    }
//
//    /**
//     * 队伍名称
//     */
//    public String getName() {
//        return name;
//    }
//
//    /**
//     * 队伍名称
//     */
//    public void setName(String name) {
//        this.name = name;
//    }
//
//    /**
//     * 描述
//     */
//    public String getDescription() {
//        return description;
//    }
//
//    /**
//     * 描述
//     */
//    public void setDescription(String description) {
//        this.description = description;
//    }
//
//    /**
//     * 最大人数
//     */
//    public Integer getMaxNum() {
//        return maxNum;
//    }
//
//    /**
//     * 最大人数
//     */
//    public void setMaxNum(Integer maxNum) {
//        this.maxNum = maxNum;
//    }
//
//    /**
//     * 过期时间
//     */
//    public Date getExpireTime() {
//        return expireTime;
//    }
//
//    /**
//     * 过期时间
//     */
//    public void setExpireTime(Date expireTime) {
//        this.expireTime = expireTime;
//    }
//
//    /**
//     * 用户id (队长 id)
//     */
//    public Long getUserld() {
//        return userld;
//    }
//
//    /**
//     * 用户id (队长 id)
//     */
//    public void setUserld(Long userld) {
//        this.userld = userld;
//    }
//
//    /**
//     * 0 -公开,1 -私有, 2- 加密
//     */
//    public Integer getStatus() {
//        return status;
//    }
//
//    /**
//     * 0 -公开,1 -私有, 2- 加密
//     */
//    public void setStatus(Integer status) {
//        this.status = status;
//    }
//
//    /**
//     * 密码
//     */
//    public String getPassword() {
//        return password;
//    }
//
//    /**
//     * 密码
//     */
//    public void setPassword(String password) {
//        this.password = password;
//    }
//
//    /**
//     * 创建时间
//     */
//    public Date getCreateTime() {
//        return createTime;
//    }
//
//    /**
//     * 创建时间
//     */
//    public void setCreateTime(Date createTime) {
//        this.createTime = createTime;
//    }
//
//    /**
//     *
//     */
//    public Date getUpdateTime() {
//        return updateTime;
//    }
//
//    /**
//     *
//     */
//    public void setUpdateTime(Date updateTime) {
//        this.updateTime = updateTime;
//    }
//
//    /**
//     * 是否删除
//     */
//    public Integer getIsDelete() {
//        return isDelete;
//    }
//
//    /**
//     * 是否删除
//     */
//    public void setIsDelete(Integer isDelete) {
//        this.isDelete = isDelete;
//    }
//
//    @Override
//    public boolean equals(Object that) {
//        if (this == that) {
//            return true;
//        }
//        if (that == null) {
//            return false;
//        }
//        if (getClass() != that.getClass()) {
//            return false;
//        }
//        Team other = (Team) that;
//        return (this.getId() == null ? other.getId() == null : this.getId().equals(other.getId()))
//            && (this.getName() == null ? other.getName() == null : this.getName().equals(other.getName()))
//            && (this.getDescription() == null ? other.getDescription() == null : this.getDescription().equals(other.getDescription()))
//            && (this.getMaxNum() == null ? other.getMaxNum() == null : this.getMaxNum().equals(other.getMaxNum()))
//            && (this.getExpireTime() == null ? other.getExpireTime() == null : this.getExpireTime().equals(other.getExpireTime()))
//            && (this.getUserld() == null ? other.getUserld() == null : this.getUserld().equals(other.getUserld()))
//            && (this.getStatus() == null ? other.getStatus() == null : this.getStatus().equals(other.getStatus()))
//            && (this.getPassword() == null ? other.getPassword() == null : this.getPassword().equals(other.getPassword()))
//            && (this.getCreateTime() == null ? other.getCreateTime() == null : this.getCreateTime().equals(other.getCreateTime()))
//            && (this.getUpdateTime() == null ? other.getUpdateTime() == null : this.getUpdateTime().equals(other.getUpdateTime()))
//            && (this.getIsDelete() == null ? other.getIsDelete() == null : this.getIsDelete().equals(other.getIsDelete()));
//    }
//
//    @Override
//    public int hashCode() {
//        final int prime = 31;
//        int result = 1;
//        result = prime * result + ((getId() == null) ? 0 : getId().hashCode());
//        result = prime * result + ((getName() == null) ? 0 : getName().hashCode());
//        result = prime * result + ((getDescription() == null) ? 0 : getDescription().hashCode());
//        result = prime * result + ((getMaxNum() == null) ? 0 : getMaxNum().hashCode());
//        result = prime * result + ((getExpireTime() == null) ? 0 : getExpireTime().hashCode());
//        result = prime * result + ((getUserld() == null) ? 0 : getUserld().hashCode());
//        result = prime * result + ((getStatus() == null) ? 0 : getStatus().hashCode());
//        result = prime * result + ((getPassword() == null) ? 0 : getPassword().hashCode());
//        result = prime * result + ((getCreateTime() == null) ? 0 : getCreateTime().hashCode());
//        result = prime * result + ((getUpdateTime() == null) ? 0 : getUpdateTime().hashCode());
//        result = prime * result + ((getIsDelete() == null) ? 0 : getIsDelete().hashCode());
//        return result;
//    }
//
//    @Override
//    public String toString() {
//        StringBuilder sb = new StringBuilder();
//        sb.append(getClass().getSimpleName());
//        sb.append(" [");
//        sb.append("Hash = ").append(hashCode());
//        sb.append(", id=").append(id);
//        sb.append(", name=").append(name);
//        sb.append(", description=").append(description);
//        sb.append(", maxNum=").append(maxNum);
//        sb.append(", expireTime=").append(expireTime);
//        sb.append(", userld=").append(userld);
//        sb.append(", status=").append(status);
//        sb.append(", password=").append(password);
//        sb.append(", createTime=").append(createTime);
//        sb.append(", updateTime=").append(updateTime);
//        sb.append(", isDelete=").append(isDelete);
//        sb.append("]");
//        return sb.toString();
//    }
}