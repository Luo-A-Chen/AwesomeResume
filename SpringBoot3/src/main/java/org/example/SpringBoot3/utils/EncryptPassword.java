package org.example.SpringBoot3.utils;

import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.util.Base64;
import javax.crypto.Cipher;

/**
 * @author luochen
 * @description: bilibili密码加密
 */
public class EncryptPassword {
    /**
     * @param publicKey 公钥
     * @param password 密码
     * @return
     * @throws Exception
     */
    public static String encryptPassword(Key publicKey, String password) throws Exception {
        //static多用于工具类中直接调用，直接通过类名调用，不需要实例化
        byte[] salt = "16个字符的盐值".getBytes();//将16个字符的盐值转为字节数组
        byte[] message = new byte[salt.length + password.getBytes(StandardCharsets.UTF_8).length];//创建字节数组，长度为盐值和密码的长度之和
        System.arraycopy(salt, 0, message, 0, salt.length);
        System.arraycopy(password.getBytes(StandardCharsets.UTF_8), 0, message, salt.length, password.getBytes(StandardCharsets.UTF_8).length);//将盐值和密码复制到字节数组中

        Cipher cipher = Cipher.getInstance("RSA");//创建密码器,并指定RSA算法
        cipher.init(Cipher.ENCRYPT_MODE, publicKey);//将cipher初始化加密模式，并传入公钥
        byte[] encryptedMessage = cipher.doFinal(message);//对message执行加密操作

        return Base64.getEncoder().encodeToString(encryptedMessage);//将加密后的字节数组转为Base64字符串并返回
    }
}
