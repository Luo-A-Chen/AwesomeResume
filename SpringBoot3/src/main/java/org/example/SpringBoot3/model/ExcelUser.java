package org.example.SpringBoot3.model;

import com.alibaba.excel.annotation.ExcelProperty;
import lombok.Data;

@Data
public class ExcelUser {
    @ExcelProperty("成员昵称")
    private String username;

}
