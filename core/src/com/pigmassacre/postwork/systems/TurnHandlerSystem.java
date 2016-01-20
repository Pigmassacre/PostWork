package com.pigmassacre.postwork.systems;

import com.badlogic.ashley.core.EntitySystem;
import com.badlogic.gdx.ai.msg.MessageManager;
import com.badlogic.gdx.ai.msg.Telegram;
import com.badlogic.gdx.ai.msg.Telegraph;
import com.pigmassacre.postwork.input.MessageTypes;
import com.pigmassacre.postwork.systems.subsystems.Subsystem;

import java.util.Stack;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class TurnHandlerSystem extends EntitySystem implements Telegraph {

    private Stack<Integer> messagesToHandle;

    public TurnHandlerSystem() {
        messagesToHandle = new Stack<Integer>();
        MessageManager.getInstance().addListener(this,
                MessageTypes.NEXT_TURN);
    }

    @Override
    public boolean handleMessage(Telegram msg) {
        messagesToHandle.push(msg.message);
        return true;
    }

    @Override
    public void update(float deltaTime) {
        while (!messagesToHandle.empty()) {
            messagesToHandle.pop();
            for (EntitySystem entitySystem : getEngine().getSystems()) {
                if (entitySystem instanceof Subsystem) {
                    entitySystem.update(deltaTime);
                }
            }
        }
    }
}
