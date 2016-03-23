package com.pigmassacre.postwork.systems;

import com.badlogic.ashley.core.Engine;
import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.Family;
import com.badlogic.ashley.utils.ImmutableArray;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.ai.msg.MessageManager;
import com.badlogic.gdx.ai.msg.Telegram;
import com.pigmassacre.postwork.components.*;
import com.pigmassacre.postwork.components.collision.CollisionComponent;
import com.pigmassacre.postwork.input.MessageTypes;
import com.pigmassacre.postwork.managers.EntityCreator;
import com.pigmassacre.postwork.managers.GameManager;
import com.pigmassacre.postwork.systems.supersystems.IteratingMessageHandlingSystem;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class ShootingSystem extends IteratingMessageHandlingSystem {

    private static final float CHARGE_PER_FRAME = 1f;
    private static final float CHARGE_REQUIRED_PER_SHOT = 30f;
    private final Family targetFamily;
    private boolean charging = false;
    private float chargeLevel = 0f;
    private ImmutableArray<Entity> targetedEntities;

    public ShootingSystem() {
        super(Family.all(PositionComponent.class, ShootingComponent.class).get());
        targetFamily = Family.all(PositionComponent.class, CollisionComponent.class).exclude(PlayerControllerComponent.class, PlayerOwnedComponent.class).get();
        MessageManager.getInstance().addListeners(this,
                MessageTypes.START_SHOOTING,
                MessageTypes.STOP_SHOOTING);
    }

    @Override
    public void update(float deltaTime) {
        super.update(deltaTime);
        if (charging) {
            chargeLevel += CHARGE_PER_FRAME;
        }
    }

    @Override
    public void addedToEngine(Engine engine) {
        super.addedToEngine(engine);
        targetedEntities = engine.getEntitiesFor(targetFamily);
    }

    @Override
    protected void processMessage(Telegram message, Entity entity, float deltaTime) {
        switch (message.message) {
            case MessageTypes.START_SHOOTING:
                charging = true;
                break;
            case MessageTypes.STOP_SHOOTING:
                charging = false;
                fire(entity);
                break;
        }
    }

    private void fire(Entity entity) {
        PositionComponent position = Mappers.position.get(entity);

        Gdx.app.log("", "ChargeLevel: " + chargeLevel);

        for (Entity targetedEntity : targetedEntities) {
            float missileCount = chargeLevel / CHARGE_REQUIRED_PER_SHOT;
            Gdx.app.log("", "Missilecount: " + missileCount);
            for (int i = 0; i < missileCount; i++) {
                Entity bullet = EntityCreator.createBullet(position.x, position.y, 1f, 1f, targetedEntity);
                HomingComponent homing = Mappers.homing.get(bullet);
                homing.speed = 9f;
                bullet.add(GameManager.getGame().engine.createComponent(PlayerOwnedComponent.class));
            }
        }

        chargeLevel = 0f;
    }

}
