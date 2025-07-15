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
    public BusinessException(int code, String message, String description) {
        super(message);
        this.code = code;
        this.description = description;
    }
    public BusinessException(ErrorCode errorCode) {
        super(errorCode.getMessage());
        this.code = errorCode.getCode();
        this.description = errorCode.getDescription();
    }
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
