package org.example.SpringBoot3.utils;

import com.alibaba.excel.EasyExcel;
import com.baomidou.mybatisplus.core.toolkit.StringUtils;
import org.example.SpringBoot3.model.ExcelUser;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;


public class ImportExcel {
    public static void main(String[] args) {
        //C:\Users\luochen\Desktop\个人项目\琛多多伙伴匹配
        String fileName = "C:\\Users\\luochen\\Desktop\\个人项目\\琛多多伙伴匹配\\testExcel.xlsx";
        synchronousRead(fileName);
    }

    /**
     * 监听器读取
     *
     * @param fileName
     */
    public static void readByListener(String fileName) {
        // 这里 需要指定读用哪个class去读，然后读取第一个sheet 文件流会自动关闭
        // 这里每次会读取100条数据 然后返回过来 直接调用使用数据就行
        EasyExcel.read(fileName, ExcelUser.class, new ExcelListener()).sheet().doRead();
    }

    /**
     * 同步读
     * 同步的返回，不推荐使用，如果数据量大会把数据放到内存里面
     */
    public static void synchronousRead(String fileName) {
        // 这里 需要指定读用哪个class去读，然后读取第一个sheet 同步读取会自动finish
        List<ExcelUser> list = EasyExcel.read(fileName).head(ExcelUser.class).sheet().doReadSync();
        for (ExcelUser ExcelUser : list) {
            System.out.println(ExcelUser);
        }

    }
//    // 这里 需要指定读用哪个class去读，然后读取第一个sheet 同步读取会自动finish
//    String fileName = "C:\\Users\\25073\\Desktop\\testExcel.xlsx";
//    List<ExcelUser> userInfoList =
//            EasyExcel.read(fileName).head(ExcelUser.class).sheet().doReadSync();
//    System.out.println("总数 = " + userInfoList.size());
//    Map<String, List<ExcelUser>> listMap =
//            userInfoList.stream()
//                    .filter(userInfo -> StringUtils.isNotEmpty(userInfo.getUsername()))
//                    .collect(Collectors.groupingBy(ExcelUser::getUsername));
//        for (
//    Map.Entry<String, List<ExcelUser>> stringListEntry : listMap.entrySet()) {
//        if (stringListEntry.getValue().size() > 1) {
//            System.out.println("username = " + stringListEntry.getKey());
//            System.out.println("1");
//        }
//    }
//        System.out.println("不重复昵称数 = " + listMap.keySet().size());
}

