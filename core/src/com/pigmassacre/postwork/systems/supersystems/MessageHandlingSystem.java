package com.pigmassacre.postwork.systems.supersystems;

import com.badlogic.ashley.core.EntitySystem;
import com.badlogic.gdx.ai.msg.Telegram;
import com.badlogic.gdx.ai.msg.Telegraph;
import com.badlogic.gdx.utils.Queue;
import com.pigmassacre.postwork.utils.TelegramPool;

import java.util.Iterator;

/**
 * Created by pigmassacre on 2016-02-03.
 */
public abstract class MessageHandlingSystem extends EntitySystem implements Telegraph {

    private Queue<Telegram> messagesToHandle;

    public MessageHandlingSystem() {
        messagesToHandle = new Queue<Telegram>();
    }

    @Override
    public void update(float deltaTime) {
        Iterator<Telegram> iterator = messagesToHandle.iterator();
        while (iterator.hasNext()) {
            Telegram next = iterator.next();
            processMessage(next, deltaTime);
            TelegramPool.pool.free(next);
        }
        messagesToHandle.clear();
    }

    protected abstract void processMessage(Telegram message, float deltaTime);

    @Override
    public boolean handleMessage(Telegram msg) {
        messagesToHandle.addLast(TelegramPool.copyTelegram(msg));
        return true;
    }

}
