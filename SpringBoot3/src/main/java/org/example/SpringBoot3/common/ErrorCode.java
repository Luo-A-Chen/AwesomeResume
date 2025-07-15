package org.example.SpringBoot3.common;

/**
 * 错误码
 *
 * @author luochen
 */
public enum ErrorCode {
    SUCCESS(0, "ok", ""),
    PARAMS_ERROR(40000, "请求参数错误", ""),
    NULL_ERROR(40001, "请求数据为空", ""),
    NOT_LOGIN_ERROR(40100, "未登录", ""),
    NO_AUTH_ERROR(40101, "无权限", ""),
    SYSTEM_ERROR(50000, "系统内部异常", ""),
    ;
    private final int code;
    /**
     * 错误信息
     */
    private final String message;
    /**
     * 错误码的描述
     */
    private final String description;

    ErrorCode(int code, String message, String description) {
        this.code = code;
        this.message = message;
        this.description = description;
    }
    public int getCode() {
        return code;
    }
    public String getMessage() {
        return message;
    }
    public String getDescription() {
        return description;
    }
}
