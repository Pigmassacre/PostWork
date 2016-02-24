package com.pigmassacre.postwork.systems;

import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.Family;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.ai.msg.MessageManager;
import com.badlogic.gdx.ai.msg.Telegram;
import com.pigmassacre.postwork.components.PlayerControllerComponent;
import com.pigmassacre.postwork.input.MessageTypes;
import com.pigmassacre.postwork.systems.supersystems.IteratingMessageHandlingSystem;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class PlayerControllerSystem extends IteratingMessageHandlingSystem {

    public PlayerControllerSystem() {
        super(Family.all(PlayerControllerComponent.class).get());
        MessageManager.getInstance().addListeners(this,
                MessageTypes.MOVE_LEFT,
                MessageTypes.MOVE_RIGHT,
                MessageTypes.MOVE_UP,
                MessageTypes.MOVE_DOWN,
                MessageTypes.STOP_MOVE_LEFT,
                MessageTypes.STOP_MOVE_RIGHT,
                MessageTypes.STOP_MOVE_UP,
                MessageTypes.STOP_MOVE_DOWN);
    }

    @Override
    protected void processMessage(Telegram message, Entity entity, float deltaTime) {
        final PlayerControllerComponent playerController = Mappers.playerController.get(entity);

        Gdx.app.log("Movement", String.valueOf(message.message));
        switch (message.message) {
            case MessageTypes.MOVE_LEFT:
                Gdx.app.log("Movement", "Starting left");
                playerController.isMovingLeft = true;
                break;
            case MessageTypes.MOVE_RIGHT:
                Gdx.app.log("Movement", "Starting right");
                playerController.isMovingRight = true;
                break;
            case MessageTypes.MOVE_UP:
                Gdx.app.log("Movement", "Starting up");
                playerController.isMovingUp = true;
                break;
            case MessageTypes.MOVE_DOWN:
                Gdx.app.log("Movement", "Starting down");
                playerController.isMovingDown = true;
                break;
            case MessageTypes.STOP_MOVE_LEFT:
                Gdx.app.log("Movement", "Stopping left");
                playerController.isMovingLeft = false;
                break;
            case MessageTypes.STOP_MOVE_RIGHT:
                Gdx.app.log("Movement", "Stopping right");
                playerController.isMovingRight = false;
                break;
            case MessageTypes.STOP_MOVE_UP:
                Gdx.app.log("Movement", "Stopping up");
                playerController.isMovingUp = false;
                break;
            case MessageTypes.STOP_MOVE_DOWN:
                Gdx.app.log("Movement", "Stopping down");
                playerController.isMovingDown = false;
                break;
        }
    }

}
