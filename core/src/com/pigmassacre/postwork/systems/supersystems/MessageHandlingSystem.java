package com.pigmassacre.postwork.systems.supersystems;

import com.badlogic.ashley.core.EntitySystem;
import com.badlogic.gdx.ai.msg.Telegram;
import com.badlogic.gdx.ai.msg.Telegraph;
import com.pigmassacre.postwork.utils.TelegramPool;

import java.util.Comparator;
import java.util.PriorityQueue;

/**
 * Created by pigmassacre on 2016-02-03.
 */
public abstract class MessageHandlingSystem extends EntitySystem implements Telegraph {

    private static final int INITIAL_CAPACITY = 128;
    private PriorityQueue<Telegram> messagesToHandle;

    public MessageHandlingSystem() {
        messagesToHandle = new PriorityQueue<>();
    }

    public MessageHandlingSystem(Comparator<Telegram> queueComparator) {
        messagesToHandle = new PriorityQueue<>(INITIAL_CAPACITY, queueComparator);
    }

    @Override
    public void update(float deltaTime) {
        while (messagesToHandle.peek() != null) {
            final Telegram next = messagesToHandle.poll();
            processMessage(next, deltaTime);
            TelegramPool.pool.free(next);
        }
    }

    protected abstract void processMessage(Telegram message, float deltaTime);

    @Override
    public boolean handleMessage(Telegram msg) {
        messagesToHandle.add(TelegramPool.copyTelegram(msg));
        return true;
    }

}
