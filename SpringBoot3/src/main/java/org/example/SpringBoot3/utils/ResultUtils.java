package org.example.SpringBoot3.utils;

import org.example.SpringBoot3.common.BaseResponse;
import org.example.SpringBoot3.common.ErrorCode;

/**
 * @author: luochen
 * @date 2023/4/9
 * @description:返回工具类，里面再次封装好baseresponse的响应类
 */
public class ResultUtils {
    //成功
    public static<T> BaseResponse<T> success(T data){
        return new BaseResponse<> (0,data,"成功");
    }
    //错误码
    public static<T> BaseResponse<T> error(ErrorCode errorCode){
        return new BaseResponse<> (errorCode);
    }
    //错误编号+信息+描述
    public static<T> BaseResponse<T> error(int code,String message,String description){
        return new BaseResponse<> (code,null,message,description);
    }
    //错误码+描述
    public static<T> BaseResponse<T> error(ErrorCode errorCode,String description){
        return new BaseResponse<> (errorCode.getCode(),null,errorCode.getMessage(),description);
    }
    //错误码+描述+信息
    public static<T> BaseResponse<T> error(ErrorCode errorCode,String message,String description){
        return new BaseResponse<> (errorCode.getCode(),null,message);
    }
}
