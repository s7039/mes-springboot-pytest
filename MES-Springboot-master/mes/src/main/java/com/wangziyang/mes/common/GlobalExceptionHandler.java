package com.wangziyang.mes.common;

import org.apache.shiro.authz.AuthorizationException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * 全局异常处理器
 *
 * @author SongPeng
 */
@ControllerAdvice
public class GlobalExceptionHandler {

    Logger logger = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    /**
     * Shiro权限不足异常处理
     */
    @ExceptionHandler(AuthorizationException.class)
    @ResponseBody
    public Result handleAuthorizationException(AuthorizationException e,
                                                HttpServletRequest request,
                                                HttpServletResponse response) {
        logger.warn("权限不足: {}", e.getMessage());
        return Result.failure("您没有此操作的权限");
    }
}
