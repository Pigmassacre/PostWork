package com.pigmassacre.postwork.systems;

import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.Family;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.ai.msg.MessageManager;
import com.badlogic.gdx.ai.msg.Telegram;
import com.pigmassacre.postwork.components.PlayerControlledComponent;
import com.pigmassacre.postwork.components.PositionComponent;
import com.pigmassacre.postwork.input.MessageTypes;
import com.pigmassacre.postwork.systems.supersystems.IteratingMessageHandlingSystem;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class MovementSystem extends IteratingMessageHandlingSystem {

    public MovementSystem() {
        super(Family.all(PositionComponent.class, PlayerControlledComponent.class).get());
        MessageManager.getInstance().addListeners(this,
                MessageTypes.MOVE_LEFT,
                MessageTypes.MOVE_RIGHT,
                MessageTypes.MOVE_UP,
                MessageTypes.MOVE_DOWN);
    }

    @Override
    protected void processMessage(Telegram message, Entity entity, float deltaTime) {
        final PositionComponent position = Mappers.position.get(entity);
        Gdx.app.log("Movement", String.valueOf(message.message));
        switch (message.message) {
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

}
