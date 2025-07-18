package org.example.SpringBoot3.exception;

import org.example.SpringBoot3.common.ErrorCode;

/**
 * @author luochen
 * @date 2025/4/20 10:10
 * 捕捉程序运行时异常
 */

public class BusinessException extends RuntimeException{
    private int code;
    private String description;
    //传入自定义错误码，错误信息，错误描述
    public BusinessException(int code, String message, String description) {
        super(message);
        this.code = code;
        this.description = description;
    }
    //传入自定义通用的错误码
    public BusinessException(ErrorCode errorCode) {
        super(errorCode.getMessage());
        this.code = errorCode.getCode();
        this.description = errorCode.getDescription();
    }
    //传入自定义通用的错误码，加上更多的描述
    public BusinessException(ErrorCode errorCode, String description) {
        super(errorCode.getMessage());
        this.code = errorCode.getCode();
        this.description = description;
    }
    public int getCode() {
        return code;
    }
    public String getDescription() {
        return description;
    }
}
