package com.pigmassacre.postwork.systems.supersystems;

import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.Family;
import com.badlogic.ashley.systems.IteratingSystem;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.ai.msg.MessageManager;
import com.badlogic.gdx.ai.msg.Telegram;
import com.badlogic.gdx.ai.msg.TelegramProvider;
import com.badlogic.gdx.ai.msg.Telegraph;
import com.badlogic.gdx.utils.Queue;
import com.pigmassacre.postwork.utils.TelegramPool;

import java.util.Iterator;

/**
 * Created by pigmassacre on 2016-02-03.
 */
public abstract class IteratingMessageHandlingSystem extends IteratingSystem implements Telegraph {

    private Queue<Telegram> messagesToHandle;

    public IteratingMessageHandlingSystem(Family family) {
        super(family);
        messagesToHandle = new Queue<>();
    }

    @Override
    public void update(float deltaTime) {
        super.update(deltaTime);
        Iterator<Telegram> iterator = messagesToHandle.iterator();
        while (iterator.hasNext()) {
            TelegramPool.pool.free(iterator.next());
        }
        messagesToHandle.clear();
    }

    @Override
    protected void processEntity(Entity entity, float deltaTime) {
        Iterator<Telegram> iterator = messagesToHandle.iterator();
        while (iterator.hasNext()) {
            Telegram next = iterator.next();
            processMessage(next, entity, deltaTime);
        }
    }

    protected abstract void processMessage(Telegram message, Entity entity, float deltaTime);

    @Override
    public boolean handleMessage(Telegram msg) {
        messagesToHandle.addLast(TelegramPool.copyTelegram(msg));
        return true;
    }

}
