package org.example.SpringBoot3.exception;

import lombok.extern.slf4j.Slf4j;
import org.example.SpringBoot3.common.BaseResponse;
import org.example.SpringBoot3.common.ErrorCode;
import org.example.SpringBoot3.common.ResultUtils;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * 全局异常处理器
 * @author luochen
 * @date 2025/4/20 10:56
 */
@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    @ExceptionHandler(value=BusinessException.class)
    public BaseResponse handlerBusinessException(BusinessException e) {
        log.error("businessException: "+e.getMessage(),e);
        return ResultUtils.error(e.getCode(), e.getMessage(), e.getDescription());
    }
    @ExceptionHandler(value=RuntimeException.class)
    public BaseResponse handlerRuntimeException(RuntimeException e) {
        log.error("runtimeException", e);
        return ResultUtils.error(ErrorCode.SYSTEM_ERROR, e.getMessage(), "");
    }

}
