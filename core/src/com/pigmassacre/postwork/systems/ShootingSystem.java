package com.pigmassacre.postwork.systems;

import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.Family;
import com.badlogic.ashley.utils.ImmutableArray;
import com.badlogic.gdx.ai.msg.MessageManager;
import com.badlogic.gdx.ai.msg.Telegram;
import com.pigmassacre.postwork.components.*;
import com.pigmassacre.postwork.input.MessageTypes;
import com.pigmassacre.postwork.managers.EntityCreator;
import com.pigmassacre.postwork.managers.GameManager;
import com.pigmassacre.postwork.systems.supersystems.IteratingMessageHandlingSystem;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class ShootingSystem extends IteratingMessageHandlingSystem {

    private static final float COOLDOWN_TIME_BETWEEN_SHOTS = 1f / 8f;

    private Family targetFamily;

    public ShootingSystem() {
        super(Family.all(PositionComponent.class, ShootingComponent.class).get());
        targetFamily = Family.all(PositionComponent.class, TargetableComponent.class).get();
        MessageManager.getInstance().addListeners(this,
                MessageTypes.PAUSE_SHOOTING,
                MessageTypes.UNPAUSE_SHOOTING);
    }

    @Override
    protected void processEntity(Entity entity, float deltaTime) {
        super.processEntity(entity, deltaTime);

        final ShootingComponent shooting = Mappers.shooting.get(entity);

        if (shooting.shooting) {
            shooting.timeSinceLastShot += deltaTime;

            if (shooting.timeSinceLastShot > COOLDOWN_TIME_BETWEEN_SHOTS) {
                ImmutableArray<Entity> targetableEntities = getEngine().getEntitiesFor(targetFamily);
                for (Entity targetableEntity : targetableEntities) {
                    fire(entity, targetableEntity);
                }
                shooting.timeSinceLastShot = 0f;
            }
        }
    }

    @Override
    protected void processMessage(Telegram message, Entity entity, float deltaTime) {
        final ShootingComponent shooting = Mappers.shooting.get(entity);

        switch (message.message) {
            case MessageTypes.PAUSE_SHOOTING:
                shooting.shooting = false;
                break;
            case MessageTypes.UNPAUSE_SHOOTING:
                shooting.shooting = true;
                break;
        }
    }

    private void fire(Entity shootingEntity, Entity targetEntity) {
        PositionComponent position = Mappers.position.get(shootingEntity);
        VisualComponent visual = Mappers.visual.get(shootingEntity);

        float width = 3f;
        float height = 3f;
        Entity bullet = EntityCreator.createHomingBullet(position.x + visual.width / 2f - width / 2f, position.y + visual.height / 2f - height / 2f, width, height, shootingEntity, targetEntity);
        Mappers.propel.get(bullet).speed = 14f;
        bullet.add(GameManager.getGame().engine.createComponent(PlayerOwnedComponent.class));
    }

}
