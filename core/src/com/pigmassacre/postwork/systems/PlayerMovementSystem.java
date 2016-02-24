package com.pigmassacre.postwork.systems;

import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.Family;
import com.badlogic.ashley.systems.IteratingSystem;
import com.pigmassacre.postwork.components.AccelerationComponent;
import com.pigmassacre.postwork.components.PlayerControllerComponent;
import com.pigmassacre.postwork.components.VelocityComponent;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class PlayerMovementSystem extends IteratingSystem {

    private static final float SPEED = 0.02f;

    public PlayerMovementSystem() {
        super(Family.all(VelocityComponent.class, AccelerationComponent.class, PlayerControllerComponent.class).get());
    }

    @Override
    protected void processEntity(Entity entity, float deltaTime) {
        final VelocityComponent velocity = Mappers.velocity.get(entity);
        final AccelerationComponent acceleration = Mappers.acceleration.get(entity);
        final PlayerControllerComponent playerController = Mappers.playerController.get(entity);

        if (playerController.isMovingLeft) {
            acceleration.acceleration.x = -SPEED;
        } else if (playerController.isMovingRight) {
            acceleration.acceleration.x = SPEED;
        } else {
            acceleration.acceleration.x = 0f;
        }

        if (playerController.isMovingUp) {
            acceleration.acceleration.y = SPEED;
        } else if (playerController.isMovingDown) {
            acceleration.acceleration.y = -SPEED;
        } else {
            acceleration.acceleration.y = 0f;
        }
    }

}
