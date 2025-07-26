package org.example.SpringBoot3.utils;

import com.alibaba.excel.context.AnalysisContext;
import com.alibaba.excel.read.listener.ReadListener;
import lombok.extern.slf4j.Slf4j;
import org.example.SpringBoot3.model.ExcelUser;
//excel表中的所有数据都会被映射到ExcelUser对象中
@Slf4j
public class ExcelListener implements ReadListener<ExcelUser> {
    @Override
    public void invoke(ExcelUser excelUser, AnalysisContext analysisContext) {
        //解析完每一行都会回调这个方法
        System.out.println(excelUser);
    }
    @Override
    public void doAfterAllAnalysed(AnalysisContext analysisContext) {
        //解析完成后使用的方法
        System.out.println("解析完成");

    }
}
