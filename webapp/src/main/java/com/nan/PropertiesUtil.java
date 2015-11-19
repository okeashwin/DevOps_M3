package com.nan;

import java.util.Properties;

public class PropertiesUtil {

    private static String redisHost;
    private static int redisPort;

    static {
        Properties prop = new Properties();
        try {
            prop.load(Thread.currentThread().getContextClassLoader().getResourceAsStream("redis.properties"));
            redisHost = prop.getProperty("redis_host");
            redisPort = Integer.parseInt(prop.getProperty("redis_port"));
        }
        catch (Throwable t) {
            throw new RuntimeException("Failed to read from build.properties file", t);
        }
    }

    public static String getRedisHost() {
        return redisHost;
    }

    public static int getRedisPort() {
        return redisPort;
    }
}
