package com.pigmassacre.postwork.utils;

import com.badlogic.gdx.ai.msg.Telegram;
import com.badlogic.gdx.utils.Pool;

/**
 * Created by pigmassacre on 2016-02-03.
 */
public class TelegramPool {

    public static final Pool<Telegram> pool = new Pool<Telegram>(16) {
        protected Telegram newObject () {
            return new Telegram();
        }
    };

    public static Telegram copyTelegram(Telegram msg) {
        Telegram telegram = pool.obtain();
        telegram.message = msg.message;
        telegram.extraInfo = msg.extraInfo;
        telegram.receiver = msg.receiver;
        telegram.sender = msg.sender;
        telegram.returnReceiptStatus = msg.returnReceiptStatus;
        return telegram;
    }

}
