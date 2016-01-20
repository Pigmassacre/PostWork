package com.pigmassacre.postwork.systems.subsystems;

import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.Family;
import com.badlogic.ashley.systems.IteratingSystem;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.ai.msg.MessageManager;
import com.badlogic.gdx.ai.msg.Telegram;
import com.badlogic.gdx.ai.msg.Telegraph;
import com.badlogic.gdx.utils.Array;
import com.badlogic.gdx.utils.Queue;
import com.pigmassacre.postwork.components.PlayerControlledComponent;
import com.pigmassacre.postwork.components.PositionComponent;
import com.pigmassacre.postwork.input.MessageTypes;
import com.pigmassacre.postwork.utils.Mappers;

import java.util.Iterator;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class MovementSystem extends IteratingSystem implements Telegraph, Subsystem {

    private Queue<Integer> messagesToHandle;
    private int currentMessage = -1;

    public MovementSystem() {
        super(Family.all(PositionComponent.class, PlayerControlledComponent.class).get());
        messagesToHandle = new Queue<Integer>();
        MessageManager.getInstance().addListeners(this,
                MessageTypes.MOVE_LEFT,
                MessageTypes.MOVE_RIGHT,
                MessageTypes.MOVE_UP,
                MessageTypes.MOVE_DOWN);

        /* All subsystems should set this to false as their processing is handle by the TurnHandlerSystem */
        setProcessing(false);
    }

    @Override
    public void update(float deltaTime) {
        Iterator<Integer> iterator = messagesToHandle.iterator();
        while (iterator.hasNext()) {
            currentMessage = iterator.next();
            super.update(deltaTime);
        }
        messagesToHandle.clear();
        currentMessage = -1;
    }

    @Override
    protected void processEntity(Entity entity, float deltaTime) {
        final PositionComponent position = Mappers.position.get(entity);
        switch (currentMessage) {
            case MessageTypes.MOVE_LEFT:
                Gdx.app.log("Movement", "Handling left");
                position.x -= 1;
                break;
            case MessageTypes.MOVE_RIGHT:
                Gdx.app.log("Movement", "Handling right");
                position.x += 1;
                break;
            case MessageTypes.MOVE_UP:
                Gdx.app.log("Movement", "Handling up");
                position.y += 1;
                break;
            case MessageTypes.MOVE_DOWN:
                Gdx.app.log("Movement", "Handling down");
                position.y -= 1;
                break;
        }
    }

    @Override
    public boolean handleMessage(Telegram msg) {
        messagesToHandle.addLast(msg.message);
        return true;
    }
}
