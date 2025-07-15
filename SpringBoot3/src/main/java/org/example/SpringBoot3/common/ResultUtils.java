package org.example.SpringBoot3.common;

/**
 * @author: luochen
 * @date 2023/4/9
 * @description:帮助生成响应对象
 */
public class ResultUtils {
    //成功
    public static<T> BaseResponse<T> success(T data){
        return new BaseResponse<> (0,data,"成功");
    }
    //失败
    public static<T> BaseResponse<T> error(ErrorCode errorCode){
        return new BaseResponse<> (errorCode);
    }
    //失败
    public static<T> BaseResponse<T> error(int code,String message,String description){
        return new BaseResponse<> (code,null,message,description);
    }
    //失败
    public static<T> BaseResponse<T> error(ErrorCode errorCode,String description){
        return new BaseResponse<> (errorCode.getCode(),null,errorCode.getMessage(),description);
    }
    public static<T> BaseResponse<T> error(ErrorCode errorCode,String message,String description){
        return new BaseResponse<> (errorCode.getCode(),null,message);
    }
}
