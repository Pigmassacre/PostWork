package com.pigmassacre.postwork.systems.supersystems;

import com.badlogic.ashley.core.Entity;
import com.badlogic.gdx.ai.msg.MessageManager;
import com.badlogic.gdx.ai.msg.Telegram;
import com.pigmassacre.postwork.input.MessageTypes;
import com.pigmassacre.postwork.systems.collision.EntityCollisionSystem;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class HandleCollisionSystem extends MessageHandlingSystem {

    public HandleCollisionSystem() {
        MessageManager.getInstance().addListeners(this,
                MessageTypes.COLLISION,
                MessageTypes.LEVEL_COLLISION,
                MessageTypes.LEVEL_COLLISION_X,
                MessageTypes.LEVEL_COLLISION_Y);
    }

    @Override
    protected void processMessage(Telegram message, float deltaTime) {
        handle(message, message.extraInfo);
    }

    private void handle(Telegram message, Object data) {
        switch (message.message) {
            case MessageTypes.COLLISION:
                handleCollision(message.message, (EntityCollisionSystem.CollisionData) data);
                break;
            case MessageTypes.LEVEL_COLLISION:
                handleLevelCollision(message.message, (Entity) data);
                break;
        }

    }

    protected void handleCollision(int message, EntityCollisionSystem.CollisionData data) {

    }

    protected void handleLevelCollision(int message, Entity entity) {

    }

}
