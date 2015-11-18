package com.nan;

import redis.clients.jedis.Jedis;

import java.util.Map;

public class FeatureImpl {

    public static final String FEATURES_MAP_KEY = "features";
    public static final String FLAG_OFF = "off";
    public static final String FLAG_ON = "on";

    public String setFlag(String name, String flag) {
        flag = FLAG_OFF.equalsIgnoreCase(flag) ? FLAG_OFF : FLAG_ON;
        getJedis().hset(FEATURES_MAP_KEY, name, flag);
        return "Successfully switched " + flag + " feature " + name;
    }

    public String getFlag(String name) {
        String flag = getJedis().hget(FEATURES_MAP_KEY, name);
        String message;
        if (flag == null) {
            message = "Cannot find feature with name " + name;
        } else {
            message = "Feature " + name + " is " + flag;
        }

        return message;
    }

    public Map<String, String> list() {
        return getJedis().hgetAll(FEATURES_MAP_KEY);
    }

    private Jedis getJedis() {
        return new Jedis(PropertiesUtil.getRedisHost(), PropertiesUtil.getRedisPort());
    }
}
