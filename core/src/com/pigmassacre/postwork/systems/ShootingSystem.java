package com.pigmassacre.postwork.systems;

import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.Family;
import com.badlogic.gdx.ai.msg.MessageManager;
import com.badlogic.gdx.ai.msg.Telegram;
import com.badlogic.gdx.math.MathUtils;
import com.pigmassacre.postwork.components.PlayerOwnedComponent;
import com.pigmassacre.postwork.components.PositionComponent;
import com.pigmassacre.postwork.components.ShootingComponent;
import com.pigmassacre.postwork.components.VelocityComponent;
import com.pigmassacre.postwork.input.MessageTypes;
import com.pigmassacre.postwork.managers.EntityCreator;
import com.pigmassacre.postwork.managers.GameManager;
import com.pigmassacre.postwork.systems.supersystems.IteratingMessageHandlingSystem;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class ShootingSystem extends IteratingMessageHandlingSystem {

    private static final float TIME_PER_SHOT = 1f / 16f;

    public ShootingSystem() {
        super(Family.all(PositionComponent.class, ShootingComponent.class).get());
        MessageManager.getInstance().addListeners(this,
                MessageTypes.START_SHOOTING,
                MessageTypes.STOP_SHOOTING);
    }

    @Override
    protected void processEntity(Entity entity, float deltaTime) {
        super.processEntity(entity, deltaTime);

        final ShootingComponent shooting = Mappers.shooting.get(entity);

        if (shooting.shooting) {
            shooting.timeSinceLastShot += deltaTime;

            if (shooting.timeSinceLastShot > TIME_PER_SHOT) {
                fire(entity);
                shooting.timeSinceLastShot = 0f;
            }
        }
    }

    @Override
    protected void processMessage(Telegram message, Entity entity, float deltaTime) {
        final VelocityComponent velocity = Mappers.velocity.get(entity);
        final ShootingComponent shooting = Mappers.shooting.get(entity);

        switch (message.message) {
            case MessageTypes.START_SHOOTING:
                shooting.shooting = true;
                velocity.max = 0.5f;
                break;
            case MessageTypes.STOP_SHOOTING:
                shooting.shooting = false;
                velocity.max = -1f;
                break;
        }
    }

    private void fire(Entity entity) {
        PositionComponent position = Mappers.position.get(entity);

        Entity bullet = EntityCreator.createBullet(position.x, position.y, 1f, 1f);
        Mappers.angle.get(bullet).angle = Mappers.angle.get(entity).angle - MathUtils.PI;
        Mappers.propel.get(bullet).speed = 8f;
        bullet.add(GameManager.getGame().engine.createComponent(PlayerOwnedComponent.class));
    }

}
